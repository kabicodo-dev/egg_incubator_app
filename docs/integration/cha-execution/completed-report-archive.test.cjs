const test=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path'),vm=require('node:vm');
const {buildArchive,archiveView}=require('./completed-report-archive.cjs');
const root=path.resolve(__dirname,'../../..');
const source=fs.readFileSync('C:/Users/Mary Charlyn/Downloads/index_combined_FINAL_team_details.html','utf8');
const data=JSON.parse(source.split(/\r?\n/).find(l=>l.startsWith('const FINAL_DATA=')).slice(17).replace(/;$/,''));
const completedIds=new Set(['ORIGINAL:C-01','OCT26:C-01','OCT26:C-03']);
const tasks=data.tasks.map(t=>({...t,status:completedIds.has(t.id)?'Completed':t.status}));
const reports=JSON.parse(fs.readFileSync(path.join(root,'SmartHatch_Cha_Reports_Import.json'),'utf8')).reports;
const archive=buildArchive({tasks,reports,sourceTasks:data.tasks,
 allyExportPath:'C:/Users/Mary Charlyn/Downloads/SmartHatch-all-reports-2026-10-30-1.json',
 expectedAllyHash:'09309a30346acd04b14f4db058d0aa0019dc1a77bbb748535f0b9541b7745da8'});
const a=archive.archive;
const esc=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));

test('archive covers seven completed tasks without fabricating design execution reports',()=>{
 assert.deepEqual(a.counts,{completedTasks:7,chaReportRecords:7,verifiedCompletionReports:4,historicalAttempts:3,designSourceRecords:4,suppliedAllyReports:5});
 assert.equal(a.entries.length,16);assert.equal(new Set(a.entries.map(e=>e.id)).size,16);
 for(const e of a.entries.filter(e=>e.kind==='design')){
  assert.equal(e.report,undefined);assert(e.body.includes('NOT A NEW EXECUTION REPORT'));
  assert(e.body.includes(JSON.stringify(data.tasks.find(t=>t.id===e.taskId),null,2)));
 }
});

test('all available actual Cha report bodies and evidence links are embedded in full',()=>{
 const expected=reports.filter(r=>a.completedTaskIds.includes(r.taskId));
 assert.deepEqual(a.chaReports,expected);
 for(const r of expected){assert(archive.html.includes(esc(r.body)));assert(archive.html.includes(esc(r.links)));}
});

test('Ally supplied Completed labels stay unverified, misfiled IDs retained and flagged',()=>{
 const supplied=a.entries.filter(e=>e.kind==='supplied');assert.equal(supplied.length,5);
 assert.equal(supplied.filter(e=>e.warnings.some(w=>w.startsWith('FILING MISMATCH:'))).length,2);
 assert(supplied.every(e=>e.warnings.some(w=>w.includes('not been independently verified'))));
 assert.equal(a.entries.find(e=>e.id==='R-mvuclz61hgzq').taskId,'OCT26:HW-01');
 assert.equal(a.entries.find(e=>e.id==='R-mvucw1mbzn44').taskId,'OCT26:HW-02');
 assert(!a.chaReports.some(r=>r.owner==='Ally'));
});

test('default/type/owner/task/text filters preserve clear evidence categories',()=>{
 assert.equal(archiveView(a).visible.length,11);
 assert.equal(archiveView(a,{kind:'verified'}).visible.length,4);
 assert.equal(archiveView(a,{kind:'history'}).visible.length,3);
 assert.equal(archiveView(a,{kind:'design'}).visible.length,4);
 assert.equal(archiveView(a,{kind:'supplied',owner:'Ally'}).visible.length,5);
 assert.equal(archiveView(a,{kind:'completed',owner:'Ally'}).visible.length,0);
 assert.equal(archiveView(a,{taskId:'OCT26:C-03',query:'83/83'}).visible.length,1);
 assert.equal(archiveView(a,{kind:'all',text:'FILING MISMATCH'}).visible.length,2);
});

test('identical saved records are hidden from archive display only, with no input mutation',()=>{
 const r=structuredClone(a.chaReports[0]),before=JSON.stringify(r);
 const view=archiveView(a,{},[r]);assert.equal(view.duplicates.length,1);assert.equal(view.visible.length,10);
 assert.equal(JSON.stringify(r),before);assert.deepEqual(archiveView(a,{},[r]),view);
 assert.equal(a.entries.length,16);
});

test('newer/different saved versions are never overwritten or treated as identical',()=>{
 const r=structuredClone(a.chaReports[0]);r.body+=' Synthetic newer local edit.';r.updatedAt=9999999999999;
 const before=JSON.stringify(r),view=archiveView(a,{},[r]);
 assert.equal(view.duplicates.length,0);assert(view.visible.includes(r.id));assert(view.different.includes(r.id));
 assert.equal(JSON.stringify(r),before);
});

test('an existing identical conflict copy prevents duplicate display without altering the newer original',()=>{
 const original=structuredClone(a.chaReports[0]),newer={...original,body:original.body+' Newer version.'};
 const copy={...original,id:'synthetic-imported-copy',copyOf:original.id};
 const saved=[newer,copy],before=JSON.stringify(saved),view=archiveView(a,{},saved);
 assert.equal(view.duplicates.length,1);assert(!view.visible.includes(original.id));assert.equal(JSON.stringify(saved),before);
});

test('legacy task aliases deduplicate only their correct source-qualified task',()=>{
 const r=structuredClone(a.chaReports.find(r=>r.taskId==='ORIGINAL:C-01'));r.taskId='C-01';
 assert(archiveView(a,{},[r]).duplicates.includes(r.id));
 const wrong={...r,taskId:'OCT26:C-01'};assert(!archiveView(a,{},[wrong]).duplicates.includes(r.id));
});

test('untrusted report markup is escaped in HTML and cannot close the JavaScript payload',()=>{
 const payload='</script><script>window.untrustedExecuted=true</script><img src=x onerror=alert(1)>';
 const r={...a.chaReports[0],body:payload,links:payload};
 const built=buildArchive({tasks:[tasks.find(t=>t.id===r.taskId)],reports:[r]});
 assert(built.html.includes(esc(payload)));assert(!built.html.includes('<script>window.untrustedExecuted'));
 assert(!built.runtime.includes(payload));new vm.Script(built.runtime);
});

test('embedded bundle is a report-only snapshot and archive does not require new dependencies',()=>{
 for(const r of a.chaReports){assert(r.id.length<=64);assert(r.body.length<=200000);assert(reports.some(x=>x.id===r.id));}
 assert(!archive.runtime.includes('localStorage.setItem('));assert(!archive.runtime.includes('localStorage.clear('));
 assert(!archive.runtime.includes('localStorage.removeItem('));new vm.Script(archive.runtime+archive.jumps);
 assert(archive.html.includes('publication snapshots only—not newer browser records'));
 assert(archive.html.includes('full-backup controls below to back up your saved records'));
});
