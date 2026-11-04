// Executes documentation validators using ALREADY INSTALLED approved-temp tools.
// No install/network/database/production source writes. UTF-8 evidence logs only.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict'),cp=require('node:child_process');
const root=path.resolve(__dirname,'../../..');
const tools='C:/Users/Mary Charlyn/AppData/Local/Temp/opencode/node_modules';
const inputPaths=['docs/validate-c02-provisional.cjs','docs/C02-provisional-communication-contract.md','docs/C02-provisional.schema.json','docs/C02-provisional.examples.json',
 'docs/contract-review/manual-result-0.1.schema.json','docs/contract-review/manual-result-0.1.fixtures.json','docs/contract-review/manual-result-0.1.closure-matrix.json'];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const before=Object.fromEntries(inputPaths.map(p=>[p,hash(fs.readFileSync(path.join(root,p)))]));
const versions=Object.fromEntries(['ajv','ajv-formats'].map(p=>[p,JSON.parse(fs.readFileSync(path.join(tools,p,'package.json'),'utf8')).version]));
assert.equal(versions.ajv,'8.17.1');assert.equal(versions['ajv-formats'],'3.0.1');
function run(args,file){
 const r=cp.spawnSync(process.execPath,args,{cwd:root,env:{...process.env,NODE_PATH:tools},encoding:'utf8',timeout:60000});
 fs.writeFileSync(path.join(__dirname,file),(r.stdout||'')+(r.stderr||''));
 assert.equal(r.status,0,'Validator failed; inspect '+file);return r.stdout;
}
const legacy=run(['docs/validate-c02-provisional.cjs'],'c02-schema-revalidation.txt');
for(const line of ['14 labeled synthetic messages accepted','65 schema-negative mutations rejected','11 malformed/unsafe frame fixtures rejected'])assert(legacy.includes(line));
const modern=run(['--test','--test-reporter=tap','docs/integration/cha-execution/manual-result-jsonschema.test.cjs'],'manual-result-jsonschema.tap');
assert(/^# pass 13$/m.test(modern));assert(/^# fail 0$/m.test(modern));
const reference=run(['--test','--test-reporter=tap','docs/integration/cha-execution/manual-result-proposal.test.cjs'],'manual-result-reference-revalidation.tap');
assert(/^# pass 21$/m.test(reference));assert(/^# fail 0$/m.test(reference));
for(const [p,h] of Object.entries(before))assert.equal(hash(fs.readFileSync(path.join(root,p))),h,'Input was modified: '+p);
const result={recordedAt:new Date().toISOString(),node:process.version,validatorVersions:versions,dependencies:'Reused approved-temp installation; no package installs or application dependency edits',
 inputHashes:before,inputBytesUnchanged:true,c02:{schemaMetaValidation:'PASSED',positiveFixtures:14,negativeSchemaMutations:65,malformedFrames:11,additional:'CRLF/trailing whitespace and two status/time edges passed'},
 manualResult:{ajvTestGroups:13,referenceTests:21,failures:0,implementationClosureCases:24,implementationClosureStatus:'ALL NOT RUN'},
 limitations:['No selected-protocol compatibility or approval inferred','No Auth/database/durable storage/Dart/raw HTTP/physical tests','Schema alone cannot enforce receipt identity, trusted original quantity or signed-bigint range','Current proposal admits outer/nested lookup mismatch and retryable:true on authorization errors as shapes; exact runtime guards/future schema hardening required'],
 taskStatusChanges:[],newFullTaskCompletions:[]};
fs.writeFileSync(path.join(__dirname,'independent-schema-verification.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
