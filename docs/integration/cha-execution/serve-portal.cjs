// Read-only allowlisted test server; never exposes .env or repository files generally.
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname,'../../..');
const files = new Set(['SmartHatch_Cha_Backend_Updated.html','SmartHatch_Cha_Reports_Import.json','SmartHatch_Cha_Backend_Task_Reports.md','SmartHatch_Cha_Backend_Handoff.md']);
const server=http.createServer((req,res)=>{
 const name=decodeURIComponent(new URL(req.url,'http://localhost').pathname).slice(1);
 if(!files.has(name)){res.writeHead(404);res.end('Not found');return;}
 res.setHeader('Content-Type',name.endsWith('.html')?'text/html; charset=utf-8':name.endsWith('.json')?'application/json':'text/plain; charset=utf-8');
 res.setHeader('Cache-Control','no-store');
 res.end(fs.readFileSync(path.join(root,name)));
});
server.listen(8876,'127.0.0.1',()=>console.log('Isolated portal test origin http://127.0.0.1:8876'));
