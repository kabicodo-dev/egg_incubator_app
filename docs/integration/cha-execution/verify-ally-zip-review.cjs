// Local document/integrity checks. No execution of supplied code or remote access.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const input=process.argv[2];assert(input,'Pass the isolated extracted 01 directory');
const zip='C:/Users/Mary Charlyn/Downloads/01-20261030T075957Z-1-001.zip';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const expected='d7657d191f11d18d4e87f803c1314719157bbe7b9f56a184b56e0cde31d15eb2';
assert.equal(hash(fs.readFileSync(zip)),expected);
const files=fs.readdirSync(input).sort().map(file=>{
 assert(/^[a-z0-9_-]+\.md$/.test(file));const bytes=fs.readFileSync(path.join(input,file)),text=bytes.toString('utf8');
 return {file,bytes:bytes.length,sha256:hash(bytes),title:text.split(/\r?\n/).find(l=>/^# /.test(l))||'',status:text.split(/\r?\n/).find(l=>/^\*\*Status/.test(l))||'See disposition in document'};
});
const read=name=>fs.readFileSync(path.join(input,name),'utf8');
const response=read('ally_d02_d04_d06_response.md');
const headings=[...response.matchAll(/^### (D0[246]-\d)[^\n]+/gm)].map(m=>({id:m[1],heading:m[0]}));
const dispositions=headings.map(h=>({...h,primary:h.heading.includes('BLOCKED')?'BLOCKED':h.heading.includes('CHANGE')?'CHANGE':'ACCEPT'}));
const counts=dispositions.reduce((o,p)=>(o[p.primary]=(o[p.primary]||0)+1,o),{});
const conditions=response.match(/1\. Completion never[\s\S]*?from sensors\./)?.[0];
const root=path.resolve(__dirname,'../../..');
const report=fs.readFileSync(path.join(__dirname,'ALLY_ZIP_C02B_REVIEW.md'),'utf8');
const source=fs.readFileSync('C:/Users/Mary Charlyn/Downloads/index_combined_FINAL_team_details.html','utf8');
const data=JSON.parse(source.split(/\r?\n/).find(l=>l.startsWith('const FINAL_DATA=')).slice(17).replace(/;$/,''));
const task=data.tasks.find(t=>t.id==='OCT26:C-02B'),prereq=data.tasks.find(t=>t.id==='OCT26:C-02A');
const checks=[];function check(name,fn){fn();checks.push({name,result:'PASSED'});}
check('immutable ZIP fingerprint matches supplied bytes; 34 Markdown-only extracted entries',()=>assert.equal(files.length,34));
check('all thirteen directly received positions retained with correct primary counts',()=>{
 assert.equal(dispositions.length,13);assert.deepEqual(counts,{BLOCKED:3,CHANGE:4,ACCEPT:6});
 for(const p of dispositions)assert(report.includes('| '+p.id+' |'));
});
check('all four original completion conditions present in received response and review',()=>{
 assert(conditions);for(const text of ['physical Stop','single-Active guard','server receipt time','derived\n   from sensors'])assert(conditions.includes(text));
 for(const text of ['original completion time stays NULL','not sensor-derived','another hardware batch'])assert(report.replace(/\s+/g,' ').includes(text),text);
});
check('all ten A-01 findings and A-03 question responses are covered',()=>{
 const findings=read('oct26_a03_a01_findings_for_cha.md');
 for(let n=1;n<=10;n++){const id='F-'+String(n).padStart(2,'0');assert(findings.includes(id));assert(report.includes('| '+id));}
 for(let n=1;n<=10;n++)assert(new RegExp('^'+n+'\\. \\*\\*','m').test(report));
});
check('task dependencies and acceptance are preserved, not bypassed for completion',()=>{
 assert.equal(task.o,'Mary Charlyn');assert.deepEqual(task.deps,['OCT26:A-01','OCT26:C-02A']);
 assert.equal(prereq.acc,'Schema reviewed by Ally and Kath');
 const p=JSON.parse(fs.readFileSync(path.join(__dirname,'ally-zip-progress.json'),'utf8')).tasks[0];
 assert.equal(p.status,'Partial');assert.equal(p.id,task.id);assert(report.includes('No remaining full task is newly completed'));
});
check('source claims remain attributed and do not select another branch or hardware',()=>{
 const local=hash(fs.readFileSync(path.join(root,'arduino/SmartHatch_Combined/SmartHatch_Combined.ino')));
 assert.notEqual(local,'7106ebfe01d037c95766cd51c43b43fa02f92b922fc5a180770fd27b3822c5ec');
 assert(report.includes('No Arduino/Flutter build'));assert(report.includes('no baseline selected'));
});
check('known input contradictions are retained, not copied as accepted constraints',()=>{
 for(const text of ['RX application buffer','eight-byte command','software RX ring','No RUNNING frame','not durable idempotency'])assert(report.includes(text));
});
check('old API schema remains byte-identical and production source gate remains closed',()=>{
 assert.equal(hash(fs.readFileSync(path.join(root,'docs/contract-review/DB-02_Exact_Bridge_Sync_API.md'))),'5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab');
 assert(fs.readFileSync(path.join(root,'supabase/functions/_shared/bridge-sync-core.mjs'),'utf8').includes("throw new BridgeError('CONTRACT_NOT_ENABLED',503"));
});
const result={zip,zipSha256:expected,files,dispositions,counts,verbatimCompletionConditions:conditions,checks,
 task:{id:task.id,status:'Partial',completedNow:[],reason:'C-02A schema-review prerequisite open; selected source/catalog absent'},
 boundary:'Document/hash checks only. Markdown reports are not supplied build/firmware/model artifacts; no reported test rerun.'};
fs.writeFileSync(path.join(__dirname,'ally-zip-review-index.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({files:files.length,counts,checks,task:result.task},null,2));
