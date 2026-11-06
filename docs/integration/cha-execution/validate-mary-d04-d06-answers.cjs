// Offline checks of actual recorded user replies; never signs for another member.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'../../..');
const answers=JSON.parse(fs.readFileSync(path.join(__dirname,'mary-d04-d06-answers.json'),'utf8'));
const record=fs.readFileSync(path.join(root,answers.reportFile),'utf8');
const ledger=fs.readFileSync(path.join(root,'docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md'),'utf8');
const checks=[],check=(name,fn)=>{fn();checks.push({name,result:'PASSED'});};
check('exact four user selections preserved',()=>{
 assert.deepEqual(answers.answers.map(a=>a.selection),['Accept this position','Accept fail-closed release','Accept these positions','Separate completion from Stop']);
 for(const a of answers.answers)assert(record.includes(a.selection));
});
check('three personal acceptances and one pending change request only',()=>{
 assert.equal(answers.answers.filter(a=>a.disposition==='ACCEPTED_PERSONAL_POSITION').length,3);
 assert.equal(answers.answers.find(a=>a.topic==='D06.completion_prerequisite').disposition,'CHANGE_REQUEST_PENDING_KATH_ALLY');
 assert(record.includes('NOT JOINTLY APPROVED'));assert(record.includes('PENDING KATH + ALLY REVIEW'));
});
check('no Kath/Ally sign-off or full freeze invented',()=>{
 assert.equal(answers.jointStatus.Kath,'NO_ANSWER_RECORDED');assert.equal(answers.jointStatus.Ally,'NO_ANSWER_RECORDED');
 assert.equal(answers.jointStatus.designFreeze,'NOT_APPROVED');
 const allyRow=ledger.split('\n').find(l=>l.startsWith('| Ally | D01–D06 firmware/source/safety feasibility |'));
 assert(allyRow&&(allyRow.endsWith('| PENDING |')||allyRow.endsWith('| PROGRESS REPORTS RECEIVED; FORMAL ANSWERS PENDING |')));
 assert(ledger.includes('| Kath | D01–D06 Android/compatibility/local recovery | PENDING — no reply supplied | PENDING |'));
});
check('joint D04/D06 gates remain blocked/pending',()=>{
 assert.equal(answers.jointStatus.D04,'BLOCKED');assert.equal(answers.jointStatus.D06,'NEEDS_ANSWER');
 assert(ledger.split('\n').find(l=>l.startsWith('| D04 —')).includes('| BLOCKED |'));
 assert(ledger.split('\n').find(l=>l.startsWith('| D06 —')).includes('| NEEDS ANSWER |'));
});
check('all operation permissions remain false for this decision update',()=>assert(Object.values(answers.authorization).every(v=>v===false)));
check('three original candidate documents remain byte-identical to reviewed context',()=>{
 for(const [p,h] of Object.entries(answers.referencedCandidates))assert.equal(crypto.createHash('sha256').update(fs.readFileSync(path.join(root,p))).digest('hex'),h,p);
});
check('completion conflict and unsafe new-batch inference explicitly disclosed',()=>{
 assert(record.includes('requires an applied referenced Stop'));
 assert(record.includes('No completion behavior was'));
 assert(record.includes('bypass the current physical-batch guard'));
 assert(record.includes('not proof that credentials cannot be copied'));
});
const result={scope:'Offline decision-record verification; no backend/remote/runtime test',checks,personalSelections:4,fullJointApprovals:0,newTaskCompletions:0};
fs.writeFileSync(path.join(__dirname,'mary-d04-d06-validation.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
