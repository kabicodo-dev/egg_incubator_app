// Isolated headless profile only. No user browser, backend or network credentials.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {spawn}=require('node:child_process');
const {pathToFileURL}=require('node:url');
const temp='C:/Users/Mary Charlyn/AppData/Local/Temp/opencode';
const profile=fs.mkdtempSync(path.join(temp,'completed-archive-browser-'));
const browser=spawn('C:/Program Files/Google/Chrome/Application/chrome.exe',[
 '--headless=new','--disable-gpu','--no-first-run','--no-default-browser-check',
 '--remote-debugging-address=127.0.0.1','--remote-debugging-port=0','--user-data-dir='+profile,'about:blank'
],{stdio:['ignore','ignore','pipe']});
const checks=[],errors=[];let socket;
async function main(){
 const endpoint=await new Promise((resolve,reject)=>{
  let text='';browser.stderr.on('data',chunk=>{text+=chunk;const match=text.match(/DevTools listening on (ws:\/\/[^\s]+)/);if(match)resolve(match[1]);});
  browser.once('error',reject);browser.once('exit',code=>reject(new Error('Browser exited '+code)));
 });
 socket=new WebSocket(endpoint);await new Promise((resolve,reject)=>{socket.addEventListener('open',resolve,{once:true});socket.addEventListener('error',reject,{once:true});});
 let id=0;const pending=new Map(),events=new Map();
 socket.addEventListener('message',event=>{const m=JSON.parse(event.data);
  if(m.id){const p=pending.get(m.id);if(!p)return;pending.delete(m.id);m.error?p.reject(new Error(JSON.stringify(m.error))):p.resolve(m.result);}
  else {if(m.method==='Runtime.exceptionThrown')errors.push(m.params.exceptionDetails);const key=(m.sessionId||'')+':'+m.method;const f=events.get(key);if(f){events.delete(key);f(m.params);}}
 });
 function send(method,params={},sessionId){return new Promise((resolve,reject)=>{const n=++id;pending.set(n,{resolve,reject});socket.send(JSON.stringify({id:n,method,params,...(sessionId?{sessionId}:{})}));});}
 const target=await send('Target.createTarget',{url:'about:blank'});
 const {sessionId:s}=await send('Target.attachToTarget',{targetId:target.targetId,flatten:true});
 const cmd=(m,p)=>send(m,p,s);
 await cmd('Page.enable');await cmd('Runtime.enable');
 const evaluate=async expression=>{const r=await cmd('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});if(r.exceptionDetails)throw new Error(JSON.stringify(r.exceptionDetails));return r.result.value;};
 const waitLoad=()=>new Promise(resolve=>events.set(s+':Page.loadEventFired',resolve));
 const url=pathToFileURL(path.resolve(__dirname,'../../../SmartHatch_Cha_Backend_Updated.html')).href;
 async function load(reload=false){const done=waitLoad();await cmd(reload?'Page.reload':'Page.navigate',reload?{}:{url});await done;}
 async function check(name,fn){await fn();checks.push({name,result:'PASSED'});}
 const count=()=>evaluate('Array.from(document.querySelectorAll("[data-archive-id]")).filter(x=>!x.hidden).length');
 async function filter(id,value){await evaluate(`(()=>{const e=document.getElementById(${JSON.stringify(id)});e.value=${JSON.stringify(value)};e.dispatchEvent(new Event(e.tagName==='SELECT'?'change':'input',{bubbles:true}));})()`);}
 await load();
 await check('portal boot has 136 tasks, eight tabs, seven archive task groups and seven jump links',async()=>{
  const v=await evaluate('({tasks:document.querySelectorAll(".task").length,tabs:document.querySelectorAll("[role=tab]").length,groups:document.querySelectorAll(".ec-task-group").length,jumps:document.querySelectorAll(".embedded-completion-jump").length,reports:localStorage.getItem("sh_reports_v1")})');
  assert.equal(v.tasks,136);assert.equal(v.tabs,8);assert.equal(v.groups,8);assert.equal(v.jumps,7);assert.equal(v.reports,null);
 });
 await evaluate('document.getElementById("tab-reports").click()');
 if(fs.existsSync(path.resolve(__dirname,'../remaining-task-workqueue/task-index.json')))await check('all remaining-task preparation cards/requests render without changing task counts or claiming acceptance',async()=>{
  const v=await evaluate('({cards:document.querySelectorAll("[data-workqueue-task]").length,cases:document.querySelectorAll("[data-workqueue-case]").length,requests:document.querySelectorAll("[data-workqueue-decision]").length,tasks:document.querySelectorAll(".task").length,section:!!document.getElementById("remaining-task-preparation"),notStarted:FINAL_DATA.tasks.filter(t=>t.o==="Mary Charlyn"&&t.status==="Not started").length})');
  assert.equal(v.cards,34);assert.equal(v.cases,102);assert.equal(v.requests,14);assert.equal(v.tasks,136);assert.equal(v.section,true);assert.equal(v.notStarted,25);
  assert.equal(await evaluate('Array.from(document.querySelectorAll("[data-workqueue-case]")).every(e=>e.textContent.includes("NOT RUN"))'),true);
 });
 if(fs.existsSync(path.join(__dirname,'ally-zip-progress.json')))await check('review and independent verification render Partial; completed archive and dependencies unchanged',async()=>{
  const v=await evaluate('({status:FINAL_DATA.tasks.find(t=>t.id==="OCT26:C-02B").status,deps:FINAL_DATA.tasks.find(t=>t.id==="OCT26:C-02B").deps,completed:FINAL_DATA.tasks.filter(t=>t.o==="Mary Charlyn"&&t.status==="Completed").length,body:document.getElementById("cha-execution-20261030").textContent.includes("all thirteen positions")})');
  assert.equal(v.status,'Partial');assert.equal(v.completed,7);assert.deepEqual(v.deps,['OCT26:A-01','OCT26:C-02A']);assert.equal(v.body,true);
  const schemaProgress=JSON.parse(fs.readFileSync(path.join(__dirname,'ally-zip-progress.json'),'utf8')).tasks.some(t=>t.id==='OCT26:C-02A');
  if(schemaProgress){
   assert.equal(await evaluate('FINAL_DATA.tasks.find(t=>t.id==="OCT26:C-02A").status'),'Partial');
   assert.equal(await evaluate('document.getElementById("cha-execution-20261030").textContent.includes("13/13 test groups")'),true);
  }
  const monitoringProgress=JSON.parse(fs.readFileSync(path.join(__dirname,'ally-zip-progress.json'),'utf8')).tasks.some(t=>t.id==='ORIGINAL:C-09');
  if(monitoringProgress){
   assert.equal(await evaluate('FINAL_DATA.tasks.find(t=>t.id==="ORIGINAL:C-09").status'),'Partial');
   assert.equal(await evaluate('document.getElementById("cha-execution-20261030").textContent.includes("27/27 passed")'),true);
  }
 });
 await check('all full embedded bodies and links match publication data byte for byte',async()=>{
  assert.equal(await evaluate('SH_COMPLETED_REPORT_ARCHIVE.entries.every(e=>{const p=document.getElementById("embedded-report-"+e.id).querySelectorAll("pre");return p[0].textContent===e.body&&p[1].textContent===e.links;})'),true);
  assert.equal(await count(),11);
 });
 await check('type owner task and text filters work independently',async()=>{
  for(const [kind,n] of [['verified',4],['history',3],['design',4],['supplied',5],['all',16]]){await filter('ecKind',kind);assert.equal(await count(),n);}
  await filter('ecOwner','Ally');assert.equal(await count(),5);
  await filter('ecOwner','ALL');await filter('ecTask','OCT26:C-03');assert.equal(await count(),1);
  await filter('ecSearch','83/83');assert.equal(await count(),1);
  await filter('ecSearch','not a real matching phrase');assert.equal(await count(),0);
  await filter('ecSearch','');await filter('ecTask','ALL');await filter('ecKind','completed');
 });
 await check('expand collapse and overview/task anchors route to Reports',async()=>{
  await evaluate('document.getElementById("ecExpand").click()');assert.equal(await evaluate('Array.from(document.querySelectorAll("[data-archive-id]")).filter(x=>!x.hidden&&x.open).length'),11);
  await evaluate('document.getElementById("ecCollapse").click()');assert.equal(await evaluate('document.querySelectorAll("[data-archive-id][open]").length'),0);
  await evaluate('document.getElementById("tab-home").click();Array.from(document.querySelectorAll("a")).find(a=>a.getAttribute("href")==="#completed-report-archive").click()');
  assert.equal(await evaluate('document.getElementById("panel-reports").hidden'),false);
  assert.equal(await evaluate('Array.from(document.querySelectorAll(".embedded-completion-jump")).every(a=>{document.getElementById("tab-tracker").click();a.click();return !document.getElementById("panel-reports").hidden&&!!document.getElementById(a.hash.slice(1));})'),true);
 });
 await check('global search routes a full-body match to Reports',async()=>{
  await evaluate('document.getElementById("tab-home").click()');
  await filter('q','FILING MISMATCH');await filter('ecKind','all');
  // Global search must include archive matches when its type filter permits them.
  await filter('q','');await filter('q','FILING MISMATCH');
  assert.equal(await count(),2);assert.equal(await evaluate('document.getElementById("panel-reports").hidden'),false);
  await filter('q','');await filter('ecKind','completed');
 });
 await check('snapshot export contains exactly seven unchanged Cha records and no Ally/design summaries',async()=>{
  await evaluate('window.__exportBlob=null;window.__createObjectURL=URL.createObjectURL;URL.createObjectURL=function(blob){window.__exportBlob=blob;return window.__createObjectURL(blob)};document.getElementById("ecExport").click()');
  const payload=await evaluate('window.__exportBlob.text().then(JSON.parse)');
  assert.equal(payload.type,'reports');assert.equal(payload.reports.length,7);
  const expected=JSON.parse(fs.readFileSync(path.resolve(__dirname,'../../../SmartHatch_Cha_Reports_Import.json'),'utf8')).reports;
  assert.deepEqual(payload.reports,expected.filter(r=>['ORIGINAL:C-01','OCT26:C-01','OCT26:C-03'].includes(r.taskId)));
 });
 await check('320/390/768/1440 viewport archive controls and expanded cards fit horizontally',async()=>{
  for(const width of [320,390,768,1440]){
   await cmd('Emulation.setDeviceMetricsOverride',{width,height:900,deviceScaleFactor:1,mobile:width<768});
   await evaluate('document.getElementById("ecExpand").click()');
   const v=await evaluate('(()=>{const a=document.getElementById("completed-report-archive"),r=a.getBoundingClientRect();return {width:innerWidth,right:r.right,scroll:a.scrollWidth,client:a.clientWidth};})()');
   assert(v.right<=v.width+1,JSON.stringify({width,...v}));assert(v.scroll<=v.client+1,JSON.stringify({width,...v}));
  }
 });
 const seeded=await evaluate(`(()=>{const a=SH_COMPLETED_REPORT_ARCHIVE.chaReports;const identical=structuredClone(a[0]),newer=structuredClone(a[1]);newer.body+=' SYNTHETIC NEWER LOCAL VERSION';newer.updatedAt=9999999999999;
 const values={sh_reports_v1:JSON.stringify([identical,newer]),sh_state_v2:JSON.stringify({'OCT26:C-03':{status:'Partial',note:'synthetic local override'}}),sh_ev:JSON.stringify([]),sh_status:JSON.stringify({synthetic:'preserve'}),sh_last_export:'synthetic preserved export marker'};
 Object.entries(values).forEach(([k,v])=>localStorage.setItem(k,v));return values;})()`);
 await load(true);
 await check('reload byte-preserves existing reports status evidence and export markers',async()=>{
  const actual=await evaluate('Object.fromEntries('+JSON.stringify(Object.keys(seeded))+'.map(k=>[k,localStorage.getItem(k)]))');assert.deepEqual(actual,seeded);
  assert.equal(await count(),10);
  assert.equal(await evaluate('document.querySelectorAll(".ec-version-note:not([hidden])").length'),1);
 });
 await check('original report editor can still save without importing archive or changing task statuses',async()=>{
  await evaluate('document.getElementById("tab-reports").click()');
  await filter('rTask','OCT26:C-03');await filter('rBy','Mary Charlyn');await filter('rStatus','Partial');
  await evaluate('document.getElementById("rBody").value="Synthetic isolated-profile editor smoke check";document.getElementById("rSave").click()');
  const records=await evaluate('JSON.parse(localStorage.getItem("sh_reports_v1"))');assert.equal(records.length,3);
  assert(records.some(r=>r.body==='Synthetic isolated-profile editor smoke check'));
  assert.equal(await evaluate('localStorage.getItem("sh_state_v2")'),seeded.sh_state_v2);
 });
 assert.equal(errors.length,0,JSON.stringify(errors));
 fs.writeFileSync(path.join(__dirname,'completed-report-archive-browser.json'),JSON.stringify({browser:'Chrome headless isolated profile',url,profile,checks,runtimeErrors:errors,scope:'Local HTML UI only; no cloud or hardware verification'},null,2)+'\n');
 console.log(JSON.stringify(checks,null,2));
 await send('Browser.close');
}
main().catch(error=>{console.error(error);process.exitCode=1;}).finally(()=>{if(socket)socket.close();if(browser.exitCode===null)browser.kill();});
