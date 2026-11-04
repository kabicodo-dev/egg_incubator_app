// Local retained-evidence validation, not backend acceptance or a remote test.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'../../..'),checks=[];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
function check(name,fn){fn();checks.push({name,result:'PASSED'});}
const logs={};
for(const [file,n] of [['monitoring-boundary-targeted.tap',27],['monitoring-backend-regression.tap',110]])check(file+' actual passing output',()=>{
 const text=fs.readFileSync(path.join(__dirname,file),'utf8');for(const line of [`1..${n}`,`# tests ${n}`,`# pass ${n}`,'# fail 0','# skipped 0','# cancelled 0'])assert(text.split(/\r?\n/).includes(line));
 assert(!/^not ok /m.test(text));logs[file]=hash(Buffer.from(text));
});
const probes=JSON.parse(fs.readFileSync(path.join(__dirname,'monitoring-boundary-probes.json'),'utf8'));
check('observed source fingerprint unchanged and three probes retained as limitations',()=>{
 assert.equal(hash(fs.readFileSync(path.join(root,probes.source))),probes.sourceSha256);assert.equal(probes.findings.length,3);
 assert.equal(probes.productionSourceChanged,false);assert.equal(probes.selectedFreshnessThreshold,null);
});
check('published progress report remains Partial, no inferred full completion or numeric policy',()=>{
 const task=JSON.parse(fs.readFileSync(path.join(__dirname,'ally-zip-progress.json'),'utf8')).tasks.find(t=>t.id==='ORIGINAL:C-09');assert(task);assert.equal(task.status,'Partial');
 const report=fs.readFileSync(path.join(__dirname,task.reportFile),'utf8');
 for(const s of ['27/27 passed','110/110 passed','arbitrary TEST inputs','remains Partial','No production module'])assert(report.includes(s));
});
check('portal structural and browser results retain original tasks and pass',()=>{
 const s=JSON.parse(fs.readFileSync(path.join(__dirname,'portal-structural-results.json'),'utf8'));
 const b=JSON.parse(fs.readFileSync(path.join(__dirname,'completed-report-archive-browser.json'),'utf8'));
 const portfolio=fs.existsSync(path.resolve(__dirname,'../remaining-task-workqueue/task-index.json'));
 assert.equal(s.checks.length,portfolio?10:9);assert(s.checks.every(c=>c.result==='PASSED'));
 assert.equal(b.checks.length,portfolio?11:10);assert(b.checks.every(c=>c.result==='PASSED'));assert.equal(b.runtimeErrors.length,0);
});
const result={taskId:'ORIGINAL:C-09',status:'Partial',targetedTests:27,regressionTests:110,regressionIncludesTargeted:true,checks,logHashes:logs,
 testSourceSha256:hash(fs.readFileSync(path.join(root,'test/backend/monitoring_boundary_test.mjs'))),
 newFullTaskCompletions:[],scope:'Existing backend helpers/validators, local tests and portal only; no measured cadence or UI/transport/Auth/database/hardware acceptance',recordedAt:new Date().toISOString()};
fs.writeFileSync(path.join(__dirname,'monitoring-verification.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
