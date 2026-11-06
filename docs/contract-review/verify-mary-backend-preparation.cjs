// Read-only local snapshot integrity check. No network, environment loading,
// application imports, database access, packet approval or evidence-file writes.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');

const root = path.resolve(__dirname, '../..');
const name = 'MARY_Backend_Preparation_2026-11-01';
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, name + '.inputs.json'), 'utf8'));
assert.equal(manifest.files.length, 13);
assert.equal(new Set(manifest.files.map(file => file.path)).size, 13);
for (const file of manifest.files) {
  const resolved = path.resolve(root, file.path);
  assert(resolved.startsWith(root + path.sep), 'Path must stay inside repository');
  assert(/^[a-f0-9]{64}$/.test(file.sha256), 'Expected SHA-256: ' + file.path);
  const bytes = fs.readFileSync(resolved);
  assert.equal(bytes.length, file.bytes, 'Snapshot size changed: ' + file.path);
  assert.equal(crypto.createHash('sha256').update(bytes).digest('hex'), file.sha256,
    'Snapshot bytes changed; review diff, do not silently repin: ' + file.path);
}
const report = fs.readFileSync(path.join(__dirname, name + '.md'), 'utf8');
const links = [...report.matchAll(/\]\(([^)]+)\)/g)].map(match => match[1]);
for (const link of links) {
  assert(fs.existsSync(path.resolve(__dirname, link)), 'Missing local report link: ' + link);
}
console.log(JSON.stringify({
  result: 'PASSED',
  snapshotFiles: manifest.files.length,
  localLinks: links.length,
  boundary: 'Local integrity only; no source selection, signature, remote or physical verification.'
}, null, 2));
