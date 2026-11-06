'use strict';

// Documentation-only validator. No network, serial port, database, or writes.
// Supply Ajv 8 and ajv-formats outside the Flutter application's dependencies.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const Ajv = require('ajv/dist/2020').default;
const addFormats = require('ajv-formats');

const schema = JSON.parse(fs.readFileSync(path.join(__dirname, 'C02-provisional.schema.json'), 'utf8'));
const fixtures = JSON.parse(fs.readFileSync(path.join(__dirname, 'C02-provisional.examples.json'), 'utf8'));
const isolationSources = [
  {file: '../test/fixtures/integration/hw02_batch_review.ndjson', count: 14},
  {file: '../test/fixtures/integration/hw02_corrected_review.ndjson', count: 6}
];
const protectedInputs = [
  'C02-provisional-communication-contract.md', 'C02-provisional.schema.json',
  'C02-provisional.examples.json', ...isolationSources.map(source => source.file)
].map(file => ({file: path.join(__dirname, file), bytes: fs.readFileSync(path.join(__dirname, file))}));
const originalSchema = structuredClone(schema);
const originalFixtures = structuredClone(fixtures);
assert.equal(fixtures.draft, '0.1.0-provisional');
assert.match(fixtures.notice, /SYNTHETIC TEST FIXTURES ONLY/);
const ajv = new Ajv({allErrors: true, strict: true, strictTypes: false, strictRequired: false});
addFormats(ajv);
ajv.validateSchema(schema, true);
const validate = ajv.compile(schema);

// JSON.parse accepts duplicate keys; reject those explicitly for NDJSON frames.
// JSON.parse first validates syntax. Tokens then track keys at each object depth,
// including keys encoded with JSON escapes. This is a fixture checker, not a
// production serial parser or an implementation of the proposed protocol.
function parseFrame(line) {
  assert.equal(typeof line, 'string');
  assert.ok(line.endsWith('\n'), 'frame must end in LF');
  const body = line.endsWith('\r\n') ? line.slice(0, -2) : line.slice(0, -1);
  assert.ok(!body.includes('\n') && !body.includes('\r'), 'one object on one line');
  const message = JSON.parse(body);
  assert.ok(message !== null && typeof message === 'object' && !Array.isArray(message), 'object required');
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
  const originalMessage = structuredClone(message);
  const accepted = validate(message);
  assert.deepEqual(message, originalMessage, 'frame validation must not mutate input');
  assert.ok(accepted, JSON.stringify(validate.errors));
  return message;
}

const names = new Set();
for (const example of fixtures.examples) {
  assert.ok(!names.has(example.name), 'unique fixture names');
  names.add(example.name);
  parseFrame(JSON.stringify(example.message) + '\n');
}
const get = name => structuredClone(fixtures.examples.find(x => x.name === name).message);
let negativeChecks = 0;
function reject(name, base, mutate) {
  const message = get(base);
  mutate(message);
  assert.equal(validate(message), false, `expected invalid: ${name}`);
  negativeChecks++;
}
const reading = 'telemetry-known-time';
const start = 'command-start';
const verified = 'status-verified-shape-only-not-real-evidence';
for (const key of schema.required) reject(`missing ${key}`, reading, m => { delete m[key]; });
reject('unsupported version', reading, m => { m.v = 2; });
reject('string version', reading, m => { m.v = '1'; });
reject('unknown message type', reading, m => { m.type = 'debug'; });
reject('brooder', reading, m => { m.chamber = 'brooder'; });
reject('empty device', reading, m => { m.device_id = ''; });
reject('oversized ID', reading, m => { m.device_id = 'A'.repeat(65); });
reject('invalid ID characters', reading, m => { m.device_id = 'test device'; });
reject('numeric batch ID', reading, m => { m.batch_id = 123; });
reject('missing sample identity', reading, m => { m.sample_id = null; });
reject('missing boot identity', reading, m => { m.boot_id = null; });
reject('fractional sequence', reading, m => { m.seq = 1.5; });
reject('negative sequence', reading, m => { m.seq = -1; });
reject('unsafe sequence integer', reading, m => { m.seq = 9007199254740992; });
reject('null device sequence', reading, m => { m.seq = null; });
reject('telemetry command identity', reading, m => { m.command_id = 'TEST-CMD'; });
reject('true time flag with null timestamp', reading, m => { m.measured_at = null; });
reject('false time flag with timestamp', reading, m => { m.timestamp_valid = false; });
reject('string validity flag', reading, m => { m.timestamp_valid = 'true'; });
reject('invalid calendar date', reading, m => { m.measured_at = '2026-02-30T00:00:00Z'; });
reject('non-UTC timestamp', reading, m => { m.measured_at = '2026-10-26T08:00:00+08:00'; });
reject('bad timestamp text', reading, m => { m.measured_at = 'yesterday'; });
reject('numeric string reading', reading, m => { m.payload.temperature_c.value = '25'; });
reject('valid sensor without value', reading, m => { m.payload.temperature_c.value = null; });
reject('invalid sensor with value', reading, m => { m.payload.temperature_c.valid = false; });
reject('missing sensor validity', reading, m => { delete m.payload.temperature_c.valid; });
reject('humidity above unit range', reading, m => { m.payload.humidity_pct.value = 101; });
reject('humidity below unit range', reading, m => { m.payload.humidity_pct.value = -1; });
reject('nonfinite number', reading, m => { m.payload.temperature_c.value = Infinity; });
reject('unknown top-level field', reading, m => { m.received_at = '2026-10-26T00:00:00Z'; });
reject('unknown sensor field', reading, m => { m.payload.temperature_c.target = 25; });
reject('START without batch', start, m => { m.batch_id = null; });
reject('START without command', start, m => { m.command_id = null; });
reject('START without profile', start, m => { delete m.payload.profile_id; });
reject('START with previous-incubation offset', start, m => { m.payload.previous_incubation_days = 2; });
reject('START with target override', start, m => { m.payload.target_temperature = 25; });
reject('unsupported GET_READINGS', start, m => { m.payload = {action: 'GET_READINGS'}; });
reject('command with device sequence', start, m => { m.seq = 0; });
reject('command with device clock', start, m => { m.measured_at = '2026-10-26T00:00:00Z'; m.timestamp_valid = true; });
reject('STOP without batch', 'command-stop', m => { m.batch_id = null; });
reject('accepted ACK with error', 'ack-accepted-not-running-proof', m => { m.payload.code = 'INVALID_MESSAGE'; });
reject('rejected ACK without error', 'ack-rejected', m => { m.payload.code = null; });
reject('ACK without correlation', 'ack-rejected', m => { m.command_id = null; });
reject('ACK with sensor sample', 'ack-rejected', m => { m.sample_id = 'TEST-SAMPLE'; });
reject('VERIFIED status without evidence reference', verified, m => { m.payload.evidence_id = null; });
reject('VERIFIED status without batch', verified, m => { m.batch_id = null; });
reject('VERIFIED status without command', verified, m => { m.command_id = null; });
reject('VERIFIED status without original Start', verified, m => { m.payload.original_start_valid = false; m.payload.original_start_at = null; });
reject('VERIFIED UNKNOWN state', verified, m => { m.payload.state = 'UNKNOWN'; });
reject('VERIFIED status unknown inspection', verified, m => { m.payload.inspection_required = null; });
reject('false original-Start flag with time', verified, m => { m.payload.original_start_valid = false; });
reject('controller-only status with evidence claim', 'status-controller-reported-unconfirmed', m => { m.payload.evidence_id = 'TEST-EVIDENCE'; });
reject('unknown error code', 'error-unsolicited', m => { m.payload.code = 'SOMETHING'; });
reject('oversized error detail', 'error-unsolicited', m => { m.payload.detail = 'X'.repeat(161); });

let framingChecks = 0;
for (const [name, line] of [
  ['array', '[]\n'], ['null', 'null\n'], ['text', 'debug text\n'],
  ['truncated JSON', '{\n'], ['missing LF', JSON.stringify(get(reading))],
  ['multiple objects', JSON.stringify(get(reading)) + '\n' + JSON.stringify(get(reading)) + '\n'],
  ['duplicate version key', JSON.stringify(get(reading)).replace('"v":1', '"v":1,"v":1') + '\n'],
  ['escaped duplicate key', JSON.stringify(get(reading)).replace('"v":1', '"v":1,"\\u0076":1') + '\n'],
  ['nested duplicate sensor flag', JSON.stringify(get(reading)).replace('"valid":true', '"valid":true,"valid":true') + '\n'],
  ['NaN literal', JSON.stringify(get(reading)).replace('"value":25', '"value":NaN') + '\n'],
  ['overflow exponent', JSON.stringify(get(reading)).replace('"value":25', '"value":1e999') + '\n']
]) {
  assert.throws(() => parseFrame(line), undefined, `expected frame rejected: ${name}`);
  framingChecks++;
}
parseFrame(JSON.stringify(get(reading)) + '\r\n');
parseFrame(JSON.stringify(get(reading)) + ' \n');

// Additional structural edges: neither a STOPPED report nor a VERIFIED flag is
// physically tested here. These only check schema combinations.
const stopped = get(verified);
stopped.payload.state = 'STOPPED';
stopped.payload.original_start_at = null;
stopped.payload.original_start_valid = false;
assert.ok(validate(stopped), JSON.stringify(validate.errors));
const clockUnknown = get(verified);
clockUnknown.measured_at = null;
clockUnknown.timestamp_valid = false;
assert.ok(validate(clockUnknown), JSON.stringify(validate.errors));

// These are incompatible historical SYNTHETIC review families, not a selected
// source contract. Validate literal frames without adding aliases/defaults or
// translating identities. In particular, never serialize parsed uint64 values
// back into fixtures: JSON.parse alone does not preserve unsafe integer digits.
const isolationResults = [];
for (const source of isolationSources) {
  const file = path.join(__dirname, source.file);
  const bytes = protectedInputs.find(input => input.file === file).bytes;
  const lines = bytes.toString('utf8').match(/[^\n]*\n|[^\n]+$/g) || [];
  assert.equal(lines.length, source.count, 'expected complete historical fixture corpus');
  for (const [index, line] of lines.entries()) {
    assert.ok(line.endsWith('\n'), 'existing fixture must already be LF terminated');
    const message = JSON.parse(line);
    const originalMessage = structuredClone(message);
    for (let attempt = 0; attempt < 2; attempt++) {
      assert.equal(validate(message), false, 'foreign family must not match provisional schema');
      assert.ok(validate.errors.some(error => ['required', 'additionalProperties'].includes(error.keyword)),
        'rejection must include an envelope/schema mismatch');
      assert.deepEqual(message, originalMessage, 'rejected object must remain unchanged');
      assert.throws(() => parseFrame(line), assert.AssertionError,
        'literal foreign frame must fail documentation schema validation');
      assert.deepEqual(message, originalMessage, 'repeated validation must not translate input');
    }
    isolationResults.push(`${path.basename(file)}:${index + 1} ${message.t || message.type}`);
  }
}
assert.deepEqual(schema, originalSchema, 'schema object must remain unchanged');
assert.deepEqual(fixtures, originalFixtures, 'original positive examples must remain unchanged');
for (const input of protectedInputs) {
  assert.ok(fs.readFileSync(input.file).equals(input.bytes),
    `protected file bytes changed: ${path.basename(input.file)}`);
}

console.log('PASS: draft 2020-12 schema meta-validation and compilation');
console.log(`PASS: ${fixtures.examples.length} labeled synthetic messages accepted`);
console.log(`PASS: ${negativeChecks} schema-negative mutations rejected`);
console.log(`PASS: ${framingChecks} malformed/unsafe frame fixtures rejected`);
console.log('PASS: CRLF, trailing whitespace, and 2 status/time edge cases');
for (const result of isolationResults) console.log(`PASS: isolation rejection and no-mutation ${result}`);
console.log(`PASS: ${isolationResults.length} incompatible literal frames rejected, each checked twice`);
console.log('PASS: schema/example objects and all 5 protected contract/fixture files unchanged');
console.log('LIMITATION: isolation checks prove documentation-validator rejection only; not a live parser, lossless uint64 decoder, protocol selection or reviewer approval.');
console.log('NOT TESTED: firmware, physical Start/Stop, clocks, identity persistence, authentication, RLS, network, or hardware.');
