// Read-only helper characterization, NOT acceptance tests or application code.
// Deliberately identifies missing caller boundaries without modifying production.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const {pathToFileURL}=require('node:url');
const root=path.resolve(__dirname,'../../..');
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
async function main(){
 const file=path.join(root,'supabase/functions/_shared/bridge-monitoring.mjs'),before=sha(file);
 const {remoteReadingStates}=await import(pathToFileURL(file).href);
 const base={current_temperature:25,temperature_valid:true,current_humidity:40,humidity_valid:true,timestamp_valid:true};
 const p={nowMs:Date.parse('2026-03-02T00:00:00Z'),staleAfterMs:5000,futureSkewMs:0};
 const malformed=remoteReadingStates({...base,measured_at:'2026-02-30T00:00:00Z'},p);
 assert.equal(malformed.temperature.state,'fresh');
 const unassociated=remoteReadingStates({...base,measured_at:'2026-03-02T00:00:00Z'},p);
 assert.equal(unassociated.temperature.state,'fresh');
 const disconnected=remoteReadingStates({...base,measured_at:'2026-03-02T00:00:00Z',connected:false},p);
 assert.equal(disconnected.temperature.state,'fresh');assert(!('connected' in disconnected));
 assert.equal(sha(file),before);
 const result={date:'2026-10-30',source:'supabase/functions/_shared/bridge-monitoring.mjs',sourceSha256:before,
 scope:'Observed pure-helper behavior only. These are caller-boundary findings, NOT accepted production safety results or proof an actual upstream path is exploitable.',
 findings:[
  {id:'MON-01',input:'measured_at=2026-02-30T00:00:00Z, now=2026-03-02T00:00:00Z',observed:malformed.temperature,
   required:'A strict validated input boundary must reject impossible calendar dates before freshness classification. Date.parse alone normalizes this date; helper must not serve as raw timestamp validator.',status:'CALLER/INTEGRATION GUARD NOT VERIFIED'},
  {id:'MON-02',input:'No device_id, batch_id or sample identity; otherwise fresh synthetic values',observed:unassociated.temperature,
   required:'Validate source authorization and original batch/sample association before selecting a live reading. Helper itself cannot establish association and must not be the selection/security gate.',status:'CALLER/INTEGRATION GUARD NOT VERIFIED'},
  {id:'MON-03',input:'connected:false plus otherwise fresh synthetic acquisition',observed:disconnected.temperature,
   required:'Track transport connected/disconnected as an independent dimension; metric freshness alone is not connection status. Do not interpret loss as physical Stop or suppress the separate disconnection warning.',status:'UI/TRANSPORT COMPOSITION NOT VERIFIED'}
 ],productionSourceChanged:false,selectedFreshnessThreshold:null,newTaskCompletions:[]};
 fs.writeFileSync(path.join(__dirname,'monitoring-boundary-probes.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
