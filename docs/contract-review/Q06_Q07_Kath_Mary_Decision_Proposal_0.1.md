# Q06/Q07 — storage and enrollment/session choices

**Revision:** 0.1 · **Prepared:** 2026-11-01
**Status:** DISCUSSION PROPOSAL — Mary/Kath exact choices PENDING.
**Scope:** recommendations prepared at Mary's request, not new Mary/Kath votes,
implementation permission, a replacement API or a selected controller protocol.
Actual responses belong in [the existing decision ledger](CONTRACT-FREEZE-01_Team_Decisions.md).

## Preserve previous agreement

Use [Mary's M01–M08](D04_D06_Mary_Backend_Position.md) and
[Kath's manual-result 0.2 scoped ACCEPT](../integration/cha-execution/KATH_02_DELTA_ACCEPT_RECEIPT.md)
without another general review. Result recording leaves Active/end_date/admission
unchanged; unknown times and original identities are not repaired by cloud receipts.
Cloud authentication is not offline controller-command authorization.

Kath's earlier storage/enrollment suggestions are already received; do not request
a new general proposal. The rows below ask for exact remaining choices and evidence.
Ally's source packet still gates decoder/source mapping, not these independent
client/cloud design discussions. Source-specific claims remain pending Ally.

## Decision table — reply to each row

Labels S1–E5 are discussion-row references under Q06/Q07, not new task/API IDs.
Every recommendation below is **PROPOSED**, unless explicitly carried forward
from M01–M08. Reply ACCEPT, CHANGE with replacement, or BLOCKED with missing input.

| Row | Recommended concrete choice | Required answer / limit |
|---|---|---|
| S1 / Q06 — platform/packages | Native Android is the pilot storage target. Keep Kath's proposed `sqflite_sqlcipher 3.4.1` and `flutter_secure_storage 11.2.0` as evaluation candidates only; no unencrypted fallback. Select exact pins and minimum API only after device/Flutter/Gradle/native compatibility review. | Kath: confirm/change candidates, provide actual device model/API/ABI, SDK/toolchain and support-floor evidence. API 30+ is not selected here. Web/desktop are not certified by Android tests. No install authorized. |
| S2 / Q06 — keys/backup | Generate a random per-installation database key using platform cryptographic randomness, protected through a reviewed Android Keystore-backed mechanism. Keep DB key separate from session-token material; no key in source, `.env`, logs or preferences. Require local owner unlock to access protected evidence. Exclude protected DB/key/token artifacts from automatic cloud/device-transfer backup until a reviewed encrypted recovery design exists. | Kath: exact key wrapping, unlock/device-credential, app background/process death, plugin storage and backup rules; verify actual native behavior, not plugin-name assurances. Do not promise credential-copy resistance or hardware exclusivity from a UUID/Keystore label. |
| S3 / Q06 — commits/retry | Carry forward M06/M08: durable draft reserves original action ID; sealing commits immutable action+outbox atomically. Validated receipt+mapping+outbox-state change is atomic. One logical initial result per original device/batch, also enforced server-side across actors/replacements. Only cloud facts/results enter upload queue; no physical command replay. | Kath: concrete schema/unique constraints, transaction boundaries, single-uploader lease/expiry recovery and crash tests. Missing trusted manifest remains Pending validation. Disk/commit ambiguity preserves original identity and never claims Saved. |
| S4 / Q06 — reinstall/key loss | Fail closed on unreadable/missing keys or corrupt storage; do not auto-delete/recreate the DB, overwrite evidence, regenerate an existing action ID or treat reinstall as recovery. Recovery is an explicit support process; unrecoverable local-only evidence must be reported as unavailable/lost, not reconstructed. | Kath/Mary: reviewed recovery/export/import policy and supported OS reset/uninstall cases. No guarantee of recovering encrypted local-only records after key loss. A new installation gets a distinct identity; old actor facts require explicit recovery scope. |
| E1 / Q07 — enrollment/admin | Recommend administrator-created/invited non-anonymous Supabase identity with public self-registration disabled for the pilot. Bootstrap through a supported provider invite/email-OTP flow over verified HTTPS; no shared static password or custom secret in the app. Binding to installation/controller/session is a separately authorized admin action, not something the phone may self-grant. | Mary: name a real authorized administrator and controlled inbox/support recipient privately. Kath: confirm provider/client flow and UI compatibility; invitation alone grants no protected SmartHatch capability. No account/invite/config change authorized. |
| E2 / Q07 — activation | Avoid a new custom activation-code endpoint for this slice. Use only the selected provider flow's verified expiry/replay/rate-limit behavior; no local-clock-only eligibility check. Admin scope binding must be auditable and atomically enforce the designated active installation rule. | Kath/Mary: confirm actual provider expiry, one-time-use/replay behavior, deep-link handling and resend/expired-flow UX from verified configuration/tests. Earlier 30-minute expiry is NOT selected. If provider flow cannot meet the agreed requirements, record BLOCKED before proposing a replacement. |
| E3 / Q07 — refresh/relogin | Refresh-token rotation may continue upload only when the trusted Auth result retains the approved non-anonymous user/session scope and registry authorization remains valid. Changed session/subject, expiry or revocation requires approved reauthentication/reapproval; app cannot silently rewrite registry binding. | Kath: actual SDK session-ID/refresh behavior and secure token-storage plan. Mary: exact session pin/reapproval rule. Verify server-side claims and authorization for every protected operation; decoding a JWT alone is not verification. Token possession/session pinning is not proof of one physical phone. |
| E4 / Q07 — offline/logout | Restore/unlock authorized local evidence before network-dependent cloud setup; lack of internet must not prevent truthful local viewing/drafts. Cloud 401/403 blocks protected uploads, not controller operation. Logout stops new upload dispatch and clears cloud session credentials according to the reviewed SDK flow, while retaining encrypted original evidence and locking protected local access. | Kath/Mary: define local owner unlock/background-lock behavior independently of cloud login. Do not delete the evidence key on ordinary logout. No automatic hardware command or Stop. Remote revocation cannot instantly revoke offline vault/command access; record this limitation. |
| E5 / Q07 — in-flight/replacement | On logout/revocation, do not assume an in-flight request was canceled or uncommitted. Preserve its original identity; reconcile under explicitly authorized scope on recovery. Replacement enrollment revokes old cloud scope and grants only reviewed access to historical evidence; never rename its original actor/source identity. | Mary/Kath: exact support/reapproval/historical-grant policy and transaction/concurrency tests. No automatic installation transfer or credential copying. Denial, network failure and unknown commit remain distinct. |

### Choices the assistant cannot fill for the team

- Actual pilot device model/API/ABI and exact supported native packages/build floor.
- Named administrator, authorized inbox and support recipient (no passwords/tokens
  should be posted in replies).
- Provider invitation/OTP settings and verified refresh/session behavior.
- Actual key/backup/recovery implementation and any accepted data-loss policy.
- Source-specific authorization/admission, trusted original manifest, and controller
  retention/time guarantees: these still require Ally/shared inputs.

## Compatibility and acceptance gates — future tests, all NOT RUN here

1. **Native storage:** on the agreed Android target, prove encrypted DB opening,
   wrong/missing-key denial, reviewed unlock behavior, backup/restore exclusion and
   no plaintext token/key/evidence leakage. Verify physical-device results separately
   from emulator/native build success. No security certification inferred.
2. **Durability:** failed write/disk-full/crash before and after draft, seal,
   receipt and uploader-lease commits preserves inputs/identities and truthful state;
   concurrent workers cannot produce duplicate logical result submissions.
3. **Offline startup:** no-internet cold start/restart can unlock retained local
   evidence according to the approved policy; cloud denial never invents Stop.
4. **Auth:** real non-anonymous enrolled scope allowed; anonymous, other, expired,
   revoked and wrong-device/session scopes denied for uploads AND receipt reads.
   Invite/OTP success without approved registry binding grants no data access.
5. **Session lifecycle:** refresh, relogin, expiry, logout during upload, lost reply,
   replacement/uninstall/key-loss preserve original facts; unknown outcomes reconcile
   without minting new actions or dispatching hardware commands.
6. **Bypass/rollback:** test both RPC and legacy direct-table boundaries. No permissive
   direct route may bypass the approved model. Rollback/cleanup must preserve existing
   data and must not silently reopen access; prepare exact affected-object evidence first.

Existing Flutter anonymous startup/direct-table calls and SQL drafts are NOT a
working implementation of these recommendations. Existing hard-disabled registries
must not be enabled to manufacture a positive test. Do not add native packages or
apply SQL before exact scoped implementation/test permission and prerequisites.
The [current Q12 status](../integration/cha-execution/q12-phase-a-status.json)
remains authoritative for the separately gated remote attempt/phases.

## Copy/paste message to Kath

> Thanks, Kath. We can coordinate Q06/Q07 independently while awaiting Ally's
> source packet; decoder/source compatibility stays pending. Please review the
> attached Q06_Q07_Kath_Mary_Decision_Proposal_0.1.md and reply ACCEPT/CHANGE/BLOCKED
> for S1–S4 and E1–E5, identifying this revision/hash. These are recommendations,
> not recorded new personal approvals or implementation consent. Keep your existing
> manual-result 0.2 ACCEPT and our M01–M08 requirements unchanged; no repeat Q05 review.
> Reuse your prior storage/enrollment proposal and answer only the concrete choices:
> native package/device floor; key/unlock/backup/recovery; atomic commits/uploader;
> provider invitation/OTP enrollment; activation/session refresh; offline/logout and
> in-flight/replacement behavior. Please attach existing device/toolchain evidence
> where available, and label missing evidence BLOCKED rather than claiming a pass.
> Administrator/inbox naming and exact backend scope will be coordinated with me;
> no credentials should be shared. No installs, accounts, database changes, deployment
> or physical operations are requested by this review.

```text
Responder / role / date:
Proposal revision: Q06/Q07 0.1
Reviewed SHA-256:
Row: S1 / S2 / S3 / S4 / E1 / E2 / E3 / E4 / E5
Disposition: ACCEPT / CHANGE / BLOCKED
Exact supported choice or replacement:
Evidence: file/build/device/config reference; actual check; limitations
Missing input / owner / next action:
Scope: design only; no implementation/remote/native test permission inferred
```

No delivery to Kath, reply, new member acceptance, test execution or whole-task
completion is claimed by preparing this file. Record actual replies in the existing
ledger; changes to this proposal require a distinguishable revision/hash, not a
silent change to the bytes Kath reviewed.
