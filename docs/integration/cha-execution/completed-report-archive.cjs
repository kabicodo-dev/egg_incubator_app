// Self-contained, read-only report archive. Never imports records or writes browser storage.
const fs=require('node:fs');
const crypto=require('node:crypto');
const assert=require('node:assert/strict');
const esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const json=x=>JSON.stringify(x).replace(/</g,'\\u003c').replace(/\u2028/g,'\\u2028').replace(/\u2029/g,'\\u2029');
const taskAnchor=id=>'embedded-completed-task-'+id.replace(/[^A-Za-z0-9_-]/g,'-');

// Shared pure model for browser rendering and offline unit tests. Inputs remain unchanged.
function archiveView(archive,filters={},saved=[]){
 const aliases=archive.aliases||{};
 const canonical=id=>aliases[id]||id;
 const same=(a,b)=>a.body===b.body&&(a.links||'')===(b.links||'')&&a.status===b.status&&a.date===b.date&&
   canonical(a.taskId)===canonical(b.taskId)&&a.reportedBy===b.reportedBy;
 const records=Array.isArray(saved)?saved:[];
 const queries=[filters.query,filters.text].filter(Boolean).map(s=>String(s).trim().toLowerCase()).filter(Boolean);
 const visible=[],duplicates=[],different=[];
 for(const e of archive.entries){
  const matching=records.filter(r=>e.report&&(r.id===e.report.id||r.copyOf===e.report.id));
  if(matching.some(r=>same(r,e.report))){duplicates.push(e.id);continue;}
  if(matching.length)different.push(e.id);
  const kind=filters.kind||'completed';
  if(kind==='completed'&&e.kind==='supplied')continue;
  if(!['all','completed'].includes(kind)&&e.kind!==kind)continue;
  if(filters.owner&&filters.owner!=='ALL'&&e.owner!==filters.owner)continue;
  if(filters.taskId&&filters.taskId!=='ALL'&&canonical(e.taskId)!==canonical(filters.taskId))continue;
  const haystack=[e.taskId,e.owner,e.title,e.status,e.date,e.body,e.links,...e.warnings].join(' ').toLowerCase();
  if(!queries.every(q=>haystack.includes(q)))continue;
  visible.push(e.id);
 }
 return {visible,duplicates,different};
}

function installArchive(archive,view){
 const root=document.getElementById('completed-report-archive');
 const cards=Array.from(root.querySelectorAll('[data-archive-id]'));
 const owner=root.querySelector('#ecOwner'),task=root.querySelector('#ecTask'),kind=root.querySelector('#ecKind'),text=root.querySelector('#ecSearch');
 let saved=[];
 function filters(query){return {owner:owner.value,taskId:task.value,kind:kind.value,text:text.value,query:query??document.getElementById('q').value};}
 function render(records){
  if(Array.isArray(records))saved=records;
  const state=view(archive,filters(),saved),visible=new Set(state.visible),different=new Set(state.different);
  cards.forEach(card=>{const id=card.getAttribute('data-archive-id');card.hidden=!visible.has(id);
   const note=card.querySelector('.ec-version-note');if(note)note.hidden=!different.has(id);
  });
  root.querySelectorAll('[data-archive-group]').forEach(group=>{group.hidden=!Array.from(group.querySelectorAll('[data-archive-id]')).some(card=>!card.hidden);});
  root.querySelector('#ecCount').textContent=state.visible.length+' embedded record(s) shown; '+state.duplicates.length+' identical record(s) already in Saved reports below, not displayed twice.';
  root.querySelector('#ecEmpty').hidden=state.visible.length>0;
 }
 for(const control of [owner,task,kind])control.addEventListener('change',()=>render());
 text.addEventListener('input',()=>render());
 document.getElementById('q').addEventListener('input',()=>render());
 root.querySelector('#ecExpand').addEventListener('click',()=>cards.forEach(c=>{if(!c.hidden)c.open=true;}));
 root.querySelector('#ecCollapse').addEventListener('click',()=>cards.forEach(c=>{c.open=false;}));
 root.querySelector('#ecExport').addEventListener('click',()=>{
  // This exports publication snapshots, NOT a backup of newer browser records.
  const payload={app:'smarthatch-portal',type:'reports',version:1,exportedAt:new Date().toISOString(),reports:archive.chaReports};
  const url=URL.createObjectURL(new Blob([JSON.stringify(payload,null,2)],{type:'application/json'}));
  const a=document.createElement('a');a.href=url;a.download='SmartHatch-embedded-completed-task-reports.json';
  document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1500);
 });
 window.renderEmbeddedCompletedReports=render;
 window.countEmbeddedCompletedMatches=query=>view(archive,filters(query),saved).visible.length;
 render();
}

function buildArchive({tasks,reports,sourceTasks=tasks,allyExportPath,expectedAllyHash}){
 const completed=tasks.filter(t=>t.status==='Completed');
 const completedIds=new Set(completed.map(t=>t.id));
 const chaReports=reports.filter(r=>completedIds.has(r.taskId));
 assert.equal(new Set(chaReports.map(r=>r.id)).size,chaReports.length);
 const aliases=Object.fromEntries(tasks.filter(t=>['ORIGINAL','CURRENT'].includes(t.source)).map(t=>[t.visible,t.id]));
 const entries=chaReports.map(r=>({id:r.id,taskId:r.taskId,owner:r.owner,title:r.title,status:r.status,date:r.date,
  kind:r.status==='Completed'?'verified':'history',body:r.body,links:r.links||'',report:r,
  warnings:r.status==='Completed'?['Verified completion scope is the audit/review described, not a production or hardware pass.']:
   ['Historical attempt for a task now published Completed. This report’s original Partial status/body is preserved.']}));
 for(const t of completed.filter(t=>!chaReports.some(r=>r.taskId===t.id))){
  entries.push({id:'SOURCE-'+t.id.replace(/[^A-Za-z0-9_-]/g,'-'),taskId:t.id,owner:t.o,title:t.t,status:'Completed (existing design decision)',date:'Source publication',kind:'design',
   body:'PRESERVED SOURCE EVIDENCE — NOT A NEW EXECUTION REPORT\n\n'+
    'No separate execution report was supplied for this established design decision. The exact original task record/evidence follows. No tests, implementation, adviser signature or new approval is fabricated.\n\n'+JSON.stringify(sourceTasks.find(x=>x.id===t.id)||t,null,2),
   links:'Original uploaded portal task record and embedded K06/source library',
   warnings:['Existing design-only completion; not hardware/security/integration verification and not a newly authored completion report.']});
 }
 let allyCount=0;
 if(allyExportPath&&fs.existsSync(allyExportPath)){
  const bytes=fs.readFileSync(allyExportPath);
  if(expectedAllyHash)assert.equal(crypto.createHash('sha256').update(bytes).digest('hex'),expectedAllyHash,'Ally export changed; review new bytes before embedding');
  const source=JSON.parse(bytes.toString('utf8'));
  for(const r of source.reports.filter(r=>r.status==='Completed')){
   const declared=r.body.match(/Task ID:\s*([A-Z]+:[A-Za-z0-9-]+)/)?.[1];
   const warnings=['Supplied by Ally with a Completed label. Its claims have not been independently verified here; task status is unchanged.'];
   if(declared&&declared!==r.taskId)warnings.push('FILING MISMATCH: outer task '+r.taskId+' but body task '+declared+'. This is NOT confirmation of RTC/Bluetooth identification.');
   entries.push({id:r.id,taskId:r.taskId,owner:r.owner,title:r.title,status:r.status+' (as reported; not certified)',date:r.date,
    kind:'supplied',body:r.body,links:r.links||'',report:r,warnings});allyCount++;
  }
 }
 assert.equal(new Set(entries.map(e=>e.id)).size,entries.length);
 const archive={version:1,completedTaskIds:[...completedIds],aliases,chaReports,entries,
  counts:{completedTasks:completed.length,chaReportRecords:chaReports.length,verifiedCompletionReports:entries.filter(e=>e.kind==='verified').length,
   historicalAttempts:entries.filter(e=>e.kind==='history').length,designSourceRecords:entries.filter(e=>e.kind==='design').length,suppliedAllyReports:allyCount}};
 const options=[...new Set(entries.map(e=>e.taskId))].map(id=>'<option value="'+esc(id)+'">'+esc(id+' · '+tasks.find(t=>t.id===id)?.t)+'</option>').join('');
 function card(e){
  return '<details class="embedded-completed-card" id="embedded-report-'+esc(e.id)+'" data-archive-id="'+esc(e.id)+'">'+
   '<summary><b>'+esc(e.taskId)+'</b> · '+esc(e.owner)+' · '+esc(e.status)+'<br>'+esc(e.title)+'</summary>'+
   '<p><b>Source record:</b> '+esc(e.id)+' · <b>Date:</b> '+esc(e.date)+' · <a href="#'+esc(e.taskId)+'">Open task</a></p>'+
   e.warnings.map(w=>'<p class="ec-warning">'+esc(w)+'</p>').join('')+
   '<p class="ec-version-note" hidden>A different/newer browser record with this ID is preserved in Saved reports. This is the distinct published snapshot, not a replacement.</p>'+
   '<h4>Full report / preserved evidence</h4><pre>'+esc(e.body)+'</pre><h4>Evidence links and file references</h4><pre>'+esc(e.links)+'</pre></details>';
 }
 const groups=completed.map(t=>'<div class="ec-task-group" data-archive-group="'+esc(t.id)+'"><h3 id="'+esc(taskAnchor(t.id))+'">'+esc(t.id+' — '+t.t)+'</h3><p>'+esc(t.o)+' · Published Completed. Saved browser overrides, if any, are not changed.</p>'+entries.filter(e=>e.taskId===t.id&&e.kind!=='supplied').map(card).join('')+'</div>').join('');
 const supplied='<div class="ec-task-group" data-archive-group="supplied-ally"><h3>Ally reports labelled Completed — supplied evidence only</h3><p>Shown only when the archive filter includes supplied reports. Two filing mismatches are prominently flagged. These records do not change Ally’s task statuses.</p>'+entries.filter(e=>e.kind==='supplied').map(card).join('')+'</div>';
 const html='<article class="section" id="completed-report-archive" data-title="Completed-task reports · embedded"><h2>Completed-task reports — embedded in this HTML</h2>'+
  '<p>Read these offline without importing JSON. '+archive.counts.completedTasks+' completed Cha task records are covered: '+archive.counts.chaReportRecords+' full report/history records across '+new Set(chaReports.map(r=>r.taskId)).size+' audited/reviewed tasks, plus '+archive.counts.designSourceRecords+' original design-evidence records. No standalone report is invented for those design decisions.</p>'+
  '<p>Earlier attempts retain their original status. '+allyCount+' supplied Ally reports with Completed labels are available separately as unverified evidence, including the two misfiled HW-IMP bodies. Saved reports below remain editable and are never overwritten or automatically imported. Identical saved copies are not displayed twice.</p>'+
  entries.filter(e=>e.kind==='supplied').flatMap(e=>e.warnings.filter(w=>w.startsWith('FILING MISMATCH:')).map(w=>'<p class="ec-warning"><b>'+esc(e.id)+'</b>: '+esc(w)+'</p>')).join('')+
  '<div class="toolbar"><label>Owner <select id="ecOwner"><option value="ALL">Everyone</option><option value="Mary Charlyn">Mary Charlyn (Cha/Mary)</option><option>Ally</option></select></label>'+
  '<label>Task <select id="ecTask"><option value="ALL">All tasks</option>'+options+'</select></label>'+
  '<label>Evidence type <select id="ecKind"><option value="completed">Completed tasks + earlier attempts</option><option value="verified">Verified completion reports</option><option value="history">Historical attempts</option><option value="design">Existing design source evidence</option><option value="supplied">Ally supplied Completed labels</option><option value="all">All embedded records</option></select></label>'+
  '<label>Search embedded text <input id="ecSearch" type="search" autocomplete="off"></label></div>'+
  '<div class="toolbar"><button type="button" class="btn" id="ecExpand">Expand shown reports</button><button type="button" class="btn" id="ecCollapse">Collapse reports</button><button type="button" class="btn" id="ecExport">Export embedded Cha reports ('+chaReports.length+')</button></div>'+
  '<p>This export contains publication snapshots only—not newer browser records, design-source summaries, or misfiled Ally records. Use the original full-backup controls below to back up your saved records.</p>'+
  '<p id="ecCount" role="status" aria-live="polite"></p><p id="ecEmpty" hidden>No embedded records match, or identical records are already in Saved reports below. Change these filters or open Saved reports.</p>'+
  groups+supplied+'</article>';
 const runtime='\n/* Self-contained completed-report archive: read-only view, no startup import/storage writes. */\nconst SH_COMPLETED_REPORT_ARCHIVE='+json(archive)+';\n('+installArchive.toString()+')(SH_COMPLETED_REPORT_ARCHIVE,'+archiveView.toString()+');\n';
 const jumps='\n/* Links to embedded reports preserve the existing View/Add Report editor workflow. */\n'+json(completed.map(t=>({id:t.id,anchor:taskAnchor(t.id)})))+'.forEach(x=>{const row=document.querySelector(\'[data-task="\'+x.id+\'"]\');if(!row)return;const p=document.createElement("p"),a=document.createElement("a");a.className="btn embedded-completion-jump";a.href="#"+x.anchor;a.textContent="Read embedded completion reports";p.appendChild(a);(row.querySelector(".pbox")||row).appendChild(p);});\n{const h=document.querySelector("#reports .callout h3");if(h)h.textContent="Browser-saved reports live on this device";const p=document.createElement("p"),a=document.createElement("a");a.href="#completed-report-archive";a.textContent="Read the self-contained completed-task report archive below";p.appendChild(a);document.getElementById("reports").appendChild(p);}\n';
 const css='\n#completed-report-archive{min-width:0;overflow-wrap:anywhere}#completed-report-archive .toolbar{display:flex;flex-wrap:wrap;gap:12px;align-items:end}#completed-report-archive label{display:flex;flex-direction:column;gap:4px;min-width:0;max-width:100%}#completed-report-archive select,#completed-report-archive input{max-width:100%;min-width:0}#completed-report-archive pre{white-space:pre-wrap;overflow-wrap:anywhere;max-width:100%;box-sizing:border-box}#completed-report-archive .embedded-completed-card{min-width:0;border:1px solid var(--line);border-radius:12px;padding:14px;margin:12px 0;background:var(--paper,#fff)}#completed-report-archive summary{cursor:pointer;overflow-wrap:anywhere}#completed-report-archive .ec-warning,#completed-report-archive .ec-version-note{padding:10px;border-left:3px solid var(--brand);background:var(--soft,#f5f7f8)}#completed-report-archive [hidden]{display:none!important}.embedded-completion-jump{max-width:100%;white-space:normal;overflow-wrap:anywhere}\n';
 return {archive,html,runtime,jumps,css};
}
module.exports={buildArchive,archiveView};
