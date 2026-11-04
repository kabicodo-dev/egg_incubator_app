const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const ref=require('./manual-result-reference.cjs');
const fixtures=JSON.parse(fs.readFileSync(path.resolve(__dirname,'../../contract-review/manual-result-0.1.fixtures.json'),'utf8'));
const original=fixtures.requests.unknown_time_zero,ctx=fixtures.context,copy=structuredClone;
test('published synthetic fixtures reproduce exact closed input and output snapshots',()=>assert.deepEqual(fixtures,ref.vectors()));
test('zero and original-quantity upper bound pass pure local dependency checks',()=>{
 for(const x of [original,fixtures.requests.phone_time_upper]){assert(ref.validateSubmit(x));assert(ref.dependencies(x,ctx));}
});
test('negative fractional string Boolean and over-original counts are rejected locally',()=>{
 for(const n of [-1,1.5,'1',true,13,2147483648])assert.throws(()=>ref.dependencies({...copy(original),eggs_hatched:n},ctx));
});
test('exact no-Stop request rejects legacy dependency and lifecycle/physical command fields',()=>{
 for(const field of ['stopped_event_id','wire_evidence','command_id','status','start','session_id'])assert.throws(()=>ref.validateSubmit({...copy(original),[field]:null}));
});
test('old version or unknown contract cannot silently use proposal semantics',()=>{
 assert.throws(()=>ref.validateSubmit({...copy(original),api_version:1}));assert.throws(()=>ref.validateSubmit({...copy(original),contract:'other'}));
});
test('UUID lexemes are lossless and reject legacy numeric identities',()=>{
 for(const key of ['installation_id','device_id','batch_id','actor_installation_id','result_id'])assert.throws(()=>ref.validateSubmit({...copy(original),[key]:7001}));
});
test('unknown original action time stays null; no false phone/controller provenance',()=>{
 for(const time of [{value:null,provenance:'phone_clock'},{value:'2026-10-30T00:00:00Z',provenance:'unknown'},{value:'2026-10-30T00:00:00Z',provenance:'controller_clock'}])assert.throws(()=>ref.validateSubmit({...copy(original),action_time:time}));
 assert.equal(ref.core(original).action_time.value,null);
});
test('invalid calendar dates and fractional timestamp input fail rather than silently rounding',()=>{
 for(const value of ['2026-02-30T00:00:00Z','2026-10-30T00:00:00.123Z'])assert.throws(()=>ref.validateSubmit({...copy(original),action_time:{value,provenance:'phone_clock'}}));
});
test('missing manifest or real mapping is not a fabricated validated result',()=>{
 assert.throws(()=>ref.dependencies(original,{}),/MANIFEST_REQUIRED/);
 assert.throws(()=>ref.dependencies(original,{manifest:ctx.manifest}),/BATCH_MAPPING_REQUIRED/);
});
test('original manifest controller batch actor and digest mismatches fail local comparison',()=>{
 for(const key of ['device_id','batch_id','actor_installation_id','sha256']){
  const c=copy(ctx);c.manifest[key]=key==='sha256'?'b'.repeat(64):'ffffffff-ffff-4fff-8fff-ffffffffffff';assert.throws(()=>ref.dependencies(original,c),/MANIFEST_CONFLICT/);
 }
});
test('zero original quantity and unknown quantity cannot validate counts',()=>{
 for(const egg_quantity of [0,null,undefined])assert.throws(()=>ref.dependencies(original,{...copy(ctx),manifest:{...ctx.manifest,egg_quantity}}));
});
test('new result fixture cannot reopen a non-Active session',()=>{
 for(const status of ['Completed',null,'Stopped'])assert.throws(()=>ref.dependencies(original,{...copy(ctx),session:{...ctx.session,status}}),/LIFECYCLE_CONFLICT/);
});
test('canonical order and exact same content reproduce both published digests',()=>{
 for(const v of fixtures.hashVectors){const reversed=Object.fromEntries(Object.entries(v.core).reverse());assert.equal(ref.canonical(reversed),v.canonical);assert.equal(Buffer.byteLength(v.canonical,'utf8'),v.utf8Bytes);}
 assert.equal(ref.digest(original),fixtures.hashVectors[0].sha256);assert.equal(ref.digest(fixtures.requests.phone_time_upper),fixtures.hashVectors[1].sha256);
});
test('current uploader replacement does not rewrite original actor content digest',()=>{
 const changed={...copy(original),installation_id:'33333333-3333-4333-8333-333333333333'};
 assert.equal(ref.digest(changed),ref.digest(original)); // Does NOT authorize that replacement.
 assert.notEqual(ref.digest({...changed,actor_installation_id:changed.installation_id}),ref.digest(original));
});
test('count manifest batch result identity and original phone time changes alter digest',()=>{
 for(const [key,value] of [['eggs_hatched',1],['original_manifest_sha256','b'.repeat(64)],['batch_id','cccccccc-cccc-4ccc-8ccc-cccccccccccc'],['result_id','cccccccc-cccc-4ccc-8ccc-cccccccccccc'],['action_time',{value:'2026-10-30T00:00:00Z',provenance:'phone_clock'}]])assert.notEqual(ref.digest({...copy(original),[key]:value}),ref.digest(original));
});
test('bigint mapping remains string beyond JavaScript safe-number range; overflow is rejected',()=>{
 assert.equal(fixtures.responses.recorded.session_id,'9007199254740993');assert(ref.checkReceipt(fixtures.responses.recorded,original,ctx));
 for(const id of [9007199254740992,'9223372036854775808','01'])assert.throws(()=>ref.dependencies(original,{...copy(ctx),session:{id,status:'Active'}}));
});
test('receipt identity count hash mapping fixed effects and retention must all match',()=>{
 for(const [key,value] of [['eggs_hatched',1],['content_sha256','0'.repeat(64)],['session_id','2'],['lifecycle_effect','Completed'],['physical_admission_effect','allowed'],['retention_ack',true],['receipt_revision',2]])assert.throws(()=>ref.checkReceipt({...copy(fixtures.responses.recorded),[key]:value},original,ctx));
});
test('an immutable receipt cannot silently acquire a new ID or first receive time on replay',()=>{
 const r=fixtures.responses.recorded;assert(ref.checkReceipt(copy(r),original,ctx,r));
 for(const [key,value] of [['receipt_id','ffffffff-ffff-4fff-8fff-ffffffffffff'],['received_at','2026-10-30T00:00:01Z']])assert.throws(()=>ref.checkReceipt({...copy(r),[key]:value},original,ctx,r));
});
test('read-only lookup carries original namespace without count command or desired status',()=>{
 assert(ref.validateLookup(fixtures.requests.lookup));
 for(const field of ['eggs_hatched','stopped_event_id','status','START'])assert.throws(()=>ref.validateLookup({...copy(fixtures.requests.lookup),[field]:0}));
});
test('reference checks do not mutate fixture inputs or session Active status',()=>{
 const before=JSON.stringify(fixtures);ref.dependencies(original,ctx);ref.checkReceipt(fixtures.responses.recorded,original,ctx);ref.digest(original);
 assert.equal(JSON.stringify(fixtures),before);assert.equal(ctx.session.status,'Active');
});
test('schema parses and closure plan is not misreported as executed integration',()=>{
 const schema=JSON.parse(fs.readFileSync(path.resolve(__dirname,'../../contract-review/manual-result-0.1.schema.json'),'utf8'));assert.equal(schema.$schema,'https://json-schema.org/draft/2020-12/schema');
 const matrix=JSON.parse(fs.readFileSync(path.resolve(__dirname,'../../contract-review/manual-result-0.1.closure-matrix.json'),'utf8'));
 assert(matrix.cases.length>=20);assert(matrix.cases.every(c=>c.status==='NOT RUN'));assert.equal(new Set(matrix.cases.map(c=>c.id)).size,matrix.cases.length);
});
