# Security Tasks (spawned by BE-01 decision D5)

**Created:** 2026-10-12 · **Source:** `docs/BE-01-session-ownership-audit.md`
**Status: TASK LIST ONLY — no security change has been made.** Every item below
requires team coordination and reviewer approval before any code, policy or
Git change is applied.

## Tracked as GitHub issues (created 2026-10-12)

| Task | Issue | Priority | Suggested owner |
|---|---|---|---|
| SEC-01 — Tighten RLS policies | [#48](https://github.com/kabicodo-dev/egg_incubator_app/issues/48) | 🔴 URGENT | Backend + team (matrix decision) |
| SEC-02 — Untrack `.env` from Git | [#49](https://github.com/kabicodo-dev/egg_incubator_app/issues/49) | 🔴 URGENT | Backend (commit needs approval) |
| SEC-03 — Key exposure & rotation | [#50](https://github.com/kabicodo-dev/egg_incubator_app/issues/50) | 🔴 URGENT | Team decision, Backend executes |
| SEC-04 — Unguarded UPDATE paths (G5/G2) | [#51](https://github.com/kabicodo-dev/egg_incubator_app/issues/51) | 🟠 HIGH | Backend |
| SEC-05 — `sensor_readings` writer policy | [#52](https://github.com/kabicodo-dev/egg_incubator_app/issues/52) | 🟡 MEDIUM | Backend |
| SEC-06 — No-DELETE posture confirmation | [#53](https://github.com/kabicodo-dev/egg_incubator_app/issues/53) | 🟢 LOW | Team / reviewer |
| SEC-07 — Single-active index in migrations | [#54](https://github.com/kabicodo-dev/egg_incubator_app/issues/54) | 🟡 MEDIUM (blocked on D4) | Backend + reviewer approval |

This document stays the reference copy: the issue bodies summarise it, and any
decision recorded here should be reflected in the issues (and vice versa).

---

## Context

The audit found that data protection currently rests on a single control: the
anon key. Everything else is open:

| Fact | Evidence |
|---|---|
| No ownership column on any table; no `auth.uid()` in any policy | `supabase/migrations/20260929070513_remote_schema.sql` |
| RLS `USING (true)` / `WITH CHECK (true)` for `anon` on sessions + settings | same file, `:166-214` |
| `GRANT ALL ON TABLE … TO anon` on all four tables and sequences | `:404-448` |
| `.env` (anon key) is **tracked and committed** despite being in `.gitignore` | `git ls-files .env` → `.env`; commit `0d25b17` |
| Anonymous sign-in only; every installation is an equal peer | `lib/main.dart:26-29`, `supabase/config.toml:46` |

**Important nuance for prioritisation:** a Supabase *anon* key is designed to be
shipped in client apps and is therefore not a secret by itself. It becomes
critical **because** RLS and grants are wide open — the key alone grants
full read/write on every row. The fix order below is therefore *RLS first,
rotation second*.

---

## SEC-01 — Tighten RLS policies (HIGH · Backend + team decision)

**Evidence:** `supabase/migrations/20260929070513_remote_schema.sql:166-227`.
**Task:** Re-decide each policy against the approved model (D1/D2/D3: one
physical incubator, sessions owned by the machine conceptually, multiple
installations as peers).

Minimum questions to answer per table: who may INSERT, who may SELECT, who may
UPDATE, who may DELETE.

**Acceptance criteria:** a written policy matrix approved by the team, then a
migration applying it; existing app flows (start batch, finish batch, settings
write, presets read) still work against it.

**Note:** any tightening must keep the app working — the client only ever
sends the anon/authenticated JWT (`lib/main.dart:26-29`).

---

## SEC-02 — Untrack `.env` from Git (HIGH · Backend, coordinate before committing)

**Evidence:** `git ls-files .env` shows `.env` tracked; `.gitignore` contains
`.env` (ignored-but-tracked, introduced in `0d25b17`).
**Task:** `git rm --cached .env`, confirm `.gitignore` still covers it, keep
the local file, commit only after reviewer approval.

**Acceptance criteria:** `git ls-files .env` returns nothing; local `.env`
still present so the app runs; `.env.example` (keys redacted) added if the team
wants an onboarding template.

**Blocked on:** approval to stage/commit (BE-01 standing rule: no staging or
committing without approval).

---

## SEC-03 — Assess key exposure and decide on rotation (HIGH · team decision)

**Evidence:** commit `0d25b17` is in the shared history, so the anon key
`SUPABASE_ANON_KEY` is readable by anyone with repository access (and by
anyone who ever cloned or forked it).
**Task:** decide whether the repository is private and who has had access;
after SEC-01 lands, decide whether to **reset the anon key** in the Supabase
dashboard (Settings → API).

**Order matters:** rotating before tightening RLS achieves nothing (the new
key is equally open); rotating after SEC-01 invalidates every old client build.

**Acceptance criteria:** written decision — rotate or accept — with the reason.

---

## SEC-04 — Close the unguarded UPDATE paths (MEDIUM · Backend)

**Evidence / gaps:**
- `incubator_sessions` and `active_settings` allow `UPDATE` to `anon` (`:202`,
  `:198`).
- `completeSession()` filters by `id` only — no `status = 'Active'` guard
  (`lib/services/supabase_service.dart:237-244`). Gap **G5** in the audit;
  pinned by `test/session_ownership_audit_test.dart`.
- `active_settings` has **no unique constraint**, so two installations writing
  it concurrently can create two rows (audit gap **G2**).

**Acceptance criteria:** status guard added (SQL or service-level), singleton
constraint decision recorded, characterization tests updated deliberately.

---

## SEC-05 — Decide who may write `sensor_readings` (MEDIUM · Backend)

**Evidence:** `Anyone can insert sensor readings … WITH CHECK (true)`
(`:174`) and no writer exists anywhere in the app.
**Task:** define the intended writer (the USB-connected installation, an edge
function, or the device), then narrow the INSERT policy to that path so
arbitrary clients cannot feed fake telemetry.

**Acceptance criteria:** policy matches the decided writer; a fake-reading
insert from an unintended client is rejected.

---

## SEC-06 — Confirm the no-DELETE posture (LOW · team confirmation)

**Evidence:** no `DELETE` policy on any table ⇒ default deny for `anon` and
`authenticated`; the app never calls `.delete()`.
**Task:** confirm this is intended (recommended: keep it) and document it, or
define a governed deletion path for old sessions.

**Acceptance criteria:** one-line decision recorded in the audit doc.

---

## SEC-07 — Reproducible schema check (MEDIUM · Backend, depends on D4)

Not a security bug, but a deployment-integrity control: the single-active index
exists only on the live database. Track under BE-01 migration
`20261012090000_incubator_sessions_single_active.sql` (prepared, **not
applied**, awaiting D4 approval).

---

## Execution order

```
SEC-02 (untrack .env)  ─┐
SEC-01 (RLS matrix)    ─┼─► SEC-03 (rotate or accept) ─► SEC-04 / SEC-05 / SEC-06
                        │
SEC-07 (index capture, pending D4)
```

No task above has been started. All changes are blocked on team coordination
and reviewer approval, per D5.
