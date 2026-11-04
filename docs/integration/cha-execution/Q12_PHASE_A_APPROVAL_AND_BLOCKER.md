# Q12 phase A — approved, blocked before remote execution

**Date:** 2026-10-31. **Owner:** Cha/Mary.

## Actual authorization

Mary stated:

> I am authorized for smarthatch-test. I approve Q12 phase A read-only inspection only for zbwntspdecngnicllwlw, using the prepared SQL, with sanitized local evidence and rollback. No mutations, deployments, production access or later phases are approved.

This authorizes phase A only; do not ask Mary to repeat it. No account/role
creation, fixture write, schema/RLS/grant/RPC change or later phase is authorized.

Approved SQL remains byte-unchanged, including its historical candidate header:
`Q12_Phase_A_Read_Only.sql` SHA-256
`9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc`.
Prepared plan SHA-256 at approval:
`7de0a687f51168e2f0f1928ec7d44a75b8b070afcce7c64de7ffb18128f27e37`.

## Preflight findings and stop

- Available local CLI help reports Supabase CLI 2.118.0; `psql` is not on PATH.
  Only local command discovery/help was run, not `db query`, login or project list.
- Inspected the published matching-version CLI query handler:
  `https://raw.githubusercontent.com/supabase/cli/v2.118.0/apps/cli/src/commands/db/query/query.handler.ts`.
  Its linked preflight calls the database connection resolver before the Management
  API query. The source explicitly describes a potential temporary login-role mint.
  The previous real probe also recorded an `Initialising login role` warning.
  Published source is a compatibility finding, not proof of installed binary
  behavior; that uncertainty is itself sufficient not to attempt this route.
- The CLI result path also does not establish that all intermediate results and
  final ROLLBACK/idle state from this multi-statement SQL can be independently
  captured as required. No substitute query or API request was attempted.
- Checked only presence booleans for existing direct-connection environment
  variables: SUPABASE_DB_URL, DATABASE_URL, PGHOST, PGUSER, PGPASSWORD, PGSERVICE,
  PGSERVICEFILE, SUPABASE_DB_PASSWORD: all absent. No values read into evidence.
  No existing approved-temp `pg` Node package found. No dependency installed.
- No credentials sought in files, no new login, no secret requested, no linked
  project changed, and no remote target was connected/verified in this step.

**Result: APPROVED / BLOCKED BEFORE REMOTE EXECUTION.** Catalog SQL NOT RUN.
No database transaction opened, therefore rollback is **not applicable**, not a
verified remote rollback. No account/fixture/object created; no cleanup attempted.
No production or test-project SQL, Auth, REST or management request was made.
Public GitHub source reads are not Supabase project access.

## Safe next prerequisite

Use an already-authorized secure direct connection/session to the exact test
project, with no role/account provisioning and with single-session result and
rollback visibility. If none exists, the authorized project owner must arrange
that access through their normal secure mechanism; do not paste secrets in chat.
Then verify its target, exact SQL hash, per-query bounds, transaction exit and
connection closure before reporting phase A results. A different execution method
must be checked against the existing approval; it cannot silently broaden scope.

Do not fall back to the CLI's temporary-role setup or ask for blanket mutation
permission merely to work around this blocker. Existing phase A consent stands;
Q12 overall and all later phases remain gated. No whole-task status/count changes.
