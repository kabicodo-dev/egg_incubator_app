'use strict';

// UNEXECUTED DOCUMENTATION TOOL — separate execution authorization required.
// Reads only the two companion JSON files; stdout/stderr only. No network,
// database, serial, app imports, writes, dependency installs or subprocesses.
// Does not run firmware/harnesses or certify authenticity/physical behavior.
// Supply Ajv 8 and ajv-formats through existing externally approved tooling.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {TextDecoder} = require('node:util');
const Ajv = require('ajv/dist/2020').default;
const addFormats = require('ajv-formats');

function main() {
  const schema = JSON.parse(fs.readFileSync(
    path.join(__dirname, 'Original-C02-candidate-1.schema.json'), 'utf8'));
  const fixtures = JSON.parse(fs.readFileSync(
    path.join(__dirname, 'Original-C02-candidate-1.examples.json'), 'utf8'));
  assert.equal(fixtures.task, 'ORIGINAL:C-02');
  assert.equal(fixtures.document_revision, 'ORIGINAL:C-02/candidate-1');
  assert.equal(fixtures.validation_status, 'NOT_RUN');
  assert.equal(fixtures.approval_status, 'PENDING');
  assert.match(fixtures.notice, /DOCUMENTATION FIXTURES ONLY/);

  const ajv = new Ajv({allErrors: true, strict: true, strictTypes: false,
    strictRequired: false, strictNumbers: true, validateFormats: true});
  addFormats(ajv);
  assert.equal(ajv.validateSchema(schema), true, JSON.stringify(ajv.errors));
  ajv.addSchema(schema);
  const allowed = new Set(['observedCommand', 'observedAck', 'observedRunning',
    'observedTelemetry', 'observedEvent', 'targetRecord']);
  const validators = new Map();
  function validator(name) {
    assert.ok(allowed.has(name), `unknown definition: ${name}`);
    if (!validators.has(name)) {
      validators.set(name, ajv.compile({$ref: `${schema.$id}#/$defs/${name}`}));
    }
    return validators.get(name);
  }
  for (const name of allowed) validator(name);

  function rejectNonfinite(value) {
    if (typeof value === 'number') assert.ok(Number.isFinite(value), 'nonfinite number');
    if (value && typeof value === 'object') {
      for (const child of Object.values(value)) rejectNonfinite(child);
    }
  }

  // Narrow relationships that a portable JSON Schema cannot compare directly.
  // These do not simulate persistent state or prove firmware enforcement.
  function relationships(message, name) {
    if ((name === 'observedAck' || name === 'observedRunning') && message.cmd === 'START') {
      assert.equal(message.command_id, message.id, 'command_id must echo id');
    }
    if (name === 'observedTelemetry' ||
        (name === 'observedEvent' && message.event === 'batch_state_restored')) {
      assert.equal(message.day, Math.floor(message.elapsed_seconds / 86400) + 1,
        'day must match powered elapsed counter');
    }
    if (name === 'targetRecord') {
      const b = message.body;
      if (message.family === 'STATE') {
        assert.equal(b.payload.query_id, b.command_id, 'STATE query correlation');
        if (b.payload.state === 'RUNNING' || b.payload.state === 'STOPPED') {
          assert.equal(typeof b.batch_id, 'string', 'reported batch state needs association');
        }
      }
      if (message.family === 'ACK') {
        assert.equal(b.payload.accepted, b.payload.code !== 'REJECTED',
          'proposed ACK code/accepted relationship');
      }
      if (message.family === 'EVENT' &&
          (b.payload.kind === 'started' || b.payload.kind === 'stopped')) {
        assert.equal(typeof b.command_id, 'string', 'deliberate event command correlation');
      }
    }
  }

  function validateMessage(message, name) {
    rejectNonfinite(message);
    const check = validator(name);
    assert.ok(check(message), JSON.stringify(check.errors));
    relationships(message, name);
  }

  // This checks ONE complete documentation frame, not fragmented/coalesced
  // RFCOMM input, queue timing, real overflow draining or an approved byte cap.
  function parseFrame(bytes, name) {
    assert.ok(Buffer.isBuffer(bytes));
    const line = new TextDecoder('utf-8', {fatal: true}).decode(bytes);
    assert.ok(line.endsWith('\n'), 'LF terminator required');
    const body = line.slice(0, -1);
    assert.ok(!/[\r\n\u0000]/.test(body), 'one LF-only object; no embedded CR/LF/NUL');
    const message = JSON.parse(body);
    assert.ok(message && typeof message === 'object' && !Array.isArray(message), 'object required');

    // JSON.parse otherwise accepts duplicate keys. Track decoded key spelling
    // at each object depth, including escaped spellings. Syntax checked first.
    const stack = [];
    const tokens = body.match(/"(?:\\.|[^"\\])*"|[{}\[\],:]/g) || [];
    for (const token of tokens) {
      if (token === '{') stack.push({kind: 'object', keys: new Set(), keyNext: true});
      else if (token === '[') stack.push({kind: 'array'});
      else if (token === '}' || token === ']') stack.pop();
      else if (token === ',') {
        if (stack.at(-1)?.kind === 'object') stack.at(-1).keyNext = true;
      } else if (token.startsWith('"')) {
        const scope = stack.at(-1);
        if (scope?.kind === 'object' && scope.keyNext) {
          const key = JSON.parse(token);
          assert.ok(!scope.keys.has(key), 'duplicate JSON key');
          scope.keys.add(key);
          scope.keyNext = false;
        }
      }
    }
    validateMessage(message, name);
    return message;
  }

  const examples = new Map();
  for (const example of fixtures.examples) {
    assert.ok(!examples.has(example.id), `duplicate example: ${example.id}`);
    assert.ok(typeof example.provenance === 'string' && example.provenance.length > 0);
    assert.ok(typeof example.classification === 'string' && example.classification.length > 0);
    assert.equal(example.profile === 'target', example.schema_ref === 'targetRecord',
      'explicit profile/definition correspondence');
    examples.set(example.id, example);
    const text = example.serialized ?? JSON.stringify(example.message);
    const decoded = parseFrame(Buffer.from(text + '\n', 'utf8'), example.schema_ref);
    assert.deepEqual(decoded, example.message, 'serialized specimen must match documented object');
    const content = Buffer.byteLength(text, 'utf8');
    if (example.expected_bytes) {
      assert.equal(content, example.expected_bytes.content, `${example.id}: content bytes`);
      assert.equal(content + 1, example.expected_bytes.with_lf, `${example.id}: LF bytes`);
    }
    console.log(`BYTES ${example.id}: content=${content}, with_LF=${content + 1}; ${example.profile === 'target' ? 'review record, NOT selected wire encoding' : 'reference specimen only; NOT a permitted-set maximum'}`);
  }

  function cloneExample(id) {
    const example = examples.get(id);
    assert.ok(example, `unknown example: ${id}`);
    return {message: structuredClone(example.message), schema_ref: example.schema_ref};
  }

  function mutate(message, change) {
    assert.ok(change.path.startsWith('/'), 'JSON pointer required');
    const parts = change.path.slice(1).split('/').map(x => x.replace(/~1/g, '/').replace(/~0/g, '~'));
    assert.ok(parts.every(x => !['__proto__', 'prototype', 'constructor'].includes(x)), 'unsafe pointer');
    let parent = message;
    for (const part of parts.slice(0, -1)) {
      assert.ok(parent && Object.hasOwn(parent, part), `unknown path: ${change.path}`);
      parent = parent[part];
    }
    const key = parts.at(-1);
    if (change.op === 'delete') {
      assert.ok(Object.hasOwn(parent, key), 'delete must name an existing field');
      delete parent[key];
    } else {
      assert.equal(change.op, 'set');
      parent[key] = structuredClone(change.value);
    }
  }

  const caseIds = new Set(examples.keys());
  function uniqueCase(id) {
    assert.ok(!caseIds.has(id), `duplicate case: ${id}`);
    caseIds.add(id);
  }
  for (const item of fixtures.negative_examples) {
    uniqueCase(item.id);
    const base = cloneExample(item.base);
    const name = item.schema_ref ?? base.schema_ref;
    assert.ok(allowed.has(name), 'negative case definition must exist');
    for (const change of item.changes) mutate(base.message, change);
    assert.throws(() => validateMessage(base.message, name), undefined,
      `expected invalid reference shape: ${item.id}`);
  }

  for (const item of fixtures.framing_examples) {
    uniqueCase(item.id);
    assert.ok(allowed.has(item.schema_ref), 'framing case definition must exist');
    assert.equal(typeof item.expected_valid, 'boolean');
    const bytes = item.hex === undefined ? Buffer.from(item.text, 'utf8') : Buffer.from(item.hex, 'hex');
    if (item.expected_valid) parseFrame(bytes, item.schema_ref);
    else assert.throws(() => parseFrame(bytes, item.schema_ref), undefined,
      `expected malformed reference frame: ${item.id}`);
  }

  // Tiny ordering examples only. No durable retry/journal/store implementation.
  function order(steps) {
    const receipts = new Set();
    const turnProgress = new Set();
    const turnTerminal = new Set();
    const startKey = m => `${m.id}:${m.batch_id}`;
    for (const step of steps) {
      const example = examples.get(step);
      assert.ok(example && example.profile === 'observed', 'observed sequence member required');
      const m = example.message;
      if (m.type === 'ack' && m.cmd === 'START') {
        if (m.status === 'accepted') receipts.add(startKey(m));
        else receipts.delete(startKey(m));
      }
      if (m.type === 'running' && m.cmd === 'START') {
        assert.ok(receipts.has(startKey(m)), 'START report requires earlier matching receipt');
      }
      if (m.type === 'running' && m.cmd === 'TURN_NOW') {
        assert.ok(!turnTerminal.has(m.id), 'turn progress cannot follow terminal ACK');
        turnProgress.add(m.id);
      }
      if (m.type === 'ack' && m.cmd === 'TURN_NOW' && m.status === 'accepted') {
        assert.ok(turnProgress.has(m.id), 'turn completion needs earlier progress in this scenario');
        turnTerminal.add(m.id);
      }
    }
    for (const id of turnProgress) assert.ok(turnTerminal.has(id), 'scenario lacks terminal turn ACK');
  }

  for (const item of fixtures.ordering_examples) {
    uniqueCase(item.id);
    for (const id of item.steps) assert.ok(examples.has(id), 'sequence references must exist');
    assert.equal(typeof item.expected_valid, 'boolean');
    if (item.expected_valid) order(item.steps);
    else assert.throws(() => order(item.steps), undefined, `expected invalid order: ${item.id}`);
  }

  const targetFamilies = new Set(fixtures.examples.filter(x => x.profile === 'target').map(x => x.message.family));
  for (const family of ['TELEMETRY', 'START', 'STOP', 'STATUS', 'ACK', 'STATE', 'EVENT', 'ERROR']) {
    assert.ok(targetFamilies.has(family), `missing target family specimen: ${family}`);
  }
  console.log('PASS: candidate documentation schema definitions compiled');
  console.log(`PASS: ${examples.size} reference examples; ${fixtures.negative_examples.length} expected-invalid mutations/profile cases; ${fixtures.framing_examples.length} framing fixtures; ${fixtures.ordering_examples.length} narrow ordering cases`);
  console.log('NOT VERIFIED: firmware parser enforcement, stream splits/queues/overflow recovery, permitted-set maximum sizes, source authenticity, persistent identities, clocks, Android/HC-05, database/security, physical loads or end-to-end integration.');
  console.log('Target records remain PROPOSED. This execution does not approve the contract, change the stored NOT_RUN provenance, or complete ORIGINAL:C-02.');
}

try {
  main();
} catch (error) {
  console.error(`FAIL: candidate documentation check: ${error.message}`);
  process.exitCode = 1;
}
