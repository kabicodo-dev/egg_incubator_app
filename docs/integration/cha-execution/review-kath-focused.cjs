// Read-only input analysis; writes documentation evidence only. No package installs.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../../..'),dir=path.join(__dirname,'kath-focused-review-inputs');
const source='C:/Users/Mary Charlyn/Downloads/Kath-C02-Provisional-Focused-Review-2026-10-30.md';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const review=fs.readFileSync(source,'utf8');
assert.equal(hash(fs.readFileSync(source)),'4473813552ef21a77fe57296f89fb7843a3b4f1ad19990c3e596b70f66e162e0');
fs.mkdirSync(dir,{recursive:true});
const paths=['docs/C02-provisional-communication-contract.md','docs/C02-provisional.schema.json','docs/C02-provisional.examples.json',
 'docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md','docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md'];
const checks=[];function check(name,fn){fn();checks.push({name,result:'PASSED'});}
const inputs=paths.map(p=>{
 const file=path.basename(p),expected=review.match(new RegExp('\\| '+file.replace(/[.*+?^${}()|[\]\\]/g,'\\$&')+' \\| `([a-f0-9]{64})`'))?.[1];
 assert(expected,'Missing reviewed fingerprint '+file);
 const snapshot=path.join(dir,file);
 if(!fs.existsSync(snapshot)){const b=fs.readFileSync(path.join(root,p));assert.equal(hash(b),expected);fs.writeFileSync(snapshot,b);}
 assert.equal(hash(fs.readFileSync(snapshot)),expected);
 return {path:p,reviewedSha256:expected,snapshot:path.relative(root,snapshot).replace(/\\/g,'/'),currentSha256:hash(fs.readFileSync(path.join(root,p)))};
});
const saved=path.join(dir,path.basename(source));
if(fs.existsSync(saved))assert.equal(hash(fs.readFileSync(saved)),hash(fs.readFileSync(source)));else fs.copyFileSync(source,saved);
check('supplied review fingerprint and all five reviewed input snapshots match',()=>assert.equal(inputs.length,5));
const examples=JSON.parse(fs.readFileSync(path.join(root,paths[2]),'utf8')).examples;
const sizes=examples.map(e=>({name:e.name,contentBytes:Buffer.byteLength(JSON.stringify(e.message),'utf8'),withLF:Buffer.byteLength(JSON.stringify(e.message)+'\n','utf8')}));
check('all fourteen reported UTF-8 content and LF byte counts independently reproduced',()=>{
 assert.equal(sizes.length,14);
 for(const s of sizes){const row=review.match(new RegExp('\\| '+s.name+' \\| (\\d+) \\| (\\d+) \\|'));assert(row,s.name);assert.equal(s.contentBytes,+row[1]);assert.equal(s.withLF,+row[2]);}
});
check('all three command fixtures exceed the reported 119-byte incoming-content bound',()=>{
 const commands=sizes.filter(s=>s.name.startsWith('command-'));assert.equal(commands.length,3);
 assert(commands.every(s=>s.contentBytes>119));assert.equal(commands.find(s=>s.name==='command-start').contentBytes,314);
});
check('review explicitly distinguishes proposed positions and parser probe from full schema validation',()=>{
 for(const s of ['not a signature or approval','No new full JSON Schema validation was run','Prepared for Kath','Proposed concrete local decisions'])assert(review.includes(s));
});
check('review carries result-save guard and no physical Start replay boundaries',()=>{
 for(const s of ['Result alone leaves existing cloud Active guard intact','unknown completion time remains null','No concrete amended API/result event/schema/plugin is approved','never authorizes automatic retransmission of physical'])assert(review.includes(s));
});
const result={reviewSource:source,reviewSha256:hash(fs.readFileSync(source)),inputs,sizes,checks,
 scope:'Independent SHA-256/JSON syntax and byte-count reproduction only. Kath Dart parser probe is attributed, not rerun. No full JSON Schema/Flutter/firmware/cloud/hardware test performed.'};
fs.writeFileSync(path.join(__dirname,'kath-focused-review-validation.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({inputs:inputs.length,checks,sizes:sizes.filter(s=>s.name.startsWith('command-'))},null,2));
