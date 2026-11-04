// ORIGINAL:C-09 local verification only. Arbitrary synthetic time budgets below
// are NOT approved freshness, clock-skew, sensor or physical safety thresholds.
// No transport, database, .env, remote fetch or production modification.
import test from 'node:test';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {remoteReadingStates} from '../../supabase/functions/_shared/bridge-monitoring.mjs';
import {validateSubmission} from '../../supabase/functions/_shared/bridge-sync-core.mjs';
const require=createRequire(import.meta.url);
const fixtureReading=require('../integration/support/int_imp_01_mocks.cjs').loadKit().requests.reading;

const measured='2026-10-30T00:00:00Z',at=Date.parse(measured);
const reading={current_temperature:25,temperature_valid:true,current_humidity:40,humidity_valid:true,measured_at:measured,timestamp_valid:true};
const policy={nowMs:at+1000,staleAfterMs:5000,futureSkewMs:0};
const classify=(r=reading,p=policy)=>remoteReadingStates(r,p);

for(const [age,state] of [[0,'fresh'],[4999,'fresh'],[5000,'fresh'],[5001,'stale']]){
 test(`freshness boundary: synthetic age ${age} ms gives ${state}`,()=>{
  const result=classify(reading,{...policy,nowMs:at+age});
  for(const [metric,value] of [['temperature',25],['humidity',40]]){
   assert.equal(result[metric].state,state);assert.equal(result[metric].live_value,state==='fresh'?value:null);assert.equal(result[metric].last_value,value);
  }
 });
}
test('zero synthetic freshness budget has exact-age behavior, not a configured default',()=>{
 assert.equal(classify(reading,{...policy,nowMs:at,staleAfterMs:0}).temperature.state,'fresh');
 assert.equal(classify(reading,{...policy,nowMs:at+1,staleAfterMs:0}).temperature.state,'stale');
});
for(const metric of ['temperature','humidity']){
 test(`independent validity: invalid ${metric} cannot hide the other valid metric`,()=>{
  const other=metric==='temperature'?'humidity':'temperature',r={...reading,[metric+'_valid']:false,['current_'+metric]:null};
  assert.deepEqual(classify(r)[metric],{state:'unavailable',live_value:null,last_value:null});assert.equal(classify(r)[other].state,'fresh');
 });
 test(`strict ${metric}: no numeric/Boolean/string coercion and no nonfinite live value`,()=>{
  for(const value of [null,undefined,'25',true,NaN,Infinity,-Infinity,{},[]]){
   const result=classify({...reading,['current_'+metric]:value});assert.equal(result[metric].state,'unavailable');assert.equal(result[metric].last_value,null);
  }
  for(const valid of [false,null,undefined,'true',1])assert.equal(classify({...reading,[metric+'_valid']:valid})[metric].state,'unavailable');
 });
}
test('missing metrics never become zero or a profile/setpoint fallback',()=>{
 const x={measured_at:measured,timestamp_valid:true,target_temperature:37.5,target_humidity:55};
 for(const r of Object.values(classify(x)))assert.deepEqual(r,{state:'unavailable',live_value:null,last_value:null});
});
test('invalid takes precedence over age unknown or stale without keeping a pretend last valid value',()=>{
 for(const p of [{...policy,nowMs:at+999999},{}])assert.deepEqual(classify({...reading,temperature_valid:false},p).temperature,{state:'unavailable',live_value:null,last_value:null});
});
test('valid zero-valued synthetic metric is not treated as missing',()=>{
 const x=classify({...reading,current_temperature:0,current_humidity:0});assert.equal(x.temperature.live_value,0);assert.equal(x.humidity.live_value,0);
 // This demonstrates type/presence semantics, not sensor-range or safety approval.
});
test('unknown source timestamp or untrusted validity never becomes live from phone/server receipt',()=>{
 for(const r of [{...reading,measured_at:null,timestamp_valid:false},{...reading,measured_at:undefined},{...reading,timestamp_valid:'true'},{...reading,measured_at:'not-a-time'}]){
  const x=classify({...r,received_at:measured,server_received_at:measured,phone_received_at:measured});
  assert.deepEqual(x.temperature,{state:'unknown_age',live_value:null,last_value:25});
 }
});
test('unconfigured policy never supplies a default threshold or live value',()=>{
 for(const p of [undefined,{}, {nowMs:at}, {nowMs:at,staleAfterMs:5000}])assert.equal(remoteReadingStates(reading,p).temperature.state,'unknown_age');
});
for(const key of ['nowMs','staleAfterMs','futureSkewMs']){
 test(`policy ${key} must be a finite number, never coerced`,()=>{
  for(const value of [undefined,null,'5000',NaN,Infinity,-Infinity])assert.equal(classify(reading,{...policy,[key]:value}).temperature.state,'unknown_age');
 });
}
test('negative freshness/skew budgets do not enable live data',()=>{
 for(const key of ['staleAfterMs','futureSkewMs'])assert.equal(classify(reading,{...policy,[key]:-1}).temperature.state,'unknown_age');
});
test('future source time beyond explicit synthetic skew budget stays unknown age',()=>{
 const r={...reading,measured_at:'2026-10-30T00:00:02Z'};
 assert.equal(classify(r,{...policy,futureSkewMs:999}).temperature.state,'unknown_age');
 assert.equal(classify(r,{...policy,futureSkewMs:1000}).temperature.state,'fresh');
});
test('recent receipts cannot refresh an old acquisition',()=>{
 const p={...policy,nowMs:at+100000},receipt=new Date(p.nowMs).toISOString();
 assert.equal(classify({...reading,received_at:receipt,server_received_at:receipt,phone_received_at:receipt},p).temperature.state,'stale');
});
test('changing cloud status, source stage or relay diagnostics does not make an invalid metric valid',()=>{
 const x=classify({...reading,temperature_valid:false,status:'Active',controller_state:'RUNNING',stage:'complete',batch_complete:true,bulb_on:true,received_at:measured});
 assert.equal(x.temperature.state,'unavailable');assert.equal(x.temperature.live_value,null);
});
test('transport disconnect/reconnect cannot substitute a new acquisition timestamp',()=>{
 const p={...policy,nowMs:at+100000};
 for(const connected of [false,true])assert.equal(classify({...reading,connected,reconnected_at:new Date(p.nowMs).toISOString()},p).temperature.state,'stale');
 // Helper intentionally does not implement transport state; UI must track it separately.
});
test('metric classification never claims controller Stop/Start, cloud completion or admission',()=>{
 const result=classify();assert.deepEqual(Object.keys(result).sort(),['humidity','temperature']);
 for(const x of Object.values(result))assert.deepEqual(Object.keys(x).sort(),['last_value','live_value','state']);
});
test('duplicate local classification is stable and neither input nor policy is mutated',()=>{
 const r=structuredClone(reading),p=structuredClone(policy),before=JSON.stringify({r,p});
 assert.deepEqual(classify(r,p),classify(r,p));assert.equal(JSON.stringify({r,p}),before);
});
test('no automatic fallback from source time to ordinary phone-receipt fields',()=>{
 const r={...reading,measured_at:null,timestamp_valid:false,recorded_at:measured,created_at:measured,updated_at:measured,receivedAt:at};
 assert.equal(classify(r).humidity.state,'unknown_age');
});
test('existing submission validator rejects impossible source date before helper use',()=>{
 const r=structuredClone(fixtureReading);r.measured_at='2026-02-30T00:00:00Z';r.timestamp_valid=true;
 assert.throws(()=>validateSubmission(r));
 // This is a real unit boundary, not a claim every future monitoring caller uses it.
});
test('existing submission validator rejects missing original batch association',()=>{
 const r=structuredClone(fixtureReading);r.batch_id=null;assert.throws(()=>validateSubmission(r));
});
