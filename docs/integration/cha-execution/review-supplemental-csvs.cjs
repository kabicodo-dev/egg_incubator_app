// Offline evidence review only; no Supabase access or changes.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
function parse(text){
 const rows=[];let row=[],s='',q=false;
 for(let i=0;i<text.length;i++){
  const c=text[i];
  if(q){if(c==='"'&&text[i+1]==='"'){s+='"';i++;}else if(c==='"')q=false;else s+=c;}
  else if(c==='"')q=true;
  else if(c===','){row.push(s);s='';}
  else if(c==='\n'){row.push(s.replace(/\r$/,''));if(row.some(Boolean))rows.push(row);row=[];s='';}
  else s+=c;
 }
 assert(!q);if(s||row.length){row.push(s.replace(/\r$/,''));rows.push(row);}
 const header=rows.shift();return rows.map(r=>{assert.equal(r.length,header.length);return Object.fromEntries(header.map((k,i)=>[k,r[i]]));});
}
const files=[],data={};
for(const n of [15,16,17,18,19]){
 const name='Supabase Snippet Untitled query ('+n+').csv';
 const bytes=fs.readFileSync(path.join('C:/Users/Mary Charlyn/Downloads',name));
 const rows=parse(bytes.toString('utf8').replace(/^\uFEFF/,''));data[n]=rows;
 files.push({name,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),rowCount:rows.length,rowsReviewed:rows});
}
const catalog=JSON.parse(fs.readFileSync(path.join(__dirname,'security-run-2026-10-29T19-29-38-293Z/fresh-catalog.json'),'utf8')).rows[0].audit;
const checks=[],check=(name,fn)=>{fn();checks.push({name,result:'PASSED'});};
check('four exported sequence owners/usage/select flags match known test sequence ACLs',()=>{
 assert.equal(data[15].length,4);
 for(const r of data[15]){
  const c=catalog.tables.find(c=>c.kind==='S'&&c.name===r.sequence_name);assert(c);assert.equal(c.owner,r.sequence_owner);
  for(const role of ['anon','authenticated']){
   assert.equal(r[role+'_usage'],'true');assert.equal(r[role+'_select'],'true');
   const acl=c.acl.match(new RegExp(role+'=([^/]+)\\/'));assert(acl);assert(acl[1].includes('U')&&acl[1].includes('r'));
  }
 }
});
check('default-privilege export includes broad public defaults; completeness explicitly unknown',()=>{
 assert.equal(data[16].length,100);
 for(const role of ['anon','authenticated'])for(const privilege of ['SELECT','INSERT','UPDATE','DELETE','TRUNCATE']){
  assert(data[16].some(r=>r.grant_owner==='postgres'&&r.schema_scope==='public'&&r.object_type==='TABLES'&&r.grantee===role&&r.privilege_type===privilege));
 }
});
check('exported role flags distinguish client roles from RLS-bypassing admin/service roles',()=>{
 assert.equal(data[17].length,6);
 for(const role of ['anon','authenticated'])assert.equal(data[17].find(r=>r.role_name===role).bypasses_rls,'false');
 for(const role of ['postgres','service_role','supabase_admin'])assert.equal(data[17].find(r=>r.role_name===role).bypasses_rls,'true');
 assert.equal(data[17].find(r=>r.role_name==='postgres').is_superuser,'false');
});
check('nine exported public object owners agree with independent catalog',()=>{
 assert.equal(data[18].length,9);
 for(const r of data[18]){
  const c=r.object_type==='FUNCTION'?catalog.routines.find(c=>c.schema===r.schema_name&&c.name===r.object_name):catalog.tables.find(c=>c.schema===r.schema_name&&c.name===r.object_name);
  assert(c);assert.equal(c.owner,r.object_owner);
 }
});
check('authenticator memberships permit SET ROLE without proving a real signed JWT test',()=>{
 assert.equal(data[19].length,12);
 for(const role of ['anon','authenticated','service_role']){
  const r=data[19].find(r=>r.member_role==='authenticator'&&r.granted_role===role);assert(r);
  assert.equal(r.set_option,'true');assert.equal(r.inherit_option,'false');
 }
});
const review={scope:'All five CSVs read locally. Consistency/interpretation assertions, not live Auth/RLS tests.',
 projectContext:'Screenshots visibly show smarthatch-test/main; they do not display the exact project ref or prove all CSVs came from that project. No production state inferred.',
 defaultAclCompleteness:'UNKNOWN: export (16) contains exactly 100 rows; original query/result limit is not available. May be truncated or exactly 100; do not call it exhaustive.',
 files,checks,screenshotObservations:[
  'information_schema.schemata and pg_namespace private-name lookups show zero rows.',
  'Four public base tables are shown, matching the known application table names.',
  'An initial pg_tables query fails with SQLSTATE 42703 for forcerowsecurity; corrected pg_class/pg_namespace query returns relrowsecurity=true and relforcerowsecurity=false for four tables.',
  'rls_auto_enable metadata shows postgres owner, SECURITY DEFINER, volatile, search_path=pg_catalog and explicit grants NULL. NULL ACL is not proof that nobody can execute.',
  'A function-definition query returns the event-trigger helper; it is not a bridge-sync function.',
  'supabase_migrations.schema_migrations lookup fails with 42P01; pg_namespace lookup for supabase_migrations shows zero rows. No tracked history there is established, not proof that no SQL/migrations ever ran.',
  'Data API UI shows public and graphql_public exposed, 4/4 tables exposed, 0/1 functions exposed, automatic new-table exposure on, extra search path public/extensions, max rows 1000.',
  'The PRODUCTION badge labels the shown project main branch; it is not proof of accessing the separate egg incubator application project.'
 ],statusEffect:'No further task completion. Both C-01 audits remain Completed; security/remediation and integration tasks retain their own open criteria.'};
fs.writeFileSync(path.join(__dirname,'supplemental-csv-review.json'),JSON.stringify(review,null,2)+'\n');
console.log(JSON.stringify({files:files.map(({rowsReviewed,...x})=>x),checks,defaultAclCompleteness:review.defaultAclCompleteness,statusEffect:review.statusEffect},null,2));
