// Repository placement and integrity checks only. Never edits Downloads sources,
// adopts the amendment, installs dependencies or changes application/database code.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../../..'),downloads='C:/Users/Mary Charlyn/Downloads';
const names=['SmartHatch_K06_Consolidated_17_Decision_Contract_v0.3.md','SmartHatch_K06_Consolidated_17_Decision_Contract_v0.4_Bluetooth_Android_Bridge.md'];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const checks=[];function check(name,fn){fn();checks.push({name,result:'PASSED'});}
const ids=['INT-01','INT-02','INT-03','INT-04','INT-05','INT-06','INT-07','CHA-01','CHA-02','CHA-03','CHA-04','CHA-05','CHA-06','CHA-07','CHA-08','CHA-09','HW-01'];
const sources=names.map(name=>{
 const from=path.join(downloads,name),to=path.join(root,'docs',name),bytes=fs.readFileSync(from);
 if(fs.existsSync(to))assert.equal(hash(fs.readFileSync(to)),hash(bytes),'Existing repository source differs; do not overwrite user work: '+to);
 else fs.writeFileSync(to,bytes);
 check(name+' byte-identical repository placement, original unchanged',()=>assert.equal(hash(fs.readFileSync(to)),hash(fs.readFileSync(from))));
 const text=bytes.toString('utf8');check(name+' retains exactly 17 original decision IDs',()=>{
  const actual=[...text.matchAll(/^### ((?:INT|CHA|HW)-\d{2}) —/gm)].map(m=>m[1]);assert.deepEqual(actual,ids);
 });
 return {file:'docs/'+name,original:from,sha256:hash(bytes),bytes:bytes.length};
});
const recordPath='docs/contract-review/ARCH-05_K06_Architecture_Amendment_Record.md';
const record=fs.readFileSync(path.join(root,recordPath),'utf8');
check('all 17 decisions mapped without replacing IDs',()=>{for(const id of ids)assert(record.includes('| '+id+' |'));});
check('actual source requires formal adoption and record does not fabricate it',()=>{
 const src=fs.readFileSync(path.join(root,sources[1].file),'utf8');
 assert(src.includes('pending team review/adoption and repository placement'));assert(src.includes('Final team-reviewed contract before calling amendment adopted'));
 assert(record.includes('NOT YET ADOPTED'));assert(record.includes('remains Partial'));
});
check('existing architecture and unchanged implementation/security/safety gates explicit',()=>{
 for(const text of ['HC-05','Android','Uno','ESP8266','No protocol','safety clearance','No full task status is changed'])assert(record.includes(text));
});
check('new record links to the actual placed baseline sources',()=>{
 for(const name of names)assert(record.includes('../'+name));
});
const manifest={taskId:'OCT26:ARCH-05',sources,record:{file:recordPath,sha256:hash(Buffer.from(record))},
 adoption:'NOT YET ADOPTED — user explicitly confirmed 2026-10-30; no team signatures inferred',taskStatus:'Partial',newFullTaskCompletions:[]};
fs.writeFileSync(path.join(root,'docs/contract-review/ARCH-05_source_manifest.json'),JSON.stringify(manifest,null,2)+'\n');
fs.writeFileSync(path.join(__dirname,'arch05-record-verification.json'),JSON.stringify({recordedAt:new Date().toISOString(),checks,...manifest},null,2)+'\n');
console.log(JSON.stringify({checks,taskStatus:manifest.taskStatus,adoption:manifest.adoption},null,2));
