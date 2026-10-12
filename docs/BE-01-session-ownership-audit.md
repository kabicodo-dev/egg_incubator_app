# BE-01 — Session Ownership and Database Rules (Audit)

**Status:** ROUND 3 — D1–D5 received; **D4 verified and M1 applied (no-op) 2026-10-12**; SEC-01…SEC-07
tracked as issues #48–#54; stopped for manual review
**Branch:** `cha-branch2` (working tree clean at start; no branch switch, no commit, no push)
**SQL executed against any database:** read-only `pg_indexes` pre-checks + one no-op
`CREATE UNIQUE INDEX IF NOT EXISTS`, **both run by the reviewer** in the Supabase SQL Editor —
this task ran none (§4.4, §4.4a)

---

## 1. Task 1 — Inspection of tables, RLS and anonymous auth

### 1.1 Schema (source: `supabase/migrations/20260929070513_remote_schema.sql`)

| Table | Columns | Ownership column? |
|---|---|---|
| `incubator_sessions` | `id`, `egg_type`, `start_date`, `status` (default `'Active'`), `egg_quantity` (NOT NULL, default 0), `end_date`, `eggs_hatched`, `temperature` | **None** |
| `active_settings` | `id`, `egg_type`, `target_temperature`, `target_humidity`, `incubation_days` | **None** |
| `incubator_presets` | `id`, `egg_type` (NOT NULL), `target_temperature`, `target_humidity`, `incubation_days` | **None** (lookup data) |
| `sensor_readings` | `id`, `current_temperature`, `current_humidity`, `recorded_at` (default `now()`) | **None** — also **no `session_id`**, so a reading cannot be attributed to a batch |

Constraints found in the migration file: **primary keys only** (`:147`, `:152`, `:157`, `:162`).
There is **no `CREATE INDEX`, no `UNIQUE`, no `FOREIGN KEY`** anywhere in `supabase/migrations/`.

### 1.2 The single-active constraint is not in the repository

`incubator_sessions_single_active` is referenced by production behavior but exists **only on the live database**:

| Evidence | Location |
|---|---|
| Error string `duplicate key value violates unique constraint "incubator_sessions_single_active"` | `test/one_active_batch_test.dart:217` |
| `23505` → `ActiveBatchException` mapping (expects the index to settle races) | `lib/services/supabase_service.dart:158-166` |
| Comment "the database unique index settles any tie between devices or tabs" | `lib/main.dart:2716-2719` |
| `git log --all -S 'single_active' --name-only` | **only** `test/one_active_batch_test.dart` (commit `e2c392d`) |
| `git grep 'single_active' HEAD -- supabase` | **no matches** |

**Consequence:** a fresh environment deployed from this repository would be created **without** the
one-active guarantee, while the app assumes it exists. The schema is not reproducible from source.

Second migration file `supabase/migrations/20260929204930_remote_schema.sql` is **0 bytes** (commit `7f578af`).

### 1.3 RLS policy matrix (source: migration `:166-227`)

| Table | RLS | anon | authenticated | DELETE |
|---|---|---|---|---|
| `incubator_sessions` | ENABLED (`:224`) | INSERT `WITH CHECK (true)` (`:178`), SELECT `USING (true)` (`:194`), UPDATE `USING (true)` (`:202`) | ALL `USING/CHECK (true)` (`:166`) | **no policy → denied** |
| `active_settings` | ENABLED (`:218`) | INSERT/SELECT/UPDATE all `true` (`:170`, `:182`, `:198`) | INSERT/SELECT/UPDATE all `true` (`:206`, `:210`, `:214`) | **no policy → denied** |
| `incubator_presets` | ENABLED (`:221`) | **SELECT only** (`:186`) | (inherits SELECT policy) | **no policy → denied** |
| `sensor_readings` | ENABLED (`:227`) | INSERT (`:174`) + SELECT (`:190`) | (inherits) | **no policy → denied** |

Grants: `GRANT ALL ON TABLE … TO anon` on **all four tables** and their sequences (`:404-448`),
plus `GRANT USAGE ON SCHEMA public TO anon` (`:236`). Default privileges grant ALL on future
tables/sequences/functions to `anon` (`:458-481`).

### 1.4 Anonymous auth

- `supabase/config.toml:46` → `enable_anonymous_sign_ins = true`
- `lib/main.dart:26-29` → on every launch, `signInAnonymously()` when no session exists
- `pubspec.yaml` / `lib/` → **no** `signInWithPassword`, `signUp`, `magicLink` or `signOut` anywhere
- `SUPABASE_URL` + `SUPABASE_ANON_KEY` live in `.env`, which **is in `.gitignore` but is still tracked
  and committed at HEAD** (`git ls-files .env` → `.env`; introduced in commit `0d25b17`).

**Risk R1 (High):** no ownership column + `USING (true)` + `GRANT ALL` to `anon` + a committed anon
key means **anyone holding the repository can read and modify every session, every settings row,
and insert arbitrary sensor readings**, across all clients, with no per-user or per-device isolation.

**Risk R2 (Medium):** `incubator_sessions` and `active_settings` expose UPDATE to `anon`, and
`completeSession()` (`lib/services/supabase_service.dart:237-244`) filters only on `eq('id', …)` —
**it never checks `status = 'Active'`**, so any row (including completed history) can be rewritten
by any client. No client-side path does this today; the exposure is at the API level.

**Risk R3 (Low/Positive):** no DELETE policy on any table ⇒ deletes are denied by default for both
`anon` and `authenticated`. The application never calls `.delete()`.

---

## 2. Task 2 — One shared incubator or multiple devices?

**Cannot be answered from the code alone; it is a product decision.** Evidence for both readings:

**Points to ONE shared incubator:**

| Evidence | Location |
|---|---|
| Firmware transports telemetry over **USB serial only** — no network stack; an Arduino Uno cannot reach Supabase | `arduino/SmartHatch_Uno/SmartHatch_Uno.ino:1-23` |
| One PC runs the app, picks a COM port, connects | `README.md:79-88` |
| No `device_id` / `machine_id` / MAC / serial identifier exists in schema **or** code (`grep device_id\|machine_id\|hardware_id\|mac_address` → only `.vscode/launch.json` "chrome") | repo-wide |
| No user accounts — anonymous sign-in only, identity never used as a data key | `lib/main.dart:26-29` |
| History/`getSessions()` returns every row unfiltered, i.e. the design assumes one shared history | `lib/services/supabase_service.dart:191-197`, `lib/main.dart:983, 4008` |

**Points to MULTIPLE devices sharing one Supabase project:**

| Evidence | Location |
|---|---|
| "another device **or tab** won the race" | `lib/services/supabase_service.dart:160` |
| "settles any tie between **devices or tabs**" | `lib/main.dart:2719` |
| "a lost race between **devices or tabs**" | `test/one_active_batch_test.dart:6` |
| `_lostRaceMessage()` wording "another screen" | `lib/services/supabase_service.dart:187` |

**Conclusion:** the *hardware deployment* is one incubator per PC, but the *data model* is a single
global namespace with **no capability to distinguish devices**. If two app installs ever point at
this project, they will: block each other's batches (global one-active index), overwrite each
other's `active_settings` singleton, mix histories, and cannot tell whose sensor readings are whose.

**⇒ Decision required (acceptance criterion):** *Can two app installs/tabs/PCs use this Supabase
project concurrently?* Answer is **A** or **B** below.
*(Resolved 2026-10-12 by D1/D3: **yes**, several installations may share the project as peers and
must all see the same active batch — model **A/M1** applies; see the review in §3.4.)*

---

## 3. Task 3 — Session ownership, access isolation, single-active constraint

### 3.1 Who owns each session today?

**Nobody.** There is no `user_id`, `device_id`, `owner_id`, no `auth.uid()` predicate in any policy
(`grep auth\.uid|user_id|userId` → **no matches** in `lib/` or migrations). Ownership is implicitly
*"whoever has the anon key"* = the whole deployment. Each app install gets its own anonymous auth
user, and that identity is **never referenced by any row**.

### 3.2 What does "one active batch" mean today?

**Exactly one `status = 'Active'` row in the entire table — global across every user, device and tab.**

Three enforcement layers (all verified by reading code; layer 2 verified only by test fixture):

| Layer | Where | Scope |
|---|---|---|
| 1. UI guards | Start button disabled while in flight (`lib/main.dart:2704-2707`); setup screen blocked while a batch runs (`lib/main.dart:1724-1768`) | single app instance |
| 2. Service pre-check | `createSession()` → `getActiveSession()` before any write (`lib/services/supabase_service.dart:136-142`) | global (any row, any species) |
| 3. Database unique index | `incubator_sessions_single_active`, partial on `status` where `status = 'Active'`; `23505` mapped to `ActiveBatchException` (`supabase_service.dart:158-166`) | **global — and only on the live DB** |

Note: layer 3's definition was **confirmed against the live database** on 2026-10-12 via a
read-only `pg_indexes` query in the Supabase SQL Editor (output in §4.4):
`CREATE UNIQUE INDEX incubator_sessions_single_active ON public.incubator_sessions USING btree
(status) WHERE (status = 'Active'::text)` — **partial**, so unlimited `Completed` history rows
are unaffected. It was first *inferred* from the test's error text
(`Key (status)=(Active) already exists.`, `test/one_active_batch_test.dart:218`) plus the fact
that many `Completed` rows coexist.

### 3.3 Related isolation gaps

| # | Gap | Impact if multi-device is ever confirmed |
|---|---|---|
| G1 | Global one-active index | Device B cannot start a batch while device A's batch runs |
| G2 | `active_settings` read-modify-write on `limit(1)` with no scope (`supabase_service.dart:72-95`) | Devices silently overwrite each other's hardware setpoints |
| G3 | `sensor_readings` has no `session_id`/device column | Readings cannot be attributed to a batch or machine |
| G4 | `getSessions()` / History show all rows to every client | Cross-device history leakage |
| G5 | UPDATE `USING (true)` + `completeSession` filters by `id` only | Any client can rewrite any batch, including completed ones |
| G6 | Index missing from migrations (§1.2) | Fresh deploy silently loses the one-active guarantee |

### 3.4 D3 addendum — authorization and simultaneous hardware commands

Decision **D3** permits multiple installations on one project, all referring to
the *same* active incubation. Reviewed:

**Authorization model today**

* All Supabase I/O goes through `lib/services/supabase_service.dart` — 13
  `.from()` calls, **no** `.rpc()`, **no** `functions.invoke()`, **no** realtime
  channels (verified by grep across `lib/`).
* Every installation receives its own anonymous identity (`lib/main.dart:26-29`),
  but no policy ever reads it ⇒ installations are undifferentiated peers with
  `GRANT ALL`. Authorization effectively = possession of the committed anon key
  (see SEC-02 / SEC-03 in `docs/SECURITY-TASKS.md`).
* What actually holds the installations in agreement for D3:
  (a) reads are global, so they **do** all see the same active batch; (b) the
  global unique index means only **one** of them can create it.
  What is **not** enforced: nothing server-side stops any installation from
  *completing or editing* the shared batch (G5).

**Simultaneous hardware commands — three layers**

| Layer | Path | Concurrent-install behaviour | Verdict |
|---|---|---|---|
| Actuator / relay commands | `main.dart:7467-7483` → `ArduinoController.setActuator` → USB serial JSON → Uno | Only the installation physically holding the USB cable can send; others get "Connect the Arduino first." (`main.dart:7468-7473`). The firmware has no network stack at all. | **Safe** — physical single-writer; cross-install hardware conflict is structurally impossible |
| Setpoints (`active_settings`) | `supabase_service.dart:66-96` read-modify-write, last-writer-wins | Two installations updating → both write the same row (pinned by new test). Two installations writing for the **first** time concurrently → **both may INSERT**: the table has **no unique constraint** (G2), then `limit(1)` picks nondeterministically | **Latent** — nothing reads this table back today (`updateActiveSettings` is called once, `main.dart:2730`; no reader exists in `lib/`), so damage starts only when a reader is added → SEC-04 |
| Batch lifecycle (`incubator_sessions`) | service pre-check + global unique index | Racing starts → one wins, the loser gets `23505` → friendly refusal (existing test). Racing finishes → both succeed, last write wins (G5: no status guard) | **Acceptable** for the prototype; G5 stays open under SEC-04 |

Additional notes: installations do **not** live-sync (no realtime subscription),
so a second installation observes the shared batch only on its next read or
navigation; and `IncubatorController.toSyncPayload()`
(`incubator_controller.dart:512-536`) is **never called** — dead code that
writes nothing to Supabase.

---

## 4. Task 4 — Proposed migration and rollback (PROPOSAL ONLY — NOT RUN)

### 4.1 Decision gate — RESOLVED (D1, D2, D4)

| Decision | Outcome |
|---|---|
| **D1** | **M1 (global)** for the current prototype: one physical incubator ⇒ one active batch across the whole project, any species, which must be finished before another starts. M2 (per machine) deferred until multiple incubators are supported. |
| **D2** | The physical incubator owns the session **conceptually**; **no** machine-ownership column is added now, and the existing global model stands. |
| **D4** | **Conditional approval:** inspect the live index first; if the safeguard already exists, do not duplicate it; the migration may be prepared in `supabase/migrations/` but its SQL and effects must be shown before anything runs against the database; no session data may be deleted or modified. |

M1 satisfies all four constraints: `CREATE UNIQUE INDEX IF NOT EXISTS` cannot
duplicate an existing safeguard, and the statement touches **zero rows**.

| If the team answers… | Then… |
|---|---|
| **A — one shared incubator, one app install** (or: isolation not needed yet) | Apply **M1** only. It changes no data, no behavior, no RLS — it makes the repo reproduce what production already enforces. G2–G5 remain acceptable and are documented as accepted risk. |
| **B — multiple devices/installations on one project** | **Do not apply M1 in isolation.** M2 (draft in §4.3) must be decided first, because M2 *replaces* the index M1 would create. Schema + RLS + client changes are required together. |

**M1 is the only migration proposed as necessary now.** Nothing else (no RLS change, no column
addition, no data change) is proposed without an explicit team decision.

### 4.2 M1 — capture the existing single-active index in the repo (necessary)

Prepared file: `supabase/migrations/20261012090000_incubator_sessions_single_active.sql`
Idempotent: a **no-op** where the index already exists. **Zero rows are modified.**
**Status: written to the repository but NOT executed — awaiting D4 approval.**

```sql
-- PRE-CHECKS (read-only) — run these FIRST and paste the output into the PR.
-- 1) What indexes actually exist on the live database today?
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'incubator_sessions'
ORDER BY indexname;

-- 2) STOP if more than one Active row exists: the unique index cannot be
--    created until duplicates are resolved by a human (no automatic merge -
--    hatch results are farmer-entered and must never be invented).
SELECT id, egg_type, status, start_date, end_date, eggs_hatched
FROM public.incubator_sessions
WHERE status = 'Active'
ORDER BY id;

-- FORWARD (M1)
CREATE UNIQUE INDEX IF NOT EXISTS incubator_sessions_single_active
    ON public.incubator_sessions (status)
    WHERE (status = 'Active');

-- VERIFY
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname = 'incubator_sessions_single_active';
```

**Rollback (M1):**

```sql
-- Restores the pre-audit state (no DB-level one-active guarantee).
-- App layer 1 (UI guards) and layer 2 (service pre-check) keep working;
-- concurrent inserts from two clients would NO LONGER be settled by the
-- database, so layer 3's 23505 handling in
-- lib/services/supabase_service.dart:158-166 becomes unreachable.
DROP INDEX IF EXISTS public.incubator_sessions_single_active;
```

**Explicitly NOT included in M1** (requires separate approval, out of BE-01 scope as written):
RLS tightening, `user_id`/`device_id` columns, `DELETE` policies, removing the tracked `.env`.

### 4.4 D4 — verification result (2026-10-12): SAFEGUARD CONFIRMED ✅

Local inspection was blocked (no running Docker daemon, no Supabase CLI login
token, no `psql`), so **D4 Option 3** was used: the reviewer ran the read-only
`pg_indexes` queries in the Supabase SQL Editor. Verbatim output:

```
tablename,indexname,indexdef
active_settings,active_settings_pkey,CREATE UNIQUE INDEX active_settings_pkey ON public.active_settings USING btree (id)
incubator_presets,incubator_presets_pkey,CREATE UNIQUE INDEX incubator_presets_pkey ON public.incubator_presets USING btree (id)
incubator_sessions,incubator_sessions_pkey,CREATE UNIQUE INDEX incubator_sessions_pkey ON public.incubator_sessions USING btree (id)
incubator_sessions,incubator_sessions_single_active,CREATE UNIQUE INDEX incubator_sessions_single_active ON public.incubator_sessions USING btree (status) WHERE (status = 'Active'::text)
sensor_readings,sensor_readings_pkey,CREATE UNIQUE INDEX sensor_readings_pkey ON public.sensor_readings USING btree (id)
```

| Finding | Verdict |
|---|---|
| `incubator_sessions_single_active` exists on the live database | ✅ **PASS** — the safeguard D1 relies on is real |
| Definition is **partial**: `USING btree (status) WHERE (status = 'Active'::text)` | ✅ **PASS** — exactly what M1 would create; `Completed` history is unaffected |
| M1's `CREATE UNIQUE INDEX IF NOT EXISTS …` against this database | ✅ **no-op** — zero rows touched |
| No further indexes on `incubator_sessions` beyond the PK | ✅ consistent with §1.1 |
| `active_settings` has **only** its primary key — no singleton constraint | ⚠️ **confirms gap G2 live** → SEC-04 ([#51](https://github.com/kabicodo-dev/egg_incubator_app/issues/51)) |
| `incubator_presets`, `sensor_readings`: PK only | ✅ as documented in §1.1 |

**⇒ D4 satisfied: the existing safeguard already meets M1's requirement, so
nothing is duplicated or conflicted.** M1 changes nothing on the live database;
its only remaining value is **source-control reproducibility** — today a fresh
deploy built from this repo would silently lose the one-active rule (G6).

### 4.4a M1 applied and verified (2026-10-12)

Approved by the reviewer after §4.4 and executed in the Supabase SQL Editor:

```sql
CREATE UNIQUE INDEX IF NOT EXISTS incubator_sessions_single_active
    ON public.incubator_sessions (status)
    WHERE (status = 'Active');
```

| | |
|---|---|
| Statement result | **`Success. No rows returned`** (no-op — the index already existed, so nothing was created or modified) |
| Verification query | `incubator_sessions_single_active,CREATE UNIQUE INDEX incubator_sessions_single_active ON public.incubator_sessions USING btree (status) WHERE (status = 'Active'::text)` |
| Rows inserted / updated / deleted | **0** |
| RLS, grants, columns, app code | unchanged |
| Effect | G6 closed: the one-active rule now exists **both** on the live database **and** in `supabase/migrations/`, so fresh deploys reproduce it |

Not yet returned: **Q3** (the `status = 'Active'` row count). It is no longer a
blocker — with the index present, `IF NOT EXISTS` skips the build entirely — but
it is worth capturing for the record (is a batch running right now?).

**⚠ Deployment note:** the file sits in `supabase/migrations/`, so any
future `supabase db push` or `supabase db reset` will apply it (as a no-op on
this database). Reviewer sign-off on M1 should still be recorded before those
commands are used.

**Not executed:** no `supabase db push`, no `db reset`, no SQL of any kind has
been run against the project by this task. No session data was written,
updated or deleted; the only statements run were the reviewer's read-only
`SELECT`s above.

### 4.3 M2 — DRAFT ONLY, do not apply (conditional on decision B)

Sketched for discussion; **not approved, not written to `supabase/migrations/`.**

```sql
-- Requires decisions that must not be invented by the implementer:
--   * sentinel value for pre-existing rows' device_id (backfill)
--   * how a device learns/holds its device_id
--   * whether RLS keys off auth.uid() (per install) or device_id (per machine)
ALTER TABLE public.incubator_sessions ADD COLUMN IF NOT EXISTS device_id text;

DROP INDEX IF EXISTS public.incubator_sessions_single_active;

CREATE UNIQUE INDEX IF NOT EXISTS incubator_sessions_single_active_per_device
    ON public.incubator_sessions (device_id, status)
    WHERE (status = 'Active');
-- Rollback: DROP INDEX …_per_device; recreate M1 index; ALTER TABLE DROP COLUMN device_id;
```

---

## 5. Verification results

| Check | Command / method | Result |
|---|---|---|
| Static analysis | `flutter analyze` | **PASS** — "No issues found" |
| Full test suite (baseline, before changes) | `flutter test` | **PASS** — 153/153 |
| Full test suite (after adding BE-01 characterization tests) | `flutter test` | **PASS** — 160/160 (153 baseline + 7 new) |
| Ownership semantics pinned by tests | `test/session_ownership_audit_test.dart` | **PASS** — 7/7 |
| Live index definition / actual `pg_indexes` output | read-only SQL run by the reviewer in the Supabase SQL Editor (D4 Option 3), 2026-10-12 — verbatim output in §4.4 | **PASS** — index exists and is partial: `USING btree (status) WHERE (status = 'Active'::text)`; exactly what M1 would create. (Earlier local attempts — `supabase db dump --linked`, `supabase inspect db index-stats --linked`, `psql` — were blocked: no Docker daemon, no CLI login token, no psql.) |
| `active_settings` singleton constraint (gap G2) | same `pg_indexes` output | **CONFIRMED ABSENT** — PK only → SEC-04 [#51](https://github.com/kabicodo-dev/egg_incubator_app/issues/51) |
| Real RLS enforcement (does `anon` really read/write all rows?) | — | **NOT TESTED** — requires live DB |
| `23505` raised by the real database | — | **NOT TESTED** against live DB; covered only by the fake-API test `test/one_active_batch_test.dart:201` |
| Multi-install behaviour under D3 (two installs, one project) | — | **NOT TESTED** — only one installation exists; concurrency semantics covered only by the fake-API tests in §5.1 |
| Fresh-environment deploy reproduces schema | migration file `supabase/migrations/20261012090000_incubator_sessions_single_active.sql` + successful apply | **PASS (static)** — index DDL is now in source *and* live; a full clean-environment deploy drill was not performed (**NOT TESTED**) |
| Migration applied to the project | executed by the reviewer in the Supabase SQL Editor, 2026-10-12 (§4.4a) | **PASS — NO-OP** — `Success. No rows returned`; verification query returned the partial index definition |

### 5.1 BE-01 characterization tests added

`test/session_ownership_audit_test.dart` pins today's semantics so any future ownership change
must be a conscious, test-visible decision:

1. `getActiveSession()` is scoped **only** by `status=eq.Active` — no owner/device filter.
2. `createSession()` sends **no** `user_id` / `device_id` / `owner_id` in the insert payload.
3. `getSessions()` (History) is unscoped and returns rows from every origin.
4. `updateActiveSettings()` probes a single global row (`limit=1`), unscoped.
5. `completeSession()` filters by `id` only — pins known gap **G5** (no `status = 'Active'` guard).
6. A second installation overwrites the **same** settings row (last writer wins) — pins D3 shared state.
7. Two concurrent first-writes both INSERT — pins known gap **G2** (no singleton constraint on `active_settings`).

These assert *current behavior*, not *desired* behavior; they will fail by design once M2 lands,
and #5/#7 are expected to be updated when SEC-04 closes those gaps.

---

## 6. Decisions received (D1–D5) — 2026-10-12

| # | Decision | Consequence |
|---|---|---|
| **D1** | **M1 — global**, for the current prototype: one physical incubator, so exactly one active batch across the entire project; any species; the farmer must finish it before starting another. M2 reconsidered only if multiple incubators are supported later. | M1 migration prepared (§4.2); M2 remains draft-only (§4.3) |
| **D2** | The **physical incubator** owns the session conceptually — a session is the incubation running in the machine, not a browser or anonymous install. No machine ownership added yet. | No schema change; documented in §3.1 |
| **D3** | **Yes**, multiple installations may access the project, but they must all refer to the *same* active incubation and must not create separate active batches. Review authorization and simultaneous hardware commands. | Review delivered as §3.4; findings routed to SEC-04 (`docs/SECURITY-TASKS.md`) |
| **D4** | **Conditional approval of M1**: inspect the live index first; if the safeguard exists, do not duplicate it; prepare the file in `supabase/migrations/`; show SQL + effects before running; never delete or modify session data without approval. | File prepared, **not run**; inspection attempted and blocked (§4.4); SQL + effects shown in §4.2 and in the migration header |
| **D5** | **Yes** — create separate security tasks for RLS review and `.env` untracking; address any exposed keys immediately; coordinate with the team. | `docs/SECURITY-TASKS.md` created, tracked as issues [#48](https://github.com/kabicodo-dev/egg_incubator_app/issues/48)–[#54](https://github.com/kabicodo-dev/egg_incubator_app/issues/54) (SEC-01/02/03 flagged URGENT). **No security change has been made.** |

### Still open

| Item | Waiting on |
|---|---|
| ~~D4 — execution of M1~~ | ✅ **DONE 2026-10-12** — applied by the reviewer, no-op, verified (§4.4a) |
| **D5 — implementation of SEC-01…SEC-07** | Issues [#48](https://github.com/kabicodo-dev/egg_incubator_app/issues/48)–[#54](https://github.com/kabicodo-dev/egg_incubator_app/issues/54) created; awaiting team assignment and review. **No fix implemented** |
| Q3 (count of `status = 'Active'` rows) | optional / outstanding — no longer a blocker |

---

**STOPPED FOR MANUAL REVIEW.** This task ran **no SQL** and changed no schema, RLS, grant, auth,
environment or application code. The reviewer ran the read-only pre-checks (§4.4) and the approved
M1 no-op (§4.4a). Untracked additions awaiting commit approval: `docs/` (this audit +
`SECURITY-TASKS.md`), `supabase/migrations/20261012090000_incubator_sessions_single_active.sql`
(applied to the DB, not yet committed), `test/session_ownership_audit_test.dart`. Issues #48–#54
created for assignment — no fix implemented.
