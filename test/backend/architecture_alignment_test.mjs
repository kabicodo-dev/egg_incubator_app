// OCT26:C-03: local architecture boundaries, not a selected wire/Auth/DB contract.
// All upstream ports are in-memory stubs. No .env, external fetch, hardware or DB.
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {
  BridgeError,createBridgeSyncHandler,immutableCore,validateReceipt,
} from '../../supabase/functions/_shared/bridge-sync-core.mjs';
import {createSupabasePorts} from '../../supabase/functions/_shared/bridge-sync-supabase.mjs';
const require=createRequire(import.meta.url);
const kit=require('../integration/support/int_imp_01_mocks.cjs').loadKit();
const closed=JSON.parse(readFileSync(new URL('../fixtures/integration/db_imp_01_closed_gate.json',import.meta.url),'utf8'));
const testRef='zbwntspdecngnicllwlw';
const applicationRef='suopuhgtwyqkpupzvdng';
const key='synthetic-public-key-not-a-credential';
function request(body){
  return new Request('http://127.0.0.1/functions/v1/bridge-sync',{
    method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify(body),
  });
}
function boundary(){
  const calls={authorize:0,ingest:0,reconcile:0};
  const ports={
    async authenticate(){return {synthetic:true};},
    async authorize(){calls.authorize++;},
    async ingest(){calls.ingest++;throw new Error('UNEXPECTED_INGEST');},
    async reconcile(){calls.reconcile++;throw new Error('UNEXPECTED_RECONCILE');},
  };
  return {calls,ports,handler:createBridgeSyncHandler({ports})};
}

test('architecture: cloud control/settings operations cannot become actuator commands',async()=>{
  const b=boundary();
  for(const operation of ['START','STOP','STATUS','NEW_BATCH','update_settings','set_actuator']){
    const response=await b.handler(request({...kit.requests.started,operation}));
    assert.equal(response.status,400);
    const payload=await response.json();assert.equal(payload.error.code,'INVALID_REQUEST');
    assert.equal(Object.hasOwn(payload,'controller_state'),false);
  }
  assert.deepEqual(b.calls,{authorize:0,ingest:0,reconcile:0});
});

for(const c of closed.cases){
  test(`architecture: default source remains closed for ${c.request} despite accepted boundary stubs`,async()=>{
    const b=boundary(),body=structuredClone(kit.requests[c.request]),before=JSON.stringify(body);
    const response=await b.handler(request(body));
    assert.equal(response.status,c.status);
    const payload=await response.json();assert.equal(payload.error.code,c.code);
    assert.equal(Object.hasOwn(payload,'receipt_id'),false);
    assert.equal(payload.error.commit_status,'not_persisted');
    assert.deepEqual(b.calls,{authorize:1,ingest:0,reconcile:0});
    assert.equal(JSON.stringify(body),before);
  });
}

test('architecture: the application project cannot be selected even using its own ref as a pin',()=>{
  let fetches=0;
  assert.throws(()=>createSupabasePorts({url:`https://${applicationRef}.supabase.co`,
    testProjectRef:applicationRef,publishableKey:key,fetchImpl:async()=>{fetches++;throw new Error();}}),
  /MAIN_PROJECT_DISABLED_FOR_LOCAL_INTEGRATION/);
  assert.equal(fetches,0);
});

test('architecture: hosted endpoints require an exact HTTPS isolated-project origin without credentials/path',()=>{
  let fetches=0;
  const fetchImpl=async()=>{fetches++;throw new Error('NETWORK_FORBIDDEN');};
  for(const options of [
    {url:`https://${testRef}.supabase.co`},
    {url:`http://${testRef}.supabase.co`,testProjectRef:testRef},
    {url:'https://unselected.supabase.co',testProjectRef:testRef},
    {url:`https://${testRef}.supabase.co/other`,testProjectRef:testRef},
    {url:`https://${testRef}.supabase.co/?x=1`,testProjectRef:testRef},
    {url:`https://${testRef}.supabase.co/#other`,testProjectRef:testRef},
    {url:`https://synthetic:fixture@${testRef}.supabase.co`,testProjectRef:testRef},
  ])assert.throws(()=>createSupabasePorts({...options,publishableKey:key,fetchImpl}),/ISOLATED_SUPABASE_NOT_CONFIGURED/);
  createSupabasePorts({url:`https://${testRef}.supabase.co`,testProjectRef:testRef,publishableKey:key,fetchImpl});
  assert.equal(fetches,0);
});

test('architecture: Supabase boundary calls only the three candidate RPCs, never legacy direct table writes',async()=>{
  const calls=[];
  const ports=createSupabasePorts({url:`https://${testRef}.supabase.co`,testProjectRef:testRef,publishableKey:key,
    fetchImpl:async(url,init)=>{
      calls.push({url,method:init.method,body:JSON.parse(init.body)});
      return new Response(JSON.stringify(url.endsWith('bridge_sync_authorize_v1')?{allowed:true}:{}),{status:200});
    }});
  const identity={token:'synthetic-test-token-not-a-session'},body=kit.requests.started;
  await ports.authorize(identity,body);
  await ports.ingest(identity,{body,hash:'0'.repeat(64)});
  await ports.reconcile(identity,kit.requests.reconcile,'synthetic-request-id');
  assert.deepEqual(calls.map(c=>new URL(c.url).pathname),[
    '/rest/v1/rpc/bridge_sync_authorize_v1','/rest/v1/rpc/bridge_sync_ingest_v1','/rest/v1/rpc/bridge_sync_reconcile_v1',
  ]);
  assert(calls.every(c=>c.method==='POST'));
  assert.deepEqual(Object.keys(calls[0].body).sort(),['p_device_id','p_installation_id']);
  assert.deepEqual(Object.keys(calls[1].body).sort(),['p_content_sha256','p_submission']);
  assert.deepEqual(Object.keys(calls[2].body).sort(),['p_query','p_request_id']);
});

test('architecture: a cloud receipt cannot smuggle a controller evidence-release artifact',()=>{
  const body=kit.requests.started,receipt=structuredClone(kit.responses.started);
  assert.equal(validateReceipt(receipt,body,receipt.content_sha256).retention_ack,null);
  for(const retention_ack of [true,false,'release',{},[]]){
    const changed={...receipt,retention_ack};
    assert.throws(()=>validateReceipt(changed,body,receipt.content_sha256),e=>e instanceof BridgeError&&e.code==='SERVICE_UNAVAILABLE');
  }
});

test('architecture: phone receipt time never fills unknown source Start time in immutable evidence',()=>{
  const body=structuredClone(kit.requests.started);
  body.occurred_at=null;body.timestamp_valid=false;body.phone_received_at='2026-10-30T00:00:00Z';
  const core=immutableCore(body,null);
  assert.equal(core.occurred_at,null);assert.equal(core.timestamp_valid,false);
  assert.equal(Object.hasOwn(core,'phone_received_at'),false);
  assert.equal(core.event_id,body.event_id);assert.equal(core.command_id,body.command_id);
});

test('architecture: cloud authentication failure returns an upload error, not physical Stop state',async()=>{
  let subsequentCalls=0;
  const handler=createBridgeSyncHandler({ports:{
    async authenticate(){throw new BridgeError('AUTHENTICATION_REQUIRED',401);},
    async authorize(){subsequentCalls++;},async ingest(){subsequentCalls++;},async reconcile(){subsequentCalls++;},
  }});
  const response=await handler(request(kit.requests.started)),payload=await response.json();
  assert.equal(response.status,401);assert.equal(payload.error.code,'AUTHENTICATION_REQUIRED');
  assert.deepEqual(Object.keys(payload).sort(),['api_version','error','request_id']);
  assert.equal(subsequentCalls,0);
});
