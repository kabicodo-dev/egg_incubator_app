// Local source observations only, not Dart execution, production remediation or
// security certification. Re-read exact caller paths to avoid another-branch claims.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../../..');
const targets=['lib/main.dart','lib/services/supabase_service.dart','supabase/functions/_shared/bridge-sync-core.mjs','supabase/functions/_shared/bridge-monitoring.mjs'];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const files=Object.fromEntries(targets.map(p=>{const b=fs.readFileSync(path.join(root,p));return [p,{sha256:hash(b),text:b.toString('utf8')}];}));
function excerpt(file,from,to){const lines=files[file].text.split(/\r?\n/),start=lines.findIndex(l=>l.includes(from));assert(start>=0,from);const end=lines.findIndex((l,i)=>i>start&&l.includes(to));assert(end>start,to);return {file,startLine:start+1,endLine:end+1,text:lines.slice(start,end+1).join('\n')};}
const observations=[
 {id:'SRC-01',tasks:['ORIGINAL:C-08','OCT26:C-10','OCT26:TEST-09'],...excerpt('lib/services/supabase_service.dart','Future<void> completeSession','// ── Stats'),finding:'Current completion path writes Completed and defaults end_date to DateTime.now; no returned-row confirmation in this method. Not the new result-only API and not proof of accepted original time. Coordinate with Kath; do not patch her Flutter here.'},
 {id:'SRC-02',tasks:['ORIGINAL:C-07','ORIGINAL:C-09','OCT26:C-09'],...excerpt('lib/services/supabase_service.dart','Future<Map<String, dynamic>?> getLatestReading','return response;'),finding:'Current method selects global newest recorded_at with no controller/batch filter in this method. Caller/system acceptance must not assume original batch/source selection is implemented.'},
 {id:'SRC-03',tasks:['OCT26:C-06','OCT26:C-07','OCT26:TEST-07'],...excerpt('lib/main.dart','SpeciesData speciesDataForName','/// The farmer-facing Active'),finding:'Unknown/legacy species display helper uses fixed temperature/humidity/day fallback values. This is local UI/source observation, not an authorized profile default or biological approval; unknown-target behavior requires Kath review.'},
 {id:'SRC-04',tasks:['ORIGINAL:C-07','OCT26:C-09'],...excerpt('lib/main.dart','ActiveIncubationScreen activeIncubationScreenFor(Map','/// The Active Incubation screen for an already'),finding:'Current helper substitutes DateTime.now for an unparseable session start_date. Do not call this preserved original Start or a completed truthful-time implementation; coordinated UI change remains pending.'}
];
assert(files[targets[2]].text.includes("throw new BridgeError('CONTRACT_NOT_ENABLED',503"));
const result={date:'2026-10-30',scope:'Read-only source excerpts, no Flutter execution or app behavior test; source may differ from other reviewers branches',sourceFingerprints:Object.fromEntries(targets.map(p=>[p,files[p].sha256])),observations,sourceGate:'Default source acceptance remains CONTRACT_NOT_ENABLED',productionChanges:false};
fs.writeFileSync(path.join(__dirname,'portfolio-source-observations.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({observations:observations.map(o=>({id:o.id,tasks:o.tasks,lines:[o.startLine,o.endLine]})),sourceGate:result.sourceGate},null,2));
