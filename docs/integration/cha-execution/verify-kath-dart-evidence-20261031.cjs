// Integrity/provenance verification only. Does NOT execute received Dart code or
// reinterpret recorded console text as a newly captured test run.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../../..'),input=process.argv[2];assert(input,'Pass isolated extracted evidence directory');
const zip='C:/Users/Mary Charlyn/Downloads/Kath-Existing-Dart-Review-Evidence-2026-10-31.zip';
const mapping='C:/Users/Mary Charlyn/Downloads/TASK_CARD_MAPPING.md';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
assert.equal(hash(fs.readFileSync(zip)),'36b8bd63ad57de090ea6a22480028a22c7d57f4b088c18db57b1999c14105961');
const manifest=JSON.parse(fs.readFileSync(path.join(input,'manifest.json'),'utf8').replace(/^\uFEFF/,''));
const allowed=['dart_manual_result_review.dart','dart_manual_result_review.recorded-stdout.txt','manifest.json','README.md','TASK_CARD_MAPPING.md'];
assert.deepEqual(fs.readdirSync(input).sort(),[...allowed].sort());
const checks=[];function check(name,fn){fn();checks.push({name,result:'PASSED'});}
check('all four declared file hashes/sizes match supplied bytes',()=>{
 assert.equal(manifest.files.length,4);assert.equal(new Set(manifest.files.map(f=>f.file)).size,4);
 for(const f of manifest.files){assert(allowed.includes(f.file)&&f.file!=='manifest.json');const b=fs.readFileSync(path.join(input,f.file));assert.equal(b.length,f.bytes);assert.equal(hash(b),f.sha256);}
});
const script=fs.readFileSync(path.join(input,'dart_manual_result_review.dart'));
check('delivered Dart script matches exact hash previously reported by Kath',()=>assert.equal(hash(script),'bcb7ab832eabd97092e6d22a983910cd4e32288e5777f3cd79adbbd1ee57b45e'));
check('standalone task mapping is byte-identical to ZIP copy',()=>assert.equal(hash(fs.readFileSync(mapping)),hash(fs.readFileSync(path.join(input,'TASK_CARD_MAPPING.md')))));
const stdout=fs.readFileSync(path.join(input,'dart_manual_result_review.recorded-stdout.txt'),'utf8').replace(/^\uFEFF/,'');
const readme=fs.readFileSync(path.join(input,'README.md'),'utf8');
check('recorded console export consistently contains 41 PASS lines and both known vectors',()=>{
 assert.equal((stdout.match(/^PASS /gm)||[]).length,41);assert(stdout.includes('REVIEW-ONLY PASS checks=41; vectors=2;'));
 const f=JSON.parse(fs.readFileSync(path.join(root,'docs/contract-review/manual-result-0.1.fixtures.json'),'utf8'));
 for(const v of f.hashVectors){assert(stdout.includes('VECTOR '+v.name+': '+v.utf8Bytes+' '+v.sha256));assert.equal(hash(Buffer.from(v.canonical,'utf8')),v.sha256);}
});
check('stdout provenance is expressly a retained-console export, not an original captured log or rerun',()=>{
 assert(readme.includes('no separately saved original stdout file'));assert(readme.includes('without a repeat run'));
 assert(manifest.stdout_provenance.includes('not a separately captured original stdout file'));
});
check('review receipt clears task-card availability but does not claim adoption/acceptance execution',()=>{
 const text=fs.readFileSync(mapping,'utf8');
 for(const s of ['All **34 task cards** are accessible','102 unique cases, all NOT RUN','Receipt does not constitute formal adoption','No acceptance case or whole task was marked Completed'])assert(text.includes(s));
});
const dest=path.join(__dirname,'received-kath-dart-20261031');fs.mkdirSync(dest,{recursive:true});
const snapshots=[];
for(const file of allowed){const b=fs.readFileSync(path.join(input,file)),to=path.join(dest,file);if(fs.existsSync(to))assert.equal(hash(fs.readFileSync(to)),hash(b),'Do not overwrite changed evidence');else fs.writeFileSync(to,b);snapshots.push({file:path.relative(root,to).replace(/\\/g,'/'),bytes:b.length,sha256:hash(b)});}
const result={received:'2026-10-31',zip,zipSha256:hash(fs.readFileSync(zip)),mappingSha256:hash(fs.readFileSync(mapping)),checks,snapshots,
 scriptStatus:'DELIVERED and hash verified; not executed by this verification',
 stdoutStatus:'DELIVERED export from original session console; NOT independently captured original stdout and NOT rerun here',
 deliveryStatus:'Kath acknowledges actual full 79-file packet, all 34 task cards, 102 NOT RUN cases and architecture amendment availability; not other-recipient distribution/adoption',
 newFullTaskCompletions:[],taskStatusChanges:[]};
fs.writeFileSync(path.join(__dirname,'kath-dart-evidence-20261031-verification.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({checks,scriptStatus:result.scriptStatus,stdoutStatus:result.stdoutStatus,taskStatusChanges:[]},null,2));
