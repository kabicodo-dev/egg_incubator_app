import test from 'node:test';
import assert from 'node:assert/strict';
import {randomBytes,randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {
  BridgeError,createBridgeSyncHandler,parseStrictObject,validateSubmission,
  canonicalJson,immutableCore,fingerprint,speciesFromCode,unavailableSourceAdapter,
} from '../../supabase/functions/_shared/bridge-sync-core.mjs';
import {createSupabasePorts} from '../../supabase/functions/_shared/bridge-sync-supabase.mjs';
import {listenBridge} from '../../supabase/dev/serve-bridge-sync.mjs';
const require=createRequire(import.meta.url);
const {loadKit}=require('../integration/support/int_imp_01_mocks.cjs');
const kit=loadKit(),clone=structuredClone;

// Test-only adapter for the pre-existing review fixture, NOT Ally's selected
// wire implementation. Actual deployed/dev handler defaults to disabled source.
const fixtureAdapter={async validate(b){
  if(b.wire_evidence===null)return null;
  if(b.wire_evidence.adapter.endsWith('SPLIT'))throw new BridgeError('WIRE_SPLIT_UNFROZEN',503);
  const w=parseStrictObject(b.wire_evidence.frames[0]);
  if(w.dev!=='A001A1B2C3D4E5F6'||w.bid!==(b.batch_id===null?null:b.batch_id.replaceAll('-','')))throw new BridgeError('INVALID_SOURCE_EVIDENCE',422);
  if(w.t==='EVENT') {
    if(w.seq!==b.source_sequence||w.cid!==b.command_id||w.kind!==b.event_kind)throw new BridgeError('INVALID_SOURCE_EVIDENCE',422);
    return {version:w.v,family:'EVENT',controller_alias:w.dev,boot_epoch:w.ep,source_sequence:w.seq,event_kind:w.kind,command_id:w.cid,batch_token:w.bid,source_epoch_seconds:w.ts,source_time_valid:w.tv};
  }
  if(w.t==='TEL')return {version:w.v,family:'TEL',controller_alias:w.dev,boot_epoch:w.ep,sample_sequence:w.n,batch_token:w.bid,source_epoch_seconds:w.ts,source_time_valid:w.tv,temperature_c:w.tc,temperature_valid:w.t_ok,humidity_pct:w.rh,humidity_valid:w.rh_ok};
  throw new BridgeError('CONTRACT_NOT_ENABLED',503);
}};

// Supabase Auth/RPC boundary STUBS. The actual handler, HTTP socket, strict
// validators, canonicalization, ports and receipt checking run unchanged.
// No PostgreSQL transaction, JWT signature or RLS proof is asserted by this file.
function boundary() {
  const origin='http://127.0.0.1:54321';
  const userId='33333333-3333-4333-8333-333333333333',sessionId='44444444-4444-4444-8444-444444444444';
  const claims={sub:userId,session_id:sessionId,role:'authenticated',iss:origin+'/auth/v1',aud:'authenticated',exp:2000000000};
  const enc=value=>Buffer.from(JSON.stringify(value)).toString('base64url');
  const token=enc({alg:'HS256',typ:'JWT'})+'.'+enc(claims)+'.'+randomBytes(32).toString('base64url');
  const publishableKey=randomBytes(32).toString('hex');
  const state={enabled:true,anonymous:false,authCalls:0,authorizeCalls:0,ingestCalls:0,reconcileCalls:0,entries:new Map(),sessions:new Map(),activeBatch:null,failIngest:false,badReceipt:false,badReconciliation:false};
  const reply=(value,status=200)=>new Response(JSON.stringify(value),{status,headers:{'content-type':'application/json'}});
  async function fetchImpl(url,init={}) {
    // Credential assertions emit only Booleans on failure, never header values.
    assert.ok(init.headers.apikey===publishableKey);
    if(init.headers.authorization!=='Bearer '+token)return reply({},401);
    if(url===origin+'/auth/v1/user'){state.authCalls++;return reply({id:userId,is_anonymous:state.anonymous});}
    const body=JSON.parse(init.body);
    if(url.endsWith('/bridge_sync_authorize_v1')) {
      state.authorizeCalls++;
      return reply({allowed:state.enabled&&body.p_installation_id===kit.requests.started.installation_id&&body.p_device_id===kit.requests.started.device_id});
    }
    if(url.endsWith('/bridge_sync_reconcile_v1')) {
      state.reconcileCalls++;
      const q=body.p_query;
      const results=q.lookups.map(lookup=>({entity:lookup.entity,entity_id:lookup.entity_id,found:state.entries.has(lookup.entity_id),receipt:state.entries.get(lookup.entity_id)?.receipt??null}));
      const session=state.sessions.get(q.batch_id);
      const value={api_version:1,request_id:body.p_request_id,results,batch:q.batch_id===null?null:{batch_id:q.batch_id,session_id:session?.id??null,mapping_state:session?'mapped':'unmapped',status:session?.status??null}};
      if(state.badReconciliation)value.request_id=randomUUID();
      return reply(value);
    }
    assert.ok(url.endsWith('/bridge_sync_ingest_v1'));
    state.ingestCalls++;
    if(state.failIngest)throw new Error('private upstream error must never be echoed');
    const b=body.p_submission,key=b.event_id??b.sample_id,old=state.entries.get(key);
    if(old)return old.hash===body.p_content_sha256?reply({created:false,receipt:old.receipt}):reply({},409);
    let disposition='applied',code='APPLIED',mapping=state.sessions.get(b.batch_id)?.id??null;
    if(b.operation==='submit_reading') {
      if(!mapping)return reply({},422);
    } else if(b.event_kind==='started') {
      if(state.activeBatch&&state.activeBatch!==b.batch_id){disposition='conflict';code='ACTIVE_SESSION_CONFLICT';mapping=null;}
      else {mapping='42';state.sessions.set(b.batch_id,{id:mapping,status:'Active',quantity:b.data.egg_quantity,species:speciesFromCode(b.data.species_code),profile:b.data.profile_ref});state.activeBatch=b.batch_id;}
    } else {
      const predecessor=b.data.started_event_id??b.data.stopped_event_id;
      if(predecessor&&state.entries.get(predecessor)?.receipt.disposition!=='applied'){disposition='waiting_dependencies';code='DEPENDENCY_MISSING';mapping=null;}
      if(b.event_kind==='farmer_completed'&&disposition==='applied') {
        const session=state.sessions.get(b.batch_id);
        if(!session||b.data.eggs_hatched>session.quantity)return reply({},422);
        session.status='Completed';session.hatched=b.data.eggs_hatched;state.activeBatch=null;
      }
    }
    const r={api_version:1,receipt_id:randomUUID(),receipt_revision:1,entity:b.operation==='submit_reading'?'reading':'event',event_id:b.event_id??null,sample_id:b.sample_id??null,device_id:b.device_id,batch_id:b.batch_id,session_id:mapping,content_sha256:body.p_content_sha256,disposition,code,received_at:'2026-10-28T02:00:00Z',retention_ack:null};
    state.entries.set(key,{hash:body.p_content_sha256,receipt:r});
    return reply({created:true,receipt:state.badReceipt?{...r,content_sha256:'0'.repeat(64)}:r});
  }
  const ports=createSupabasePorts({url:origin,publishableKey,fetchImpl,now:()=>Date.parse('2026-10-28T02:00:00Z')});
  return {state,ports,token,origin,publishableKey};
}
async function server(t,{adapter=fixtureAdapter,afterHandle=null,maxBodyBytes=16384}={}) {
  const b=boundary(),service=await listenBridge(createBridgeSyncHandler({ports:b.ports,sourceAdapter:adapter,maxBodyBytes}),{afterHandle});
  t.after(()=>service.close());
  async function post(value,{raw=null,token=b.token,method='POST',contentType='application/json'}={}) {
    const response=await fetch(service.url,{method,headers:{'content-type':contentType,...(token?{authorization:'Bearer '+token}:{})},body:['GET','HEAD'].includes(method)?undefined:raw??JSON.stringify(value)});
    return {status:response.status,body:await response.json()};
  }
  return {...b,...service,post};
}

test('real core strict JSON rejects duplicate/escaped/nested keys, overflow numbers and trailing text',()=>{
  for(const raw of ['{"a":1,"a":2}','{"a":1,"\\u0061":2}','{"data":{"a":1,"a":2}}','{"n":1e999}','{} trailing','[]','{"id":18446744073709551615}','{"a":"\\ud800"}'])assert.throws(()=>parseStrictObject(raw),BridgeError);
  assert.deepEqual(parseStrictObject('{"a":[{"x":1},{"x":2}]}'),{a:[{x:1},{x:2}]});
});

test('real core accepts all seven existing candidate request shapes without changing fixtures',()=>{
  for(const value of Object.values(kit.requests))assert.equal(validateSubmission(clone(value)).api_version,1);
});

test('real canonical core matches recorded DB-02 fingerprint and ignores transport metadata',async()=>{
  const b=clone(kit.requests.started),source=await fixtureAdapter.validate(b);
  const first=await fingerprint(immutableCore(b,source));
  assert.equal(first,kit.responses.started.content_sha256);
  b.installation_id='55555555-5555-4555-8555-555555555555';b.phone_received_at='2026-10-29T02:00:00Z';
  assert.equal(await fingerprint(immutableCore(b,source)),first);
  b.data.egg_quantity=11;assert.notEqual(await fingerprint(immutableCore(b,source)),first);
  assert.equal(canonicalJson({z:-0,a:54.0}),' {"a":54,"z":0}'.trim());
  for(const value of [{a:undefined},{a:1n},new Date(),{a:()=>true}])assert.throws(()=>canonicalJson(value),BridgeError);
});

test('actual loopback HTTP records Start, duplicate and changed-content conflict via real handler/ports; DB stub only',async t=>{
  const s=await server(t);
  const first=await s.post(kit.requests.started);assert.equal(first.status,201);assert.equal(first.body.session_id,'42');
  assert.equal(first.body.content_sha256,kit.responses.started.content_sha256);
  const duplicate=await s.post(kit.requests.started);assert.equal(duplicate.status,200);assert.equal(duplicate.body.receipt_id,first.body.receipt_id);
  const changed=await s.post(kit.requests.conflicting_count);assert.equal(changed.status,409);assert.equal(changed.body.error.code,'IDENTITY_CONTENT_CONFLICT');
  assert.equal(s.state.entries.size,1);assert.equal(s.state.sessions.size,1);
});

test('actual HTTP default source gate refuses valid-looking controller evidence before persistence',async t=>{
  const b=boundary(),service=await listenBridge(createBridgeSyncHandler({ports:b.ports}));t.after(()=>service.close());
  const response=await fetch(service.url,{method:'POST',headers:{authorization:'Bearer '+b.token,'content-type':'application/json'},body:JSON.stringify(kit.requests.started)});
  assert.equal(response.status,503);assert.equal((await response.json()).error.code,'CONTRACT_NOT_ENABLED');assert.equal(b.state.ingestCalls,0);
});

test('actual HTTP missing/forged credentials and anonymous user are denied against Auth boundary stub',async t=>{
  const s=await server(t);
  assert.equal((await s.post(kit.requests.started,{token:null})).status,401);
  assert.equal((await s.post(kit.requests.started,{token:randomBytes(32).toString('hex')})).status,401);
  s.state.anonymous=true;assert.equal((await s.post(kit.requests.started)).status,401);
  assert.equal(s.state.ingestCalls,0);
});

test('actual HTTP registry/session denial blocks writes and receipt lookup even for otherwise accepted Auth fixture',async t=>{
  const s=await server(t);assert.equal((await s.post(kit.requests.started)).status,201);
  s.state.enabled=false;
  assert.equal((await s.post(kit.requests.started)).status,403);
  assert.equal((await s.post(kit.requests.reconcile)).status,403);
  assert.equal(s.state.ingestCalls,1);assert.equal(s.state.reconcileCalls,0);
});

test('actual HTTP wrong source scope is denied before source adapter/store',async t=>{
  const s=await server(t),b=clone(kit.requests.started),old=b.device_id;b.device_id='55555555-5555-4555-8555-555555555555';
  b.event_id=b.event_id.replace(old,b.device_id); // valid shape, unauthorized target scope
  assert.equal((await s.post(b)).status,403);assert.equal(s.state.ingestCalls,0);
});

test('actual HTTP source/body mismatch and unsupported split evidence cannot persist',async t=>{
  const s=await server(t),mismatch=clone(kit.requests.started);mismatch.command_id='ffffffffffffffff';
  assert.equal((await s.post(mismatch)).status,422);
  const split=clone(kit.requests.started);split.wire_evidence.adapter='HW02-EVENT-SPLIT';
  assert.equal((await s.post(split)).status,503);assert.equal(s.state.ingestCalls,0);
});

test('actual HTTP duplicate JSON keys, invalid dates, wrong types and invented event kinds are rejected',async t=>{
  const s=await server(t),raw=JSON.stringify(kit.requests.started).replace('"api_version":1','"api_version":1,"api_version":1');
  assert.equal((await s.post(null,{raw})).status,400);
  const bad=clone(kit.requests.started);bad.occurred_at='2026-02-30T00:00:00Z';assert.equal((await s.post(bad)).status,400);
  bad.occurred_at=kit.requests.started.occurred_at;bad.source_sequence='103';assert.equal((await s.post(bad)).status,400);
  const turning=clone(kit.requests.started);turning.event_kind='egg_turn_completed';
  const result=await s.post(turning);assert.equal(result.status,400);assert.equal(result.body.error.code,'UNSUPPORTED_EVENT_KIND');assert.equal(s.state.ingestCalls,0);
});

test('actual HTTP stream bounds and method/media handling fail without storage writes',async t=>{
  const s=await server(t,{maxBodyBytes:128});
  assert.equal((await s.post(kit.requests.started)).status,413);
  assert.equal((await s.post(null,{method:'GET'})).status,405);
  assert.equal((await s.post(kit.requests.started,{contentType:'text/plain'})).status,415);
  assert.equal(s.state.ingestCalls,0);
});

test('actual HTTP Stop and farmer zero completion remain separate accepted candidate facts',async t=>{
  const s=await server(t);
  await s.post(kit.requests.started);assert.equal((await s.post(kit.requests.stopped)).status,201);
  assert.equal(s.state.sessions.get(kit.requests.started.batch_id).status,'Active');
  const response=await s.post(kit.requests.completion);assert.equal(response.status,201);
  assert.equal(s.state.sessions.get(kit.requests.started.batch_id).status,'Completed');assert.equal(s.state.sessions.get(kit.requests.started.batch_id).hatched,0);
});

test('actual HTTP readings use source values and source fingerprint, not profile targets',async t=>{
  const s=await server(t);await s.post(kit.requests.started);
  const reading=await s.post(kit.requests.reading);assert.equal(reading.status,201);assert.equal(reading.body.entity,'reading');assert.equal(reading.body.content_sha256,kit.responses.reading.content_sha256);
  const replay=await s.post(kit.requests.reading);assert.equal(replay.status,200);assert.equal(replay.body.receipt_id,reading.body.receipt_id);
});

test('actual HTTP returns committed waiting/conflict receipts distinctly from rejected content',async t=>{
  const s=await server(t);
  const pending=await s.post(kit.requests.stopped);assert.equal(pending.status,201);assert.equal(pending.body.disposition,'waiting_dependencies');assert.equal(pending.body.session_id,null);
  s.state.activeBatch='legacy-unrelated';const conflict=await s.post(kit.requests.started);assert.equal(conflict.status,201);assert.equal(conflict.body.disposition,'conflict');assert.equal(s.state.sessions.size,0);
});

test('real HTTP socket response loss after handler completion reconciles same stored receipt (storage stub)',async t=>{
  let dropped=false;
  const s=await server(t,{afterHandle:response=>{if(response.status===201&&!dropped){dropped=true;return false;}return true;}});
  await assert.rejects(()=>s.post(kit.requests.started));
  assert.equal(s.state.entries.size,1);assert.equal(s.state.sessions.size,1);
  const response=await s.post(kit.requests.reconcile);assert.equal(response.status,200);assert.equal(response.body.results[0].found,true);
  const receipt=response.body.results[0].receipt;
  const replay=await s.post(kit.requests.started);assert.equal(replay.status,200);assert.equal(replay.body.receipt_id,receipt.receipt_id);assert.equal(s.state.entries.size,1);
});

test('upstream persistence failure and malformed receipt are sanitized, never false success',async t=>{
  const s=await server(t);s.state.failIngest=true;
  const failed=await s.post(kit.requests.started);assert.equal(failed.status,503);assert.equal(failed.body.error.commit_status,'unknown');assert.ok(!JSON.stringify(failed.body).includes('private upstream'));
  s.state.failIngest=false;s.state.badReceipt=true;
  const bad=await s.post(kit.requests.started);assert.equal(bad.status,503);assert.equal(bad.body.error.commit_status,'unknown');
});

test('actual reconciliation validates request IDs and nested receipt scope before echoing data',async t=>{
  const s=await server(t);await s.post(kit.requests.started);s.state.badReconciliation=true;
  const result=await s.post(kit.requests.reconcile);assert.equal(result.status,503);
});

test('real Supabase ports refuse main-project URL and require explicit isolated configuration',()=>{
  const key=randomBytes(32).toString('hex');
  assert.throws(()=>createSupabasePorts({url:'https://suopuhgtwyqkpupzvdng.supabase.co',publishableKey:key}),/MAIN_PROJECT_DISABLED/);
  assert.throws(()=>createSupabasePorts({url:'https://unselected.supabase.co',publishableKey:key}),/ISOLATED_SUPABASE/);
  const credentialUrl=new URL('http://localhost:54321');credentialUrl.username='fixture';credentialUrl.password=randomBytes(16).toString('hex');
  assert.throws(()=>createSupabasePorts({url:credentialUrl.href,publishableKey:key}),/ISOLATED_SUPABASE/);
});

test('real Supabase ports do not turn a missing RPC/registry into a fake allowed result',async()=>{
  const s=boundary();
  const unavailable=createSupabasePorts({url:s.origin,publishableKey:s.publishableKey,fetchImpl:async()=>new Response('{}',{status:404})});
  await assert.rejects(()=>unavailable.authorize({token:s.token},{installation_id:kit.requests.started.installation_id,device_id:kit.requests.started.device_id}),error=>error instanceof BridgeError&&error.code==='SERVICE_UNAVAILABLE');
});

// Security is deliberately NOT represented by an enabled fixture adapter here.
// A successful Auth/registry stub must not bypass the production source gate,
// including a farmer action with null evidence and retries of the same identity.
const closedGate=JSON.parse(readFileSync(new URL('../fixtures/integration/db_imp_01_closed_gate.json',import.meta.url),'utf8'));
for(const fixture of closedGate.cases) {
  test(`DB-IMP-01 default-closed ${fixture.request}: initial and retry never ingest`,async t=>{
    const s=await server(t,{adapter:unavailableSourceAdapter});
    const body=kit.requests[fixture.request],before=JSON.stringify(body);
    assert.ok(body&&body.operation!=='get_reconciliation');
    for(let attempt=0;attempt<2;attempt++) {
      const response=await s.post(body);
      assert.equal(response.status,fixture.status);
      assert.equal(response.body.error.code,fixture.code);
      assert.equal(response.body.error.commit_status,'not_persisted');
      assert.equal(response.body.error.retryable,false);
      assert.equal(Object.hasOwn(response.body,'receipt_id'),false);
    }
    assert.equal(s.state.authCalls,2);
    assert.equal(s.state.authorizeCalls,2);
    assert.equal(s.state.ingestCalls,0);
    assert.equal(s.state.entries.size,0);
    assert.equal(s.state.sessions.size,0);
    assert.equal(JSON.stringify(body),before);
  });
}
