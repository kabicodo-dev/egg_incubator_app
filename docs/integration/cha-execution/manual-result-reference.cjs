// TEST-ONLY proposal oracle and vector generator. No HTTP/Auth/database/Flutter
// implementation; no .env, network or production module import. NOT release code.
const assert=require('node:assert/strict'),crypto=require('node:crypto');
const CONTRACT='DB02-MANUAL-RESULT-0.1-review';
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
const V4=/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
const HASH=/^[0-9a-f]{64}$/;
const scope=['installation_id','device_id','batch_id','actor_installation_id','result_id'];
const header=['api_version','contract'];
function object(x){assert(x&&typeof x==='object'&&!Array.isArray(x),'object required');}
function keys(x,list){object(x);assert.deepEqual(Object.keys(x).sort(),[...list].sort(),'closed exact fields');}
function utc(x){assert(typeof x==='string'&&/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/.test(x),'whole-second UTC');assert.equal(new Date(x).toISOString().replace('.000Z','Z'),x,'real UTC date');}
function count(x,min=0){assert(typeof x==='number'&&Number.isInteger(x)&&x>=min&&x<=2147483647,'integer count');}
function base(x){assert.equal(x.api_version,2);assert.equal(x.contract,CONTRACT);}
function ids(x){for(const k of scope)assert(typeof x[k]==='string'&&(k==='batch_id'||k==='result_id'?V4:UUID).test(x[k]),k);}
function validateSubmit(x){
 keys(x,[...header,...scope,'operation','original_manifest_sha256','eggs_hatched','action_time']);base(x);ids(x);
 assert.equal(x.operation,'submit_manual_result');assert(HASH.test(x.original_manifest_sha256));count(x.eggs_hatched);
 keys(x.action_time,['value','provenance']);
 if(x.action_time.provenance==='unknown')assert.equal(x.action_time.value,null);
 else {assert.equal(x.action_time.provenance,'phone_clock');utc(x.action_time.value);}
 return x;
}
function validateLookup(x){keys(x,[...header,...scope,'operation']);base(x);ids(x);assert.equal(x.operation,'get_manual_result');return x;}
function core(x){validateSubmit(x);return Object.fromEntries(['contract','device_id','batch_id','actor_installation_id','result_id','original_manifest_sha256','eggs_hatched','action_time'].map(k=>[k,x[k]]));}
// Equivalent JCS for the validated closed ASCII-string/null/safe-integer core.
// This is NOT a general-purpose RFC 8785 Unicode/float implementation.
function canonical(x){
 if(x===null)return 'null';
 if(typeof x==='string'){assert(/^[\x20-\x7e]*$/.test(x));return JSON.stringify(x);}
 if(typeof x==='number'){assert(Number.isSafeInteger(x));return JSON.stringify(x);}
 object(x);return '{'+Object.keys(x).sort().map(k=>JSON.stringify(k)+':'+canonical(x[k])).join(',')+'}';
}
function digest(x){return crypto.createHash('sha256').update(canonical(core(x)),'utf8').digest('hex');}
function dependencies(x,ctx){
 validateSubmit(x);assert(ctx&&ctx.manifest,'MANIFEST_REQUIRED');const m=ctx.manifest;
 assert.equal(m.sha256,x.original_manifest_sha256,'MANIFEST_CONFLICT');
 for(const k of ['device_id','batch_id','actor_installation_id'])assert.equal(m[k],x[k],'MANIFEST_CONFLICT');
 count(m.egg_quantity,1);assert(x.eggs_hatched<=m.egg_quantity,'COUNT_OUT_OF_RANGE');
 assert(ctx.session,'BATCH_MAPPING_REQUIRED');
 assert(typeof ctx.session.id==='string'&&/^[1-9][0-9]{0,18}$/.test(ctx.session.id));
 assert(BigInt(ctx.session.id)<=9223372036854775807n,'signed bigint');
 assert.equal(ctx.session.status,'Active','LIFECYCLE_CONFLICT');
 return true;
}
function checkReceipt(r,x,ctx,previous=null){
 keys(r,[...header,'receipt_id','receipt_revision','device_id','batch_id','actor_installation_id','result_id','original_manifest_sha256','content_sha256','egg_quantity','eggs_hatched','session_id','received_at','outcome','lifecycle_effect','physical_admission_effect','retention_ack']);
 base(r);assert(UUID.test(r.receipt_id));assert.equal(r.receipt_revision,1);utc(r.received_at);
 for(const k of ['device_id','batch_id','actor_installation_id','result_id','original_manifest_sha256','eggs_hatched'])assert.equal(r[k],x[k],k);
 assert.equal(r.content_sha256,digest(x));count(r.egg_quantity,1);count(r.eggs_hatched);assert(r.eggs_hatched<=r.egg_quantity);
 assert.equal(r.egg_quantity,ctx.manifest.egg_quantity);assert.equal(r.session_id,ctx.session.id);
 assert(typeof r.session_id==='string'&&/^[1-9][0-9]{0,18}$/.test(r.session_id));assert(BigInt(r.session_id)<=9223372036854775807n);
 assert.equal(r.outcome,'result_recorded');assert.equal(r.lifecycle_effect,'none');assert.equal(r.physical_admission_effect,'none');assert.equal(r.retention_ack,null);
 if(previous)assert.deepEqual(r,previous,'immutable original receipt');return true;
}
function lookup(x){validateSubmit(x);return {...Object.fromEntries([...header,...scope].map(k=>[k,x[k]])),operation:'get_manual_result'};}
function vectors(){
 const submit={api_version:2,contract:CONTRACT,operation:'submit_manual_result',installation_id:'22222222-2222-4222-8222-222222222222',device_id:'11111111-1111-4111-8111-111111111111',batch_id:'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',actor_installation_id:'22222222-2222-4222-8222-222222222222',result_id:'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',original_manifest_sha256:'a'.repeat(64),eggs_hatched:0,action_time:{value:null,provenance:'unknown'}};
 const context={classification:'SYNTHETIC preconditions, not verified source/registry/profile or real DB records',manifest:{sha256:submit.original_manifest_sha256,device_id:submit.device_id,batch_id:submit.batch_id,actor_installation_id:submit.actor_installation_id,egg_quantity:12,profile_ref:'TEST_ONLY_NOT_APPROVED'},session:{id:'9007199254740993',status:'Active'}};
 const receipt={api_version:2,contract:CONTRACT,receipt_id:'dddddddd-dddd-4ddd-8ddd-dddddddddddd',receipt_revision:1,device_id:submit.device_id,batch_id:submit.batch_id,actor_installation_id:submit.actor_installation_id,result_id:submit.result_id,original_manifest_sha256:submit.original_manifest_sha256,content_sha256:digest(submit),egg_quantity:12,eggs_hatched:0,session_id:context.session.id,received_at:'2026-10-30T00:00:00Z',outcome:'result_recorded',lifecycle_effect:'none',physical_admission_effect:'none',retention_ack:null};
 const phone={...structuredClone(submit),eggs_hatched:12,action_time:{value:'2026-10-29T23:59:59Z',provenance:'phone_clock'}};
 const id={device_id:submit.device_id,batch_id:submit.batch_id,actor_installation_id:submit.actor_installation_id,result_id:submit.result_id};
 return {notice:'PROPOSAL / SYNTHETIC LOCAL VECTORS ONLY. Never upload. No approvals, real manifests, persistence, controller evidence or API result is claimed.',context,requests:{unknown_time_zero:submit,phone_time_upper:phone,lookup:lookup(submit)},responses:{recorded:receipt,found:{api_version:2,contract:CONTRACT,request_id:'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',...id,found:true,receipt},absent:{api_version:2,contract:CONTRACT,request_id:'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',...id,found:false,receipt:null},unknown_commit:{api_version:2,contract:CONTRACT,request_id:'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',error:{code:'COMMIT_UNKNOWN',retryable:true,commit_status:'unknown'}}},hashVectors:[submit,phone].map(x=>({name:x===submit?'unknown_time_zero':'phone_time_upper',core:core(x),canonical:canonical(core(x)),utf8Bytes:Buffer.byteLength(canonical(core(x)),'utf8'),sha256:digest(x)}))};
}
module.exports={CONTRACT,validateSubmit,validateLookup,core,canonical,digest,dependencies,checkReceipt,vectors};
if(require.main===module){
 const fs=require('node:fs'),path=require('node:path');
 const file=path.resolve(__dirname,'../../contract-review/manual-result-0.1.fixtures.json');
 fs.writeFileSync(file,JSON.stringify(vectors(),null,2)+'\n');console.log('Generated synthetic proposal fixtures: '+file);
}
