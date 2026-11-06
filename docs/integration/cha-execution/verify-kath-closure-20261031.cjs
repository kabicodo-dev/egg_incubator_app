// Received-document/hash evidence checks only, not a repeat of Kath's Dart run.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../../..');
const source='C:/Users/Mary Charlyn/Downloads/Kath-Remaining-Task-Closure-Response-2026-10-31.md';
const bytes=fs.readFileSync(source),text=bytes.toString('utf8');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
assert.equal(hash(bytes),'8e542cb82b9197fa5605c1b8ee32a729dc2c696906b6c27085e45dbf9e1da5b6');
const inputs={
 W:'docs/integration/remaining-task-workqueue/REMAINING_DECISIONS_ALL_OWNERS.md',
 R:'docs/integration/remaining-task-workqueue/README.md',
 A:'docs/contract-review/DB-02_Manual_Result_API_0.1-review.md',
 S:'docs/contract-review/manual-result-0.1.schema.json',
 F:'docs/contract-review/manual-result-0.1.fixtures.json',
 C:'docs/contract-review/manual-result-0.1.closure-matrix.json'
};
const checks=[];function check(name,fn){fn();checks.push({name,result:'PASSED'});}
const inputMatches=Object.entries(inputs).map(([alias,p])=>{
 const declared=text.match(new RegExp('\\| '+alias+' \\| [^\\n]+?`([a-f0-9]{64})`'))?.[1];assert(declared,alias);
 const actual=hash(fs.readFileSync(path.join(root,p)));assert.equal(actual,declared,p);return {alias,path:p,sha256:actual};
});
check('all six exact reviewed input fingerprints match current referenced artifacts',()=>assert.equal(inputMatches.length,6));
const fixtures=JSON.parse(fs.readFileSync(path.join(root,inputs.F),'utf8'));
check('both reported Dart vector byte lengths and digests match independent local UTF-8 hashing',()=>{
 for(const v of fixtures.hashVectors){assert(text.includes(v.name+': '+v.utf8Bytes+' UTF-8 bytes'));assert(text.includes(v.sha256));assert.equal(Buffer.byteLength(v.canonical,'utf8'),v.utf8Bytes);assert.equal(hash(Buffer.from(v.canonical,'utf8')),v.sha256);assert.deepEqual(JSON.parse(v.canonical),v.core);}
});
check('Dart work remains reported review-only subcriterion, not whole MR-15 acceptance',()=>{
 for(const x of ['41 review assertions passed','MR-15 subcriterion only','not general JCS','not a server/database/raw-parser/Auth test'])assert(text.includes(x));
 const closure=JSON.parse(fs.readFileSync(path.join(root,inputs.C),'utf8'));assert.equal(closure.cases.length,24);assert(closure.cases.every(c=>c.status==='NOT RUN'));
});
check('existing full workqueue really has 34 cards and 102 NOT RUN acceptance cases',()=>{
 const dir=path.join(root,'docs/integration/remaining-task-workqueue');
 assert.equal(fs.readdirSync(path.join(dir,'tasks')).filter(p=>p.endsWith('.md')).length,34);
 const cases=JSON.parse(fs.readFileSync(path.join(dir,'planned-test-records.json'),'utf8')).cases;assert.equal(cases.length,102);assert(cases.every(c=>c.status==='NOT RUN'));
});
const observations=JSON.parse(fs.readFileSync(path.join(__dirname,'portfolio-source-observations.json'),'utf8'));
check('same service source confirmed; differing main.dart snapshot is not a global fix',()=>{
 assert(text.includes(observations.sourceFingerprints['lib/services/supabase_service.dart']));
 assert(!text.includes(observations.sourceFingerprints['lib/main.dart']));assert(text.includes('SRC-04 differs locally'));
});
const result={received:'2026-10-31',source,reviewSha256:hash(bytes),inputMatches,checks,
 vectorParity:'Reported independent Dart run agrees with published Node vectors; source script/raw Dart log not attached and not rerun here',
 rawDartScript:{reportedSha256:'bcb7ab832eabd97092e6d22a983910cd4e32288e5777f3cd79adbbd1ee57b45e',delivered:false},
 taskStatusChanges:[],newFullTaskCompletions:[],scope:'Read/hash/byte arithmetic/document-boundary checks only; no implementation/Auth/storage/firmware/device operation'};
fs.writeFileSync(path.join(__dirname,'kath-closure-20261031-verification.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({checks,taskStatusChanges:[],newFullTaskCompletions:[]},null,2));
