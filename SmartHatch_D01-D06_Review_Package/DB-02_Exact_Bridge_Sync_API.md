# DB-CONTRACT-02 — Exact candidate bridge synchronization API

**Revision:** DB-02 `0.1-review` · **Owner:** Cha · **Date:** 2026-10-28
**Status:** PROPOSED / NOT APPROVED / NOT IMPLEMENTED / NOT DEPLOYED

Companions: [schema/security](DB-02_Proposed_Schema_And_Security.md) and
[receipts/recovery](DB-02_Conflict_Receipt_And_Recovery.md). All three are one
review bundle. This is the cloud annex candidate, not a replacement Uno protocol.

## 1. Evidence, authority and release gates

Labels: **LIVE VERIFIED (PRIOR INVENTORY)** = prior catalog evidence, not a new
query; **SOURCE VERIFIED** = inspected code/document; **CALCULATED** = actual
host-side checks; **PROPOSED** = this candidate; **UNKNOWN/BLOCKED** = absent or
unsettled evidence. No hardware or API behavior is claimed verified.

Reviewed external inputs (currently in `C:\Users\Mary Charlyn\Downloads`):

| Input | Evidence actually available |
|---|---|
| `SmartHatch_v1.2.md:128-186` | SOURCE VERIFIED: cloud route, operations, candidate receipt/mapping |
| `SmartHatch_v1.2.md:99-126` | SOURCE VERIFIED: Kath's summarized transactional intent/outbox and UI rules |
| `HW-02_Exact_Wire_Message_Catalog.md:13-167` | SOURCE VERIFIED: Ally's actual proposed catalog, including unsolved aliases/splits/auth |
| `HW-02_Uno_Feasibility_And_Recovery.md:47-95` | SOURCE VERIFIED: reported memory concerns; unproven journal, RTC, identity |
| `Open_Decisions.md:9-23` | SOURCE VERIFIED: HW-02-01 through HW-02-15 remain proposed/blocked |
| `SmartHatch_UI_02_Review_Summary.txt:1-23` | SOURCE VERIFIED **summary only**; says UI designs exist, compatibility blocked, no device/build tests |

The three full `UI-02_*.md` files named in that summary were not found in this
checkout or the searched Downloads paths. This bundle cross-checks v1.2 Annex B
and the summary, **not unseen UI-02 schemas or SQLite tables**. Direct UI-02
cross-check remains BLOCKED; request the full files before joint freeze.

Repository evidence: [actual inventory](../../SmartHatch_Supabase_Actual_Schema_Inventory.md)
at lines 124-203, 205-320, 430-458; `lib/services/supabase_service.dart:125-167,
232-245,287-295`. Prior live observation: 2026-10-27 11:00:42 UTC. No new live
database audit, Auth operation or production-row access was performed.

**Deployment must fail closed:** no controller evidence adapter is approved yet.
A future implementation returns 503 `CONTRACT_NOT_ENABLED` for submissions until
the exact catalog revision, widths/splits, identity binding, offline authorization,
profile manifest and required time policy have explicit review approval.
Synthetic examples below assume an isolated test fixture with those gates modeled
as enabled; they do not authorize production acceptance or a real profile.

## 2. Transport, authentication and scope

**PROPOSED:** `POST /functions/v1/bridge-sync`; one UTF-8 JSON object per request,
`Content-Type: application/json`; HTTPS with normal certificate verification.
Operations: `submit_event`, `submit_reading`, `get_reconciliation` only. No cloud
Start/Stop/relay/inspection-clearance/credential-provisioning operation exists.

Use a verified Supabase Auth access token. Never include a service-role key,
publisher secret, command MAC, password or Auth token in the request body or logs.
Verify JWT issuer, audience, signature, expiry, non-anonymous subject, and current
private installation/session authorization for **every** operation and replay.
Body `installation_id`/`device_id` are requested scope, not authentication.
Full authorization/RLS design is in the companion schema document.

Proposed cloud-only bounds: 16,384 request bytes; one operation; at most 4
controller evidence frames, each at most 4,096 ASCII bytes excluding LF; at most
100 reconciliation lookups. These are HTTP resource ceilings, **not approved Uno
RX/TX limits**. A reviewed adapter additionally enforces its direction-specific
wire size. Configuration must not default to unlimited when an adapter limit or
rate limit is missing. Exact rate limits await measured cadence and review.

Strict parsing rejects duplicate keys, invalid UTF-8, arrays as root, unexpected
fields, nonfinite numbers and type coercion. A JSON decoder alone is insufficient
for duplicate-key enforcement. Request schemas below plus section 5 semantic
checks are both normative **within this proposed candidate**.

## 3. Identity and type rules

| Item | Exact candidate cloud rule |
|---|---|
| UUID | Lowercase hyphenated UUID; Android creates UUIDv4 for a new batch, never a phone timestamp or local integer |
| `device_id` | Provisioned logical controller UUID; private registry maps one immutable wire `dev` alias to it |
| `installation_id` | Separate Android registry UUID; maps provisioned 16-lowercase-hex wire `iid` when applicable |
| `batch_id` | Original offline UUID; `bid` is its lowercase 32-hex encoding with hyphens removed; no lossy cast |
| `command_id` / `query_id` | Exactly 16 lowercase hex characters, stored as text/8 bytes, not signed bigint |
| Controller `event_id` | `controller:<device UUID>:<sequence>`; unpadded decimal sequence, 0..4294967295 |
| Farmer `event_id` | `farmer:<original installation UUID>:<action UUIDv4>` |
| Observation `event_id` | `observation:<device UUID>:<observation UUIDv4>`; app allocates once for one captured observation, not a durable Uno event |
| `sample_id` | `sample:<device UUID>:<boot_epoch>:<sample_sequence>`; unpadded uint32 decimal components |
| Session ID | Existing DB bigint; JSON response is a positive decimal **string**, never a floating-point number |
| Time | UTC RFC3339 `YYYY-MM-DDTHH:mm:ssZ`, whole seconds; unknown source time is explicit null with false validity |

Schema regexes establish lexical shape, not all ranges/relationships. Runtime
recomputes every composite ID from typed components, checks UUIDv4 where required,
and rejects overflow, leading zeros, device/key mismatch and identity reuse.
Counter reset under the same source identity is not a new batch: block/reconcile.
Lost provisioning/counters require administrator-controlled identity recovery;
never rotate device identity automatically to make a conflicting upload pass.

## 4. Exact structural request schema

JSON Schema 2020-12. `unevaluatedProperties:false` closes each discriminated
request. All listed nullable fields remain required. No defaults/coercion.
The profile reference bounds are proposed **cloud bounds**, not Uno feasibility.

<!-- DB02:REQUEST_SCHEMA -->
```json
{
  "$schema":"https://json-schema.org/draft/2020-12/schema",
  "title":"DB-02 0.1-review requests — not implemented",
  "oneOf":[{"$ref":"#/$defs/eventRequest"},{"$ref":"#/$defs/readingRequest"},{"$ref":"#/$defs/reconcileRequest"}],
  "$defs":{
    "uuid":{"type":"string","pattern":"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"},
    "nullableUuid":{"anyOf":[{"$ref":"#/$defs/uuid"},{"type":"null"}]},
    "hex64":{"type":"string","pattern":"^[0-9a-f]{16}$"},
    "nullableHex64":{"anyOf":[{"$ref":"#/$defs/hex64"},{"type":"null"}]},
    "uint32":{"type":"integer","minimum":0,"maximum":4294967295},
    "utc":{"type":"string","format":"date-time","pattern":"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"},
    "nullableUtc":{"anyOf":[{"$ref":"#/$defs/utc"},{"type":"null"}]},
    "profile":{"type":"string","minLength":1,"maxLength":32,"pattern":"^[A-Z0-9][A-Z0-9._-]*$"},
    "controllerEventId":{"type":"string","pattern":"^controller:[0-9a-f-]{36}:(0|[1-9][0-9]{0,9})$"},
    "eventId":{"type":"string","maxLength":128,"pattern":"^(controller:[0-9a-f-]{36}:(0|[1-9][0-9]{0,9})|farmer:[0-9a-f-]{36}:[0-9a-f-]{36}|observation:[0-9a-f-]{36}:[0-9a-f-]{36})$"},
    "sampleId":{"type":"string","maxLength":100,"pattern":"^sample:[0-9a-f-]{36}:(0|[1-9][0-9]{0,9}):(0|[1-9][0-9]{0,9})$"},
    "base":{"type":"object","required":["api_version","operation","installation_id","device_id"],"properties":{"api_version":{"type":"integer","const":1},"operation":{"enum":["submit_event","submit_reading","get_reconciliation"]},"installation_id":{"$ref":"#/$defs/uuid"},"device_id":{"$ref":"#/$defs/uuid"}}},
    "evidence":{"type":"object","additionalProperties":false,"required":["adapter","frames"],"properties":{"adapter":{"enum":["HW02-EVENT-SINGLE","HW02-EVENT-SPLIT","HW02-STATE-SINGLE","HW02-STATE-SPLIT","HW02-TEL-SINGLE"]},"frames":{"type":"array","minItems":1,"maxItems":4,"items":{"type":"string","minLength":2,"maxLength":4096,"pattern":"^[\\x20-\\x7E]+$"}}}},
    "nullableEvidence":{"anyOf":[{"$ref":"#/$defs/evidence"},{"type":"null"}]},
    "startedData":{"type":"object","additionalProperties":false,"required":["species_code","egg_quantity","profile_ref","installation_alias"],"properties":{"species_code":{"type":"integer","enum":[1,2,3]},"egg_quantity":{"type":"integer","minimum":1,"maximum":2147483647},"profile_ref":{"$ref":"#/$defs/profile"},"installation_alias":{"$ref":"#/$defs/hex64"}}},
    "stoppedData":{"type":"object","additionalProperties":false,"required":["started_event_id"],"properties":{"started_event_id":{"$ref":"#/$defs/controllerEventId"}}},
    "farmerData":{"type":"object","additionalProperties":false,"required":["eggs_hatched","stopped_event_id","actor_installation_id"],"properties":{"eggs_hatched":{"type":"integer","minimum":0,"maximum":2147483647},"stopped_event_id":{"$ref":"#/$defs/controllerEventId"},"actor_installation_id":{"$ref":"#/$defs/uuid"}}},
    "faultData":{"type":"object","additionalProperties":false,"required":["started_event_id"],"properties":{"started_event_id":{"anyOf":[{"$ref":"#/$defs/controllerEventId"},{"type":"null"}]}}},
    "stateData":{"type":"object","additionalProperties":false,"required":["query_id","boot_epoch","latest_event_sequence","controller_state","species_code","profile_ref","original_start_at","original_start_valid"],"properties":{"query_id":{"$ref":"#/$defs/hex64"},"boot_epoch":{"$ref":"#/$defs/uint32"},"latest_event_sequence":{"$ref":"#/$defs/uint32"},"controller_state":{"enum":["IDLE","STARTING","RUNNING","STOPPED","FAULT","RECOVERY"]},"species_code":{"enum":[1,2,3,null]},"profile_ref":{"anyOf":[{"$ref":"#/$defs/profile"},{"type":"null"}]},"original_start_at":{"$ref":"#/$defs/nullableUtc"},"original_start_valid":{"type":"boolean"}},"allOf":[{"if":{"properties":{"original_start_valid":{"const":true}}},"then":{"properties":{"original_start_at":{"$ref":"#/$defs/utc"}}},"else":{"properties":{"original_start_at":{"type":"null"}}}}]},
    "eventRequest":{"type":"object","allOf":[{"$ref":"#/$defs/base"},{"properties":{"operation":{"const":"submit_event"},"event_id":{"$ref":"#/$defs/eventId"},"batch_id":{"$ref":"#/$defs/nullableUuid"},"event_kind":{"enum":["started","stopped","farmer_completed","status_observed","fault_entered","fault_cleared"]},"command_id":{"$ref":"#/$defs/nullableHex64"},"source_sequence":{"anyOf":[{"$ref":"#/$defs/uint32"},{"type":"null"}]},"occurred_at":{"$ref":"#/$defs/nullableUtc"},"timestamp_valid":{"type":"boolean"},"phone_received_at":{"$ref":"#/$defs/nullableUtc"},"data":{"type":"object"},"wire_evidence":{"$ref":"#/$defs/nullableEvidence"}},"required":["event_id","batch_id","event_kind","command_id","source_sequence","occurred_at","timestamp_valid","phone_received_at","data","wire_evidence"]},
      {"if":{"properties":{"timestamp_valid":{"const":true}}},"then":{"properties":{"occurred_at":{"$ref":"#/$defs/utc"}}},"else":{"properties":{"occurred_at":{"type":"null"}}}},
      {"if":{"properties":{"event_kind":{"const":"started"}}},"then":{"properties":{"batch_id":{"$ref":"#/$defs/uuid"},"command_id":{"$ref":"#/$defs/hex64"},"source_sequence":{"$ref":"#/$defs/uint32"},"data":{"$ref":"#/$defs/startedData"},"wire_evidence":{"$ref":"#/$defs/evidence"}}}},
      {"if":{"properties":{"event_kind":{"const":"stopped"}}},"then":{"properties":{"batch_id":{"$ref":"#/$defs/uuid"},"command_id":{"$ref":"#/$defs/hex64"},"source_sequence":{"$ref":"#/$defs/uint32"},"data":{"$ref":"#/$defs/stoppedData"},"wire_evidence":{"$ref":"#/$defs/evidence"}}}},
      {"if":{"properties":{"event_kind":{"const":"farmer_completed"}}},"then":{"properties":{"batch_id":{"$ref":"#/$defs/uuid"},"command_id":{"type":"null"},"source_sequence":{"type":"null"},"data":{"$ref":"#/$defs/farmerData"},"wire_evidence":{"type":"null"}}}},
      {"if":{"properties":{"event_kind":{"enum":["fault_entered","fault_cleared"]}}},"then":{"properties":{"batch_id":{"$ref":"#/$defs/uuid"},"source_sequence":{"$ref":"#/$defs/uint32"},"data":{"$ref":"#/$defs/faultData"},"wire_evidence":{"$ref":"#/$defs/evidence"}}}},
      {"if":{"properties":{"event_kind":{"const":"status_observed"}}},"then":{"properties":{"command_id":{"$ref":"#/$defs/hex64"},"source_sequence":{"type":"null"},"occurred_at":{"type":"null"},"timestamp_valid":{"const":false},"data":{"$ref":"#/$defs/stateData"},"wire_evidence":{"$ref":"#/$defs/evidence"}}}}
    ],"unevaluatedProperties":false},
    "readingRequest":{"type":"object","allOf":[{"$ref":"#/$defs/base"},{"required":["batch_id","sample_id","boot_epoch","sample_sequence","measured_at","timestamp_valid","phone_received_at","current_temperature","temperature_valid","current_humidity","humidity_valid","wire_evidence"],"properties":{"operation":{"const":"submit_reading"},"batch_id":{"$ref":"#/$defs/uuid"},"sample_id":{"$ref":"#/$defs/sampleId"},"boot_epoch":{"$ref":"#/$defs/uint32"},"sample_sequence":{"$ref":"#/$defs/uint32"},"measured_at":{"$ref":"#/$defs/nullableUtc"},"timestamp_valid":{"type":"boolean"},"phone_received_at":{"$ref":"#/$defs/nullableUtc"},"current_temperature":{"type":["number","null"]},"temperature_valid":{"type":"boolean"},"current_humidity":{"type":["number","null"],"minimum":0,"maximum":100},"humidity_valid":{"type":"boolean"},"wire_evidence":{"$ref":"#/$defs/evidence"}}},
      {"if":{"properties":{"timestamp_valid":{"const":true}}},"then":{"properties":{"measured_at":{"$ref":"#/$defs/utc"}}},"else":{"properties":{"measured_at":{"type":"null"}}}},
      {"if":{"properties":{"temperature_valid":{"const":true}}},"then":{"properties":{"current_temperature":{"type":"number"}}},"else":{"properties":{"current_temperature":{"type":"null"}}}},
      {"if":{"properties":{"humidity_valid":{"const":true}}},"then":{"properties":{"current_humidity":{"type":"number"}}},"else":{"properties":{"current_humidity":{"type":"null"}}}}
    ],"unevaluatedProperties":false},
    "lookup":{"type":"object","additionalProperties":false,"required":["entity","entity_id"],"properties":{"entity":{"enum":["event","reading"]},"entity_id":{"type":"string","minLength":1,"maxLength":128}}},
    "reconcileRequest":{"type":"object","allOf":[{"$ref":"#/$defs/base"},{"required":["batch_id","lookups"],"properties":{"operation":{"const":"get_reconciliation"},"batch_id":{"$ref":"#/$defs/nullableUuid"},"lookups":{"type":"array","maxItems":100,"uniqueItems":true,"items":{"$ref":"#/$defs/lookup"}}}},{"anyOf":[{"properties":{"batch_id":{"$ref":"#/$defs/uuid"}}},{"properties":{"lookups":{"minItems":1}}}]}],"unevaluatedProperties":false}
  }
}
```

## 5. Semantic validation and actual HW-02 translation

The following checks are required in addition to schema validation:

| Source field | Cloud representation / verification |
|---|---|
| `dev` | Registry alias -> `device_id`; not a UUID conversion, MAC address or phone-selected reassociation |
| START `iid` | Registry installation alias -> original installation; never use alias as Auth credential |
| `bid` | Exact UUID bytes -> `batch_id`; add hyphens/lowercase only, never hash to a different batch |
| EVENT `seq`, `eid` | Recompute cloud event key from device UUID + `seq`; redundant `eid` must agree with alias/sequence, never a caller-chosen primary key |
| EVENT `ep` | Preserve original event epoch in normalized source evidence on replay; not the new boot epoch |
| EVENT `cid` | Exact `command_id`; no allocation of a new ID during upload |
| EVENT `kind` | `started`, `stopped`, `fault_entered`, `fault_cleared` map to same cloud classifications; fault clearing remains disabled until safety policy approved |
| EVENT `ts`/`tv` | `occurred_at`/`timestamp_valid`; null when invalid; timestamp range and skew checked against reviewed policy |
| TEL `ep`, `n` | `boot_epoch`, `sample_sequence`; recompute full `sample_id` |
| TEL `tc`/`t_ok`, `rh`/`rh_ok` | Exact actual values/null and independent validity flags; finite numbers, reviewed sensor bounds, no target substitution |
| STATE `qid` | `data.query_id` and `command_id`, equal; must match captured STATUS query context |
| STATE `seq` | `data.latest_event_sequence`, NOT a new event identity or observation sequence |
| STATE `start_s`/`tv` | `data.original_start_at`/`original_start_valid`; not observation time. Catalog supplies no distinct state-observed UTC time, so root `occurred_at=null`, `timestamp_valid=false` |
| START `sp`,`qty`,`pv` | Android's immutable original intent -> `started.data`. EVENT does not echo these fields. Preserve this distinction; source command admission/correlation must be reviewed before claiming Uno independently substantiated these metadata |

Farmer event key must name `data.actor_installation_id`, normally the current
authorized installation. Uploading an old farmer namespace after reinstall needs
an explicit administrator recovery grant; it is not permitted just because the
new phone knows the old IDs. Controller events can be relayed by a newly authorized
replacement for the same controller; uploader changes do not change event identity.

Started/stopped need complete accepted controller transition evidence. ACK,
HELLO, REPLAY_END or a historical/current STATE alone is insufficient. A fault
is not automatically STOP or Completed. Internal stopped events with null `cid`
are deliberately not enabled in this candidate: Ally must define their origin,
reason/evidence policy before a cloud schema revision accepts them.

Farmer completion references an applied Stop for the same batch and validates an
integer `0..original egg_quantity`; original quantity must be positive. A form may
save a local draft before Stop identity is known, but must not freeze/upload a
fake dependency ID. Corrections are separately audited operations, not mutation
of an already committed event under the same ID.

### Source conflicts / cross-check disposition

| ID | Actual evidence | Consequence |
|---|---|---|
| W1 | HW catalog:17 says 16 uppercase hex; examples:37,87,95,103 use `SH01...` containing nonhex S/H | BLOCKED. Registry candidate requires `[0-9A-F]{16}`. Original literals are invalid under their own declared rule; do not silently normalize/reassign. Synthetic examples here use a distinct valid hex test alias. |
| W2 | STATE 198 and EVENT 204 content bytes; proposed wire ceiling 191 | CALCULATED again locally. Both oversized; single adapters remain disabled until an agreed direction-specific limit/redesign. |
| W3 | Catalog:164-167 lists split STATE/EVENT fields but no frozen literals/maxima | `HW02-*-SPLIT` evidence structure is reserved; semantic adapter rejects with `WIRE_SPLIT_UNFROZEN` until exact schemas and complete correlation are approved. A partial record must never become a time-unknown complete event. |
| W4 | HELLO request has qid, response does not echo it (catalog:29,37) | Identity/compatibility reply correlation is unresolved. Registry association cannot be learned from a name or whichever frame arrived next. |
| W5 | MAC algorithm/keys/replay rules undefined (catalog:22); RCPT_ACK lacks full content binding | Source authenticity/receipt release BLOCKED. This cloud schema does not approve authentication or fabricate a valid MAC. |
| W6 | REPLAY limit=2 but sample first=101,last=103,more=false; gap reporting deferred | Meaning may be range endpoints, but completeness/gaps and terminal cursor are unproven. Do not infer complete history or final dependencies from this marker. |
| W7 | Persistent sequence global versus epoch/reset/exhaustion unresolved | Device UUID + sequence is only safe if sequence never silently repeats. No new event identity on replay/reboot. |
| W8 | qty allows 1..unknown capacity; app source validates 6..12; CH-PENDING is unapproved | Approved profile manifest supplies species/capacity/numbers. Structural quantity bound is SQL-integer capacity, NOT hardware approval. No positive production admission is claimed. |
| W9 | STATE has original Start time but no observation instant/unique ordering beyond current event seq | Store as bridge observation, never auto-project cloud current Running or derive freshness from upload order. |
| U1 | UI summary says its review lacked HW-02; full UI documents unavailable | Cross-check to v1.2 Annex B and summary only. Direct UI-02 compatibility remains BLOCKED. |

## 6. Exact structural response schemas

Every error and reconciliation response includes server `request_id`; committed
receipts use stable `receipt_id`. Unknown fields rejected. No physical status or
freshness claim is implicit in any response. Receipt `retention_ack` is **always
null in this candidate**; signed/MAC-verifiable Uno release remains a review gate.

<!-- DB02:RESPONSE_SCHEMA -->
```json
{
  "$schema":"https://json-schema.org/draft/2020-12/schema",
  "title":"DB-02 0.1-review responses — not implemented",
  "oneOf":[{"$ref":"#/$defs/receipt"},{"$ref":"#/$defs/error"},{"$ref":"#/$defs/reconciliation"}],
  "$defs":{
    "uuid":{"type":"string","pattern":"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"},
    "nullableUuid":{"anyOf":[{"$ref":"#/$defs/uuid"},{"type":"null"}]},
    "sessionId":{"anyOf":[{"type":"string","pattern":"^[1-9][0-9]{0,18}$"},{"type":"null"}]},
    "utc":{"type":"string","format":"date-time","pattern":"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"},
    "receipt":{"type":"object","additionalProperties":false,"required":["api_version","receipt_id","receipt_revision","entity","event_id","sample_id","device_id","batch_id","session_id","content_sha256","disposition","code","received_at","retention_ack"],"properties":{"api_version":{"type":"integer","const":1},"receipt_id":{"$ref":"#/$defs/uuid"},"receipt_revision":{"type":"integer","minimum":1,"maximum":2147483647},"entity":{"enum":["event","reading"]},"event_id":{"type":["string","null"],"maxLength":128},"sample_id":{"type":["string","null"],"maxLength":100},"device_id":{"$ref":"#/$defs/uuid"},"batch_id":{"$ref":"#/$defs/nullableUuid"},"session_id":{"$ref":"#/$defs/sessionId"},"content_sha256":{"type":"string","pattern":"^[0-9a-f]{64}$"},"disposition":{"enum":["applied","waiting_dependencies","conflict"]},"code":{"enum":["APPLIED","DEPENDENCY_MISSING","ACTIVE_SESSION_CONFLICT","TRANSITION_CONFLICT","PROFILE_UNAPPROVED","LEGACY_MAPPING_REQUIRED","TIME_POLICY_UNAPPROVED"]},"received_at":{"$ref":"#/$defs/utc"},"retention_ack":{"type":"null"}},"allOf":[{"if":{"properties":{"entity":{"const":"event"}}},"then":{"properties":{"event_id":{"type":"string","minLength":1},"sample_id":{"type":"null"}}},"else":{"properties":{"sample_id":{"type":"string","minLength":1},"event_id":{"type":"null"},"batch_id":{"$ref":"#/$defs/uuid"},"session_id":{"type":"string","pattern":"^[1-9][0-9]{0,18}$"},"disposition":{"const":"applied"},"code":{"const":"APPLIED"}}}},{"if":{"properties":{"disposition":{"const":"applied"}}},"then":{"properties":{"code":{"const":"APPLIED"}}},"else":{"properties":{"code":{"not":{"const":"APPLIED"}}}}},{"if":{"properties":{"disposition":{"const":"waiting_dependencies"}}},"then":{"properties":{"code":{"const":"DEPENDENCY_MISSING"}}}},{"if":{"properties":{"disposition":{"const":"conflict"}}},"then":{"properties":{"code":{"enum":["ACTIVE_SESSION_CONFLICT","TRANSITION_CONFLICT","PROFILE_UNAPPROVED","LEGACY_MAPPING_REQUIRED","TIME_POLICY_UNAPPROVED"]}}}}]},
    "error":{"type":"object","additionalProperties":false,"required":["api_version","request_id","error"],"properties":{"api_version":{"type":"integer","const":1},"request_id":{"$ref":"#/$defs/uuid"},"error":{"type":"object","additionalProperties":false,"required":["code","message","retryable","commit_status"],"properties":{"code":{"enum":["INVALID_REQUEST","AUTHENTICATION_REQUIRED","NOT_AUTHORIZED","IDENTITY_CONTENT_CONFLICT","READING_DEPENDENCY_MISSING","PROFILE_UNAPPROVED","INVALID_SOURCE_EVIDENCE","UNSUPPORTED_EVENT_KIND","CONTRACT_NOT_ENABLED","WIRE_SPLIT_UNFROZEN","LIMIT_EXCEEDED","RATE_LIMITED","SERVICE_UNAVAILABLE","COMMIT_UNKNOWN"]},"message":{"type":"string","minLength":1,"maxLength":160},"retryable":{"type":"boolean"},"commit_status":{"enum":["not_persisted","unknown"]}}}}},
    "lookupResult":{"type":"object","additionalProperties":false,"required":["entity","entity_id","found","receipt"],"properties":{"entity":{"enum":["event","reading"]},"entity_id":{"type":"string","minLength":1,"maxLength":128},"found":{"type":"boolean"},"receipt":{"anyOf":[{"$ref":"#/$defs/receipt"},{"type":"null"}]}},"allOf":[{"if":{"properties":{"found":{"const":true}}},"then":{"properties":{"receipt":{"$ref":"#/$defs/receipt"}}},"else":{"properties":{"receipt":{"type":"null"}}}}]},
    "reconciliation":{"type":"object","additionalProperties":false,"required":["api_version","request_id","results","batch"],"properties":{"api_version":{"type":"integer","const":1},"request_id":{"$ref":"#/$defs/uuid"},"results":{"type":"array","maxItems":100,"items":{"$ref":"#/$defs/lookupResult"}},"batch":{"anyOf":[{"type":"null"},{"type":"object","additionalProperties":false,"required":["batch_id","session_id","mapping_state","status"],"properties":{"batch_id":{"$ref":"#/$defs/uuid"},"session_id":{"$ref":"#/$defs/sessionId"},"mapping_state":{"enum":["unmapped","mapped","conflict"]},"status":{"enum":["Active","Completed",null]}}}]}}}
  }
}
```

Runtime response checks also enforce signed-bigint maximum 9223372036854775807,
lookup/result identity equality, session/device/batch association, allowed receipt
revision transitions, and non-regressing mapping/receipts. An applied started,
stopped or farmer-completed request requires a real non-null session mapping;
unassociated status observation may have null. Reconciliation mapped requires
non-null session_id; unmapped requires null. Receipt lookup entity/id must match
the nested receipt. These relational constraints are runtime checks in addition
to shape validation. See recovery document.

## 7. HTTP outcomes and canonical content

| HTTP | Exact candidate meaning |
|---|---|
| 201 | A new receipt and valid event or reading committed. An event may still be waiting/conflicted; inspect disposition. |
| 200 | Exact duplicate receipt/current revision or read-only reconciliation result. |
| 400 | `INVALID_REQUEST` or `UNSUPPORTED_EVENT_KIND`; no new evidence persisted. |
| 401 | `AUTHENTICATION_REQUIRED`; token missing/invalid/expired/anonymous; no new persistence. |
| 403 | `NOT_AUTHORIZED`; revoked/mismatched scope/session/installation; no new persistence. |
| 409 | `IDENTITY_CONTENT_CONFLICT`; same key changed immutable core; original unchanged, new attempt not persisted as replacement. |
| 422 | Invalid source/profile or reading prerequisite unavailable; codes `INVALID_SOURCE_EVIDENCE`, `PROFILE_UNAPPROVED`, `READING_DEPENDENCY_MISSING`. Missing **event** dependencies instead get a committed waiting receipt. |
| 405 / 413 / 415 | Unsupported method / size / media type; fixed `INVALID_REQUEST` or `LIMIT_EXCEEDED` error. |
| 429 | `RATE_LIMITED`; configured retry delay, no write. |
| 503 | `CONTRACT_NOT_ENABLED`, `WIRE_SPLIT_UNFROZEN`, `SERVICE_UNAVAILABLE`, or `COMMIT_UNKNOWN`. Only a known pre-commit failure may claim `not_persisted`; uncertain commit uses `unknown`. |

Fixed public error text must not expose table/SQL errors, tokens, raw frames,
MACs or unrelated batch/user details. Retry flags are guidance, not permission to
change event identity or repeat a physical command.

Canonical immutable core = JSON object containing `api_version`, semantic entity
kind, `device_id`, original batch/entity IDs, command/source counters, source time
and validity, event-specific `data` or typed reading values/flags, plus normalized
**source** evidence. Normalize via the reviewed adapter; include original event
`ep`, not replay/current boot fields. Validate redundant wire fields before
normalization; never silently repair inconsistent source data.

Use RFC 8785 JSON Canonicalization Scheme (JCS) UTF-8 bytes, then SHA-256 lowercase
hex. JSON numeric 54 and 54.0 compare semantically equal; property order and
irrelevant frame whitespace do not cause conflicts. Reject nonfinite numbers and
duplicate keys before normalization. Preserve original source frames separately
under protected storage; they are not ordinary logs.

Exclude transport `operation`, current `installation_id`, JWT/session, request
ID, current retry time, `phone_received_at`, wire whitespace/part arrival order,
server receipts and dispositions from the immutable core. First uploader/phone
receipt remain protected provenance; new authorized replay attempts are separate
audit records, not overwrites. Source metadata/count/profile/time changes DO
change the hash. A replacement authorized uploader cannot change the source fact.

RFC 8785 selection is a cloud design proposal; it is **not** a claim that Uno
can compute the cloud hash or authenticate a receipt over this JSON. The retained
hardware fingerprint must be jointly specified separately.

## 8. Complete synthetic request fixtures

These are parser/design inputs only, never readings, approvals or records for
upload. `TEST-ONLY` has no production approval. Alias `A001A1B2C3D4E5F6` is a
synthetic hex-format correction, **not** the catalog's device or an assigned ID.
Frames intentionally exercise the full proposed single records, including the
oversized EVENT. They pass cloud shape examples only; real adapter acceptance is
BLOCKED until the wire issues above are resolved. No source MAC/authentication
or physical result is fabricated as verified.

<!-- DB02:REQUEST_EXAMPLES -->
```json
{
  "started":{"api_version":1,"operation":"submit_event","installation_id":"22222222-2222-4222-8222-222222222222","device_id":"11111111-1111-4111-8111-111111111111","event_id":"controller:11111111-1111-4111-8111-111111111111:103","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","event_kind":"started","command_id":"0123456789abcdef","source_sequence":103,"occurred_at":"2026-10-28T00:00:00Z","timestamp_valid":true,"phone_received_at":"2026-10-28T00:00:01Z","data":{"species_code":1,"egg_quantity":12,"profile_ref":"TEST-ONLY","installation_alias":"0123456789abcdef"},"wire_evidence":{"adapter":"HW02-EVENT-SINGLE","frames":["{\"v\":1,\"t\":\"EVENT\",\"dev\":\"A001A1B2C3D4E5F6\",\"ep\":7,\"seq\":103,\"eid\":\"A001A1B2C3D4E5F6-00000103\",\"kind\":\"started\",\"cid\":\"0123456789abcdef\",\"bid\":\"aaaaaaaaaaaa4aaa8aaaaaaaaaaaaaaa\",\"ts\":1793145600,\"tv\":true}"]}},
  "stopped":{"api_version":1,"operation":"submit_event","installation_id":"22222222-2222-4222-8222-222222222222","device_id":"11111111-1111-4111-8111-111111111111","event_id":"controller:11111111-1111-4111-8111-111111111111:104","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","event_kind":"stopped","command_id":"fedcba9876543210","source_sequence":104,"occurred_at":"2026-10-28T01:00:00Z","timestamp_valid":true,"phone_received_at":"2026-10-28T01:00:01Z","data":{"started_event_id":"controller:11111111-1111-4111-8111-111111111111:103"},"wire_evidence":{"adapter":"HW02-EVENT-SINGLE","frames":["{\"v\":1,\"t\":\"EVENT\",\"dev\":\"A001A1B2C3D4E5F6\",\"ep\":7,\"seq\":104,\"eid\":\"A001A1B2C3D4E5F6-00000104\",\"kind\":\"stopped\",\"cid\":\"fedcba9876543210\",\"bid\":\"aaaaaaaaaaaa4aaa8aaaaaaaaaaaaaaa\",\"ts\":1793149200,\"tv\":true}"]}},
  "completion":{"api_version":1,"operation":"submit_event","installation_id":"22222222-2222-4222-8222-222222222222","device_id":"11111111-1111-4111-8111-111111111111","event_id":"farmer:22222222-2222-4222-8222-222222222222:bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","event_kind":"farmer_completed","command_id":null,"source_sequence":null,"occurred_at":null,"timestamp_valid":false,"phone_received_at":null,"data":{"eggs_hatched":0,"stopped_event_id":"controller:11111111-1111-4111-8111-111111111111:104","actor_installation_id":"22222222-2222-4222-8222-222222222222"},"wire_evidence":null},
  "reading":{"api_version":1,"operation":"submit_reading","installation_id":"22222222-2222-4222-8222-222222222222","device_id":"11111111-1111-4111-8111-111111111111","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","sample_id":"sample:11111111-1111-4111-8111-111111111111:7:501","boot_epoch":7,"sample_sequence":501,"measured_at":"2026-10-28T00:01:00Z","timestamp_valid":true,"phone_received_at":"2026-10-28T00:01:01Z","current_temperature":37.6,"temperature_valid":true,"current_humidity":54,"humidity_valid":true,"wire_evidence":{"adapter":"HW02-TEL-SINGLE","frames":["{\"v\":1,\"t\":\"TEL\",\"dev\":\"A001A1B2C3D4E5F6\",\"ep\":7,\"n\":501,\"bid\":\"aaaaaaaaaaaa4aaa8aaaaaaaaaaaaaaa\",\"ts\":1793145660,\"tv\":true,\"tc\":37.6,\"t_ok\":true,\"rh\":54.0,\"rh_ok\":true}"]}},
  "reconcile":{"api_version":1,"operation":"get_reconciliation","installation_id":"22222222-2222-4222-8222-222222222222","device_id":"11111111-1111-4111-8111-111111111111","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","lookups":[{"entity":"event","entity_id":"controller:11111111-1111-4111-8111-111111111111:103"}]},
  "conflicting_count":{"api_version":1,"operation":"submit_event","installation_id":"22222222-2222-4222-8222-222222222222","device_id":"11111111-1111-4111-8111-111111111111","event_id":"controller:11111111-1111-4111-8111-111111111111:103","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","event_kind":"started","command_id":"0123456789abcdef","source_sequence":103,"occurred_at":"2026-10-28T00:00:00Z","timestamp_valid":true,"phone_received_at":"2026-10-28T00:00:01Z","data":{"species_code":1,"egg_quantity":11,"profile_ref":"TEST-ONLY","installation_alias":"0123456789abcdef"},"wire_evidence":{"adapter":"HW02-EVENT-SINGLE","frames":["{\"v\":1,\"t\":\"EVENT\",\"dev\":\"A001A1B2C3D4E5F6\",\"ep\":7,\"seq\":103,\"eid\":\"A001A1B2C3D4E5F6-00000103\",\"kind\":\"started\",\"cid\":\"0123456789abcdef\",\"bid\":\"aaaaaaaaaaaa4aaa8aaaaaaaaaaaaaaa\",\"ts\":1793145600,\"tv\":true}"]}},
  "status":{"api_version":1,"operation":"submit_event","installation_id":"22222222-2222-4222-8222-222222222222","device_id":"11111111-1111-4111-8111-111111111111","event_id":"observation:11111111-1111-4111-8111-111111111111:cccccccc-cccc-4ccc-8ccc-cccccccccccc","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","event_kind":"status_observed","command_id":"1111222233334444","source_sequence":null,"occurred_at":null,"timestamp_valid":false,"phone_received_at":"2026-10-28T00:02:00Z","data":{"query_id":"1111222233334444","boot_epoch":7,"latest_event_sequence":103,"controller_state":"RUNNING","species_code":1,"profile_ref":"TEST-ONLY","original_start_at":"2026-10-28T00:00:00Z","original_start_valid":true},"wire_evidence":{"adapter":"HW02-STATE-SINGLE","frames":["{\"v\":1,\"t\":\"STATE\",\"qid\":\"1111222233334444\",\"dev\":\"A001A1B2C3D4E5F6\",\"ep\":7,\"seq\":103,\"st\":\"RUNNING\",\"bid\":\"aaaaaaaaaaaa4aaa8aaaaaaaaaaaaaaa\",\"sp\":1,\"pv\":\"TEST-ONLY\",\"start_s\":1793145600,\"tv\":true}"]}}
}
```

### Eight end-to-end examples (hypothetical isolated model, not actual API results)

The full bodies above are named request examples, not substitution templates.
Repeated upload means **byte-for-byte the same full request**, except permitted
transport-envelope/provenance changes under section 7. `H(started)` below denotes
the actual canonical SHA-256, not a literal accepted hash. Exact example responses
with calculated hashes are recorded after host validation below.

| Case | Complete request selected | Expected modeled result |
|---|---|---|
| 1 confirmed Start | `started` | 201, one committed receipt, `applied/APPLIED`, session `"42"`, hash H(started). This records a past transition, not current Running. |
| 2 confirmed Stop | `stopped`, after case 1 | 201, `applied/APPLIED`, same `"42"`; session lifecycle stays Active awaiting manual completion. |
| 3 manual completion | `completion`, after cases 1/2 | 201, `applied/APPLIED`, same `"42"`; farmer-entered zero is valid, session Completed; `end_date=null` because this fixture's action time is unknown. No invented hatch result/time. |
| 4 actual-value structure | `reading`, after case 1 and before case 2 | 201 reading receipt; source values/time match TEL; no live/fresh assertion. Values are synthetic test inputs, not actual measurements. |
| 5 duplicate | resend exact `started` after case 1 | 200, same receipt ID/first time/revision if processing unchanged; one session/event only. After completion, replay cannot reopen session. |
| 6 same ID, changed content | `conflicting_count` (full body above; only original count differs) | 409 `IDENTITY_CONTENT_CONFLICT`, no replacement or new session; original hash/content unchanged. |
| 7a missing dependency | full `stopped` in a fresh model before `started` | 201 committed `waiting_dependencies/DEPENDENCY_MISSING`, null session mapping; later valid predecessor can advance same receipt revision. |
| 7b existing Active row | full `started` with an unrelated preexisting Active session | 201 committed `conflict/ACTIVE_SESSION_CONFLICT`, null mapping; existing session unchanged; admin reconciliation, never auto-complete/delete. |
| 8 response lost | submit full `started`, discard reply, then full `reconcile` | 200 reconciliation returns the same receipt and mapped `"42"`; no new physical or cloud batch. If not found, retry same `started`, never allocate a new identity. |

### Complete response examples

Each named response pairs with its corresponding complete request above and the
scenario table. `waiting`/`conflict` use independent fresh-store scenarios, not
different receipt identities for the same event in one store. Hashes below were
actually calculated from the documented synthetic semantic cores. They are not
commit evidence, signatures, real database IDs, or proof of a working endpoint.
The duplicate Start response is exactly `started` again; receipt revisions change
only when committed processing changes. The 409 body pairs with the full Start
request with original identity and count 11, as specified by scenario 6.

<!-- DB02:RESPONSE_EXAMPLES -->
```json
{
  "started":{"api_version":1,"receipt_id":"70000000-0000-4000-8000-000000000001","receipt_revision":1,"entity":"event","event_id":"controller:11111111-1111-4111-8111-111111111111:103","sample_id":null,"device_id":"11111111-1111-4111-8111-111111111111","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","session_id":"42","content_sha256":"3ec2e9e1d4d8e06500276e9a47713eea3f7069b9525ea3a45664b66bf45ced86","disposition":"applied","code":"APPLIED","received_at":"2026-10-28T02:00:00Z","retention_ack":null},
  "stopped":{"api_version":1,"receipt_id":"70000000-0000-4000-8000-000000000002","receipt_revision":1,"entity":"event","event_id":"controller:11111111-1111-4111-8111-111111111111:104","sample_id":null,"device_id":"11111111-1111-4111-8111-111111111111","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","session_id":"42","content_sha256":"4fe292bcc3a1670a81c73e2ec48f5b1a27913de33828a61a2fad15f2c1ca8a4e","disposition":"applied","code":"APPLIED","received_at":"2026-10-28T02:00:00Z","retention_ack":null},
  "completion":{"api_version":1,"receipt_id":"70000000-0000-4000-8000-000000000003","receipt_revision":1,"entity":"event","event_id":"farmer:22222222-2222-4222-8222-222222222222:bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb","sample_id":null,"device_id":"11111111-1111-4111-8111-111111111111","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","session_id":"42","content_sha256":"f1c92f1194cdc8f6d6a725e4667205369be4a634645f79e71e9a4634341d7947","disposition":"applied","code":"APPLIED","received_at":"2026-10-28T02:00:00Z","retention_ack":null},
  "reading":{"api_version":1,"receipt_id":"70000000-0000-4000-8000-000000000004","receipt_revision":1,"entity":"reading","event_id":null,"sample_id":"sample:11111111-1111-4111-8111-111111111111:7:501","device_id":"11111111-1111-4111-8111-111111111111","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","session_id":"42","content_sha256":"192ad69e96391ab52540784387f736593506dc69f22f0596c5fc2a092285c3ba","disposition":"applied","code":"APPLIED","received_at":"2026-10-28T02:00:00Z","retention_ack":null},
  "waiting":{"api_version":1,"receipt_id":"70000000-0000-4000-8000-000000000005","receipt_revision":1,"entity":"event","event_id":"controller:11111111-1111-4111-8111-111111111111:104","sample_id":null,"device_id":"11111111-1111-4111-8111-111111111111","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","session_id":null,"content_sha256":"4fe292bcc3a1670a81c73e2ec48f5b1a27913de33828a61a2fad15f2c1ca8a4e","disposition":"waiting_dependencies","code":"DEPENDENCY_MISSING","received_at":"2026-10-28T02:00:00Z","retention_ack":null},
  "conflict":{"api_version":1,"receipt_id":"70000000-0000-4000-8000-000000000006","receipt_revision":1,"entity":"event","event_id":"controller:11111111-1111-4111-8111-111111111111:103","sample_id":null,"device_id":"11111111-1111-4111-8111-111111111111","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","session_id":null,"content_sha256":"3ec2e9e1d4d8e06500276e9a47713eea3f7069b9525ea3a45664b66bf45ced86","disposition":"conflict","code":"ACTIVE_SESSION_CONFLICT","received_at":"2026-10-28T02:00:00Z","retention_ack":null},
  "identity_conflict":{"api_version":1,"request_id":"90000000-0000-4000-8000-000000000001","error":{"code":"IDENTITY_CONTENT_CONFLICT","message":"This identity already records different content.","retryable":false,"commit_status":"not_persisted"}},
  "reconcile":{"api_version":1,"request_id":"90000000-0000-4000-8000-000000000002","results":[{"entity":"event","entity_id":"controller:11111111-1111-4111-8111-111111111111:103","found":true,"receipt":{"api_version":1,"receipt_id":"70000000-0000-4000-8000-000000000001","receipt_revision":1,"entity":"event","event_id":"controller:11111111-1111-4111-8111-111111111111:103","sample_id":null,"device_id":"11111111-1111-4111-8111-111111111111","batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","session_id":"42","content_sha256":"3ec2e9e1d4d8e06500276e9a47713eea3f7069b9525ea3a45664b66bf45ced86","disposition":"applied","code":"APPLIED","received_at":"2026-10-28T02:00:00Z","retention_ack":null}}],"batch":{"batch_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","session_id":"42","mapping_state":"mapped","status":"Active"}}
}
```

## 9. Validation record / boundaries

Actual host checks: Node v26.4.0, Ajv 8.17.1 with ajv-formats 3.0.1, dependencies
and validator outside the repository in approved temporary tooling storage.
Command used:

```powershell
node "C:\Users\MARYCH~1\AppData\Local\Temp\opencode\db02-review-validation.cjs"
```

The helper reads these Markdown blocks, compiles both schemas, checks examples,
derives normalized source data and canonical hashes, and rejects selected invalid
mutations. Its in-memory illustration does not implement or exercise an HTTP
endpoint, PostgreSQL transaction, complete wire parser, or production JCS library.
It canonicalizes the fixtures' ASCII-key/finite-number subset consistently with
the proposed JCS rule; a complete audited implementation still requires review.

Actual result:

```text
PASS: 2 JSON Schema 2020-12 meta-validations/compilations
PASS: 7 complete synthetic requests
PASS: 8 calculated synthetic responses
PASS: 46 schema-negative mutations rejected
PASS: 7 source-mapping conflicts rejected by host fixture assertions
PASS: 4 canonical invariance checks; changed-count hash differs
PASS: in-memory duplicate/conflict/lost-response illustration (not PostgreSQL or HTTP)
PASS: published response JSON matches calculated hashes and receipts
NOT TESTED: endpoint, source adapter approval, Auth/RLS, database transactions/concurrency, SQLite, signatures, firmware, network, RTC or hardware.
```

The four invariance cases are reordered object keys, changed wire whitespace,
54/54.0 numeric spelling, and changed permitted uploader/phone-receipt metadata.
The source assertions also reject sequence/batch/command/value/Start-time mismatch,
unapproved splits and the catalog's nonhex alias. These are selected fixture
assertions, not complete parser/adaptor or authorization enforcement tests.

Independently recounted all 14 exact HW catalog literals with Node JSON.parse
and Buffer.byteLength, excluding LF / including one LF:

| HW example | Content / with LF |
|---|---|
| HELLO request / response | 44/45; 133/134 |
| START / STOP / STATUS | 169/170; 134/135; 45/46 |
| accepted / rejected ACK | 70/71; 67/68 |
| STATE / EVENT | **198/199; 204/205** — over provisional 191-content target |
| TEL / ERROR | 169/170; 48/49 |
| REPLAY / REPLAY_END / RCPT_ACK | 67/68; 85/86; 105/106 |

These are exact literal counts only, not maximum-width proofs, safe SRAM claims
or approval of 191-byte framing. Companion script from Ally was not required
or executed; Node reproduction independently confirms the listed literals.

Final documentation checks also passed: all 8 local Markdown links resolve,
code fences balance in all three artifacts, and Git whitespace checks report no
whitespace errors. Git emits its existing LF-to-CRLF conversion warnings; no
line-ending configuration was changed. Final Git status adds only these three
review files beyond the initial pending-work snapshot.

Only the three DB-02 Markdown review artifacts were added in the repository;
temporary validator/tool dependencies live outside it. No production changes,
schema execution, secrets, deployment or new live audit. Full UI-02 cross-check,
wire feasibility, source/receipt authentication and team sign-off remain BLOCKED.
