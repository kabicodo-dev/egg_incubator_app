# Fresh Q12 v3 source/evidence review

2026-10-31. **Local verdict: PASS WITH DOCUMENTED LIMITATIONS for a bounded
Phase A candidate. Remote readiness: BLOCKED.** No newly identified locally
resolvable blocking defect required a v4. v1/v2/v3 sources were preserved.

This is a fresh source/evidence review by the same assistant, not a separate
human reviewer or externally signed audit. No subagent or external reviewer
was used. Authorized reviewer acceptance remains pending.

## Reviewed source and findings

Paths in this table are in `../q12-controller/v3/` unless stated otherwise.

| Control / finding | Fresh review result and evidence |
|---|---|
| F1 catalog evidence | ModelPolicy.cs:158–305 retains allowlisted vocabulary, opaque unknown names, ACL normalization, narrow exact comparisons and explicit uncertainty. CompleteCatalogVerification stays false. Partial F1 semantic coverage is **not** a closed full audit requirement. |
| F2 native adapter | NativeBoundary.cs:13–104 exercises scalar polling/decoding/draining over fake IPq; :106–231 contains Cdecl libpq bindings and memory-only probes. Load uses installed absolute DLL path and restricted dependency search. No network call except Start/Poll/connection operations; local tests never call NativePq.Start. Native DNS/buffering/stalls remain beyond hard realtime guarantees. |
| F3 evidence durability | DurableController.cs:47–70 creates new files, validates events, writes UTF-8 JSONL and Flush(true); statement intent/result/failure records are incremental. Primary/emergency failures stop. Shared storage/crash/torn lines remain risks, not guaranteed crash recovery. |
| F4 shape and overflow | ModelPolicy.cs:63–113 checks all 12 SELECT shapes, order/OIDs/nullability/value types, command tags, settings guards. Native Decode counts using PQntuples, skips materializing >500 rows and Shapes rejects overflow. 500 vs 501 cases pass; managed cells <=16 KiB; server/libpq may buffer before managed limits. |
| F5 provenance | Full preflight carries target, SQL, source/draft/certificate hashes, runtime/libpq, approval reference/run ID/mode; UTC/elapsed/status/state present. Machine records cannot authenticate human authorization. |
| F6 certificate | Strict eight-field owner record, pinned target/source URL/method/hash/time; actual trust unavailable. Parser tests are synthetic, not real provenance. Offline CA observation alone cannot approve trust. |
| F7 honest coverage | Historical 211 case objects all PASS, eight source hashes/five receipts verified. Fresh 211/211 run d7b25ad8655a47318783ec987cee2859. Three actual native probes only allocate/use/clear PGresult memory; real TLS/Auth/pooler/rollback NOT RUN. |
| R1 | ModelPolicy.cs:81 requires non-null defaclacl. Independent literal fixture plus installed PG17 postgres.bki:11329 FORCE NOT NULL checked. |
| R2 | :203–211 binds private schema, intended table/name, check kind and exact definition; :236–239 rejects duplicate tuple identities. Wrong table/schema/kind/expression and ambiguity tests pass. A per-cell MATCH never implies whole-object acceptance. |
| R3 | DurableController.cs:91–96 flushes full manifest to both destinations before connect. :155–164 mirrors terminal outcome, appending a correction if main fails. Independent emergency-only file check confirms actual test run/source hashes, simulated tag/idle/close, STOPPED/JournalDurable=false after primary failure. Use last terminal event; sequence numbers span both files, so numeric gaps in one file alone are not automatic data loss. |
| R4 | ModelPolicy.cs:115–126 validates whole version syntax, strips package text, exports numeric server value; DurableController.cs:109 retains it. Client version separately labelled. Unknown versions fail closed; supported syntax is not server-compatibility certification. |
| R5 | SourceSnapshot.psm1:12–98 holds eight read-sharing locks, strict UTF-8/no BOM, byte/text hashes, compiles captured strings and validates generated compiler-file/decoded content receipts. Original paths are not passed as compiler inputs. Normal writes, broken lock, memory tamper and missing unit tests pass. Host/module bootstrap/compiler/same-process integrity are trusted; not code signing. |
| Procedure NULL | ModelPolicy.cs:78,112,277–293 accepts legitimate NULL result_type but labels UNCLASSIFIED/UNRESOLVED and suppresses approved function matching. Approved SQL lacks prokind filter; PG17 functions-info.html:967 independently confirms procedure NULL. Unrelated NULLs, wrong OIDs/order and blank values still rejected. |
| Credentials | Launcher :55 prompts SecureString locally before connecting; no secret arguments/file/environment writes. Native :153–181 clears temporary chars/UTF-8/unmanaged buffers, rejects embedded NUL, uses fixed parameters, passfile=NUL, expand_dbname=0 and clears/restores inherited PG* environment during setup. Notices discarded; no raw server error output. Libpq/OS may retain auth memory; no crash dumps/transcripts/debugger/host compromise guarantee. Do not paste credentials in chat. |
| One connection / ordering | Session attempted/disposed and NativePq.started reject repeat starts; no reset/reconnect API. Controller loops exactly 17 pinned statements, drains one result, validates/journals before next; sole failure extra is literal ROLLBACK on same usable in/failed-transaction connection. |
| Transaction / cleanup | State must initially be idle; after BEGIN through SELECTs must be INTRANS. Final ROLLBACK tag and idle required. Recoverable failure uses original connection once; transport/deadline failure marks unusable, closes, and reports unavailable rollback. No reconnect-as-proof. |
| Target / TLS | Exact ref/host/port/db/user and verify-full/root pin; connection getters/SSL/read-only/idle rechecked. Project identity depends on authenticated owner confirming coordinates and project-specific pooler username, not database name. Actual server/pooler attestation pending. Native application_name still contains v2; this benign retained label is not used as revision proof; source hashes identify v3. |

Independent installed libpq-status.html:176 documents
default_transaction_read_only among supported ParameterStatus keys in PG17.
This supports the native API assumption, not actual Supabase output.

## Catalog evidence coverage and audit limits

Approved SQL is the immutable scope. Do not add queries or save raw expressions
to compensate for limitations during an approved run.

| Area | Retained / comparable | Remains UNRESOLVED or outside scope |
|---|---|---|
| Schemas / relations | Allowlisted schema/object/owner identities, relkind, ACL metadata, RLS flags; three draft table name-presence checks | Unknown identities opaque; presence not complete schema equivalence; no data or tenant routing proof from db name |
| Columns | Name, supported type strings, nullability/identity/generated enums; exact false defaults on named registry tables | Other types/default expressions withheld; no complete ordered schema baseline comparison |
| Constraints | Three full-identity disabled-registry checks | Other constraints or semantic equivalence/format variants not interpreted |
| Indexes | Allowlisted names, unique/valid booleans | Definitions withheld; full index coverage/effectiveness unresolved |
| Policies / RLS | Table/name-bound three owner policy expression comparisons, commands/roles/permissive flags, ENABLE/FORCE flags | Arbitrary expressions withheld; policy composition and enforcement not tested with actual JWTs |
| Triggers | Names/enabled enum | Definitions/bodies withheld; behavior and internal triggers outside inspection |
| Routines | Name/owner/definer/volatility, four known argument/owner comparators, empty search_path check, ACLs | Result type generally withheld, bodies not selected, arbitrary overloads/prokind unresolved; no function execution |
| Roles / memberships | Selected role booleans, granted/member/admin flag | No complete recursive effective privilege audit; other membership options not selected |
| Grants / defaults | Supported unquoted ACL grammar normalized; explicit NULL-not-expanded label | Quoted role ACLs, implicit defaults/effective privileges unresolved; no acldefault expansion query |
| Authorization / DB-IMP-01 | Metadata collisions/missing draft names can be reported | No Auth/session/JWT, enrollment, atomic persistence, race, direct-table/RPC bypass or endpoint acceptance; these remain separate tasks |

Draft hashes are pinned solely as unapproved design comparators; they are older
event/reading drafts, not adopted manual-result 0.2 schema. Do not label draft
deviation a confirmed security vulnerability without actual context. Missing
objects are valid findings, never implicit permission to create objects.

## Verification evidence

- `local-review-evidence.json`: v2/v3 historical inventory hashes/sizes checked;
  historical and fresh 211-case arrays checked; eight source/five compiler receipts;
  emergency-only correlation; immutable SQL; 61 JSON/JSONL files scanned for known
  synthetic secret markers. Scanner success is not an arbitrary-secret detector.
- Fresh run: `../q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/test-results.json`.
- Original final run and original review inventories remain byte-preserved. New
  run files are supplemental and will be captured by this package's inventory;
  the old v3 inventory is intentionally not rewritten.
- Local test commands: v3/Test-Corrections.ps1, then this package's
  Verify-LocalEvidence.ps1, both run using Windows PowerShell -NoProfile
  -NonInteractive -ExecutionPolicy Bypass -File. The latter is create-once.

**No external sign-off, trusted-origin certificate approval, live result-schema
certification, full catalog audit or original-task completion is asserted.**
