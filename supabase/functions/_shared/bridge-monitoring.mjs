import {BridgeError,speciesFromCode} from './bridge-sync-core.mjs';

// Backend-domain helpers, NOT new Arduino wire fields or approved targets.
export function profileIdentity(selection) {
  const species=speciesFromCode(selection.species_code);
  if(typeof selection.profile_ref!=='string'||!/^[A-Z0-9][A-Z0-9._-]{0,31}$/.test(selection.profile_ref))throw new BridgeError('INVALID_REQUEST');
  return Object.freeze({egg_type:species,profile_ref:selection.profile_ref});
}

export function remoteReadingStates(reading,{nowMs,staleAfterMs,futureSkewMs}={}) {
  let age=null;
  const measured=typeof reading.measured_at==='string'?Date.parse(reading.measured_at):NaN;
  const configured=Number.isFinite(nowMs)&&Number.isFinite(staleAfterMs)&&staleAfterMs>=0&&Number.isFinite(futureSkewMs)&&futureSkewMs>=0;
  if(reading.timestamp_valid===true&&Number.isFinite(measured)&&configured&&measured<=nowMs+futureSkewMs)age=Math.max(0,nowMs-measured);
  function metric(value,valid) {
    if(valid!==true||typeof value!=='number'||!Number.isFinite(value))return {state:'unavailable',live_value:null,last_value:null};
    if(age===null)return {state:'unknown_age',live_value:null,last_value:value};
    if(age>staleAfterMs)return {state:'stale',live_value:null,last_value:value};
    return {state:'fresh',live_value:value,last_value:value};
  }
  // received_at/server_received_at are intentionally ignored for freshness.
  return {temperature:metric(reading.current_temperature,reading.temperature_valid),humidity:metric(reading.current_humidity,reading.humidity_valid)};
}

// Describes already-observed Combined sketch shapes for diagnostic tests. It
// cannot authorize a synced transition: those frames lack durable source IDs,
// full batch attribution and validated clock/authorization in current source.
export function describeCombinedDiagnostic(frame) {
  if(!frame||typeof frame!=='object')throw new BridgeError('INVALID_REQUEST');
  const base={sync_eligible:false,can_confirm_start:false};
  if(frame.type==='event'&&frame.event==='egg_turn_completed')return {...base,condition:'egg_turn_reported'};
  if(frame.type==='telemetry') {
    const code={chicken:1,duck:2,quail:3}[frame.egg_type];
    const species=code?speciesFromCode(code):null;
    const context={...base,egg_type:species,reported_stage:['active','lockdown','complete'].includes(frame.stage)?frame.stage:null};
    if(frame.incubator?.valid===false)return {...context,condition:'sensor_unavailable'};
    if(frame.stage==='lockdown')return {...context,condition:'lockdown_reported'};
    return {...context,condition:'telemetry_unattributed'};
  }
  if(frame.type==='event'&&frame.code==='SENSOR_INVALID')return {...base,condition:'sensor_unavailable'};
  return {...base,condition:'unrecognized_diagnostic'};
}

export function conditionNotificationData({event_id,device_id,batch_id,event_kind}) {
  // Delivery/push subscription is not implemented. Consume a persisted scoped
  // backend fact; do not construct notifications from unbound wire diagnostics.
  const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
  if(typeof event_id!=='string'||!uuid.test(device_id??'')||!uuid.test(batch_id??'')||!['fault_entered','fault_cleared'].includes(event_kind))throw new BridgeError('INVALID_REQUEST');
  const prefix='controller:'+device_id+':',counter=event_id.slice(prefix.length);
  if(!event_id.startsWith(prefix)||!/^(0|[1-9][0-9]{0,9})$/.test(counter)||Number(counter)>4294967295)throw new BridgeError('INVALID_REQUEST');
  return {notification_id:event_id+':'+event_kind,event_id,device_id,batch_id,condition:event_kind==='fault_entered'?'controller_attention_required':'controller_fault_clear_reported',controller_report_only:true};
}
