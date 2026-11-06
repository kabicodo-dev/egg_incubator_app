// Offline consistency checks of actual retained results; never connects to Supabase.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const read=p=>JSON.parse(fs.readFileSync(path.join(__dirname,p),'utf8'));
const latest=read('approved-security-test-latest.json');
const dir=latest.runDirectory;
assert(/^security-run-[0-9TZ-]+$/.test(dir));
const target=read(dir+'/verified-target.json'),catalog=read(dir+'/fresh-catalog.json').rows[0].audit;
const result=read(dir+'/probe-results.json').rows[0].security_probe;
const cleanup=read(dir+'/cleanup-results.json'),status=read(dir+'/status.json');
const sql=fs.readFileSync(path.join(__dirname,dir,'probe.sql'),'utf8');
const checks=[];
function check(name,fn){fn();checks.push({name,result:'PASSED'});}
check('exact current test project and distinct linked application',()=>{
 assert.equal(target.target.id,'zbwntspdecngnicllwlw');assert.equal(target.target.linked,false);
 assert.equal(target.target.status,'ACTIVE_HEALTHY');assert.equal(target.application.id,'suopuhgtwyqkpupzvdng');
 assert.equal(target.application.linked,true);assert.equal(result.target_ref,target.target.id);
});
check('eight unique role/operation results without SQL errors',()=>{
 assert.equal(result.results.length,8);assert.equal(new Set(result.results.map(r=>r.role+':'+r.operation)).size,8);
 assert(result.results.every(r=>r.sqlstate===null));
});
check('reported sensor security findings match real output',()=>{
 for(const role of ['anon','authenticated'])for(const [operation,count] of Object.entries({select:2,insert:1,update:0,delete:0})){
  assert.equal(result.results.find(r=>r.role===role&&r.operation===operation).affected_fixture_rows,count);
 }
 assert.equal(status.allowedOnFixtures,4);assert.equal(status.zeroRows,4);
 assert.equal(status.status,'SECURITY_GAPS_OBSERVED');
});
check('fixture IDs are explicit, negative, unique and bigint-safe',()=>{
 assert.equal(result.fixture_ids.length,3);assert.equal(new Set(result.fixture_ids).size,3);
 for(const id of result.fixture_ids){assert(BigInt(id)<0n&&BigInt(id)>=-(2n**63n));assert(sql.includes(id));}
});
check('separate absence check confirms rollback cleanup',()=>{
 assert.equal(cleanup.rows[0].remaining_fixture_rows,0);assert.equal(status.remainingFixtureRows,0);
 assert.equal(status.rollbackCleanupVerified,true);assert(sql.trim().endsWith('ROLLBACK;'));
});
check('no Auth users or schema/security mutations in submitted probe',()=>{
 assert.equal(status.authUsersCreated,0);
 const code=sql.replace(/--[^\n]*/g,'');
 assert(!/\b(create|alter|drop|grant|revoke|truncate)\s/i.test(code));
 assert(!/\b(insert\s+into|update|delete\s+from)\s+auth\./i.test(code));
 assert(!sql.includes('suopuhgtwyqkpupzvdng'));
});
check('fresh catalog still has no bridge-sync RPCs and was read-only',()=>{
 assert.equal(catalog.read_only,'on');
 for(const n of ['bridge_sync_authorize_v1','bridge_sync_ingest_v1','bridge_sync_reconcile_v1'])assert(!catalog.routines.some(r=>r.name===n));
});
const evidence={scope:'Offline evidence consistency, not an additional live test',checks};
fs.writeFileSync(path.join(__dirname,'approved-security-results-validation.json'),JSON.stringify(evidence,null,2)+'\n');
console.log(JSON.stringify(evidence,null,2));
