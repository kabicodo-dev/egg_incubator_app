// Offline plan-safety assertions only. No network, database or provisioning API.
const fs=require('node:fs');
const path=require('node:path');
const assert=require('node:assert/strict');
const p=JSON.parse(fs.readFileSync(path.join(__dirname,'security-test-plan.json'),'utf8'));
const catalog=JSON.parse(fs.readFileSync(path.join(__dirname,'2026-10-30-test-catalog.json'),'utf8')).rows[0].audit;
const checks=[];
function check(name,fn){fn();checks.push({name,result:'PASSED'});}
check('all remote permissions remain false',()=>assert(Object.values(p.authorization).every(v=>v===false)));
check('explicit test target excludes application project',()=>{
 assert.equal(p.target.ref,'zbwntspdecngnicllwlw');
 assert.equal(new URL(p.target.url).hostname,p.target.ref+'.supabase.co');
 assert.notEqual(p.target.ref,p.target.forbiddenRef);
 assert.equal(p.target.requireFreshVerificationBeforeRemoteUse,true);
});
check('exact existing RPC names only',()=>{
 const adapter=fs.readFileSync(path.resolve(__dirname,'../../../supabase/functions/_shared/bridge-sync-supabase.mjs'),'utf8');
 assert.equal(p.rpcNames.length,3);
 for(const n of p.rpcNames){assert(adapter.includes("'"+n+"'"));assert(!catalog.routines.some(r=>r.name===n));}
});
check('case IDs unique and results do not fabricate live success',()=>{
 assert.equal(new Set(p.cases.map(c=>c.id)).size,p.cases.length);
 for(const c of p.cases)assert(['LOCAL_EVIDENCE_REVIEW_ONLY','NOT_RUN','BLOCKED_BY_TEAM_DECISIONS'].includes(c.status));
});
check('positive and transaction paths explicitly team-gated',()=>{
 for(const id of ['AUDIT-ALLOW-01','AUDIT-TXN-01']){
  const c=p.cases.find(c=>c.id===id);assert.equal(c.status,'BLOCKED_BY_TEAM_DECISIONS');assert(c.gates.some(s=>/D0[1246]/.test(s)));
 }
});
check('fixture inputs exist; prior observation is read-only',()=>{
 for(const input of p.inputs)assert(fs.existsSync(path.resolve(__dirname,'../../..',input)));
 assert.equal(catalog.read_only,'on');
});
check('cleanup remains unapproved and explicitly ID-scoped',()=>{
 assert.equal(p.authorization.fixtureCleanup,false);
 assert(p.futureCleanupConstraints.some(s=>s.includes('exact IDs')));
 assert(p.futureCleanupConstraints.some(s=>s.includes('sequence')));
 assert(p.futureCleanupConstraints.some(s=>s.includes('Auth provisioning')));
});
const result={taskId:p.taskId,scope:'Offline plan validation ONLY; no real Auth/RLS/RPC tests run.',checks};
fs.writeFileSync(path.join(__dirname,'security-test-plan-validation.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
