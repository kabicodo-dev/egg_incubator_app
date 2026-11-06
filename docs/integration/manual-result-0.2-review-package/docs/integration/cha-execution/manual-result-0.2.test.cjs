// Exact 0.2 candidate shape and parsed-object oracle checks; no live API/store.
const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const Ajv=require('ajv/dist/2020').default,addFormats=require('ajv-formats');
const root=path.resolve(__dirname,'../../..'),dir=path.join(root,'docs/contract-review/manual-result-0.2-review');
const ref=require(path.join(dir,'reference.cjs')),fixtures=JSON.parse(fs.readFileSync(path.join(dir,'fixtures.json'),'utf8'));
const schema=JSON.parse(fs.readFileSync(path.join(dir,'schema.json'),'utf8'));
const ajv=new Ajv({allErrors:true,strict:true,strictTypes:false,strictRequired:false});addFormats(ajv);const validate=ajv.compile(schema);
const s=fixtures.requests.unknown_time_zero,l=fixtures.requests.lookup,c=fixtures.context,r=fixtures.responses.recorded,found=fixtures.responses.found;
const clone=structuredClone;const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const ok=x=>assert.equal(validate(x),true,JSON.stringify(validate.errors));
const bad=x=>assert.equal(validate(x),false,'unexpected shape acceptance');
const guard=x=>ref.checkLookupResponse(x,l,s,c);

test('0.2 standard 2020-12 schema meta-validates and compiles',()=>assert.equal(ajv.validateSchema(schema),true));
test('all nine synthetic request/response shapes pass candidate schema',()=>{
 const xs=[...Object.values(fixtures.requests),...Object.values(fixtures.responses)];assert.equal(xs.length,9);xs.forEach(ok);
});
test('exact generated fixture/core/byte/hash output is deterministic',()=>{
 assert.deepEqual(fixtures,ref.vectors());for(const v of fixtures.hashVectors){assert.equal(Buffer.byteLength(v.canonical,'utf8'),v.utf8Bytes);assert.equal(hash(Buffer.from(v.canonical,'utf8')),v.sha256);assert.deepEqual(JSON.parse(v.canonical),v.core);}
});
test('four original 0.1 input fingerprints remain unchanged',()=>{
 const m=JSON.parse(fs.readFileSync(path.join(dir,'parent-and-change-manifest.json'),'utf8'));assert.equal(Object.keys(m.parents).length,4);
 for(const [p,h] of Object.entries(m.parents))assert.equal(hash(fs.readFileSync(path.join(root,p))),h);
});
test('wrong contract/version cannot fall back to 0.1 request or receipt semantics',()=>{
 for(const x of [...Object.values(fixtures.requests),...Object.values(fixtures.responses)])bad({...clone(x),contract:'DB02-MANUAL-RESULT-0.1-review'});
 assert.throws(()=>ref.validateSubmit({...clone(s),api_version:1}));assert.throws(()=>ref.validateSubmit({...clone(s),contract:'DB02-MANUAL-RESULT-0.1-review'}));
});
test('every error code permits only its exact retryability and commit-state combination',()=>{
 const codes=schema.$defs.errorResponse.allOf[1].properties.error.properties.code.enum;assert.equal(codes.length,13);
 for(const code of codes)for(const retryable of [false,true])for(const commit_status of ['unknown','not_persisted']){
  const x={...clone(fixtures.responses.unknown_commit),error:{code,retryable,commit_status}};
  const good=retryable===['SERVICE_UNAVAILABLE','COMMIT_UNKNOWN'].includes(code)&&commit_status===(code==='COMMIT_UNKNOWN'?'unknown':'not_persisted');
  assert.equal(validate(x),good,JSON.stringify(x.error));if(good)assert(ref.checkErrorResponse(x));else assert.throws(()=>ref.checkErrorResponse(x));
 }
});
test('unknown malformed or contradictory error never passes the test-only guard',()=>{
 const e=fixtures.responses.not_authorized;
 for(const x of [{...clone(e),error:{...e.error,code:'OTHER'}},{...clone(e),error:{...e.error,retryable:'false'}},{...clone(e),error:{...e.error,commit_status:'unknown'}},{...clone(e),extra:true}])assert.throws(()=>ref.checkErrorResponse(x));
 for(const key of Object.keys(e)){const x=clone(e);delete x[key];assert.throws(()=>ref.checkErrorResponse(x));}
 for(const key of Object.keys(e.error)){const x=clone(e);delete x.error[key];assert.throws(()=>ref.checkErrorResponse(x));}
});
test('lookup found/absent passes only with explicit matching receipt presence',()=>{
 assert(guard(found));assert(guard(fixtures.responses.absent));
 for(const x of [{...clone(found),receipt:null},{...clone(fixtures.responses.absent),receipt:r}])assert.throws(()=>guard(x));
 const missing=clone(fixtures.responses.absent);delete missing.receipt;assert.throws(()=>guard(missing));
});
for(const key of ['device_id','batch_id','actor_installation_id','result_id']){
 test('outer '+key+' must match outstanding lookup/original, beyond shape',()=>{
  const x=clone(found);x[key]='ffffffff-ffff-4fff-8fff-ffffffffffff';ok(x);assert.throws(()=>guard(x));
 });
 test('nested '+key+' must match both outer and original tuple, beyond shape',()=>{
  const x=clone(found);x.receipt[key]='ffffffff-ffff-4fff-8fff-ffffffffffff';ok(x);assert.throws(()=>guard(x));
 });
}
test('lookup cannot be matched to a different locally retained original action',()=>{
 const other={...clone(s),result_id:'ffffffff-ffff-4fff-8fff-ffffffffffff'};assert.throws(()=>ref.checkLookupResponse(found,l,other,c));
});
test('hash manifest count and original quantity mismatches cannot mark result recorded',()=>{
 for(const [key,value] of [['content_sha256','0'.repeat(64)],['original_manifest_sha256','b'.repeat(64)],['eggs_hatched',1],['egg_quantity',11]]){const x=clone(found);x.receipt[key]=value;ok(x);assert.throws(()=>guard(x));}
});
test('session mapping remains lossless and bounded, rejecting wrong/null/numeric/overflow values',()=>{
 assert(guard(found));assert.equal(r.session_id,'9007199254740993');
 for(const value of ['2',null,9007199254740992,'9223372036854775808']){const x=clone(found);x.receipt.session_id=value;assert.throws(()=>guard(x));}
});
test('retained receipt ID and first receive-time are immutable across lookup replies',()=>{
 assert(ref.checkLookupResponse(found,l,s,c,r));
 for(const [key,value] of [['receipt_id','ffffffff-ffff-4fff-8fff-ffffffffffff'],['received_at','2026-10-30T00:00:01Z']]){const x=clone(found);x.receipt[key]=value;ok(x);assert.throws(()=>ref.checkLookupResponse(x,l,s,c,r));}
});
test('missing receipt identity/time or unapproved lifecycle/admission/release fields fail',()=>{
 for(const key of ['receipt_id','received_at']){const x=clone(found);delete x.receipt[key];assert.throws(()=>guard(x));}
 for(const [key,value] of [['receipt_revision',2],['outcome','applied'],['lifecycle_effect','Completed'],['physical_admission_effect','allowed'],['retention_ack',true]]){const x=clone(found);x.receipt[key]=value;assert.throws(()=>guard(x));}
});
test('closed schema, original count and strict original time rules remain in effect',()=>{
 for(const eggs_hatched of [-1,1.5,'1',true])bad({...clone(s),eggs_hatched});
 for(const value of ['2026-02-30T00:00:00Z','2026-10-30T00:00:00.1Z'])bad({...clone(s),action_time:{value,provenance:'phone_clock'}});
 bad({...clone(s),stopped_event_id:null});assert.throws(()=>ref.dependencies({...clone(s),eggs_hatched:13},c));
});
test('alternative same-identity vectors differ in content, not two sequential accepted results',()=>{
 const a=fixtures.requests.unknown_time_zero,b=fixtures.requests.phone_time_upper;assert.equal(a.result_id,b.result_id);assert.equal(a.actor_installation_id,b.actor_installation_id);
 assert.notEqual(ref.digest(a),ref.digest(b));assert.equal(fixtures.scenarioRelationship.sequentialChangedContentExpected,'IDENTITY_CONTENT_CONFLICT');
});
test('draft reservation example reuses original identity; no durable transaction is claimed',()=>{
 assert.equal(fixtures.draftIdentity.reservedAtFirstDurableDraft,fixtures.draftIdentity.reusedAtSeal);assert(fixtures.draftIdentity.classification.includes('not a durable transaction'));
 const p=fs.readFileSync(path.join(root,'docs/contract-review/D04_D06_Mary_Backend_Position.md'),'utf8');assert(p.includes('yes i approve that specific rule'));assert(p.includes('Do not ask Mary to confirm M08 again'));
});
test('new contract produces new digests, not silent migration of reviewed 0.1 evidence',()=>{
 const old=JSON.parse(fs.readFileSync(path.join(root,'docs/contract-review/manual-result-0.1.fixtures.json'),'utf8'));
 for(let i=0;i<old.hashVectors.length;i++){assert.notEqual(fixtures.hashVectors[i].sha256,old.hashVectors[i].sha256);assert.equal(fixtures.hashVectors[i].core.result_id,old.hashVectors[i].core.result_id);}
});
test('local guards do not mutate input/session or claim authentication and actual-case completion',()=>{
 const before=JSON.stringify(fixtures);guard(found);ref.checkErrorResponse(fixtures.responses.unknown_commit);assert.equal(JSON.stringify(fixtures),before);assert.equal(c.session.status,'Active');
 const cases=JSON.parse(fs.readFileSync(path.join(root,'docs/contract-review/manual-result-0.1.closure-matrix.json'),'utf8')).cases;assert(cases.every(x=>x.status==='NOT RUN'));
});
test('0.2 schema closes known authorization-retry gap without rewriting 0.1',()=>{
 const oldSchema=JSON.parse(fs.readFileSync(path.join(root,'docs/contract-review/manual-result-0.1.schema.json'),'utf8'));
 const oldAjv=new Ajv({allErrors:true,strict:true,strictTypes:false,strictRequired:false});addFormats(oldAjv);const oldValidate=oldAjv.compile(oldSchema);
 const oldFixtures=JSON.parse(fs.readFileSync(path.join(root,'docs/contract-review/manual-result-0.1.fixtures.json'),'utf8'));
 const old={...clone(oldFixtures.responses.unknown_commit),error:{code:'NOT_AUTHORIZED',retryable:true,commit_status:'not_persisted'}};
 assert.equal(oldValidate(old),true);bad({...old,contract:ref.CONTRACT});
});
