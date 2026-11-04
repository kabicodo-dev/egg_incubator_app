// Prepares a review directory + manifest only. Does not send or deploy anything.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../../..');
const dest=path.join(root,'docs/integration/manual-result-0.1-review-package');
const paths=[
 'docs/contract-review/DB-02_Manual_Result_API_0.1-review.md',
 'docs/contract-review/manual-result-0.1.schema.json',
 'docs/contract-review/manual-result-0.1.fixtures.json',
 'docs/contract-review/manual-result-0.1.closure-matrix.json',
 'docs/contract-review/D04_D06_Mary_Backend_Position.md',
 'docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md',
 'docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md',
 'docs/integration/cha-execution/manual-result-reference.cjs',
 'docs/integration/cha-execution/manual-result-proposal.test.cjs',
 'docs/integration/cha-execution/manual-result-proposal.tap',
 'docs/integration/cha-execution/MANUAL_RESULT_PREPARATION_REPORT.md'
];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
fs.mkdirSync(dest,{recursive:true});
const files=paths.map(p=>{
 const bytes=fs.readFileSync(path.join(root,p)),to=path.join(dest,p);fs.mkdirSync(path.dirname(to),{recursive:true});fs.writeFileSync(to,bytes);
 assert.equal(hash(fs.readFileSync(to)),hash(bytes));return {file:p,bytes:bytes.length,sha256:hash(bytes)};
});
const schema=JSON.parse(fs.readFileSync(path.join(root,paths[1]),'utf8'));
function refs(value){if(!value||typeof value!=='object')return;for(const [key,x] of Object.entries(value)){
 if(key==='$ref'){assert(x.startsWith('#/'));let target=schema;for(const k of x.slice(2).split('/'))target=target[k.replace(/~1/g,'/').replace(/~0/g,'~')];assert(target,'Unresolved '+x);}else refs(x);
}}
refs(schema);
const readme=`# Manual-result API 0.1-review — exact-byte review package

Prepared 2026-10-30. PROPOSED, NOT JOINTLY APPROVED, NOT IMPLEMENTED/DEPLOYED.
The user confirmed personal M01–M07 directions; exact fields are NEW proposals.

Read docs/contract-review/DB-02_Manual_Result_API_0.1-review.md first, then the
companion schema, fixtures and closure matrix. All 24 actual implementation
acceptance cases remain NOT RUN. The 21 passing tests are pure local proposal
checks, not a real server, Auth, database, Flutter or physical integration pass.

Kath: please return ACCEPT / CHANGE / BLOCKED against the exact candidate bytes:
1. Separate result-only version/operation (no old farmer_completed fallback).
2. Original manifest/mapping required; missing stays Pending validation, not dummy IDs.
3. Unknown vs explicitly phone-clock action time; whole-second precision.
4. Exact eight-field core/hash vectors; reproduce canonical UTF-8/digests in Dart.
5. Immutable result receipt/lookup and validation; lossless bigint session mapping.
6. One ordinary result per batch, deferred corrections, unchanged Active/end_date.
7. Durable local freeze/result/outbox and T4 receipt/mapping commit boundaries.
Provide only your concrete package/version/schema/SDK proposal and remaining changes;
do not repeat architecture review or assume these new fields are already approved.

Ally: this adds NO controller command, Stop evidence, admission or release proof.
Existing selected-source/manifest-trust/recovery facts remain your deliverables.
No fresh general audit or physical test is requested.

From the package root, local optional reproduction (no install required):
node docs/integration/cha-execution/manual-result-reference.cjs
node --test docs/integration/cha-execution/manual-result-proposal.test.cjs
These scripts are test-only. Do not import them into production or upload fixtures.
General JSON Schema/raw parser validation is NOT performed by this test oracle.

No code/database changes, deployment, flashing or powered tests authorized.
No external send occurred; preparing this ZIP does not complete distribution.
See manifest.json for byte fingerprints; do not silently edit review inputs.
`;
fs.writeFileSync(path.join(dest,'README.md'),readme);files.push({file:'README.md',bytes:Buffer.byteLength(readme),sha256:hash(Buffer.from(readme))});
fs.writeFileSync(path.join(dest,'manifest.json'),JSON.stringify({contract:'DB02-MANUAL-RESULT-0.1-review',status:'Prepared for review, not delivered/approved',files},null,2)+'\n');
console.log(JSON.stringify({directory:dest,files:files.length,localSchemaReferences:'RESOLVED; not full schema validation'},null,2));
