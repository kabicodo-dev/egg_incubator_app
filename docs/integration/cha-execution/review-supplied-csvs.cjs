// Offline review: reads all supplied CSV bytes; no credentials, network or writes to Downloads.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
function csv(text){
 const rows=[];let row=[],value='',quoted=false;
 for(let i=0;i<text.length;i++){
  const c=text[i];
  if(quoted){if(c==='"'&&text[i+1]==='"'){value+='"';i++;}else if(c==='"')quoted=false;else value+=c;}
  else if(c==='"')quoted=true;
  else if(c===','){row.push(value);value='';}
  else if(c==='\n'){row.push(value.replace(/\r$/,''));if(row.some(v=>v!==''))rows.push(row);row=[];value='';}
  else value+=c;
 }
 assert(!quoted,'Unterminated CSV field');
 if(value||row.length){row.push(value.replace(/\r$/,''));rows.push(row);}
 const headers=rows.shift();assert(headers);
 return rows.map(r=>{assert.equal(r.length,headers.length);return Object.fromEntries(headers.map((h,i)=>[h,r[i]]));});
}
const catalog=JSON.parse(fs.readFileSync(path.join(__dirname,'security-run-2026-10-29T19-29-38-293Z/fresh-catalog.json'),'utf8')).rows[0].audit;
const numbers=[6,7,8,9,10,11,12,13,14],files=[],parsed={};
for(const n of numbers){
 const name='Supabase Snippet Untitled query ('+n+').csv';
 const bytes=fs.readFileSync(path.join('C:/Users/Mary Charlyn/Downloads',name));
 const rows=csv(bytes.toString('utf8').replace(/^\uFEFF/,''));parsed[n]=rows;
 files.push({name,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length,rows:rows.length,columns:Object.keys(rows[0]||{}),sourceProject:'NOT_EMBEDDED_IN_CSV',rowsReviewed:rows});
}
const checks=[];const check=(name,fn)=>{fn();checks.push({name,result:'PASSED'});};
const nullable=s=>s==='null'?null:s;
check('13 policy definitions match independently verified test catalog',()=>{
 assert.equal(parsed[6].length,13);
 for(const r of parsed[6]){const p=catalog.policies.find(p=>p.tablename===r.tablename&&p.policyname===r.policyname);
  assert(p);assert.equal(p.cmd,r.cmd);assert.equal(p.qual,nullable(r.using_expression));assert.equal(p.with_check,nullable(r.check_expression));
  assert.equal('{'+p.roles.join(',')+'}',r.roles);assert.equal(p.permissive,r.permissive);}
});
check('eight role grant rows agree with test ACL inventory, not CRUD execution proof',()=>{
 assert.equal(parsed[7].length,8);
 for(const r of parsed[7])for(const [field,privilege] of Object.entries({can_select:'SELECT',can_insert:'INSERT',can_update:'UPDATE',can_delete:'DELETE',can_truncate:'TRUNCATE'})){
  assert.equal(r[field],'true');assert(catalog.grants.some(g=>g.table_name===r.table_name&&g.grantee===r.role_name&&g.privilege_type===privilege));}
});
check('one listed public routine matches test name/security-definer flag',()=>{
 assert.equal(parsed[8].length,1);assert.equal(parsed[8][0].function_name,'rls_auto_enable');
 assert(catalog.routines.some(r=>r.name==='rls_auto_enable'&&r.security_definer));
});
check('function body and enabled DDL event trigger are supplied, not ingest RPCs',()=>{
 assert.equal(parsed[9].length,1);assert(parsed[9][0].function_definition.includes('RETURNS event_trigger'));
 assert(parsed[9][0].function_definition.includes('enable row level security'));
 assert.equal(parsed[10].length,1);assert.equal(parsed[10][0].function_name,'rls_auto_enable');
 assert.equal(parsed[10][0].event_type,'ddl_command_end');
});
check('four primary-key constraints match test catalog',()=>{
 assert.equal(parsed[11].length,4);
 for(const r of parsed[11])assert(catalog.constraints.some(c=>c.table===r.table_name&&c.name===r.constraint_name&&c.definition===r.constraint_definition));
});
check('five indexes including single-active-session guard match test catalog',()=>{
 assert.equal(parsed[12].length,5);
 for(const r of parsed[12])assert(catalog.indexes.some(x=>x.tablename===r.tablename&&x.indexname===r.indexname&&x.indexdef===r.indexdef));
});
check('22 column definitions match test catalog',()=>{
 assert.equal(parsed[13].length,22);
 for(const r of parsed[13]){const c=catalog.columns.find(c=>c.table_name===r.table_name&&c.column_name===r.column_name);
  assert(c);assert.equal(c.data_type,r.data_type);assert.equal(c.is_nullable,r.is_nullable);assert.equal(c.column_default,nullable(r.column_default));}
});
check('four BY DEFAULT identity columns match known test identity columns',()=>{
 assert.equal(parsed[14].length,4);
 for(const r of parsed[14]){assert.equal(r.is_identity,'YES');assert.equal(r.identity_generation,'BY DEFAULT');
  assert(catalog.columns.some(c=>c.table_name===r.table_name&&c.column_name===r.column_name&&c.is_identity==='YES'));}
});
const result={scope:'Complete local review of all nine user CSVs; structural agreement with independently targeted test catalog does not prove CSV project provenance.',
 sourceProject:'CSV exports contain no project ref, original SQL, execution role, verified observation time or fixture test outcomes.',
 files,checks,conclusions:[
  'Schema inventory/audit evidence is valid and useful. An audit can finish with open security findings.',
  'can_* grant booleans are not executed SELECT/INSERT/UPDATE/DELETE tests and do not incorporate all RLS effects.',
  'The rls_auto_enable event trigger enables RLS for new public tables; it does not remove permissive policies or implement bridge-sync RPCs.',
  'This evidence does not establish installation identity, ingestion/ledger/RPC implementation, secure persisted receipts, Flutter/Arduino compatibility or physical integration.'
 ]};
fs.writeFileSync(path.join(__dirname,'supplied-csv-review.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({files:files.map(({rowsReviewed,...f})=>f),checks,scope:result.scope},null,2));
