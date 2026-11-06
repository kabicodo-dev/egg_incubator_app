// Offline consistency checks; no Arduino builds, network, report import or approvals.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const index=JSON.parse(fs.readFileSync(path.join(__dirname,'ally-export-review/index.json'),'utf8'));
const source=fs.readFileSync(index.source),exported=JSON.parse(source.toString('utf8'));
const review=fs.readFileSync(path.join(__dirname,'ALLY_REPORT_REVIEW.md'),'utf8');
const ledger=fs.readFileSync(path.resolve(__dirname,'../../contract-review/CONTRACT-FREEZE-01_Team_Decisions.md'),'utf8');
const checks=[],check=(name,fn)=>{fn();checks.push({name,result:'PASSED'});};
check('original export unchanged, valid marker/schema and 26 unique reports indexed',()=>{
 assert.equal(crypto.createHash('sha256').update(source).digest('hex'),index.sha256);
 assert.equal(exported.app,'smarthatch-portal');assert.equal(exported.version,1);assert.equal(exported.type,'reports');
 assert.equal(index.reportCount,26);assert.equal(index.uniqueReportIds,26);assert.equal(index.distinctTaskCount,23);
 assert.equal(index.importPerformed,false);assert.equal(index.reports.length,26);
});
check('every complete source body indexed with exact hash and attributed owner',()=>{
 for(const r of exported.reports){const item=index.reports.find(x=>x.id===r.id);assert(item);
  assert.equal(item.bodySha256,crypto.createHash('sha256').update(r.body).digest('hex'));
  assert.equal(item.bodyChars,r.body.length);assert.equal(item.owner,'Ally');assert.equal(item.reportedBy,'Ally');
  assert(fs.existsSync(path.join(__dirname,'ally-export-review',item.file)));
 }
});
check('two misfiled HW-IMP reports identified without rewriting original task IDs',()=>{
 assert.deepEqual(index.misfiledReports.map(r=>[r.outerTaskId,r.bodyTaskId]),[
  ['OCT26:HW-01','CURRENT:HW-IMP-01'],['OCT26:HW-02','CURRENT:HW-IMP-02']]);
 for(const r of index.misfiledReports)assert.equal(exported.reports.find(x=>x.id===r.id).taskId,r.outerTaskId);
});
check('all six shared decisions explicitly assessed, not blanket rejected/approved',()=>{
 for(const id of ['D01','D02','D03','D04','D05','D06'])assert(review.includes('**'+id+':'));
 assert(review.includes('Partially documented'));assert(review.includes('Build evidence reported'));
 assert(review.includes('No such acceptance is recorded'));
});
check('latest source hash distinct from local source; seven named packet files absent',()=>{
 assert.notEqual(index.localSourceComparison.combinedSha256,index.localSourceComparison.reportedPatchedCombinedSha256);
 assert.equal(index.referencedFiles.length,7);assert(index.referencedFiles.every(r=>r.presentInChaCheckout===false));
 assert.equal(index.localSourceComparison.localUnoSketchPresent,true);
});
check('receipt of progress distinguished from formal Ally answer and joint approval',()=>{
 assert(ledger.includes('PROGRESS REPORTS RECEIVED; FORMAL ANSWERS PENDING'));
 assert(ledger.includes('Design-freeze disposition: **NOT APPROVED**'));
 assert(review.includes('No task status or sign-off is changed'));
 assert(review.includes('manual completion independent of physical Stop'));
});
const result={scope:'Offline report/decision review only; attributed software results not rerun',checks,allQuestionsAnswered:false,
 decisionAssessment:{D01:'PARTIAL_SOURCE_CONTEXT',D02:'PARTIAL_HOST_EVIDENCE',D03:'BUILD_REPORTED_BOUNDS_PENDING',D04:'AUTHORIZATION_AND_RETENTION_UNAPPROVED',D05:'RTC_PROFILE_TIME_BLOCKED',D06:'MAPPING_AND_INDEPENDENT_COMPLETION_ACCEPTANCE_PENDING'},
 fullJointApprovals:0,newTaskCompletions:0,rawReportsImported:0};
fs.writeFileSync(path.join(__dirname,'ally-report-review-validation.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
