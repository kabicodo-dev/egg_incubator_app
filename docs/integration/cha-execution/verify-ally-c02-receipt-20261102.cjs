'use strict';
// Local documentation review only. No install, network, serial or database access.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const cp = require('node:child_process');
const root = path.resolve(__dirname, '../../..');
const sha = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const inputs = {};
function read(relative) {
  const bytes = fs.readFileSync(path.join(root, relative));
  inputs[relative] = sha(bytes);
  return bytes.toString('utf8');
}
const supplied = fs.readFileSync('C:/Users/Mary Charlyn/Downloads/c-02.txt');
const snapshot = path.join(__dirname, 'received-ally-c02-20261102.txt');
if (fs.existsSync(snapshot)) assert.equal(sha(fs.readFileSync(snapshot)), sha(supplied));
else fs.writeFileSync(snapshot, supplied, {flag: 'wx'});
const response = read('docs/integration/cha-execution/received-ally-c02-20261102.txt');
const checks = [];
function check(name, fn) { fn(); checks.push({name, result: 'PASSED'}); }
const expected = {
  'C02-provisional-communication-contract.md': '3559b60ace2b2d12e0a52304ed4ff1d9831a416b9a4edb5478d7ec359a69ddb7',
  'C02-provisional.schema.json': '9e95d34ca160cae8600548c5c4919ece26953d892d77bd786198d9e9e15461dd',
  'C02-provisional.examples.json': '155a44ed24f2c0627481822569c008b1ee332d315d72abe3bf9f09fc584275b5'
};
check('Both delivered reviews refer to unchanged provisional input bytes', () => {
  const kath = read('docs/integration/cha-execution/kath-focused-review-inputs/Kath-C02-Provisional-Focused-Review-2026-10-30.md');
  for (const [name, hash] of Object.entries(expected)) {
    read('docs/' + name);
    read('docs/integration/cha-execution/kath-focused-review-inputs/' + name);
    assert.equal(inputs['docs/' + name], hash);
    assert.equal(inputs['docs/integration/cha-execution/kath-focused-review-inputs/' + name], hash);
    assert(response.includes(hash));
    assert(kath.includes(hash));
  }
});
check('Ally delivers CHANGE, supersession and no replacement-contract claim', () => {
  for (const text of ['REQUEST CHANGES', 'START_BATCH/CONFIRM is not implemented', 'I have not issued a corrected contract', '266 B SRAM free']) assert(response.includes(text));
});
check('Existing A-01 comparison covers all ten finding IDs', () => {
  const comparison = read('docs/integration/cha-execution/ALLY_ZIP_C02B_REVIEW.md');
  for (let i = 1; i <= 10; i++) assert(comparison.includes('F-' + String(i).padStart(2, '0')));
});
read('docs/validate-c02-provisional.cjs');
const modules = 'C:/Users/Mary Charlyn/AppData/Local/Temp/opencode/node_modules';
const versions = Object.fromEntries(['ajv', 'ajv-formats'].map(name => [name,
  JSON.parse(fs.readFileSync(path.join(modules, name, 'package.json'), 'utf8')).version]));
check('Existing temporary validator tools available without installation', () => {
  assert(versions.ajv.startsWith('8.'));
  assert(versions['ajv-formats'].startsWith('3.'));
});
const run = cp.spawnSync(process.execPath, ['docs/validate-c02-provisional.cjs'], {
  cwd: root, env: {...process.env, NODE_PATH: modules}, encoding: 'utf8', timeout: 60000
});
const log = (run.stdout || '') + (run.stderr || '');
fs.writeFileSync(path.join(__dirname, 'ally-c02-schema-revalidation-20261102.txt'), log);
check('Current unchanged validator passes 14 examples, 65 negatives and 11 unsafe frames', () => {
  assert.equal(run.status, 0, log);
  for (const text of ['14 labeled synthetic messages accepted', '65 schema-negative mutations rejected', '11 malformed/unsafe frame fixtures rejected']) assert(log.includes(text));
});
check('All fingerprinted review inputs unchanged after execution', () => {
  for (const [file, hash] of Object.entries(inputs)) assert.equal(sha(fs.readFileSync(path.join(root, file))), hash);
});
const result = {
  recordedAt: new Date().toISOString(), node: process.version, versions,
  suppliedResponseSha256: sha(supplied), inputs, checks,
  logSha256: sha(Buffer.from(log)),
  assessment: {
    'OCT26:C-02A': 'Review-only criteria demonstrated at user-delivered review-evidence level; eligible for scoped completion, not protocol approval',
    'OCT26:C-02B': 'Ten-finding comparison evidenced; formal OCT26:A-01 dependency completion not independently certified here; retain Partial'
  },
  publishedStatusChanges: [],
  limits: ['No firmware compatibility/build/physical verification', 'No independent reviewer-identity authentication', 'No source selection, ingestion activation or implementation authorization', 'No portal/browser-storage changes']
};
fs.writeFileSync(path.join(__dirname, 'ally-c02-receipt-verification-20261102.json'), JSON.stringify(result, null, 2) + '\n');
console.log(JSON.stringify(result, null, 2));
