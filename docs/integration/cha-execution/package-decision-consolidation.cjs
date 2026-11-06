// Documentation circulation bundle only. Does not modify implementation or send files.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../../..');
const dest=path.join(root,'docs/integration/decision-consolidation-2026-10-30');
const downloads='C:/Users/Mary Charlyn/Downloads';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const records=[];
const repo=[
 'docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md',
 'docs/contract-review/D04_D06_Mary_Backend_Position.md',
 'docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md',
 'docs/contract-review/DB-02_Exact_Bridge_Sync_API.md',
 'docs/contract-review/DB-02_Proposed_Schema_And_Security.md',
 'docs/contract-review/DB-02_Conflict_Receipt_And_Recovery.md',
 'docs/contract-review/INTEGRATION-CONTRACT-03_Shared_Decision_Register.md'];
const external=['SmartHatch_Shared_Communication_Contract_v1.3_DECISION_READY_DRAFT.md',
 'Ally-2026-10-30-Packet-Review.md','ORIGINAL-C-02-Flutter-Compatibility-Review.md'];
fs.mkdirSync(dest,{recursive:true});
function copy(from,to,origin){
 const bytes=fs.readFileSync(from),target=path.join(dest,to);fs.mkdirSync(path.dirname(target),{recursive:true});
 fs.writeFileSync(target,bytes);assert.equal(hash(fs.readFileSync(target)),hash(bytes));
 records.push({file:to.replace(/\\/g,'/'),sha256:hash(bytes),bytes:bytes.length,origin});
}
for(const p of repo)copy(path.join(root,p),path.basename(p),'Current repository documentation');
for(const p of external)copy(path.join(downloads,p),p,'User-supplied Downloads input; byte-identical copy');
const checks=[];
function check(name,fn){fn();checks.push({name,result:'PASSED'});}
check('all ten supplied review files are copied byte-identically',()=>assert.equal(records.length,10));
check('v1.3 remains the original unfrozen decision-ready input',()=>{
 assert.equal(records.find(r=>r.file.startsWith('SmartHatch_Shared_')).sha256,'70987831890edb16daaccfb47f7188061b41c5ea66658ac45fe4866cd1074f66');
});
check('three DB-02 historical candidate snapshots remain unchanged',()=>{
 const expected={
  'DB-02_Proposed_Schema_And_Security.md':'6322985031a82d25184bd0ebefc7e1a9016d74c22b7e8d587e94dafb16d3f230',
  'DB-02_Conflict_Receipt_And_Recovery.md':'08e6f97c7c320769e223218fbea7ce52a1d4a1b0ec5d117a83965d5678f39f06',
  'DB-02_Exact_Bridge_Sync_API.md':'5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab'};
 for(const [file,h] of Object.entries(expected))assert.equal(records.find(r=>r.file===file).sha256,h);
});
const ledger=fs.readFileSync(path.join(dest,'CONTRACT-FREEZE-01_Team_Decisions.md'),'utf8');
const amendment=fs.readFileSync(path.join(dest,'DB-02_30Oct_Consolidated_Alignment.md'),'utf8');
check('six existing decision rows record received answers instead of no-reply defaults',()=>{
 const rows=ledger.split(/\r?\n/).filter(l=>/^\| D0[1-6] —/.test(l));assert.equal(rows.length,6);
 for(const row of rows){assert(row.includes('RECEIVED:'));assert(!row.includes('no reply supplied'));assert(!row.includes('no D0'));}
});
check('protocol supersession unresolved and four conditions now recorded as received',()=>{
 assert(amendment.includes('No translation'));assert(amendment.includes('all four conditions'));
 assert(amendment.includes('Ally must identify'));assert(amendment.includes('Flashed identity stays UNKNOWN'));
});
check('result storage lifecycle and physical admission are distinct proposed decisions',()=>{
 for(const marker of ['### A. Manual result recording','### B. Cloud lifecycle projection','### C. Physical batch admission','not automatically mutate session status','App enrollment is not controller authentication'])assert(amendment.includes(marker));
});
check('reported software evidence is not presented as reproduced or physical readiness',()=>{
 assert(amendment.includes('not independently rerun here'));assert(amendment.includes('Pilot remains **NO-GO**'));
 assert(amendment.includes('ARCH-06 is not completed'));assert(amendment.includes('not actual delivery'));
});
const readme=`# Same-revision D01–D06 review package — 30 Oct 2026

Read CONTRACT-FREEZE-01_Team_Decisions.md first: this is the existing current answer ledger.
Then read DB-02_30Oct_Consolidated_Alignment.md: one consolidated update, backend
amendment proposal, only unresolved choices, responsible owners and closure tests.

Also included: the current v1.3 decision-ready draft UNCHANGED; Mary's actual
D04/D06 backend-position response; the three DB-02 0.1 historical candidates;
the existing integration register; and both supplied review attachments.

The older v1.3 PENDING sheet/four-participant wording and DB-02 Stop prerequisite
are preserved historical candidate text, not newer approvals. The ledger and
amendment state the latest received positions and their limits. Cha and Mary are
one respondent. No common source/catalog has been selected. Do not implement a
silent translation between START_BATCH/CONFIRM and numeric START.

Ally: the full response and four completion conditions are now received. Send the
matching source/patch/catalog, raw fixtures/build logs and reported Dart model. Answer only
supersession, boot/output ambiguity and remaining exact firmware choices.
Kath: accept/change the precise storage/UX/lifecycle/admission proposal and selected
wire once delivered, not principles alone. Mary: finalize versioned backend design
against that same packet before requesting implementation/test authorization.
Named profile approver: sign existing candidate values/version/capacity; no new
profile values are requested from Ally.

Tests/builds in attached reviews are ATTRIBUTED, not independently reproduced here.
No code/database/authorization/deployment/flashing/powered-test permission is granted.
Pilot NO-GO and physical gates stand. No new task status is changed by this package.

Prepared locally for the user to circulate to Ally and Kath. No message has been
sent; recipient/delivery acknowledgments are not recorded. This does not complete
ARCH-06 distribution. Check manifest.json for each supplied file's SHA-256.
`;
fs.writeFileSync(path.join(dest,'README.md'),readme);
records.push({file:'README.md',sha256:hash(Buffer.from(readme)),bytes:Buffer.byteLength(readme),origin:'Generated circulation cover'});
fs.writeFileSync(path.join(dest,'manifest.json'),JSON.stringify({date:'2026-10-30',status:'Prepared for circulation; NOT delivered or approved',files:records},null,2)+'\n');
fs.writeFileSync(path.join(__dirname,'decision-consolidation-validation.json'),JSON.stringify({checks,files:records.length,scope:'Documentation/hash checks only; no build/cloud/hardware tests',recordedAt:new Date().toISOString()},null,2)+'\n');
console.log(JSON.stringify({directory:dest,checks},null,2));
