const fs=require('node:fs');
const path=require('node:path');
const vm=require('node:vm');
const assert=require('node:assert/strict');
const dir=path.resolve(__dirname,'../../..');
const source=fs.readFileSync('C:/Users/Mary Charlyn/Downloads/index_combined_FINAL_team_details.html','utf8');
const html=fs.readFileSync(path.join(dir,'SmartHatch_Cha_Backend_Updated.html'),'utf8');
const checks=[];
function check(name,fn){fn();checks.push({name,result:'PASSED'});}
check('all original source lines preserved except two merge-safety edits and read-only archive display/search hooks',()=>{
 const allowed=['if(!l)P.newR.push(r);else if(sameR(l,r))P.same++;else P.conflict.push(r)',"save('sh_state_v2',state);save('sh_ev',ev);rl();paint();",'function renderReports(){var host=',"if(tab==='reports')return reports.filter(reportMatches).length+items.filter"];
 for(const line of source.split(/\r?\n/)){
  if(!line.trim()||line.includes('id="statRow"')||line.includes('</head>')||line.includes('id="final-sources"')||allowed.some(a=>line.includes(a)))continue;
  assert(html.includes(line),'missing source line: '+line.slice(0,100));
 }
});
check('JavaScript syntax',()=>{for(const m of html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/gi))new vm.Script(m[1]);});
check('HTML tag balance',()=>{
 const text=html.replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi,'').replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi,'').replace(/<!--[\s\S]*?-->/g,'');
 const stack=[],voids=new Set('area base br col embed hr img input link meta param source track wbr'.split(' '));
 for(const m of text.matchAll(/<\/?([a-z][a-z0-9:-]*)\b[^>]*>/gi)){
  const tag=m[1].toLowerCase(),token=m[0];if(voids.has(tag)||token.endsWith('/>'))continue;
  if(token.startsWith('</'))assert.equal(stack.pop(),tag,'unbalanced '+tag);else stack.push(tag);
 }
 assert.equal(stack.length,0);
});
check('136 original IDs/owners/source groups exact',()=>{
 const get=h=>JSON.parse(h.split(/\r?\n/).find(l=>l.startsWith('const FINAL_DATA=')).slice(17).replace(/;$/,''));
 const a=get(source),b=get(html);assert.deepEqual(a,b);assert.equal(b.tasks.length,136);
 assert.equal(new Set(b.tasks.map(t=>t.id)).size,136);
});
check('eight tabs and adviser/team details retained',()=>{
 assert.equal((html.match(/role="tab"/g)||[]).length,8);
 for(const name of ['Mr. Renly Jade S. Laud','Katherine Anne B. Bicodo','Jan Allysandra I. Espia','Mary Charlyn L. Aguirre','Clarieze Anne A. Gumban'])assert(html.includes(name));
});
check('additive import schema and stable report identity',()=>{
 const x=JSON.parse(fs.readFileSync(path.join(dir,'SmartHatch_Cha_Reports_Import.json'),'utf8'));
 assert.equal(x.app,'smarthatch-portal');assert.equal(x.type,'reports');assert.equal(x.version,1);
 const hasLocalPlan=fs.existsSync(path.join(__dirname,'TEAM_APPROVALS_AND_LOCAL_PLAN.md'));
 const hasApprovedProbe=fs.existsSync(path.join(__dirname,'approved-security-test-latest.json'));
 const hasCompletion=fs.existsSync(path.join(__dirname,'audit-completion.json'));
 const hasSupplement=fs.existsSync(path.join(__dirname,'SUPPLEMENTAL_AUDIT_EVIDENCE.md'));
 const hasMaryAnswers=fs.existsSync(path.join(__dirname,'mary-d04-d06-answers.json'));
 const hasAllyReview=fs.existsSync(path.join(__dirname,'ALLY_REPORT_REVIEW.md'));
 const independent=fs.existsSync(path.join(__dirname,'independent-task-completions.json'))?JSON.parse(fs.readFileSync(path.join(__dirname,'independent-task-completions.json'),'utf8')).tasks:[];
 const progress=fs.existsSync(path.join(__dirname,'ally-zip-progress.json'))?JSON.parse(fs.readFileSync(path.join(__dirname,'ally-zip-progress.json'),'utf8')).tasks:[];
 assert.equal(x.reports.length,1+(hasLocalPlan?1:0)+(hasApprovedProbe?1:0)+(hasCompletion?2:0)+(hasSupplement?1:0)+(hasMaryAnswers?1:0)+(hasAllyReview?1:0)+independent.length+progress.length);assert.equal(new Set(x.reports.map(r=>r.id)).size,x.reports.length);
 for(const r of x.reports){
  if(r.id.startsWith('R-CHA-C01-AUDIT-COMPLETE-')||r.id==='R-CHA-C01-SUPPLEMENT-15-19'){assert.equal(r.status,'Completed');assert(['ORIGINAL:C-01','OCT26:C-01'].includes(r.taskId));}
  else if(r.id==='R-CHA-D04-D06-POSITION-01'){assert.equal(r.status,'Partial');assert.equal(r.taskId,'CURRENT:DB-IMP-01');assert(r.body.includes('Separate completion from Stop'));}
  else if(r.id==='R-CHA-ALLY-EXPORT-REVIEW-01'){assert.equal(r.status,'Partial');assert.equal(r.taskId,'CURRENT:INT-IMP-01');assert.equal(r.reportedBy,'Mary Charlyn');assert(r.body.includes('two filing mismatches')||r.body.includes('Important filing problems'));}
  else if(independent.some(t=>t.reportId===r.id)){assert.equal(r.status,'Completed');assert.equal(r.taskId,'OCT26:C-03');assert(r.body.includes('PASSED 83/83'));}
   else if(progress.some(t=>t.reportId===r.id)){
    const p=progress.find(t=>t.reportId===r.id);assert.equal(r.status,'Partial');assert.equal(r.taskId,p.id);
    if(p.id==='OCT26:C-02B'){assert(r.body.includes('F-10'));assert(r.body.includes('four conditions'));}
    else if(p.id==='OCT26:C-02A'){assert(r.body.includes('65 schema-negative'));assert(r.body.includes('NOT RUN'));}
    else {assert.equal(p.id,'ORIGINAL:C-09');assert(r.body.includes('27/27 passed'));assert(r.body.includes('110/110 passed'));assert(r.body.includes('remains Partial'));}
   }
  else{assert.equal(r.status,'Partial');assert.equal(r.taskId,'OCT26:C-01');}
 }
 assert(!('state' in x));assert(!('evidence' in x));assert(!('readiness' in x));
 assert(x.reports[0].id.length<=64);assert(x.reports[0].body.length<200000);
});
check('reports-only import does not write unrelated storage',()=>{
 assert(html.includes("if(imp.state)save('sh_state_v2',state);if(imp.evidence)save('sh_ev',ev);"));
 assert(html.includes('x.copyOf===r.id&&sameR(x,r)'));
});
if(fs.existsSync(path.join(__dirname,'ally-zip-progress.json')))check('documented review/monitoring progress is Partial only and preserves all dependencies/other tasks',()=>{
 const get=h=>JSON.parse(h.split(/\r?\n/).find(l=>l.startsWith('const FINAL_DATA=')).slice(17).replace(/;$/,''));
 const baseline=get(source).tasks,taskCopies=structuredClone(baseline),embedded={tasks:structuredClone(baseline)};
 const start=html.indexOf('/* Attributed Ally ZIP review progress; no saved browser writes. */');
 const end=html.indexOf('/* Independent local task completion;',start);assert(start>=0&&end>start);
 vm.runInNewContext(html.slice(start,end),{TASKS:taskCopies,FINAL_DATA:embedded},{timeout:1000});
 for(let i=0;i<baseline.length;i++){
   if(['OCT26:C-02A','OCT26:C-02B','ORIGINAL:C-09'].includes(baseline[i].id)){
    assert.equal(taskCopies[i].status,'Partial');assert.deepEqual(taskCopies[i].deps,baseline[i].deps);
   }
  else assert.deepEqual(taskCopies[i],baseline[i]);
 }
  const rs=JSON.parse(fs.readFileSync(path.join(dir,'SmartHatch_Cha_Reports_Import.json'),'utf8')).reports.filter(r=>['OCT26:C-02A','OCT26:C-02B'].includes(r.taskId));
  assert.equal(rs.length,2);for(const r of rs)assert(html.includes(r.body.replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))));
});
if(fs.existsSync(path.join(__dirname,'independent-task-completions.json')))check('independent completion metadata updates only the verified task, not browser storage or other owners',()=>{
 const get=h=>JSON.parse(h.split(/\r?\n/).find(l=>l.startsWith('const FINAL_DATA=')).slice(17).replace(/;$/,''));
 const baseline=get(source).tasks,taskCopies=structuredClone(baseline),embedded={tasks:structuredClone(baseline)};
 const start=html.indexOf('/* Independent local task completion; no saved browser state writes. */');
 assert(start>=0);const archiveStart=html.indexOf('/* Self-contained completed-report archive:',start);
 const end=archiveStart>=0?archiveStart:html.indexOf("(function(){'use strict';",start);assert(end>start);
 vm.runInNewContext(html.slice(start,end),{TASKS:taskCopies,FINAL_DATA:embedded},{timeout:1000});
 for(let i=0;i<baseline.length;i++){
  if(baseline[i].id==='OCT26:C-03'){assert.equal(taskCopies[i].status,'Completed');assert.equal(taskCopies[i].o,'Mary Charlyn');}
  else assert.deepEqual(taskCopies[i],baseline[i]);
 }
 assert.equal(taskCopies.length,136);assert.equal(embedded.tasks.find(t=>t.id==='OCT26:C-03').status,'Completed');
});
if(fs.existsSync(path.join(dir,'docs/integration/remaining-task-workqueue/task-index.json')))check('all 34 preparation cards and 14 requests are read-only with 102 NOT RUN cases, not extra tasks',()=>{
 assert.equal((html.match(/data-workqueue-task="/g)||[]).length,34);assert.equal((html.match(/data-workqueue-decision="/g)||[]).length,14);
 assert.equal((html.match(/data-workqueue-case="/g)||[]).length,102);assert(html.includes('Preparation is not implementation or completion'));
 const section=html.slice(html.indexOf('<article class="section" id="remaining-task-preparation"'),html.indexOf('<article class="section" id="mary-integration-report"'));
 assert(!section.includes('data-task='));assert(!section.includes('<script'));assert(!section.includes('localStorage.setItem'));
});
fs.writeFileSync(path.join(__dirname,'portal-structural-results.json'),JSON.stringify({checks,boundary:'Static Node assertions, not database/security/hardware evidence.'},null,2)+'\n');
console.log(JSON.stringify(checks,null,2));
