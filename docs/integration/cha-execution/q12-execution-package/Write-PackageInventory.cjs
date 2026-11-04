// Local reads and create-new evidence only; no external access or subprocess.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const assert = require('assert/strict');
const root = path.resolve(__dirname, '../../../..');
const relative = p => path.relative(root, p).replaceAll('\\', '/');
const hash = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const read = p => JSON.parse(fs.readFileSync(p, 'utf8').replace(/^\uFEFF/, ''));
const write = (p, data) => fs.writeFileSync(p, JSON.stringify(data, null, 2) + '\n', { flag: 'wx' });
const decisionPath = path.join(root, 'docs/integration/remaining-task-workqueue/decision-index.json');
const ledger = read(decisionPath);
function findQ12(value) {
  if (!value || typeof value !== 'object') return null;
  if (value.id === 'Q12') return value;
  for (const v of Object.values(value)) { const found = findQ12(v); if (found) return found; }
  return null;
}
const decision = findQ12(ledger);
assert(decision && decision.affectedTasks.length === 14);
const portalPath = path.join(root, 'SmartHatch_Cha_Backend_Updated.html');
const portal = fs.readFileSync(portalPath, 'utf8');
const section = portal.match(/<details\b[^>]*data-workqueue-decision="Q12"[^>]*>[\s\S]*?<\/details>/);
assert(section, 'Portal decision section missing');
const text = section[0].replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
assert(text.includes(decision.needed));
write(path.join(__dirname, 'original-scope-extract.json'), {
  observedAtUtc: new Date().toISOString(),
  decisionSource: relative(decisionPath), decisionSourceSha256: hash(decisionPath), decision,
  portalSource: relative(portalPath), portalSha256: hash(portalPath),
  selector: 'details[data-workqueue-decision="Q12"]', portalDecisionText: text,
  finding: 'Shared permission decision; no separate standalone Q12 implementation issue located. No portal changes.'
});
const sources = new Set();
function add(p) {
  if (fs.statSync(p).isDirectory()) for (const name of fs.readdirSync(p)) add(path.join(p, name));
  else sources.add(p);
}
add(__dirname);
add(path.join(root, 'docs/integration/cha-execution/q12-controller'));
for (const name of [
  'Q12_Test_Project_Approval_Plan.md', 'Q12_Phase_A_Read_Only.sql',
  'Q12_PHASE_A_ATTEMPT_1_RECEIPT.md', 'Q12_PHASE_A_APPROVAL_AND_BLOCKER.md',
  'Q12_PHASE_A_PREFLIGHT_20261031_103006Z.json'
]) add(path.join(root, 'docs/integration/cha-execution', name));
for (const name of [
  'DB-IMP-01_disabled_registry.sql', 'DB-IMP-01_authorization_schema_draft.sql',
  'DB-IMP-01_bridge_sync_rpcs_draft.sql'
]) add(path.join(root, 'supabase/drafts', name));
for (const name of ['decision-index.json', 'REMAINING_DECISIONS_ALL_OWNERS.md', 'tasks/CURRENT_DB-IMP-01.md'])
  add(path.join(root, 'docs/integration/remaining-task-workqueue', name));
add(portalPath);
for (const version of ['v2', 'v3']) {
  const base = path.join(root, 'docs/integration/cha-execution/q12-controller', version);
  for (const f of read(path.join(base, 'review-inventory.json')).files) {
    assert.equal(hash(path.join(base, f.file)), f.sha256);
    assert.equal(fs.statSync(path.join(base, f.file)).size, f.bytes);
  }
}
const fresh = read(path.join(root, 'docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/test-results.json'));
assert.equal(fresh.tests, 211);
assert.equal(fresh.failed, 0);
assert.equal(fresh.cases.length, 211);
assert(fresh.cases.every(c => c.Status === 'PASS'));
for (const [name, digest] of Object.entries(fresh.inputHashes))
  assert.equal(hash(path.join(root, 'docs/integration/cha-execution/q12-controller/v3', name)), digest);
assert.equal(hash(path.join(root, 'docs/integration/cha-execution/Q12_Phase_A_Read_Only.sql')),
  '9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc');
const inventory = {
  observedAtUtc: new Date().toISOString(), scope: 'Q12 offline coordinated review/execution preparation only',
  excludes: 'This generated inventory itself; pending owner approval file intentionally absent',
  files: [...sources].sort().map(p => ({ file: relative(p), bytes: fs.statSync(p).size, sha256: hash(p) })),
  controllerRevision: 'v3 unchanged', freshTests: { passed: 211, failed: 0, runId: fresh.runId },
  certificateTrusted: false, remoteExecuted: false, closureAccepted: false, taskStatusEdited: false
};
write(path.join(__dirname, 'package-inventory.json'), inventory);
console.log(`PASS: ${inventory.files.length} file fingerprints; original portal/decision text agree; historical inventories unchanged; fresh 211 tests and source/SQL pins match. No remote execution.`);
