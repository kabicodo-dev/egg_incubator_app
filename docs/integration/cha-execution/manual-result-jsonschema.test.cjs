// Standards-validator checks against unchanged proposal bytes. External tooling
// only: Ajv 8 + ajv-formats via NODE_PATH; no dependency installation or runtime API.
const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const Ajv=require('ajv/dist/2020').default,addFormats=require('ajv-formats');
const ref=require('./manual-result-reference.cjs');
const dir=path.resolve(__dirname,'../../contract-review');
const schema=JSON.parse(fs.readFileSync(path.join(dir,'manual-result-0.1.schema.json'),'utf8'));
const fixture=JSON.parse(fs.readFileSync(path.join(dir,'manual-result-0.1.fixtures.json'),'utf8'));
const ajv=new Ajv({allErrors:true,strict:true,strictTypes:false,strictRequired:false});addFormats(ajv);
assert(ajv.validateSchema(schema,true));const validate=ajv.compile(schema);
const clone=structuredClone,submit=fixture.requests.unknown_time_zero,receipt=fixture.responses.recorded;
function valid(x){assert.equal(validate(x),true,JSON.stringify(validate.errors));}
function invalid(x){assert.equal(validate(x),false,'Unexpected schema acceptance: '+JSON.stringify(x));}

test('Ajv 2020-12 meta-validation and compilation succeed on unchanged proposal',()=>assert.equal(ajv.validateSchema(schema),true));
test('all seven published request/response fixture objects pass standards shape validation',()=>{
 const xs=[...Object.values(fixture.requests),...Object.values(fixture.responses)];assert.equal(xs.length,7);xs.forEach(valid);
});
test('submission rejects every missing required top-level field',()=>{
 for(const key of Object.keys(submit)){const x=clone(submit);delete x[key];invalid(x);}
});
test('submission rejects unknown Stop command status mapping or credential fields',()=>{
 for(const key of ['stopped_event_id','command_id','wire_evidence','status','session_id','access_token','START'])invalid({...clone(submit),[key]:null});
});
test('typed count version contract UUID and digest failures are rejected by schema',()=>{
 for(const n of [-1,1.5,'1',true,null,2147483648])invalid({...clone(submit),eggs_hatched:n});
 for(const [key,value] of [['api_version',1],['api_version','2'],['contract','other'],['operation','submit_event'],['batch_id',7001],['result_id','bbbbbbbb-bbbb-1bbb-8bbb-bbbbbbbbbbbb'],['original_manifest_sha256','g'.repeat(64)]])invalid({...clone(submit),[key]:value});
});
test('unknown versus phone-clock time requires exact provenance and a real whole-second UTC date',()=>{
 for(const action_time of [{value:null,provenance:'phone_clock'},{value:'2026-10-30T00:00:00Z',provenance:'unknown'},{value:'2026-02-30T00:00:00Z',provenance:'phone_clock'},{value:'2026-10-30T00:00:00.123Z',provenance:'phone_clock'},{value:'2026-10-30T00:00:00Z',provenance:'controller_clock'},{value:null,provenance:'unknown',valid:true}])invalid({...clone(submit),action_time});
});
test('receipt requires all fields and rejects non-null release lifecycle/admission effects',()=>{
 for(const key of Object.keys(receipt)){const x=clone(receipt);delete x[key];invalid(x);}
 for(const [key,value] of [['retention_ack',true],['lifecycle_effect','Completed'],['physical_admission_effect','allowed'],['receipt_revision',2],['session_id',9007199254740992],['session_id',null],['outcome','applied']])invalid({...clone(receipt),[key]:value});
});
test('found/absent response cannot contradict receipt presence and nested receipt must validate',()=>{
 invalid({...clone(fixture.responses.found),receipt:null});invalid({...clone(fixture.responses.absent),receipt:clone(receipt)});
 const broken=clone(fixture.responses.found);broken.receipt.retention_ack=true;invalid(broken);
});
test('unknown-commit and known-failure commit-status combinations are structurally enforced',()=>{
 const base=fixture.responses.unknown_commit;
 invalid({...clone(base),error:{code:'COMMIT_UNKNOWN',retryable:true,commit_status:'not_persisted'}});
 invalid({...clone(base),error:{code:'COMMIT_UNKNOWN',retryable:false,commit_status:'unknown'}});
 invalid({...clone(base),error:{code:'NOT_AUTHORIZED',retryable:false,commit_status:'unknown'}});
});
test('lookup is closed and never accepts result content or desired physical operation',()=>{
 for(const key of ['eggs_hatched','action_time','START','status','stopped_event_id'])invalid({...clone(fixture.requests.lookup),[key]:null});
});
test('schema alone deliberately cannot prove original quantity bigint range or receipt identity',()=>{
 // These positive shape results are NOT acceptance passes; oracle rejects the
 // relational values. Real runtime implementation/testing remains required.
 const over={...clone(receipt),eggs_hatched:13};valid(over);assert.throws(()=>ref.checkReceipt(over,submit,fixture.context));
 const huge={...clone(receipt),session_id:'9223372036854775808'};valid(huge);assert.throws(()=>ref.checkReceipt(huge,submit,fixture.context));
 const foreign={...clone(receipt),batch_id:'cccccccc-cccc-4ccc-8ccc-cccccccccccc'};valid(foreign);assert.throws(()=>ref.checkReceipt(foreign,submit,fixture.context));
});
test('documents two remaining semantic gaps without mutating or silently upgrading the schema',()=>{
 const wrongLookup=clone(fixture.responses.found);wrongLookup.batch_id='cccccccc-cccc-4ccc-8ccc-cccccccccccc';valid(wrongLookup);
 // A full runtime reconciliation validator must compare outer identity and
 // nested receipt. That validator is not implemented by this schema test.
 const misleading={...clone(fixture.responses.unknown_commit),error:{code:'NOT_AUTHORIZED',retryable:true,commit_status:'not_persisted'}};valid(misleading);
 // Follow error code + approved recovery, never blindly retry authorization.
 // Recommend a future schema revision restricting retryable by code, not
 // replacement of the already-shared 0.1 input bytes in this verification.
});
test('standards checks do not mutate fixtures or turn future implementation cases into passes',()=>{
 const before=JSON.stringify(fixture);Object.values(fixture.requests).forEach(valid);assert.equal(JSON.stringify(fixture),before);
 const matrix=JSON.parse(fs.readFileSync(path.join(dir,'manual-result-0.1.closure-matrix.json'),'utf8'));
 assert.equal(matrix.cases.length,24);assert(matrix.cases.every(c=>c.status==='NOT RUN'));
});
