import test from 'node:test';
import assert from 'node:assert/strict';
import {profileIdentity,remoteReadingStates,describeCombinedDiagnostic,conditionNotificationData} from '../../supabase/functions/_shared/bridge-monitoring.mjs';

for(const [code,name,ref] of [[1,'Chicken','TEST-CHICKEN'],[2,'Duck','TEST-DUCK'],[3,'Quail','TEST-QUAIL']]) {
  test(`updated objective: ${name} profile identity propagates without invented numerical targets`,()=>{
    const result=profileIdentity({species_code:code,profile_ref:ref});
    assert.equal(result.egg_type,name);assert.equal(result.profile_ref,ref);
    assert.equal(Object.hasOwn(result,'target_temperature'),false);assert.equal(Object.hasOwn(result,'target_humidity'),false);
    assert.ok(Object.isFrozen(result));
  });
}
test('updated objective: unknown species/profile identity is rejected, never defaults to Chicken',()=>{
  for(const code of [0,4,'2',null])assert.throws(()=>profileIdentity({species_code:code,profile_ref:'TEST-PROFILE'}));
  assert.throws(()=>profileIdentity({species_code:1,profile_ref:'unapproved string with spaces'}));
});

const reading={current_temperature:25,temperature_valid:true,current_humidity:40,humidity_valid:true,measured_at:'2026-10-28T00:00:00Z',timestamp_valid:true};
// Explicit arbitrary TEST policy; not a deployed/approved sensor cadence/limit.
const now=Date.parse('2026-10-28T00:00:01Z'),policy={nowMs:now,staleAfterMs:5000,futureSkewMs:0};
test('updated objective: temperature and humidity have independent actual-value/freshness states',()=>{
  const fresh=remoteReadingStates(reading,policy);assert.equal(fresh.temperature.state,'fresh');assert.equal(fresh.humidity.live_value,40);
  const invalid=remoteReadingStates({...reading,current_temperature:null,temperature_valid:false,target_temperature:37.5},policy);
  assert.equal(invalid.temperature.state,'unavailable');assert.equal(invalid.temperature.live_value,null);assert.equal(invalid.humidity.state,'fresh');
});
test('updated objective: stale remote reading stays stale despite recent cloud receipt',()=>{
  const result=remoteReadingStates({...reading,server_received_at:'2026-10-28T01:00:00Z',received_at:'2026-10-28T01:00:00Z'},{...policy,nowMs:now+3600000});
  assert.equal(result.temperature.state,'stale');assert.equal(result.temperature.live_value,null);assert.equal(result.temperature.last_value,25);
});
test('updated objective: invalid RTC, unconfigured threshold or future clock does not claim live data',()=>{
  for(const r of [{...reading,timestamp_valid:false,measured_at:null},{...reading,measured_at:'2026-10-29T00:00:00Z'}])assert.equal(remoteReadingStates(r,policy).humidity.state,'unknown_age');
  assert.equal(remoteReadingStates(reading).temperature.state,'unknown_age');
});
test('updated objective: source egg-turning diagnostic is recognized but never fabricated into a synced event',()=>{
  const result=describeCombinedDiagnostic({type:'event',event:'egg_turn_completed'});
  assert.equal(result.condition,'egg_turn_reported');assert.equal(result.sync_eligible,false);assert.equal(result.can_confirm_start,false);
});
test('updated objective: source lockdown stage is recognized for all species, not inferred from relay off',()=>{
  for(const name of ['chicken','duck','quail']) {
    const result=describeCombinedDiagnostic({type:'telemetry',egg_type:name,stage:'lockdown',incubator:{valid:true}});
    assert.equal(result.condition,'lockdown_reported');assert.equal(result.sync_eligible,false);
  }
  const normal=describeCombinedDiagnostic({type:'telemetry',egg_type:'chicken',stage:'active',incubator:{valid:true},bulb_on:false});
  assert.equal(normal.condition,'telemetry_unattributed');assert.equal(normal.can_confirm_start,false);
});
test('updated objective: sensor errors have diagnostic data without claiming source identity or safety',()=>{
  const result=describeCombinedDiagnostic({type:'event',code:'SENSOR_INVALID',payload:{sensor:'i',time:100}});
  assert.equal(result.condition,'sensor_unavailable');assert.equal(result.sync_eligible,false);
});
test('updated objective: a sensor error does not erase a separately reported lockdown stage',()=>{
  const result=describeCombinedDiagnostic({type:'telemetry',egg_type:'duck',stage:'lockdown',incubator:{valid:false}});
  assert.equal(result.condition,'sensor_unavailable');assert.equal(result.reported_stage,'lockdown');assert.equal(result.sync_eligible,false);
});
test('updated objective: condition notification data is stable and controller-reported, not push delivery proof',()=>{
  const fact={event_id:'controller:11111111-1111-4111-8111-111111111111:105',device_id:'11111111-1111-4111-8111-111111111111',batch_id:'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',event_kind:'fault_entered'};
  assert.deepEqual(conditionNotificationData(fact),conditionNotificationData({...fact}));
  assert.equal(conditionNotificationData(fact).condition,'controller_attention_required');
  assert.equal(conditionNotificationData(fact).controller_report_only,true);
  assert.throws(()=>conditionNotificationData({...fact,event_kind:'egg_turn_completed'}));
  assert.throws(()=>conditionNotificationData({...fact,device_id:'55555555-5555-4555-8555-555555555555'}));
});
