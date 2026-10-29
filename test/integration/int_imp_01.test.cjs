'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const {spawnSync} = require('node:child_process');
const {
  root,fixtureDir,copy,sha256,assertPinnedText,mockCore,loadKit,ReviewOnlyGate,MockLineFramer,
  MockBluetoothLink,FileBackedMockLedger,FakeController,FakeCloud,MockIntegration,
} = require('./support/int_imp_01_mocks.cjs');

const kit = loadKit();
function context(t) {
  // Windows default resolves to the preapproved temporary OpenCode directory.
  const parent = path.join(os.tmpdir(),'opencode');
  fs.mkdirSync(parent,{recursive:true});
  const dir=fs.mkdtempSync(path.join(parent,'int-imp-01-'));
  t.after(()=>fs.rmSync(dir,{recursive:true,force:false}));
  const file=path.join(dir,'mock-ledger.json');
  const store=new FileBackedMockLedger(file), controller=new FakeController(), cloud=new FakeCloud(kit);
  const app=new MockIntegration(kit,store,controller,cloud); app.connect();
  return {file,store,controller,cloud,app};
}
function start(c,options) { c.app.dispatch('start',copy(kit.requests.started),options); }
function stop(c,options) { c.app.dispatch('stop',copy(kit.requests.stopped),options); }

test('INT-08 source snapshots and fixture namespaces are pinned, not selected',()=>{
  assert.equal(kit.manifest.kit_revision,'INT-IMP-01.mock.1');
  assert.equal(kit.manifest.active_implementation.catalog_revision,null);
  assert.equal(kit.manifest.active_implementation.firmware_commit,null);
  for(const source of kit.manifest.source_snapshots) assertPinnedText(fs.readFileSync(path.join(root,source.path)),source);
  assert.equal(kit.manifest.matrix.length,8);
  assert.match(kit.manifest.classification,/MOCK USE ONLY/);
});

test('INT-08 source pinning permits checkout line endings, never semantic source drift',()=>{
  const source=kit.manifest.db02_reference;
  const text=fs.readFileSync(path.join(root,source.path),'utf8').replace(/\r\n/g,'\n');
  assertPinnedText(Buffer.from(text.replace(/\n/g,'\r\n')),source);
  assertPinnedText(Buffer.from(text),source);
  assert.throws(()=>assertPinnedText(Buffer.from(text+'changed source content'),source),/Source snapshot changed/);
  assert.equal(sha256(Buffer.from(text)),source.lf_sha256);
});

test('INT-08 review references cannot open real hardware or claim an active catalog',()=>{
  const gate=new ReviewOnlyGate(kit.manifest);
  assert.throws(()=>gate.requireActiveCatalog(),/ACTIVE_SOURCE_MISSING/);
  assert.throws(()=>gate.openRealTransport(),/REAL_TRANSPORT_DISABLED/);
});

test('INT-08 all 20 reference frames retain exact payload byte counts across checkout line endings',()=>{
  for(const wire of kit.wires){
    const bytes=fs.readFileSync(path.join(fixtureDir,wire.fixture_file));
    assert.equal(bytes.at(-1),10);
    assert.equal(bytes.toString('utf8').replace(/\r\n/g,'\n').includes('\r'),false);
    assert.equal(wire.lines.length,wire.expected_content_bytes.length);
    wire.lines.forEach((line,index)=>{
      assert.equal(Buffer.byteLength(line,'utf8'),wire.expected_content_bytes[index]);
      assert.doesNotThrow(()=>JSON.parse(line)); // syntax only, not schema approval
    });
  }
  assert.ok(kit.wires[0].lines[7].length>191);
  assert.ok(kit.wires[0].lines[8].length>191);
  assert.match(kit.wires[1].lines[1],/18446744073709551615/); // preserve raw uint64, not Number round-trip
});

test('INT-01 byte fragmentation at every boundary preserves each reference frame',()=>{
  for(const wire of kit.wires) for(const line of wire.lines){
    const bytes=Buffer.from(line+'\n','ascii');
    for(let cut=0;cut<=bytes.length;cut++){
      const framer=new MockLineFramer(4096); // host test budget, not an Uno cap
      assert.deepEqual([...framer.push(bytes.subarray(0,cut)),...framer.push(bytes.subarray(cut))],[line]);
    }
  }
});

test('INT-01 coalesced reads and one-byte reads preserve order',()=>{
  const lines=kit.wires[0].lines, bytes=Buffer.from(lines.join('\n')+'\n');
  assert.deepEqual(new MockLineFramer(4096).push(bytes),lines);
  const framer=new MockLineFramer(4096),result=[];
  for(const byte of bytes) result.push(...framer.push(Buffer.from([byte])));
  assert.deepEqual(result,lines);
});

test('INT-01 exact test bound succeeds; overflow suffix is discarded through LF',()=>{
  const line=kit.wires[0].lines[4];
  assert.deepEqual(new MockLineFramer(Buffer.byteLength(line)).push(Buffer.from(line+'\n')),[line]);
  const framer=new MockLineFramer(Buffer.byteLength(line));
  assert.deepEqual(framer.push(Buffer.from('X'.repeat(line.length+1)+line+'\n'+line+'\n')),[line]);
  assert.deepEqual(framer.errors,['overflow']);
});

test('INT-01 invalid ASCII/NUL input is not surfaced as a valid frame',()=>{
  const good=kit.wires[0].lines[4];
  const framer=new MockLineFramer(4096);
  const bad=Buffer.concat([Buffer.from('{'),Buffer.from([0,255]),Buffer.from('STATUS\n'+good+'\n')]);
  assert.deepEqual(framer.push(bad),[good]);
  assert.deepEqual(framer.errors,['invalid-byte']);
});

test('INT-01 disconnect clears partial bytes; reconnect does not join old suffix',()=>{
  const framer=new MockLineFramer(4096),line=kit.wires[0].lines[4];
  assert.deepEqual(framer.push(Buffer.from(line.slice(0,10))),[]);
  framer.reset();
  assert.deepEqual(framer.push(Buffer.from(line+'\n')),[line]);
  const link=new MockBluetoothLink();
  assert.throws(()=>link.dispatch('start',kit.requests.started),/LINK_DISCONNECTED/);
  link.connect();link.disconnect();assert.equal(link.realWrites,0);
});

test('INT-02 repeated read-only status queries never actuate or create outbox events',t=>{
  const c=context(t),before=copy(c.controller.memory);
  const first=c.app.recover(),second=c.app.recover();
  assert.notEqual(first.queryId,second.queryId);
  assert.deepEqual(c.controller.memory,before);
  assert.equal(c.app.link.logicalWrites.length,0);
  assert.equal(Object.keys(c.store.state.outbox).length,0);
});

test('INT-03 explicit mock Start then Stop; controller report differs from cloud lifecycle',t=>{
  const c=context(t);start(c);
  assert.equal(c.app.operation,'RUNNING');assert.equal(c.controller.memory.effects,1);
  c.app.upload(kit.requests.started.event_id);
  stop(c);assert.equal(c.app.operation,'STOPPED');assert.equal(c.controller.memory.effects,2);
  c.app.upload(kit.requests.stopped.event_id);
  assert.equal(c.cloud.sessions.get(kit.requests.started.batch_id).status,'Active');
  assert.equal(c.app.link.realWrites,0);
});

test('INT-03 ACK alone remains unknown; it is not a Running report',t=>{
  const c=context(t);start(c,{ackOnly:true});
  assert.equal(c.app.lastAck,true);assert.equal(c.app.operation,'UNKNOWN');
  assert.equal(Object.keys(c.store.state.events).length,0);
  assert.equal(c.controller.memory.effects,1); // the fake transition may have happened
});

test('INT-03 manual zero hatch count does not dispatch a physical Stop',t=>{
  const c=context(t);start(c);stop(c);
  c.app.upload(kit.requests.started.event_id);c.app.upload(kit.requests.stopped.event_id);
  const before=c.app.link.logicalWrites.length;
  c.store.event(copy(kit.requests.completion));c.app.upload(kit.requests.completion.event_id);
  const session=c.cloud.sessions.get(kit.requests.started.batch_id);
  assert.equal(session.status,'Completed');assert.equal(session.hatched,0);
  assert.equal(c.app.link.logicalWrites.length,before);
});

test('INT-04 lost ACK with event/report still records one Start',t=>{
  const c=context(t);start(c,{loseAck:true});
  assert.equal(c.app.lastAck,false);assert.equal(c.app.operation,'RUNNING');
  c.app.disconnect();assert.equal(c.app.operation,'UNKNOWN');
  c.app.connect();c.app.recover();
  assert.equal(c.controller.memory.effects,1);
  assert.equal(c.app.link.logicalWrites.filter(x=>x.action==='start').length,1);
  assert.equal(Object.keys(c.store.state.events).length,1);
});

test('INT-04 lost entire outcome, app restart and reconnect recover original retained mock event',t=>{
  const c=context(t);start(c,{loseAck:true,loseAllEvidence:true});
  assert.equal(c.app.operation,'UNKNOWN');
  assert.equal(Object.keys(c.store.state.outbox).length,0);
  const reopened=new FileBackedMockLedger(c.file);
  assert.equal(reopened.state.intents[kit.requests.started.command_id].dispatchMayOccur,true);
  const replacement=new MockIntegration(kit,reopened,new FakeController(copy(c.controller.memory)),c.cloud);
  replacement.connect();replacement.recover();
  assert.equal(replacement.operation,'RUNNING');
  assert.equal(Object.keys(reopened.state.events)[0],kit.requests.started.event_id);
  assert.equal(replacement.link.logicalWrites.length,0);
  assert.equal(replacement.controller.memory.effects,1);
});

test('INT-04 older retained Start cannot override newer current mock Stop',t=>{
  const c=context(t);start(c);stop(c);c.app.disconnect();c.app.connect();c.app.recover();
  assert.equal(c.app.operation,'STOPPED');
  assert.equal(Object.keys(c.store.state.events).length,2);
  assert.equal(c.controller.memory.effects,2);
});

test('INT-04 replayed original command result after Stop is not current Running evidence',t=>{
  const c=context(t);start(c);stop(c);
  const old=c.controller.command('start',copy(kit.requests.started));
  assert.equal(old.record.event_kind,'started');
  assert.equal(Object.hasOwn(old,'controllerReport'),false);
  c.app.recover();
  assert.equal(c.app.operation,'STOPPED');assert.equal(c.controller.memory.effects,2);
});

test('INT-04 wrong controller on reconnect cannot bind, Start or reassign original local events',t=>{
  const c=context(t);start(c);c.app.disconnect();
  const wrong=new FakeController();wrong.memory.deviceId='99999999-9999-4999-8999-999999999999';
  const replacement=new MockIntegration(kit,c.store,wrong,c.cloud);
  assert.throws(()=>replacement.connect(),/WRONG_CONTROLLER/);
  assert.throws(()=>replacement.dispatch('start',copy(kit.requests.started)),/UNBOUND_CONTROLLER/);
  assert.equal(wrong.memory.effects,0);
  assert.equal(c.store.state.events[kit.requests.started.event_id].device_id,kit.requests.started.device_id);
});

test('INT-05 same logical command replays outcome; changed content conflicts',t=>{
  const c=context(t);start(c);
  const old=c.controller.command('start',copy(kit.requests.started));
  assert.equal(old.record.event_id,kit.requests.started.event_id);
  assert.equal(c.controller.memory.effects,1);
  assert.throws(()=>c.controller.command('start',kit.requests.conflicting_count),/COMMAND_CONTENT_CONFLICT/);
  assert.equal(c.controller.memory.effects,1);
});

test('INT-05 a different Start identity cannot replace an active batch; wrong batch Stop rejected',t=>{
  const c=context(t);start(c);
  const other=copy(kit.requests.started);other.command_id='aaaaaaaaaaaaaaaa';other.batch_id='dddddddd-dddd-4ddd-8ddd-dddddddddddd';
  assert.throws(()=>c.controller.command('start',other),/BUSY/);
  const wrong=copy(kit.requests.stopped);wrong.batch_id=other.batch_id;
  assert.throws(()=>c.controller.command('stop',wrong),/WRONG_BATCH/);
  assert.equal(c.controller.memory.effects,1);
});

test('INT-05 repeated local event has one outbox entry; changed same-key content is retained as conflict',t=>{
  const c=context(t);start(c);c.store.event(copy(kit.requests.started));
  assert.equal(Object.keys(c.store.state.outbox).length,1);
  assert.throws(()=>c.store.event(kit.requests.conflicting_count),/EVENT_CONTENT_CONFLICT/);
  assert.equal(c.store.state.events[kit.requests.started.event_id].data.egg_quantity,12);
});

test('INT-06 failed initial local commit prevents command dispatch',t=>{
  const c=context(t);c.store.failNextCommit=true;
  assert.throws(()=>start(c),/MOCK_LOCAL_COMMIT_FAILED/);
  assert.equal(c.app.link.logicalWrites.length,0);assert.equal(c.controller.memory.effects,0);
});

test('INT-06 Running report plus failed event save stays distinct; source recovery repairs mock outbox',t=>{
  const c=context(t);
  assert.throws(()=>start(c,{failEvidenceCommit:true}),/MOCK_LOCAL_COMMIT_FAILED/);
  assert.equal(c.app.operation,'RUNNING');assert.equal(c.app.localSaveFailed,true);
  assert.equal(Object.keys(c.store.state.outbox).length,0);
  c.app.recover();assert.equal(c.app.localSaveFailed,false);
  assert.equal(Object.keys(c.store.state.outbox).length,1);assert.equal(c.controller.memory.effects,1);
});

test('INT-06 offline event checkpoint survives reopen; failed upload preserves immutable outbox',t=>{
  const c=context(t);c.cloud.online=false;start(c);
  assert.throws(()=>c.app.upload(kit.requests.started.event_id),/MOCK_OFFLINE/);
  const reopened=new FileBackedMockLedger(c.file);
  assert.deepEqual(reopened.state.outbox[kit.requests.started.event_id].record,kit.requests.started);
  assert.equal(reopened.state.outbox[kit.requests.started.event_id].state,'pending');
  assert.equal(c.cloud.entries.size,0);
});

test('INT-07 response lost after mock commit reconciles same receipt with one session',t=>{
  const c=context(t);start(c);c.cloud.dropNextReply=true;
  assert.throws(()=>c.app.upload(kit.requests.started.event_id),/MOCK_RESPONSE_LOST_AFTER_COMMIT/);
  assert.equal(c.cloud.entries.size,1);assert.equal(c.cloud.sessions.size,1);
  assert.equal(c.store.state.outbox[kit.requests.started.event_id].state,'pending');
  const receipt=c.app.reconcileUpload(kit.requests.started.event_id);
  const replay=c.app.upload(kit.requests.started.event_id);
  assert.equal(receipt.receipt_id,replay.receipt_id);assert.equal(receipt.session_id,'42');
  assert.equal(c.cloud.entries.size,1);assert.equal(c.cloud.sessions.size,1);
  assert.equal(c.controller.memory.effects,1);
});

test('INT-07 identical duplicate does not reopen completed batch; same ID changed count rejected',t=>{
  const c=context(t);start(c);stop(c);c.store.event(copy(kit.requests.completion));
  for(const req of [kit.requests.started,kit.requests.stopped,kit.requests.completion])c.app.upload(req.event_id);
  const before=c.cloud.entries.size;c.app.upload(kit.requests.started.event_id);
  assert.equal(c.cloud.sessions.get(kit.requests.started.batch_id).status,'Completed');
  assert.throws(()=>c.cloud.submit(kit.requests.conflicting_count),/IDENTITY_CONTENT_CONFLICT/);
  assert.equal(c.cloud.entries.size,before);assert.equal(c.cloud.sessions.size,1);
});

test('INT-07 uploader/phone receipt changes do not rename an existing mock source fact',t=>{
  const c=context(t);start(c);const first=c.app.upload(kit.requests.started.event_id);
  const replay=copy(kit.requests.started);replay.phone_received_at='2026-10-29T00:00:00Z';
  replay.installation_id='33333333-3333-4333-8333-333333333333';
  // Authorization below is an explicit fake allow decision, not a proof that any
  // replacement installation is actually allowed by Mary's registry.
  const result=c.cloud.submit(replay);
  assert.equal(mockCore(replay),mockCore(kit.requests.started));
  assert.deepEqual(result,first);assert.equal(c.cloud.entries.size,1);
});

test('INT-07 missing predecessor persists waiting receipt; no invented session',t=>{
  const c=context(t);c.store.event(copy(kit.requests.stopped));
  const receipt=c.app.upload(kit.requests.stopped.event_id);
  assert.equal(receipt.disposition,'waiting_dependencies');assert.equal(receipt.session_id,null);
  assert.equal(c.cloud.sessions.size,0);
  assert.equal(c.store.state.outbox[kit.requests.stopped.event_id].state,'waiting_dependencies');
});

test('INT-07 existing unrelated Active record conflicts without automatic completion or reassignment',t=>{
  const c=context(t);c.cloud.activeBatch='LEGACY-UNRELATED';start(c);
  const receipt=c.app.upload(kit.requests.started.event_id);
  assert.equal(receipt.disposition,'conflict');assert.equal(receipt.code,'ACTIVE_SESSION_CONFLICT');
  assert.equal(receipt.session_id,null);assert.equal(c.cloud.activeBatch,'LEGACY-UNRELATED');
  assert.equal(c.cloud.sessions.size,0);assert.equal(c.app.operation,'RUNNING');
});

test('INT-07 fake revoked-authorization gate denies submission and receipt reads, preserving local events',t=>{
  const c=context(t);start(c);c.cloud.authorized=false;
  assert.throws(()=>c.app.upload(kit.requests.started.event_id),/MOCK_NOT_AUTHORIZED/);
  assert.throws(()=>c.app.reconcileUpload(kit.requests.started.event_id),/MOCK_NOT_AUTHORIZED/);
  assert.equal(c.cloud.entries.size,0);assert.equal(Object.keys(c.store.state.outbox).length,1);
  assert.equal(c.app.operation,'RUNNING');
});

test('INT-07 mismatched receipt content cannot mark synced; no unsigned Uno release',t=>{
  const c=context(t);start(c);const receipt=c.cloud.submit(kit.requests.started);
  const altered=copy(receipt);altered.content_sha256='0'.repeat(64);
  assert.throws(()=>c.app.acceptReceipt(kit.requests.started,altered),/content hash/);
  assert.equal(c.store.state.outbox[kit.requests.started.event_id].state,'pending');
  const forged=copy(receipt);forged.retention_ack='unsigned';
  assert.throws(()=>c.app.acceptReceipt(kit.requests.started,forged),/unsigned release/);
  assert.equal(c.app.link.realWrites,0);
});

test('INT-07 lower receipt revision ignored; same revision changed receipt rejected',t=>{
  const c=context(t);c.store.event(copy(kit.requests.stopped));
  const waiting=c.app.upload(kit.requests.stopped.event_id);
  const advanced=copy(waiting);advanced.receipt_revision=2;advanced.disposition='applied';advanced.code='APPLIED';advanced.session_id='42';
  // Candidate client-state test only: no actual server dependency worker ran.
  c.app.acceptReceipt(kit.requests.stopped,advanced);
  c.app.acceptReceipt(kit.requests.stopped,waiting);
  assert.equal(c.store.state.receipts[kit.requests.stopped.event_id].receipt_revision,2);
  assert.equal(c.store.state.outbox[kit.requests.stopped.event_id].state,'applied');
  const changed=copy(advanced);changed.code='TRANSITION_CONFLICT';
  assert.throws(()=>c.app.acceptReceipt(kit.requests.stopped,changed));
});

test('INT-08 read-only export is portable labelled JSON with original wire bytes and candidate DB fixtures',()=>{
  const script=path.join(root,'test/integration/export_int_imp_01_fixtures.cjs');
  const result=spawnSync(process.execPath,[script],{cwd:root,encoding:'utf8'});
  assert.equal(result.status,0,result.stderr);
  const exported=JSON.parse(result.stdout);
  assert.equal(exported.kit_revision,kit.manifest.kit_revision);
  assert.equal(exported.active_implementation.catalog_revision,null);
  assert.deepEqual(exported.db02_candidate.requests.started,kit.requests.started);
  assert.equal(exported.wire_references[0].raw_ascii_frames.length,14);
  assert.match(exported.wire_references[1].raw_ascii_frames[1],/18446744073709551615/);
});
