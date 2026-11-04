// Offline acceptance/evidence checks for OCT26:C-03. No Supabase or hardware access.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict'),cp=require('node:child_process');
const root=path.resolve(__dirname,'../../..');
const source='C:/Users/Mary Charlyn/Downloads/index_combined_FINAL_team_details.html';
const html=fs.readFileSync(source,'utf8');
const data=JSON.parse(html.split(/\r?\n/).find(l=>l.startsWith('const FINAL_DATA=')).slice(17).replace(/;$/,''));
const manifest=JSON.parse(fs.readFileSync(path.join(__dirname,'independent-task-completions.json'),'utf8'));
const task=manifest.tasks.find(t=>t.id==='OCT26:C-03'),original=data.tasks.find(t=>t.id===task.id);
const report=fs.readFileSync(path.join(__dirname,task.reportFile),'utf8');
const checks=[],check=(name,fn)=>{fn();checks.push({name,result:'PASSED'});};
check('actual task is Mary-owned P0 independent architecture review',()=>{
 assert.equal(original.o,'Mary Charlyn');assert.equal(original.p,'P0');assert.equal(original.status,'Not started');
 assert.deepEqual(original.deps,[]);assert(original.b.includes('Review backend design'));
 assert(original.pre.includes('do not reopen selected HC-05/Android architecture'));
 assert.equal(task.initialStatus,'Not started');assert.equal(task.status,'Completed');
});
function tap(name,count){
 const text=fs.readFileSync(path.join(__dirname,name),'utf8');
 for(const line of [`1..${count}`,`# tests ${count}`,`# pass ${count}`,'# fail 0','# cancelled 0','# skipped 0','# todo 0'])assert(text.split(/\r?\n/).includes(line),name+': '+line);
 assert(!/^not ok /m.test(text));
 return crypto.createHash('sha256').update(text).digest('hex');
}
const logHashes={};
check('actual targeted output is 13 passing tests with no failures or skips',()=>{logHashes[task.targetedLog]=tap(task.targetedLog,13);});
check('actual full regression output is 83 passing tests including the new 13',()=>{logHashes[task.regressionLog]=tap(task.regressionLog,83);});
check('review maps all required boundaries and leaves shared implementation gaps explicit',()=>{
 for(const word of ['Uno','HC-05','Android','Supabase','retention_ack','CONTRACT_NOT_ENABLED','stopped_event_id','historical','NOT RUN'])assert(report.includes(word));
 assert(report.includes('Mary\'s personal request'));assert(report.includes('not silently repaired here'));
 assert(report.includes('not implement'));assert(report.includes('No additional team answer'));
});
const sourcePaths=['supabase/functions/_shared/bridge-sync-core.mjs','supabase/functions/_shared/bridge-sync-supabase.mjs',
 'supabase/functions/bridge-sync/index.ts','supabase/dev/serve-bridge-sync.mjs','lib/main.dart','lib/services/supabase_service.dart'];
check('tracked application/backend/firmware/drafts/migrations remain unchanged',()=>{
 const result=cp.spawnSync('git',['diff','--quiet','--','lib','arduino','supabase/functions','supabase/dev','supabase/drafts','supabase/migrations'],{cwd:root,encoding:'utf8'});
 assert.equal(result.status,0,'Unexpected production-source diff: inspect rather than discard');
});
check('source gate and candidate lifecycle rules have not been enabled/revised',()=>{
 const code=fs.readFileSync(path.join(root,sourcePaths[0]),'utf8');
 assert(code.includes("throw new BridgeError('CONTRACT_NOT_ENABLED',503"));
 assert(code.includes("keys(b.data,['eggs_hatched','stopped_event_id','actor_installation_id'])"));
 const entry=fs.readFileSync(path.join(root,sourcePaths[2]),'utf8');assert(entry.includes('handler=createBridgeSyncHandler({ports})'));
});
const sourceHashes=Object.fromEntries([...sourcePaths,'test/backend/architecture_alignment_test.mjs'].map(p=>[p,crypto.createHash('sha256').update(fs.readFileSync(path.join(root,p))).digest('hex')]));

// Reasons for parking remaining source records, not bulk changes to portal status.
const gate={
 'ORIGINAL:C-02':'Exact selected interface packet and Ally/Kath schema review are missing.',
 'ORIGINAL:C-03':'Secure source ingestion needs the selected source contract, identity scope and separately authorized schema/RPC implementation.',
 'ORIGINAL:C-04':'Actual installation bootstrap/session/Flutter compatibility remains undecided; no pilot enrollment approved.',
 'ORIGINAL:C-05':'Full authorized/other/revoked matrix needs implemented identity/RPC boundaries; the sensor role probe is not that matrix.',
 'ORIGINAL:C-06':'Confirmed source command/batch lifecycle and real Start reconciliation are not pinned/implemented across owners.',
 'ORIGINAL:C-07':'Original source timestamp/identity and batch-association mapping are not finalized.',
 'ORIGINAL:C-08':'Manual completion independent of Stop is a pending shared change; persisted validated completion is not verified.',
 'ORIGINAL:C-09':'Measured cadence/freshness policy required by this task is not approved; do not invent a threshold.',
 'OCT26:ARCH-05':'Formal adoption/repository-baseline evidence is not supplied; a locally drafted amendment is not adoption.',
 'OCT26:ARCH-06':'Actual distribution/recipient/date acknowledgments are missing; preparing a handoff is not sending it.',
 'OCT26:C-02A':'Existing provisional schema still lacks the required Ally/Kath review.',
 'OCT26:C-02B':'Requires reviewed provisional contract and the actual matching Ally interface/handoff packet, not report path strings.',
 'OCT26:C-02C':'Final fields/examples need the preceding reviews and explicit shared selection.',
 'OCT26:C-04':'Actual secure-ingestion acceptance is source/Auth/SQL-dependent; candidate fixture success is not a real secure endpoint.',
 'OCT26:C-05':'Non-anonymous installation setup and Flutter compatibility remain jointly unresolved.',
 'OCT26:C-06':'Approved species-profile input and database values/approval provenance have not been established.',
 'OCT26:C-07':'Depends on species-profile verification; app/profile behavior cannot be finalized from unapproved values.',
 'OCT26:C-08':'Depends on final contract and physical START/STATE implementation; missing cross-owner source and device evidence.',
 'OCT26:C-09':'Source schema/time/cadence and truthful batch/freshness mapping are not finalized.',
 'OCT26:C-10':'Depends on Kath completion flow and the shared completion rule; real persisted result acceptance remains unverified.',
 'OCT26:C-11':'Real secure synchronization/recovery needs DB-IMP-01 and Kath durable outbox implementation.',
 'OCT26:TEST-01':'Actual approved-transport Arduino/Android communication requires source, Android implementation and authorized devices.',
 'OCT26:TEST-02':'Secure Flutter-to-Supabase sync requires actual identities/RPCs/outbox; not established by host fixtures.',
 'OCT26:TEST-03':'Real Bluetooth/internet failure-recovery evidence is missing; mock link tests are not device results.',
 'OCT26:TEST-04':'Physical autonomous-control loss testing requires source, approvals, hardware and qualified clearance.',
 'OCT26:TEST-05':'Real physical Start/Stop/restart remains unimplemented/unverified; safety and shared lifecycle gates outstanding.',
 'OCT26:TEST-06':'Real sensor accuracy/time/freshness checks need attributable source policy and hardware evidence.',
 'OCT26:TEST-07':'Approved species values and actual integrated species-setting behavior are not verified.',
 'OCT26:TEST-08':'Turning/lockdown depends on approved timing/mechanics and shared implementation; do not infer host checks are physical proof.',
 'OCT26:TEST-09':'Real manual-entry/History persistence and approved completion behavior need the compatible app/backend.',
 'OCT26:TEST-10':'Requires actual farmer usability sessions and records; cannot fabricate participant outcomes.',
 'OCT26:TEST-11':'Requires safety-cleared actual pilot/cycle/hatch data; no real results supplied.',
 'CURRENT:DB-IMP-01':'Exact source/API/identity/storage/lifecycle decisions and separately approved remote implementation are missing.',
 'CURRENT:INT-IMP-01':'Exact matching source/decoder/backend packet and full integration acceptance remain missing; review summaries do not finish the ticket.',
};
const partial=JSON.parse('['+html.match(/const maryPartialIds=\[([^\]]+)\]/)[1].replace(/'/g,'"')+']');
const audits=JSON.parse(fs.readFileSync(path.join(__dirname,'audit-completion.json'),'utf8')).taskIds;
const done=new Set([...audits,...manifest.tasks.filter(t=>t.status==='Completed').map(t=>t.id)]);
const rows=data.tasks.filter(t=>t.o==='Mary Charlyn').map(t=>({...t,status:done.has(t.id)?'Completed':partial.includes(t.id)?'Partial':t.status}));
const remaining=rows.filter(t=>!['Completed','Superseded'].includes(t.status));
check('all 34 remaining Cha source records have explicit parking reasons, not inferred completion',()=>{
 assert.equal(remaining.length,34);assert.equal(rows.filter(t=>t.status==='Completed').length,7);
 for(const t of remaining)assert(gate[t.id],'Missing eligibility assessment for '+t.id);
});
const queue={scope:'Current independent full-completion eligibility assessment only; no portal status mutation',completedNow:[task.id],remainingSourceRecords:remaining.length,
 eligibleForFullCompletionNow:[],parked:remaining.map(t=>({id:t.id,title:t.t,owner:t.o,priority:t.p,statusUnchanged:t.status,reason:gate[t.id]}))};
fs.writeFileSync(path.join(__dirname,'remaining-queue-after-c03.json'),JSON.stringify(queue,null,2)+'\n');
fs.writeFileSync(path.join(__dirname,'REMAINING_QUEUE_AFTER_C03.md'),'# Remaining queue after OCT26:C-03\n\nOne independent architecture review completed. No other source record currently has all inputs needed for full completion without shared decisions, actual distribution/participants, implementation approval or hardware evidence. Parked means a queue decision, not changing the published task status to Blocked. Safe draft/test preparation may still be possible; it must not be labelled a completed full ticket.\n\n| Task | Existing status | Reason full completion is parked |\n|---|---|---|\n'+queue.parked.map(t=>'| '+t.id+' | '+t.statusUnchanged+' | '+t.reason+' |').join('\n')+'\n');
const result={taskId:task.id,recordedAt:new Date().toISOString(),scope:'Architecture review acceptance only; not remote/physical readiness',checks,logHashes,sourceHashes,
 taskStatus:'Completed',newIndependentCompletions:1,remainingChaSourceRecords:34};
fs.writeFileSync(path.join(__dirname,'oct26-c03-validation.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
