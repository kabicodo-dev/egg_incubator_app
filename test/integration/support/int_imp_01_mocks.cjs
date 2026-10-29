'use strict';

// TEST DOUBLES ONLY. No sockets, HTTP clients, serial libraries, Supabase client,
// production imports or executable hardware outbox. Logical calls below are NOT
// new JSON wire messages or an implementation of Mary's API/controller firmware.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');

const root = path.resolve(__dirname, '../../..');
const fixtureDir = path.join(root, 'test/fixtures/integration');
const copy = structuredClone;
const sha256 = text => crypto.createHash('sha256').update(text).digest('hex');
function assertPinnedText(bytes, source) {
  const raw=sha256(bytes);
  const lf=sha256(bytes.toString('utf8').replace(/\r\n/g,'\n'));
  assert.ok(raw===source.sha256 || lf===source.lf_sha256,
    'Source snapshot changed: revise fixture-kit provenance, do not silently adapt');
}
function ordered(value) {
  if (Array.isArray(value)) return value.map(ordered);
  if (value !== null && typeof value === 'object') {
    return Object.fromEntries(Object.keys(value).sort().map(key => [key, ordered(value[key])]));
  }
  return value;
}
// Deliberately a mock semantic comparison, NOT a production JCS/source adapter.
function mockCore(request) {
  const value = copy(request);
  for (const key of ['installation_id', 'phone_received_at', 'operation']) delete value[key];
  return JSON.stringify(ordered(value));
}
function loadKit() {
  const manifest = JSON.parse(fs.readFileSync(path.join(fixtureDir, 'int_imp_01_sources.json'), 'utf8'));
  const source = manifest.db02_reference;
  const bytes = fs.readFileSync(path.join(root, source.path));
  assertPinnedText(bytes,source);
  const md = bytes.toString('utf8');
  const fence = '`'.repeat(3);
  function block(name) {
    const marker = '<!-- DB02:' + name + ' -->';
    assert.equal(md.split(marker).length, 2, 'exactly one source block ' + name);
    return JSON.parse(md.split(marker)[1].split(fence + 'json')[1].split(fence)[0]);
  }
  const wires = manifest.wire_references.map(ref => {
    const bytes = fs.readFileSync(path.join(fixtureDir, ref.fixture_file));
    // Preserve original bytes for uint64 literals and integral float spellings.
    const lines = bytes.toString('utf8').trimEnd().split(/\r?\n/);
    return {...ref, lines};
  });
  return {manifest, wires, requests:block(source.request_block), responses:block(source.response_block)};
}

class ReviewOnlyGate {
  constructor(manifest) { this.manifest = manifest; }
  requireActiveCatalog() {
    if (!this.manifest.active_implementation.catalog_revision || !this.manifest.active_implementation.firmware_commit) {
      throw new Error('ACTIVE_SOURCE_MISSING: review fixtures cannot enable a real transport');
    }
  }
  openRealTransport() { throw new Error('REAL_TRANSPORT_DISABLED: test kit has no hardware/network implementation'); }
}

// Generic host LF-only framer with test-injected byte limit, not an approved Uno
// limit or replacement Flutter decoder. It returns original ASCII lines only.
class MockLineFramer {
  constructor(maxContentBytes) {
    assert.ok(Number.isSafeInteger(maxContentBytes) && maxContentBytes > 0);
    this.max = maxContentBytes; this.pending = []; this.discard = false; this.errors = [];
  }
  push(chunk) {
    const lines = [];
    for (const byte of chunk) {
      if (byte === 10) {
        if (!this.discard && this.pending.length) lines.push(Buffer.from(this.pending).toString('ascii'));
        this.pending = []; this.discard = false; continue;
      }
      if (this.discard) continue;
      if (byte < 32 || byte > 126 || this.pending.length >= this.max) {
        this.errors.push(this.pending.length >= this.max ? 'overflow' : 'invalid-byte');
        this.pending = []; this.discard = true; continue;
      }
      this.pending.push(byte);
    }
    return lines;
  }
  reset() { this.pending = []; this.discard = false; }
}

class MockBluetoothLink {
  constructor() { this.connected = false; this.logicalWrites = []; this.realWrites = 0; }
  connect() { this.connected = true; }
  disconnect() { this.connected = false; }
  dispatch(action, body) {
    if (!this.connected) throw new Error('LINK_DISCONNECTED');
    this.logicalWrites.push({action, commandId:body.command_id, batchId:body.batch_id});
  }
}

// Host JSON checkpoint models reopen/failure boundaries only. It does not claim
// SQLite, fsync/power-loss safety, uninstall recovery, multiprocess atomicity or
// real-controller persistence. Each test supplies its own temporary directory.
class FileBackedMockLedger {
  constructor(file) {
    this.file = file;
    this.state = fs.existsSync(file)
      ? JSON.parse(fs.readFileSync(file, 'utf8'))
      : {intents:{}, events:{}, outbox:{}, receipts:{}};
    this.failNextCommit = false;
  }
  commit(change) {
    const next = copy(this.state); change(next);
    if (this.failNextCommit) { this.failNextCommit = false; throw new Error('MOCK_LOCAL_COMMIT_FAILED'); }
    const staging = this.file + '.staging';
    fs.writeFileSync(staging, JSON.stringify(next), 'utf8');
    fs.renameSync(staging, this.file);
    this.state = next;
  }
  intent(record) {
    this.commit(state => {
      const key = record.command_id;
      const old = state.intents[key];
      if (old && mockCore(old.record) !== mockCore(record)) throw new Error('COMMAND_CONTENT_CONFLICT');
      if (!old) state.intents[key] = {record:copy(record), dispatchMayOccur:false};
    });
  }
  dispatchMarker(id) { this.commit(state => { assert.ok(state.intents[id]); state.intents[id].dispatchMayOccur = true; }); }
  event(record) {
    this.commit(state => {
      const old = state.events[record.event_id];
      if (old && mockCore(old) !== mockCore(record)) throw new Error('EVENT_CONTENT_CONFLICT');
      if (!old) {
        state.events[record.event_id] = copy(record);
        state.outbox[record.event_id] = {record:copy(record), state:'pending'};
      }
    });
  }
  receipt(record, receipt) {
    this.commit(state => {
      const old = state.receipts[record.event_id];
      if (old) {
        assert.equal(receipt.receipt_id, old.receipt_id);
        assert.equal(receipt.received_at, old.received_at);
        if (receipt.receipt_revision < old.receipt_revision) return;
        if (receipt.receipt_revision === old.receipt_revision) assert.deepEqual(receipt,old);
        if (old.session_id !== null) assert.equal(receipt.session_id, old.session_id);
      }
      state.receipts[record.event_id] = copy(receipt);
      state.outbox[record.event_id].state = receipt.disposition;
    });
  }
}

// Logical controller model consumes preexisting synthetic DB-02 records. It
// never serializes a proposed START/STOP or represents physical actuator proof.
class FakeController {
  constructor(memory = {deviceId:'11111111-1111-4111-8111-111111111111',state:'IDLE',batch:null,commands:{},events:{},effects:0}) { this.memory = memory; }
  command(action, record) {
    if (record.device_id!==this.memory.deviceId) throw new Error('WRONG_CONTROLLER');
    const old = this.memory.commands[record.command_id];
    if (old) {
      if (old.core !== mockCore(record)) throw new Error('COMMAND_CONTENT_CONFLICT');
      return copy(old.result);
    }
    if (action === 'start' && this.memory.state === 'RUNNING') throw new Error('BUSY');
    if (action === 'stop' && this.memory.batch !== record.batch_id) throw new Error('WRONG_BATCH');
    if (action === 'start') { this.memory.batch=record.batch_id; this.memory.state='RUNNING'; }
    else if (action === 'stop') this.memory.state='STOPPED';
    else throw new Error('UNKNOWN_LOGICAL_ACTION');
    this.memory.effects++;
    const result = {acknowledged:true, record:copy(record)};
    this.memory.events[record.event_id]=copy(record);
    this.memory.commands[record.command_id]={core:mockCore(record),result:copy(result)};
    return result;
  }
  status(queryId) {
    assert.ok(queryId);
    return {queryId, deviceId:this.memory.deviceId,controllerReport:this.memory.state,batch:this.memory.batch,retained:Object.values(copy(this.memory.events))};
  }
}

// Canned server double: known DB-02 review examples only, no endpoint, database,
// JWT verification, RLS, production canonicalization or concurrency guarantee.
class FakeCloud {
  constructor(kit) {
    this.kit=kit; this.online=true; this.authorized=true; this.dropNextReply=false;
    this.entries=new Map(); this.sessions=new Map(); this.activeBatch=null;
  }
  submit(record) {
    if (!this.online) throw new Error('MOCK_OFFLINE');
    if (!this.authorized) throw new Error('MOCK_NOT_AUTHORIZED');
    const old=this.entries.get(record.event_id);
    if (old) {
      if (old.core!==mockCore(record)) throw new Error('IDENTITY_CONTENT_CONFLICT');
      return this.reply(old.receipt);
    }
    const name={started:'started',stopped:'stopped',farmer_completed:'completion'}[record.event_kind];
    assert.ok(name,'double supports only recorded lifecycle fixtures');
    assert.equal(mockCore(record),mockCore(this.kit.requests[name]),'unknown source fixture is not silently accepted');
    const receipt=copy(this.kit.responses[name]);
    if (record.event_kind==='started') {
      if (this.activeBatch && this.activeBatch!==record.batch_id) Object.assign(receipt,{disposition:'conflict',code:'ACTIVE_SESSION_CONFLICT',session_id:null});
      else { this.activeBatch=record.batch_id; this.sessions.set(record.batch_id,{id:'42',status:'Active',quantity:record.data.egg_quantity,hatched:null}); }
    } else if (record.event_kind==='stopped') {
      if (this.entries.get(record.data.started_event_id)?.receipt.disposition!=='applied') Object.assign(receipt,{disposition:'waiting_dependencies',code:'DEPENDENCY_MISSING',session_id:null});
    } else {
      const session=this.sessions.get(record.batch_id);
      if (this.entries.get(record.data.stopped_event_id)?.receipt.disposition!=='applied') Object.assign(receipt,{disposition:'waiting_dependencies',code:'DEPENDENCY_MISSING',session_id:null});
      else {
        assert.ok(session && session.quantity>0);
        assert.ok(Number.isInteger(record.data.eggs_hatched) && record.data.eggs_hatched>=0 && record.data.eggs_hatched<=session.quantity);
        session.status='Completed'; session.hatched=record.data.eggs_hatched; this.activeBatch=null;
      }
    }
    this.entries.set(record.event_id,{core:mockCore(record),receipt});
    return this.reply(receipt);
  }
  reply(receipt) {
    if (this.dropNextReply) { this.dropNextReply=false; throw new Error('MOCK_RESPONSE_LOST_AFTER_COMMIT'); }
    return copy(receipt);
  }
  reconcile(id) {
    if (!this.online) throw new Error('MOCK_OFFLINE');
    if (!this.authorized) throw new Error('MOCK_NOT_AUTHORIZED');
    return this.entries.has(id)?copy(this.entries.get(id).receipt):null;
  }
}

class MockIntegration {
  constructor(kit,store,controller,cloud,link=new MockBluetoothLink()) {
    this.kit=kit; this.store=store; this.controller=controller; this.cloud=cloud; this.link=link;
    this.operation='UNKNOWN'; this.lastKnown=null; this.queryCount=0; this.localSaveFailed=false;
    this.expectedDevice=kit.requests.started.device_id; this.bound=false;
  }
  connect() {
    this.bound=false; this.link.connect();
    const identity=this.controller.status('mock-binding-'+(++this.queryCount));
    if (identity.deviceId!==this.expectedDevice) throw new Error('WRONG_CONTROLLER');
    this.bound=true; // explicit synthetic binding only, not Bluetooth authentication
  }
  disconnect() { this.bound=false; this.lastKnown=this.operation; this.operation='UNKNOWN'; this.link.disconnect(); }
  dispatch(action,record,{ackOnly=false,loseAck=false,loseAllEvidence=false,failEvidenceCommit=false}={}) {
    if (!this.link.connected) throw new Error('LINK_DISCONNECTED');
    if (!this.bound || record.device_id!==this.expectedDevice) throw new Error('UNBOUND_CONTROLLER');
    this.store.intent(record);
    this.store.dispatchMarker(record.command_id);
    this.link.dispatch(action,record);
    const reply=this.controller.command(action,record);
    this.lastAck=!loseAck && reply.acknowledged;
    if (ackOnly || loseAllEvidence) { this.operation='UNKNOWN'; return; }
    // An original outcome/ACK may be replayed after the controller has stopped.
    // Current operation comes from a separate fresh mock read-only observation.
    this.operation=this.controller.status('mock-confirmation-'+(++this.queryCount)).controllerReport;
    if (failEvidenceCommit) this.store.failNextCommit=true;
    try { this.store.event(reply.record); }
    catch(error) { this.localSaveFailed=true; throw error; }
  }
  recover() {
    if (!this.link.connected) throw new Error('LINK_DISCONNECTED');
    if (!this.bound) throw new Error('UNBOUND_CONTROLLER');
    const result=this.controller.status('mock-query-'+(++this.queryCount));
    if (result.deviceId!==this.expectedDevice) throw new Error('WRONG_CONTROLLER');
    for (const record of result.retained) this.store.event(record);
    this.operation=result.controllerReport; this.localSaveFailed=false;
    return result;
  }
  upload(id) {
    const record=this.store.state.outbox[id].record;
    return this.acceptReceipt(record,this.cloud.submit(record));
  }
  acceptReceipt(record,receipt) {
    const name={started:'started',stopped:'stopped',farmer_completed:'completion'}[record.event_kind];
    assert.ok(receipt);
    assert.equal(receipt.event_id,record.event_id);
    assert.equal(receipt.device_id,record.device_id);
    assert.equal(receipt.batch_id,record.batch_id);
    assert.equal(receipt.content_sha256,this.kit.responses[name].content_sha256,'expected pinned review content hash');
    assert.equal(receipt.retention_ack,null,'no unsigned release token');
    this.store.receipt(record,receipt);
    return receipt;
  }
  reconcileUpload(id) {
    const receipt=this.cloud.reconcile(id);
    if (receipt) return this.acceptReceipt(this.store.state.outbox[id].record,receipt);
    return null;
  }
}

module.exports={root,fixtureDir,copy,sha256,assertPinnedText,mockCore,loadKit,ReviewOnlyGate,MockLineFramer,MockBluetoothLink,FileBackedMockLedger,FakeController,FakeCloud,MockIntegration};
