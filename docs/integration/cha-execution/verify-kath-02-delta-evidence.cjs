// Read/hash/provenance checks only. Does not execute supplied Dart/PowerShell.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../../..'),input=process.argv[2];assert(input,'Pass isolated extracted evidence directory');
const zip='C:/Users/Mary Charlyn/Downloads/Kath-Manual-Result-02-Delta-Review-2026-10-31.zip';
const responsePath='C:/Users/Mary Charlyn/Downloads/RESPONSE.md';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const read=p=>fs.readFileSync(p,'utf8').replace(/^\uFEFF/,'');
assert.equal(hash(fs.readFileSync(zip)),'09706f63c6759825b298404b0c2afb6d1f511e69d440e2bdabf731a4adb5a274');
const m=JSON.parse(read(path.join(input,'evidence-manifest.json'))),response=read(responsePath);
const allowed=['dart-version.stderr.txt','dart-version.stdout.txt','dart.stderr.txt','dart.stdout.txt','dart_manual_result_02_review.dart','evidence-manifest.json','inputs.stderr.txt','inputs.stdout.txt','node.stderr.txt','node.stdout.txt','RESPONSE.md','verify_inputs.ps1'];
assert.deepEqual(fs.readdirSync(input).sort(),[...allowed].sort());
const checks=[];function check(name,fn){fn();checks.push({name,result:'PASSED'});}
check('eleven declared evidence hashes and sizes match all delivered non-manifest files',()=>{
 assert.equal(m.files.length,11);assert.equal(new Set(m.files.map(f=>f.file)).size,11);
 for(const f of m.files){assert(allowed.includes(f.file)&&f.file!=='evidence-manifest.json');const b=fs.readFileSync(path.join(input,f.file));assert.equal(b.length,f.bytes);assert.equal(hash(b),f.sha256);}
});
check('standalone response matches ZIP copy and exact source review',()=>{
 assert.equal(hash(fs.readFileSync(responsePath)),'0286f8ed0b32047eb4685b891d103417592f18fa443f54e06ca12970c3f789d0');
 assert.equal(hash(fs.readFileSync(responsePath)),hash(fs.readFileSync(path.join(input,'RESPONSE.md'))));
});
const packageDir=path.join(root,'docs/integration/manual-result-0.2-review-package');
const packageManifest=JSON.parse(read(path.join(packageDir,'manifest.json')));
const inputsLog=read(path.join(input,'inputs.stdout.txt'));
check('exact input ZIP/manifest and all seventeen snapshot entries match captured input verification',()=>{
 assert.equal(hash(fs.readFileSync(path.join(root,'SmartHatch_Manual_Result_0.2_Review.zip'))),m.inputZipSha256);
 const mh=hash(fs.readFileSync(path.join(packageDir,'manifest.json')));assert(response.includes(mh));assert(inputsLog.includes(mh));assert.equal(packageManifest.files.length,17);
 for(const f of packageManifest.files){assert.equal(hash(fs.readFileSync(path.join(packageDir,f.file))),f.sha256);assert(inputsLog.includes('PASS '+f.file+' bytes='+f.bytes+' sha256='+f.sha256));}
});
const names={
 'DB-02_Manual_Result_API_0.2-review.md':'docs/contract-review/DB-02_Manual_Result_API_0.2-review.md',
 'manual-result-0.2-review/schema.json':'docs/contract-review/manual-result-0.2-review/schema.json',
 'manual-result-0.2-review/fixtures.json':'docs/contract-review/manual-result-0.2-review/fixtures.json',
 'manual-result-0.2-review/reference.cjs':'docs/contract-review/manual-result-0.2-review/reference.cjs',
 'manual-result-0.2.test.cjs':'docs/integration/cha-execution/manual-result-0.2.test.cjs'
};
check('five exact reviewed delta inputs and all four 0.1 parents remain unchanged',()=>{
 for(const [name,p] of Object.entries(names)){const line=response.split(/\r?\n/).find(l=>l.startsWith('| '+name+' |'));assert(line,name);assert(line.includes(hash(fs.readFileSync(path.join(root,p)))));}
 const manifest=JSON.parse(read(path.join(root,'docs/contract-review/manual-result-0.2-review/parent-and-change-manifest.json')));
 for(const [p,h] of Object.entries(manifest.parents))assert.equal(hash(fs.readFileSync(path.join(root,p))),h);
});
const dartLog=read(path.join(input,'dart.stdout.txt'));
check('captured Dart output has 106 PASS lines and exact full current canonical strings/vectors',()=>{
 assert.equal(m.exitCodes.dart,0);assert.equal((dartLog.match(/^PASS /gm)||[]).length,106);assert(dartLog.includes('REVIEW-ONLY PASS checks=106 vectors=2; implementation acceptance NOT RUN'));
 const f=JSON.parse(read(path.join(root,names['manual-result-0.2-review/fixtures.json'])));
 for(const v of f.hashVectors){assert(dartLog.includes('CANONICAL '+v.name+' '+v.canonical));assert(dartLog.includes('VECTOR '+v.name+' '+v.utf8Bytes+' '+v.sha256));assert.equal(Buffer.byteLength(v.canonical,'utf8'),v.utf8Bytes);assert.equal(hash(Buffer.from(v.canonical,'utf8')),v.sha256);}
});
check('Kath Node attempt remains correctly recorded as missing tooling, not a passing or failing candidate case',()=>{
 const log=read(path.join(input,'node.stdout.txt'));assert.equal(m.exitCodes.node,1);assert(log.includes("Cannot find module 'ajv/dist/2020'"));assert(log.includes('MODULE_NOT_FOUND'));assert(log.includes('# pass 0'));
});
check('independent local exact Node candidate suite rerun passed all 27 tests',()=>{
 const log=read(path.join(__dirname,'manual-result-0.2-local-recheck-20261031.tap'));
 for(const line of ['# tests 27','# pass 27','# fail 0','# skipped 0','# cancelled 0'])assert(log.split(/\r?\n/).includes(line));
});
check('scoped ACCEPT review has no requested replacement and all actual implementation cases stay NOT RUN',()=>{
 assert(response.includes('No additional candidate text replacement is requested'));
 assert(response.includes('newly captured directly during execution'));assert(m.scope.includes('new directly captured process logs'));
 const impl=JSON.parse(read(path.join(root,'docs/contract-review/manual-result-0.1.closure-matrix.json'))).cases;
 const portfolio=JSON.parse(read(path.join(root,'docs/integration/remaining-task-workqueue/planned-test-records.json'))).cases;
 assert.equal(impl.length,24);assert.equal(portfolio.length,102);assert([...impl,...portfolio].every(c=>c.status==='NOT RUN'));
});
const dest=path.join(__dirname,'received-kath-02-20261031');fs.mkdirSync(dest,{recursive:true});const snapshots=[];
for(const file of allowed){const b=fs.readFileSync(path.join(input,file)),to=path.join(dest,file);if(fs.existsSync(to))assert.equal(hash(fs.readFileSync(to)),hash(b),'Preserve changed evidence');else fs.writeFileSync(to,b);snapshots.push({path:path.relative(root,to).replace(/\\/g,'/'),bytes:b.length,sha256:hash(b)});}
const result={received:'2026-10-31',zipSha256:hash(fs.readFileSync(zip)),responseSha256:hash(fs.readFileSync(responsePath)),checks,snapshots,
 reviewStatus:'SCOPED DELTA ACCEPT; no further text replacement requested; not a signature/implementation permission',
 dartEvidence:'Delivered source and newly captured logs report 106 review assertions; checked for integrity/consistency, not rerun here',
 nodeEvidence:{kath:'Tooling-blocked before suite cases: ajv unavailable',mary:'Fresh exact suite rerun with already-installed temporary tooling: 27/27 passes; no install'},
 newFullTaskCompletions:[],taskStatusChanges:[]};
fs.writeFileSync(path.join(__dirname,'kath-02-delta-evidence-verification.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({checks,reviewStatus:result.reviewStatus,nodeEvidence:result.nodeEvidence,newFullTaskCompletions:[]},null,2));
