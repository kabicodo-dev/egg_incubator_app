// Read and index the supplied export without importing reports or executing their contents.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const source='C:/Users/Mary Charlyn/Downloads/SmartHatch-all-reports-2026-10-30-1.json';
const bytes=fs.readFileSync(source),data=JSON.parse(bytes.toString('utf8').replace(/^\uFEFF/,''));
assert.equal(data.app,'smarthatch-portal');assert.equal(data.type,'reports');assert.equal(data.version,1);assert(Array.isArray(data.reports));
const ids=new Set();for(const r of data.reports){assert(!ids.has(r.id));ids.add(r.id);assert.equal(typeof r.body,'string');}
const latest=new Map();
for(const r of data.reports){const old=latest.get(r.taskId);if(!old||Number(r.updatedAt)>Number(old.updatedAt))latest.set(r.taskId,r);}
const patterns={
 decision:/\bD0[1-6]\b|sign.?off|accept|agreed|approved|ratif|frozen|freeze|canonical|source.{0,30}(hash|sha|manifest)|source_revision/i,
 authority:/authoriz|authentic|provision|revo[ck]|nonce|\bMAC\b|\bHMAC\b|pairing|retention|journal|CRC|torn|loss|EEPROM/i,
 completion:/complet|hatched|hatchability|Stop|receipt|cloud|Supabase|outbox|ledger/i
};
const root=path.join(__dirname,'ally-export-review');fs.mkdirSync(root,{recursive:true});
const index=[];
for(const [i,r] of data.reports.entries()){
 const text=['# '+(i+1)+' '+r.taskId+' — '+r.title,'Report ID: '+r.id,'Attribution: '+r.owner+' / '+r.reportedBy,
  'Reported status: '+r.status+'; date: '+r.date+'; latest supplied attempt for task: '+(latest.get(r.taskId).id===r.id),
  '\n## Body\n',r.body,'\n## Evidence links (not supplied files)\n',r.links||''].join('\n');
 // Wrap long logical lines for complete tool reads without silently truncating fields.
 const wrapped=text.split('\n').flatMap(l=>l.length<=160?l:l.match(/.{1,160}/g)).join('\n')+'\n';
 const file=String(i+1).padStart(2,'0')+'-'+r.taskId.replace(/[^A-Za-z0-9_-]/g,'_')+'.md';
 fs.writeFileSync(path.join(root,file),wrapped);
 const lines=(r.body+'\n'+(r.links||'')).split('\n');
 const declaredBodyTaskId=r.body.match(/Task ID:\s*([A-Z]+:[A-Za-z0-9-]+)/)?.[1]||null;
 index.push({number:i+1,file,id:r.id,taskId:r.taskId,owner:r.owner,reportedBy:r.reportedBy,status:r.status,date:r.date,
  declaredBodyTaskId,taskIdMismatch:!!declaredBodyTaskId&&declaredBodyTaskId!==r.taskId,
  createdAt:r.createdAt,updatedAt:r.updatedAt,latestSuppliedAttempt:latest.get(r.taskId).id===r.id,bodyChars:r.body.length,
  bodySha256:crypto.createHash('sha256').update(r.body).digest('hex'),
  keywordHits:Object.fromEntries(Object.entries(patterns).map(([k,p])=>[k,lines.filter(l=>p.test(l))]))});
}
const result={source,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),exportedAt:data.exportedAt,
 reportCount:data.reports.length,distinctTaskCount:latest.size,uniqueReportIds:ids.size,
 importPerformed:false,scope:'Source reports indexed only. Reported status/build/hardware claims are not independent verification; referenced file bodies are not included merely because paths are listed.',reports:index};
result.misfiledReports=index.filter(r=>r.taskIdMismatch).map(r=>({id:r.id,outerTaskId:r.taskId,bodyTaskId:r.declaredBodyTaskId,outerStatus:r.status}));
result.latestAttemptCaution='Latest flags compare outer task IDs only; misfiled reports must not supersede actual RTC/Bluetooth identification evidence.';
const repo=path.resolve(__dirname,'../../..');
result.referencedFiles=[
 'docs/a01_firmware_audit.md','docs/oct26_a02_firmware_interface.md','docs/oct26_a03_a01_findings_for_cha.md',
 'docs/oct26_a04_final_ndjson_format_decision.md','docs/evidence/oct26-a04/2026-10-30/format_decisions.csv',
 'docs/hwimp01_source_patch_start_stop_status.md','docs/hwimp02_durable_recovery_design.md'
].map(p=>({path:p,presentInChaCheckout:fs.existsSync(path.join(repo,p))}));
result.localSourceComparison={
  combinedSha256:crypto.createHash('sha256').update(fs.readFileSync(path.join(repo,'arduino/SmartHatch_Combined/SmartHatch_Combined.ino'))).digest('hex'),
  reportedPatchedCombinedSha256:'7106ebfe01d037c95766cd51c43b43fa02f92b922fc5a180770fd27b3822c5ec',
  localUnoSketchPresent:fs.existsSync(path.join(repo,'arduino/SmartHatch_Uno/SmartHatch_Uno.ino')),
  note:'Different source snapshots. No branch switch/fetch/merge or source adoption performed.'
};
fs.writeFileSync(path.join(root,'index.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({...result,reports:index.map(({keywordHits,...r})=>r)},null,2));
