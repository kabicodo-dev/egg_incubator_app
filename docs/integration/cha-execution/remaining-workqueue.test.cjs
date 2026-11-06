// Verify preparation artifacts and evidence integrity, NOT task acceptance.
const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'../../..'),out=path.join(root,'docs/integration/remaining-task-workqueue');
const read=p=>JSON.parse(fs.readFileSync(path.join(out,p),'utf8'));
const index=read('task-index.json'),decision=read('decision-index.json'),cases=read('planned-test-records.json');
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
test('exactly 34 unique Cha-owned unfinished tasks have individual preparation files',()=>{
 assert.equal(index.records.length,34);assert.equal(new Set(index.records.map(t=>t.id)).size,34);
 assert(index.records.every(t=>t.owner==='Mary Charlyn'&&t.preparationStarted&&t.fullTaskCompleted===false));
 assert.equal(fs.readdirSync(path.join(out,'tasks')).filter(x=>x.endsWith('.md')).length,34);
 for(const t of index.records)assert(fs.readFileSync(path.join(out,t.file),'utf8').includes(t.exactAcceptance));
});
test('original source and completion counts retained, not bulk-marked Partial or Completed',()=>{
 assert.equal(sha('C:/Users/Mary Charlyn/Downloads/index_combined_FINAL_team_details.html'),index.originalSha256);
 assert.deepEqual(index.publishedCounts,{Completed:7,'Not started':25,Partial:9,Superseded:1});
 assert.deepEqual(index.taskStatusChanges,[]);assert.deepEqual(index.newFullTaskCompletions,[]);
 assert(index.records.every(t=>['Partial','Not started'].includes(t.publishedStatus)));
});
test('102 exact future cases are NOT RUN with no fabricated observed output/log',()=>{
 assert.equal(cases.cases.length,102);assert.equal(new Set(cases.cases.map(c=>c.id)).size,102);
 assert(cases.cases.every(c=>c.status==='NOT RUN'&&c.observed===null&&c.log===null));
 for(const t of index.records)assert.equal(cases.cases.filter(c=>c.taskId===t.id).length,3);
});
test('all 14 deduplicated requests have owners actual missing action and affected tasks',()=>{
 assert.equal(decision.requests.length,14);assert.equal(new Set(decision.requests.map(d=>d.id)).size,14);
 for(const d of decision.requests){assert(d.owners.length);assert(d.alreadyAnswered);assert(d.needed);assert(d.affectedTasks.length);}
 for(const t of index.records)for(const id of t.decisionIds)assert(decision.requests.some(d=>d.id===id&&d.affectedTasks.includes(t.id)));
});
test('evidence paths and source observations still match actual retained bytes',()=>{
 const evidence=read('evidence-index.json');
 for(const e of evidence.evidence)assert.equal(sha(path.join(root,e.path)),e.sha256,e.path);
 assert.equal(evidence.sourceObservations.observations.length,4);
 for(const [p,h] of Object.entries(evidence.sourceObservations.sourceFingerprints))assert.equal(sha(path.join(root,p)),h);
});
test('actual task dependencies remain original, not removed to simulate eligibility',()=>{
 const html=fs.readFileSync('C:/Users/Mary Charlyn/Downloads/index_combined_FINAL_team_details.html','utf8');
 const data=JSON.parse(html.split(/\r?\n/).find(l=>l.startsWith('const FINAL_DATA=')).slice(17).replace(/;$/,''));
 for(const t of index.records)assert.deepEqual(t.dependencies,data.tasks.find(x=>x.id===t.id).deps);
 const b=index.records.find(t=>t.id==='OCT26:C-02B');assert(b.dependencies.includes('OCT26:C-02A'));
});
test('actual formal adoption response and pilot/research limits are not reopened or inferred passed',()=>{
 assert(decision.requests.find(d=>d.id==='Q10').alreadyAnswered.includes('Not yet adopted'));
 assert(decision.requests.find(d=>d.id==='Q13').alreadyAnswered.includes('NO-GO'));
 assert(decision.requests.find(d=>d.id==='Q14').needed.includes('actual observations'));
});
test('security and physical/research forms contain no actual roles/users/participants/results',()=>{
 const matrix=read('forms/security-matrix.json');assert.equal(matrix.cases.length,16);assert(matrix.cases.every(c=>c.status==='NOT RUN'&&c.observed===null));
 for(const p of ['forms/integration-observation.csv','forms/distribution.csv','forms/profile-comparison.csv','forms/pilot-observation.csv'])assert.equal(fs.readFileSync(path.join(out,p),'utf8').trim().split(/\r?\n/).length,1);
});
test('fresh backend log is 110 passes without treating planned cases as executed',()=>{
 const log=fs.readFileSync(path.join(__dirname,'portfolio-backend-regression.tap'),'utf8');assert(/^# tests 110$/m.test(log));assert(/^# pass 110$/m.test(log));assert(/^# fail 0$/m.test(log));
 const summary=read('preparation-summary.json');assert.equal(summary.localBackendTests,110);assert.equal(summary.allAcceptanceCases,'NOT RUN');
});
test('documentation source inspection is not Flutter execution or production remediation',()=>{
 const observations=read('evidence-index.json').sourceObservations;assert.equal(observations.productionChanges,false);
 assert(observations.scope.includes('no Flutter execution'));assert.equal(observations.sourceGate,'Default source acceptance remains CONTRACT_NOT_ENABLED');
});
