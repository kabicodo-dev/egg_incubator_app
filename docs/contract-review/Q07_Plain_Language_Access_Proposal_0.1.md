# SmartHatch access rules — plain-language proposal

**Revision:** 0.1 · **Prepared:** 2026-11-02 · **Prepared by:** Cha, backend review.
**Status:** FOR DISCUSSION ONLY — not a new personal approval or permission to build.

Mary's “ok lets do your recommendation” authorizes preparing this explanation.
It does not approve the new choices below or authorize accounts, app/database
changes, installations, remote checks, deployment or controller operations.

## The simple plan I recommend

### 1. Only an invited person uses the pilot app's protected cloud records

Keep the existing one-authorized-phone scope. I recommend that a named project
administrator invites the intended user instead of allowing public sign-up.
Signing in alone must not give access: the administrator must also approve which
phone installation and incubator records that user may access.

**Still needed:** choose the administrator and support contact privately. The
exact invitation/login method must be checked before anyone promises it works.
Do not share passwords, login codes or keys in project documents.

### 2. Being offline must not stop incubation

I recommend allowing the previously authorized owner to unlock records already
saved on the phone and prepare drafts without internet. Uploading waits until
internet and valid cloud permission return. Missing batch evidence remains clearly
marked as needing validation; a draft is not an accepted cloud result.

The Arduino continues its own operation. Cloud login failure does not mean the
incubator stopped. These app access rules do not authorize Bluetooth commands.

### 3. Logging out locks access; it does not erase saved evidence

I recommend stopping new uploads first, locking protected local records and
clearing cloud login credentials using the reviewed login system. Keep the
encrypted incubation evidence and its separate protection key. Closing or
backgrounding the app should require the agreed phone-owner unlock before
protected records are opened again; exact phone behavior still needs review.

An upload already sent might still finish. Do not show “canceled” or “not saved”
without evidence. Check its original identity later under authorized access;
never create a second result just because the answer was lost.

### 4. A replacement phone needs explicit approval

I recommend removing the old installation's cloud permission before approving
the replacement. No automatic account/installation transfer or copied credentials.
For this initial slice, give the approved replacement only explicitly scoped
read/reconciliation access to existing cloud evidence. Recovering or uploading
old locally saved actions requires a separate reviewed recovery grant; knowing
the old IDs is not permission to upload or change them.

Already-recorded species, original counts, original actor and result identities
must not be rewritten. Removing cloud permission cannot instantly lock an offline
old phone or stop a request already in flight; those limitations need truthful handling.

### 5. Do not promise recovery of records that existed only on a lost phone

Existing cloud records may be available again after authorized recovery. Records
that never uploaded may be unrecoverable if the phone or its encryption key is
lost. Do not invent missing records or automatically wipe/recreate damaged storage.
I recommend leaving export/import recovery outside this first slice until its
security and accepted loss limits are separately agreed.

### 6. Leave the occupied incubator out of this work

The existing batch is running on Arduino programmed by Ally; the app is disconnected.
Do not connect, reset, reflash, attach modules or send Start/Stop/settings commands
to test these rules. Existing-batch reconciliation remains proposed: it grants no
automatic registration, duplicate session or new Start. Preserve operator reports
separately from controller-confirmed evidence; RTC/Bluetooth testing remains pending.

## What is already settled, and what is not

- **Unchanged:** Mary's M01–M08 and manual-result 0.2 scoped ACCEPT. Do not ask for
  those approvals again. A result alone does not complete/Stop the batch or release Active.
- **Known intended phone:** Infinix Smart 8. Recover the previously supplied device
  details instead of asking Kath to choose a phone again. Compatibility is unverified.
- **Proposed here:** exact invitation, logout/recovery and replacement restrictions
  explained above. They are recommendations, not recorded Mary/Kath decisions.
- **Still blocked:** phone/native storage/unlock/backup compatibility; exact provider
  invitation/expiry/replay/rate-limit/callback behavior; SDK session behavior;
  administrator identity, session/reapproval policy and historical recovery grants.
- No new expiry duration, package pin, Android support floor or production setting
  is selected. No implementation or device tests were run for this proposal.

## Technical handoff — keep this separate from the simple explanation

Sources:

- [Existing Q06/Q07 discussion proposal 0.1, 2026-11-01](Q06_Q07_Kath_Mary_Decision_Proposal_0.1.md),
  S2–S4/E1–E5; raw reviewed hash
  `205f2537026a28a513e387d17f390ba49828db24e92fbec6ff77ad771d95f213`.
- Received `SEND_TO_MARY_Q06_Q07_RESPONSE.md`, **response revision 3, 2026-11-02**;
  raw SHA-256 `7b5c0bb8ca8b0ad3e4cbc900b3ef567f7ca27eab32a2675ae5d52b717c3be41e`.
  Assistant-prepared recommendations, not new personal approvals. Original remains
  in the supplied Downloads location; it has not been rewritten or imported as a vote.
- [Mary's M01–M08](D04_D06_Mary_Backend_Position.md) and
  [Kath's exact 0.2 ACCEPT receipt](../integration/cha-execution/KATH_02_DELTA_ACCEPT_RECEIPT.md).

Future implementation requirements, not instructions to execute now:

- Non-anonymous trusted Auth plus current per-operation installation/controller/
  session authorization for uploads AND receipt/reconciliation reads. Invitation
  must not self-create users through an unintended OTP path or self-grant registry scope.
- Recommend continuing upload after token refresh only for the same verified,
  approved subject/session and still-valid scope. An unusable credential pauses
  protected requests. A new subject/session needs reviewed reapproval, never silent
  registry rebinding; provider/SDK behavior must first be verified.
- Atomic, auditable old-scope revocation/new-scope activation; original identities
  unchanged. Transaction authorization recheck for future writes; an in-flight
  request may already have committed. Define and test those races before rollout.
- Fence old worker generations and late callbacks on logout/owner change. Preserve
  unknown outcomes and reconcile original IDs under an explicit authorized grant.
- Server idempotency and one logical initial result per original controller/batch
  across actors; local worker exclusion alone cannot prevent all repeated HTTP attempts.
- Preserve exact `api_version: 2` plus `DB02-MANUAL-RESULT-0.2-review`, M08 identity
  reuse, immutable receipt continuity, trusted manifest/count validation and unchanged
  Active/end_date/admission/release. No automatic old-version outbox conversion.

Actual answers belong in the [existing decision ledger](CONTRACT-FREEZE-01_Team_Decisions.md)
only after explicitly received. This preparation does not update that ledger,
supersede historical evidence or claim a newly adopted access policy.
