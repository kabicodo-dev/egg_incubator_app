# D04 / D06 — Mary Charlyn's actual backend answers

> **30 Oct consolidation update:** Ally's conditional support for independent
> manual results and the supplied Flutter compatibility review are now received.
> Earlier pending-Ally wording below preserves this original personal-response
> snapshot, not the latest receipt state. See the existing decision ledger and
> [DB-02 consolidated amendment](DB-02_30Oct_Consolidated_Alignment.md).
> Exact shared lifecycle/admission choices remain open; no implementation change.

**Respondent:** Mary Charlyn L. Aguirre (Cha/Mary: one person)  
**Recorded:** 2026-10-30, Asia/Manila  
**Disposition:** Personal backend positions accepted below; **NOT JOINTLY APPROVED**.  
**Source:** The user's four explicit answers to the D04/D06 review questions in
this session. “Let's proceed” alone was not treated as approval; the answers below
are the actual subsequent selections.

This is a focused answer/change-request record, not a replacement contract or
another general audit. The main ledger remains CONTRACT-FREEZE-01_Team_Decisions.md.
No vote is recorded for Kath, Ally, or a designated numerical-profile approver.

## D04 — cloud authorization: accepted personal position

**Exact answer:** “Accept this position”.

For **protected SmartHatch cloud data**:

- One administrator-provisioned, non-anonymous installation, bound to approved
  user/session/controller scope.
- Recheck scope on each protected operation; deny anonymous, other and revoked
  identities. Identity IDs are identifiers, not authentication credentials.
- No privileged credential in Android.

**Still unresolved:** exact login/bootstrap/enrollment/replacement mechanism,
secure session storage and refresh behavior, Flutter startup/direct-table/History
compatibility, a reviewed credential-copying threat model, migration/registry
implementation and real signed-token/revocation tests. An app UUID/session binding
alone is not proof that credentials cannot be copied to another physical phone.
Whether any presets are intentionally public is not decided by this protected-data
position. No provisioning or Auth-settings change is authorized by this answer.

Cloud authorization is separate from offline Bluetooth command authority.
Cloud failure/revocation must not be described as a physical controller Stop.
Ally/Kath still need to agree local authorization/provisioning and offline
revocation/loss boundaries before live command gates can be enabled.

## D04 — retained-evidence release: accepted personal position

**Exact answer:** “Accept fail-closed release”.

- Keep `retention_ack=null` in the candidate backend response.
- Do not delete/release Arduino's retained critical evidence merely because an
  HTTP request succeeded. Do not invent an authenticated server-release proof.

This is **not** a promise of unlimited retention or zero event loss. Journal
capacity, full/corrupt behavior, offline authority, accepted loss cases, and any
future feasible authenticated release design still need Ally/Kath agreement.
No automatic retention-release path is enabled by this answer.

## D06 — sync invariants and candidate names: accepted personal position

**Exact answer:** “Accept these positions”.

- Preserve real `egg_quantity` and `eggs_hatched` names and lossless bigint
  session mapping.
- Candidate RPC names remain `bridge_sync_authorize_v1`,
  `bridge_sync_ingest_v1`, and `bridge_sync_reconcile_v1`.
- Same original identity plus the same canonical content is an idempotent retry;
  changed content under the same identity conflicts, not a replacement event.
- Validate receipts and reconcile uncertain uploads without retrying physical
  Start. Cloud state/HTTP success is not proof of a physical transition.

**Not approved by this answer:** a complete payload/receipt/catalog revision,
exact canonical source adapter/hash implementation, source-field widths,
Kath's storage package/schema/support floor, Android outbox implementation,
transactional projections, persisted receipts, or deployment. Existing API
documents remain candidates; these answers do not ratify every field/paragraph.

The separately verified isolated target remains smarthatch-test
(`zbwntspdecngnicllwlw`). Previous narrow test authorization is preserved; it
does not expand to migrations, RLS changes, RPC activation or production access.

## D06 — completion independent of Stop: Mary's CHANGE REQUEST

**Exact answer:** “Separate completion from Stop”.

**Mary's proposal:** Save validated farmer-entered manual hatch results
independently of Stop evidence, without claiming or commanding physical Stop.

This conflicts with the current candidate in
`DB-02_Conflict_Receipt_And_Recovery.md` section 3: its `farmer_completed` row
requires an applied referenced Stop. The candidate SQL/fixtures/API/UI must not
be silently treated as compatible with Mary's proposed alternative.

**Joint disposition: PENDING KATH + ALLY REVIEW.** No completion behavior was
changed. This proposal does not approve:

- Automatically stopping/starting hardware or fabricating missing Stop evidence.
- Treating cloud `Completed` as proof that the controller is stopped or safe.
- Using a newly Completed cloud row to bypass the current physical-batch guard
  and start another batch while the controller could still be running.
- A concrete new-batch/Active-index, local draft, synchronization dependency,
  original completion-time or incomplete-source recovery rule. These still need
  exact joint lifecycle design and compatibility tests.

The safe action now is to record this as a requested candidate revision, not
remove Stop prerequisites from SQL, code, fixtures or contracts on Mary's behalf.

## Exact requests to Kath and Ally

**Kath:** Accept/change the non-anonymous protected-cloud installation direction;
provide the exact startup, secure-storage/session and direct-table migration
compatibility plan. For Mary's independent completion proposal, specify the
local draft/pending/saved UX and safe active/new-batch semantics with the backend.
No plugin/version or new UI behavior is chosen by this answer record.

**Ally:** Provide the exact controller/source identity and offline authorization,
retention/full-journal feasibility and remaining recovery facts. Review independent
farmer-result completion without interpreting it as physical Stop or admission
of another hardware batch. Do not infer hardware readiness from Mary's vote.

**Mary:** The four personal answers above are recorded. Exact source mapping,
complete API/receipt/hash dependency schema, enrollment mechanism and safe
implementation/migration scope remain to be agreed before implementation.

Ask each owner to reply ACCEPT / CHANGE / BLOCKED to those specific points,
with the actual matching source/catalog/document revision. Do not start another
architecture vote or call these personal responses a full freeze.

## Referenced candidate bytes (not signed/frozen revisions)

| Repository document | SHA-256 at this review |
|---|---|
| DB-02_Proposed_Schema_And_Security.md | `6322985031a82d25184bd0ebefc7e1a9016d74c22b7e8d587e94dafb16d3f230` |
| DB-02_Conflict_Receipt_And_Recovery.md | `08e6f97c7c320769e223218fbea7ce52a1d4a1b0ec5d117a83965d5678f39f06` |
| DB-02_Exact_Bridge_Sync_API.md | `5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab` |

These identify the inspected candidates; they are not a selected firmware packet,
joint acceptance, proof the user reviewed every byte, or approval of the conflicting
Stop prerequisite. Existing candidates are preserved unchanged as review history.

## Changes and verification boundary

Only this answer record, the main decision ledger's current answer cells, local
validation/evidence and full portal/report/handoff/import artifacts are updated.
No Supabase access or writes, Auth provisioning, SQL/Flutter/firmware changes,
deployment, Git commit, or additional task completion. D04 remains blocked in its
joint dependent scope; D06 remains awaiting joint exact mapping/lifecycle review.
Earlier no-answer reports remain historical and must not overwrite these replies.
