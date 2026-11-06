# 16 — Q07 revision 0.2 P1–P6 approval attribution

Prepared 2026-11-03. This additive clarification preserves historical documents unchanged. **Design approval is neither implementation/deployment authorization nor Kath's formal backend handover acceptance.**

## Separate approval records

| Person / disposition | Supporting source | Evidence level / missing original |
|---|---|---|
| **Kath explicitly approved Q07 revision 0.2 P1–P6 at design scope.** | Current user instruction, Step 3, explicitly supplies this fact | User-confirmed in this Phase 1 conversation. No original Kath approval message, signed per-row response, timestamp or approved-input SHA-256 found in inspected local Markdown evidence. Do not invent an original repository receipt or signature; reconcile the original if available, without requesting another unchanged vote. |
| **Mary's separate P1–P6 design approval is reported independently.** | `docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md:34–45`, specifically line 38: “Mary states P1–P6 0.2 approved at design scope only”; `docs/contract-review/Q07_SMTP_Test_Project_Plan_0.1.md:18–20`: “Mary reports Q07 technical 0.2 P1–P6 approved at design scope only.” | Two local documentary locations record Mary's reported approval, not independent authentication or an original first-person signed P1–P6 response. Original underlying approval message/date/hash not supplied locally. The two references may derive from the same reported event, not two independent approvals. |
| **Neither authorizes implementation or deployment.** | Current task boundary; technical policy 0.2 lines 4–6, 95–96, 193–195; SMTP plan status; active ledger scope | No account assignment, Auth/RLS/provider/SMTP setting, migration, remote query, source activation, code change or deployment follows. |

The explicit Kath approval fact is newly confirmed by the current user instruction; the local-only repository search cannot independently reconstruct its original wording, channel, date or reviewed hash. This is a stated evidence limitation, not a denial of her approval. Mary's approval is not attributed to Kath, and Kath's approval is not used as proof Mary approved.

## Exact design being discussed

`docs/contract-review/Q07_Provider_Session_Binding_Policy_0.2.md` defines:

| Row | Design scope |
|---|---|
| P1 | Self-service signup and verified account; signup is not record assignment |
| P2 | Provider configuration/recovery behavior; no invented hosted values |
| P3 | Account sessions, no approved-phone/session reapproval access gate |
| P4 | One-time authorized team assignment of correct existing records, audit and atomic scope checks |
| P5 | Logout/local evidence/recovery without routine reapproval; account isolation and original uncertain outcomes |
| P6 | Account-scoped History and immutable result boundaries; no lifecycle/Active/admission release |

Matching plain-language document: `docs/contract-review/Q07_Plain_Language_Access_Proposal_0.2.md`. Independently computed current-byte hashes for both and the two Mary evidence documents are in [14](14-MINIMUM-REQUIRED-TRANSFER-SET.md). Those hashes identify **current comparison inputs**, not retroactive proof either person approved those exact bytes. No approved-input hash is fabricated.

## Historical statements and precedence

- Technical 0.2's existing header says “FINAL REVIEW PENDING”; its concluding text requests P1–P6 responses. That is a preserved historical state, qualified for **Kath's design disposition** by the current explicit user confirmation. It must not be silently rewritten or treated as proof no approval ever occurred.
- Existing handover 04/06/11 records Mary approval as reported and various final review/implementation gates pending. This clarification adds Kath's independently attributed user-confirmed approval without editing those records or declaring all technical/operational gates closed.
- The Q06/Q07 revision-3 receipt concerns assistant-prepared S1–S4/E1–E5 recommendations under an older access model, not proof of Q07 0.2 P1–P6 approval.
- `KATH_02_DELTA_ACCEPT_RECEIPT.md` concerns **manual-result 0.2**, a different contract. Its ACCEPT is not Q07 P1–P6 evidence.
- SMTP plan acceptance/recipient consent is not provider configuration/send authorization and is not another P1–P6 vote.

## Still missing or blocked

Original Kath and Mary approval messages/reviewed-input hashes are not available in the inspected checkout; preserve that distinction and request reconciliation only if needed for provenance. Exact provider/native/SDK behavior, account-assignment authority, compatible authorization schema/adapter/API mapping, tests and approved rollback/operational scope remain unresolved. Existing installation/session code and SQL drafts do not implement the new account-only design.

No approvals were rewritten, no new decision was inferred, and no signatures or acceptance dates were created. Kath's formal backend handover acceptance remains **pending**.
