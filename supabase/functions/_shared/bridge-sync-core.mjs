// Candidate DB-02 HTTP implementation. No physical command, network or database
// is opened here. Persistence and validated source adapters are explicit ports.
// Unselected/unsupported firmware is fail-closed; never fabricate source evidence.
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
const HEX64 = /^[0-9a-f]{16}$/;
const UTC = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/;
const PROFILE = /^[A-Z0-9][A-Z0-9._-]{0,31}$/;
const EVENT_KINDS = new Set(['started','stopped','farmer_completed','status_observed','fault_entered','fault_cleared']);
const STATES = new Set(['IDLE','STARTING','RUNNING','STOPPED','FAULT','RECOVERY']);
const RECEIPT_CODES = {
  applied: new Set(['APPLIED']),
  waiting_dependencies: new Set(['DEPENDENCY_MISSING']),
  conflict: new Set(['ACTIVE_SESSION_CONFLICT','TRANSITION_CONFLICT','PROFILE_UNAPPROVED','LEGACY_MAPPING_REQUIRED','TIME_POLICY_UNAPPROVED']),
};

export class BridgeError extends Error {
  constructor(code,status=400,{retryable=false,commitStatus='not_persisted'}={}) {
    super(code); this.name='BridgeError'; this.code=code; this.status=status;
    this.retryable=retryable; this.commitStatus=commitStatus;
  }
}
function requireValue(ok,code='INVALID_REQUEST') { if(!ok) throw new BridgeError(code); }
function object(v) { return v!==null && typeof v==='object' && !Array.isArray(v); }
function keys(v,required) {
  requireValue(object(v));
  requireValue(Object.keys(v).length===required.length && required.every(k=>Object.hasOwn(v,k)));
}
function uuid(v) { requireValue(typeof v==='string' && UUID.test(v)); }
function uuid4(v) { uuid(v); requireValue(v[14]==='4' && /[89ab]/.test(v[19])); }
function hex(v) { requireValue(typeof v==='string' && HEX64.test(v)); }
function uint(v,max=4294967295) { requireValue(Number.isSafeInteger(v) && v>=0 && v<=max); }
function utc(v) {
  requireValue(typeof v==='string' && UTC.test(v));
  const ms=Date.parse(v);
  requireValue(Number.isFinite(ms) && new Date(ms).toISOString().replace('.000Z','Z')===v);
}
function nullableTime(v) { if(v!==null) utc(v); }
function timePair(v,valid) {
  requireValue(typeof valid==='boolean');
  if(valid) utc(v); else requireValue(v===null);
}
function profile(v) { requireValue(typeof v==='string' && PROFILE.test(v)); }
function controllerEventId(v,device) {
  requireValue(typeof v==='string' && v.startsWith('controller:'+device+':'));
  const n=v.slice(('controller:'+device+':').length);
  requireValue(/^(0|[1-9][0-9]{0,9})$/.test(n));uint(Number(n));
  return Number(n);
}
function evidence(v) {
  keys(v,['adapter','frames']);
  requireValue(['HW02-EVENT-SINGLE','HW02-EVENT-SPLIT','HW02-STATE-SINGLE','HW02-STATE-SPLIT','HW02-TEL-SINGLE'].includes(v.adapter));
  requireValue(Array.isArray(v.frames) && v.frames.length>=1 && v.frames.length<=4);
  for(const line of v.frames) requireValue(typeof line==='string' && line.length>=2 && line.length<=4096 && /^[\x20-\x7e]+$/.test(line));
}

export function speciesFromCode(code) {
  requireValue(Number.isInteger(code) && [1,2,3].includes(code));
  return ['Chicken','Duck','Quail'][code-1];
}

// JSON.parse validates syntax; a second token walk rejects duplicate keys,
// including escaped equivalents at all object depths. No permissive coercion.
export function parseStrictObject(text) {
  let result;
  try { result=JSON.parse(text); } catch { throw new BridgeError('INVALID_REQUEST'); }
  requireValue(object(result));
  const stack=[];
  for(const token of text.match(/"(?:\\.|[^"\\])*"|[{}\[\],:]/g)??[]) {
    if(token==='{') stack.push({object:true,keys:new Set(),keyNext:true});
    else if(token==='[') stack.push({object:false});
    else if(token==='}' || token===']') stack.pop();
    else if(token===',') { if(stack.at(-1)?.object) stack.at(-1).keyNext=true; }
    else if(token.startsWith('"') && stack.at(-1)?.object && stack.at(-1).keyNext) {
      const scope=stack.at(-1),key=JSON.parse(token);
      requireValue(!scope.keys.has(key));scope.keys.add(key);scope.keyNext=false;
    }
  }
  assertJsonValues(result);
  return result;
}
function assertJsonValues(v) {
  requireValue(v===null||['number','string','boolean'].includes(typeof v)||Array.isArray(v)||object(v));
  if(object(v))requireValue(Object.getPrototypeOf(v)===Object.prototype||Object.getPrototypeOf(v)===null);
  if(typeof v==='number') requireValue(Number.isFinite(v) && (!Number.isInteger(v)||Number.isSafeInteger(v)));
  if(typeof v==='string') {
    // Reject unpaired UTF-16 surrogates, which cannot be canonical Unicode data.
    for(let i=0;i<v.length;i++) {
      const c=v.charCodeAt(i);
      if(c>=0xd800 && c<=0xdbff) { const n=v.charCodeAt(++i);requireValue(n>=0xdc00 && n<=0xdfff); }
      else requireValue(!(c>=0xdc00 && c<=0xdfff));
    }
  }
  if(Array.isArray(v)) v.forEach(assertJsonValues);
  else if(object(v)) for(const [k,value] of Object.entries(v)) { assertJsonValues(k);assertJsonValues(value); }
}

export function validateSubmission(b) {
  requireValue(object(b));
  uuid(b.installation_id);uuid(b.device_id);requireValue(b.api_version===1);
  const common=['api_version','operation','installation_id','device_id'];
  if(b.operation==='get_reconciliation') {
    keys(b,[...common,'batch_id','lookups']);if(b.batch_id!==null)uuid4(b.batch_id);
    requireValue(Array.isArray(b.lookups) && b.lookups.length<=100 && (b.batch_id!==null||b.lookups.length>0));
    const seen=new Set();
    for(const item of b.lookups) {
      keys(item,['entity','entity_id']);requireValue(['event','reading'].includes(item.entity));
      requireValue(typeof item.entity_id==='string' && item.entity_id.length>0 && item.entity_id.length<=128);
      requireValue(!seen.has(item.entity+'|'+item.entity_id));seen.add(item.entity+'|'+item.entity_id);
    }
    return b;
  }
  if(b.operation==='submit_reading') {
    keys(b,[...common,'batch_id','sample_id','boot_epoch','sample_sequence','measured_at','timestamp_valid','phone_received_at','current_temperature','temperature_valid','current_humidity','humidity_valid','wire_evidence']);
    uuid4(b.batch_id);uint(b.boot_epoch);uint(b.sample_sequence);
    requireValue(b.sample_id===`sample:${b.device_id}:${b.boot_epoch}:${b.sample_sequence}`);
    timePair(b.measured_at,b.timestamp_valid);nullableTime(b.phone_received_at);evidence(b.wire_evidence);
    for(const [value,valid] of [[b.current_temperature,b.temperature_valid],[b.current_humidity,b.humidity_valid]]) {
      requireValue(typeof valid==='boolean');
      requireValue(valid ? typeof value==='number' && Number.isFinite(value) : value===null);
    }
    if(b.humidity_valid)requireValue(b.current_humidity>=0 && b.current_humidity<=100);
    return b;
  }
  requireValue(b.operation==='submit_event');
  keys(b,[...common,'event_id','batch_id','event_kind','command_id','source_sequence','occurred_at','timestamp_valid','phone_received_at','data','wire_evidence']);
  if(!EVENT_KINDS.has(b.event_kind)) throw new BridgeError('UNSUPPORTED_EVENT_KIND');
  timePair(b.occurred_at,b.timestamp_valid);nullableTime(b.phone_received_at);
  if(b.batch_id!==null)uuid4(b.batch_id);
  if(b.event_kind==='farmer_completed') {
    requireValue(b.batch_id!==null && b.command_id===null && b.source_sequence===null && b.wire_evidence===null);
    keys(b.data,['eggs_hatched','stopped_event_id','actor_installation_id']);
    uint(b.data.eggs_hatched,2147483647);uuid(b.data.actor_installation_id);
    controllerEventId(b.data.stopped_event_id,b.device_id);
    const prefix='farmer:'+b.data.actor_installation_id+':';
    requireValue(typeof b.event_id==='string' && b.event_id.startsWith(prefix));uuid4(b.event_id.slice(prefix.length));
  } else if(b.event_kind==='status_observed') {
    hex(b.command_id);requireValue(b.source_sequence===null && b.occurred_at===null && b.timestamp_valid===false);
    const prefix='observation:'+b.device_id+':';requireValue(typeof b.event_id==='string' && b.event_id.startsWith(prefix));uuid4(b.event_id.slice(prefix.length));
    keys(b.data,['query_id','boot_epoch','latest_event_sequence','controller_state','species_code','profile_ref','original_start_at','original_start_valid']);
    hex(b.data.query_id);requireValue(b.data.query_id===b.command_id);uint(b.data.boot_epoch);uint(b.data.latest_event_sequence);
    requireValue(STATES.has(b.data.controller_state));if(b.data.species_code!==null)speciesFromCode(b.data.species_code);
    if(b.data.profile_ref!==null)profile(b.data.profile_ref);timePair(b.data.original_start_at,b.data.original_start_valid);evidence(b.wire_evidence);
  } else {
    requireValue(b.batch_id!==null);uint(b.source_sequence);
    requireValue(controllerEventId(b.event_id,b.device_id)===b.source_sequence);evidence(b.wire_evidence);
    if(b.event_kind==='started') {
      hex(b.command_id);keys(b.data,['species_code','egg_quantity','profile_ref','installation_alias']);
      speciesFromCode(b.data.species_code);uint(b.data.egg_quantity,2147483647);requireValue(b.data.egg_quantity>0);
      profile(b.data.profile_ref);hex(b.data.installation_alias);
    } else if(b.event_kind==='stopped') {
      hex(b.command_id);keys(b.data,['started_event_id']);controllerEventId(b.data.started_event_id,b.device_id);
    } else {
      if(b.command_id!==null)hex(b.command_id);keys(b.data,['started_event_id']);
      if(b.data.started_event_id!==null)controllerEventId(b.data.started_event_id,b.device_id);
    }
  }
  return b;
}

// ECMAScript JSON number/string serialization + UTF-16 key order, rejecting
// non-I-JSON values above. Matches the selected JCS-style core; not Uno crypto.
export function canonicalJson(v) {
  assertJsonValues(v);
  if(Array.isArray(v)) return '['+v.map(canonicalJson).join(',')+']';
  if(object(v)) return '{'+Object.keys(v).sort().map(k=>JSON.stringify(k)+':'+canonicalJson(v[k])).join(',')+'}';
  return JSON.stringify(v);
}
export function immutableCore(b,sourceEvidence) {
  const event=b.operation==='submit_event';
  requireValue(event || b.operation==='submit_reading');
  const names=event
    ? ['device_id','event_id','batch_id','event_kind','command_id','source_sequence','occurred_at','timestamp_valid','data']
    : ['device_id','batch_id','sample_id','boot_epoch','sample_sequence','measured_at','timestamp_valid','current_temperature','temperature_valid','current_humidity','humidity_valid'];
  return {api_version:1,entity:event?'event':'reading',...Object.fromEntries(names.map(k=>[k,b[k]])),source_evidence:sourceEvidence};
}
export async function fingerprint(core) {
  const digest=await globalThis.crypto.subtle.digest('SHA-256',new TextEncoder().encode(canonicalJson(core)));
  return Array.from(new Uint8Array(digest),x=>x.toString(16).padStart(2,'0')).join('');
}

export const unavailableSourceAdapter = Object.freeze({
  async validate() { throw new BridgeError('CONTRACT_NOT_ENABLED',503,{retryable:false}); },
});

export function validateReceipt(r,b,hash) {
  const fail=()=>{throw new BridgeError('SERVICE_UNAVAILABLE',503,{retryable:true,commitStatus:'unknown'});};
  try {
    keys(r,['api_version','receipt_id','receipt_revision','entity','event_id','sample_id','device_id','batch_id','session_id','content_sha256','disposition','code','received_at','retention_ack']);
    requireValue(r.api_version===1);uuid(r.receipt_id);uint(r.receipt_revision,2147483647);requireValue(r.receipt_revision>0);
    requireValue(r.device_id===b.device_id && r.batch_id===b.batch_id && r.content_sha256===hash && r.retention_ack===null);
    requireValue(RECEIPT_CODES[r.disposition]?.has(r.code));utc(r.received_at);
    if(r.session_id!==null)requireValue(typeof r.session_id==='string' && /^[1-9][0-9]{0,18}$/.test(r.session_id) && BigInt(r.session_id)<=9223372036854775807n);
    const event=b.operation==='submit_event';
    requireValue(r.entity===(event?'event':'reading'));
    requireValue(r.event_id===(event?b.event_id:null) && r.sample_id===(event?null:b.sample_id));
    if(!event)requireValue(r.disposition==='applied' && r.session_id!==null);
    if(event && ['started','stopped','farmer_completed'].includes(b.event_kind) && r.disposition==='applied')requireValue(r.session_id!==null);
  } catch { fail(); }
  return r;
}

function sessionId(v) {
  if(v!==null)requireValue(typeof v==='string'&&/^[1-9][0-9]{0,18}$/.test(v)&&BigInt(v)<=9223372036854775807n);
}
export function validateReconciliation(result,b,requestId) {
  try {
    keys(result,['api_version','request_id','results','batch']);
    requireValue(result.api_version===1&&result.request_id===requestId&&Array.isArray(result.results)&&result.results.length===b.lookups.length);
    result.results.forEach((item,index)=>{
      keys(item,['entity','entity_id','found','receipt']);
      const query=b.lookups[index];requireValue(item.entity===query.entity&&item.entity_id===query.entity_id&&typeof item.found==='boolean');
      if(!item.found){requireValue(item.receipt===null);return;}
      requireValue(object(item.receipt)&&/^[0-9a-f]{64}$/.test(item.receipt.content_sha256));
      if(b.batch_id!==null)requireValue(item.receipt.batch_id===b.batch_id);
      validateReceipt(item.receipt,{operation:item.entity==='event'?'submit_event':'submit_reading',event_kind:'status_observed',device_id:b.device_id,batch_id:item.receipt.batch_id,event_id:item.entity_id,sample_id:item.entity_id},item.receipt.content_sha256);
    });
    if(b.batch_id===null)requireValue(result.batch===null);
    else {
      keys(result.batch,['batch_id','session_id','mapping_state','status']);
      requireValue(result.batch.batch_id===b.batch_id&&['unmapped','mapped','conflict'].includes(result.batch.mapping_state)&&['Active','Completed',null].includes(result.batch.status));
      sessionId(result.batch.session_id);
      if(result.batch.mapping_state==='mapped')requireValue(result.batch.session_id!==null);
      if(result.batch.mapping_state==='unmapped')requireValue(result.batch.session_id===null&&result.batch.status===null);
    }
  } catch {throw new BridgeError('SERVICE_UNAVAILABLE',503,{retryable:true});}
  return result;
}

async function readBody(request,maxBytes) {
  const reader=request.body?.getReader();if(!reader)throw new BridgeError('INVALID_REQUEST');
  const parts=[];let size=0;
  try {
    for(;;) { const {done,value}=await reader.read();if(done)break;size+=value.byteLength;
      if(size>maxBytes){await reader.cancel();throw new BridgeError('LIMIT_EXCEEDED',413);}parts.push(value); }
    const bytes=new Uint8Array(size);let offset=0;for(const part of parts){bytes.set(part,offset);offset+=part.length;}
    return parseStrictObject(new TextDecoder('utf-8',{fatal:true}).decode(bytes));
  } catch(error) { if(error instanceof BridgeError)throw error;throw new BridgeError('INVALID_REQUEST'); }
}
function json(body,status) { return new Response(JSON.stringify(body),{status,headers:{'content-type':'application/json; charset=utf-8','cache-control':'no-store'}}); }

export function createBridgeSyncHandler({ports,sourceAdapter=unavailableSourceAdapter,maxBodyBytes=16384}) {
  if(!ports || !Number.isSafeInteger(maxBodyBytes)||maxBodyBytes<1)throw new Error('INVALID_BRIDGE_CONFIGURATION');
  return async request=>{
    const requestId=globalThis.crypto.randomUUID();let persistenceStarted=false;
    try {
      if(request.method!=='POST')throw new BridgeError('INVALID_REQUEST',405);
      if(!/^application\/json(?:\s*;\s*charset=utf-8)?$/i.test(request.headers.get('content-type')??''))throw new BridgeError('INVALID_REQUEST',415);
      const identity=await ports.authenticate(request);
      const body=validateSubmission(await readBody(request,maxBodyBytes));
      await ports.authorize(identity,body);
      if(body.operation==='get_reconciliation') {
        const result=validateReconciliation(await ports.reconcile(identity,body,requestId),body,requestId);
        return json(result,200);
      }
      // Also gates farmer completion: enabling a fact path must not accidentally
      // enable a different unreviewed lifecycle/profile/time policy.
      const normalizedSource=await sourceAdapter.validate(body,identity);
      const core=immutableCore(body,normalizedSource),hash=await fingerprint(core);
      persistenceStarted=true;
      const result=await ports.ingest(identity,{body,core,hash});
      if(!result || typeof result.created!=='boolean')throw new Error('INVALID_STORE_RESULT');
      const receipt=validateReceipt(result.receipt,body,hash);
      return json(receipt,result.created?201:200);
    } catch(error) {
      const known=error instanceof BridgeError;
      const e=known?error:new BridgeError('SERVICE_UNAVAILABLE',503,{retryable:true,commitStatus:persistenceStarted?'unknown':'not_persisted'});
      // No token, raw body, DB error/stack, frame or source MAC is logged/echoed.
      return json({api_version:1,request_id:requestId,error:{code:e.code,message:'The synchronization request could not be completed.',retryable:e.retryable,commit_status:e.commitStatus}},e.status);
    }
  };
}
