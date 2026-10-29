-- DRAFT — NOT APPROVED — DO NOT APPLY
-- CURRENT:DB-IMP-01 / Mary Charlyn / 2026-10-30
-- Revision 2: F1-F8 correction pass (ownership/RLS, audit model, expiry split,
--             NULL-safe identity, denial policy). Still design-only.
--
-- Additive draft only. Requires DB-IMP-01_disabled_registry.sql to be reviewed
-- and applied first in an isolated, explicitly authorized database.
--
-- This file DOES NOT remove the existing fail-closed protections:
--   private.authorized_installations.active = false
--   private.controllers.active = false
--   private.controllers.contract_enabled = false
--
-- A separate reviewed enablement migration is required before authorization can
-- succeed. Until then authorization must deny and ingestion must stay disabled.
--
-- No SQL in this file has been executed, parsed or applied. No production or
-- main-project use. No client credentials are created here.

begin;

do $$
begin
  if to_regclass('private.controllers') is null
     or to_regclass('private.authorized_installations') is null then
    raise exception 'DB-IMP-01 base disabled registry draft must be applied first';
  end if;
end
$$;

-- ---------------------------------------------------------------------------
-- 0. Dedicated least-privilege function owner (F1)
-- ---------------------------------------------------------------------------
-- The base draft enables FORCE row level security on both private tables and
-- grants nothing. A SECURITY DEFINER function does not bypass RLS: if it is
-- owned by a role with no policy, it reads zero rows and cannot insert audit
-- rows. The previous revision said "do not leave this owned by a BYPASSRLS
-- superuser" while relying on exactly that, which was contradictory.
--
-- Resolution: a dedicated NOLOGIN/NOINHERIT role that owns only the bridge-sync
-- functions and receives narrow, explicit per-table policies. No BYPASSRLS.
--
-- SUPABASE COMPATIBILITY ASSUMPTIONS (unverified; confirm in the isolated
-- project before approval):
--   * the migration runs as a role allowed to CREATE ROLE (normally `postgres`);
--   * that role can become a member of the new role so ownership can be
--     transferred (`grant <role> to current_user` below);
--   * roles anon / authenticated already exist (needed by the REVOKE statements
--     in the base draft and in this file);
--   * auth.uid() / auth.jwt() exist and their EXECUTE may be granted to a
--     non-superuser role. If the grant is rejected, the deployer must grant it
--     manually as the auth-schema owner; the draft then fails closed.
--   * role creation is idempotent here: an existing role is adopted unchanged,
--     never altered. Inspect it before reuse.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'smart_hatch_bridge_owner') then
    execute 'create role smart_hatch_bridge_owner '
         || 'nologin noinherit nosuperuser nocreatedb nocreaterole '
         || 'noreplication nobypassrls';
  end if;
exception
  when insufficient_privilege then
    raise exception using
      errcode = '42501',
      message = 'BRIDGE_OWNER_ROLE_REQUIRED',
      detail = 'The migration role must be able to CREATE ROLE. Create '
            || 'smart_hatch_bridge_owner out-of-band as a NOLOGIN NOINHERIT '
            || 'role without SUPERUSER/CREATEDB/CREATEROLE/REPLICATION/BYPASSRLS.';
end
$$;

grant usage on schema private to smart_hatch_bridge_owner;

do $$
begin
  if not pg_has_role(current_user, 'smart_hatch_bridge_owner', 'member') then
    execute format('grant smart_hatch_bridge_owner to %I', current_user);
  end if;
exception
  when insufficient_privilege then
    raise exception using
      errcode = '42501',
      message = 'BRIDGE_OWNER_MEMBERSHIP_REQUIRED',
      detail = 'The migration role must be able to SET ROLE to '
            || 'smart_hatch_bridge_owner to transfer function ownership.';
end
$$;

-- Supabase-only auth helpers. Guarded so a plain PostgreSQL instance without an
-- auth schema aborts with a clear message instead of silently degrading.
do $$
begin
  if to_regprocedure('auth.uid()') is not null then
    execute 'grant usage on schema auth to smart_hatch_bridge_owner';
    execute 'grant execute on function auth.uid() to smart_hatch_bridge_owner';
    if to_regprocedure('auth.jwt()') is not null then
      execute 'grant execute on function auth.jwt() to smart_hatch_bridge_owner';
    end if;
  end if;
exception
  when insufficient_privilege then
    raise exception using
      errcode = '42501',
      message = 'AUTH_HELPER_GRANT_REQUIRED',
      detail = 'Grant USAGE on schema auth and EXECUTE on auth.uid()/auth.jwt() '
            || 'to smart_hatch_bridge_owner as the auth-schema owner.';
end
$$;

-- ---------------------------------------------------------------------------
-- 1. Current pilot authorization state
-- ---------------------------------------------------------------------------
-- The existing row remains the single pilot slot. Replacement updates this row;
-- historical bindings live in private.enrollment_audit. Multiple active
-- authorization rows are not permitted.

alter table private.authorized_installations
  add column activation_state text not null default 'pending',
  add column activation_expires_at timestamptz,
  add column activated_at timestamptz,
  add column authorization_expires_at timestamptz,
  add column revoked_at timestamptz,
  add column revoked_by text,
  add column revocation_reason text,
  add column capabilities text[] not null default '{}'::text[];

comment on column private.authorized_installations.activation_state is
  'DRAFT vocabulary: pending|active|revoked|replaced|expired. active requires the '
  'base-draft active=false lock to be removed by a reviewed enablement migration.';
comment on column private.authorized_installations.activation_expires_at is
  'PENDING ACTIVATION WINDOW ONLY. Value and duration are NOT APPROVED. Applies '
  'only while activation_state is pending; forced NULL once active.';
comment on column private.authorized_installations.authorization_expires_at is
  'ACTIVE AUTHORIZATION / OFFLINE LIFETIME. Value and duration are NOT APPROVED. '
  'No default is invented; NULL means the future policy has not set a bound.';
comment on column private.authorized_installations.activated_at is
  'When activation completed. NULL while pending.';
comment on column private.authorized_installations.revoked_by is
  'Administrator identity string for the revocation action. Never a secret.';
comment on column private.authorized_installations.revocation_reason is
  'Bounded reason code/detail for revocation.';
comment on column private.authorized_installations.capabilities is
  'Bridge-sync operation subset only. Empty means no capability (fail closed).';

alter table private.authorized_installations
  add constraint db_imp_01_activation_state_check
    check (activation_state in ('pending','active','revoked','replaced','expired')),
  add constraint db_imp_01_capabilities_check
    check (
      capabilities is not null
      and array_position(capabilities, null) is null
      and capabilities <@ array['submit_event','submit_reading','get_reconciliation']::text[]
    ),
  -- While the base draft hard-locks active = false, activation_state = 'active'
  -- is intentionally impossible. A later enablement migration must change both
  -- together under review.
  add constraint db_imp_01_activation_active_consistent
    check ((activation_state = 'active') = active),
  add constraint db_imp_01_revoked_consistency
    check (activation_state <> 'revoked' or revoked_at is not null),
  -- F3: the pending activation window must not silently expire an active row.
  -- It is only meaningful while pending (or while retained as the reason a row
  -- became 'expired'); activation must clear it.
  add constraint db_imp_01_pending_expiry_scope
    check (
      activation_expires_at is null
      or activation_state in ('pending','expired')
    ),
  add constraint db_imp_01_one_device_per_installation
    unique (device_id);

-- At most one active installation. pilot_slot already permits only one row;
-- this also protects a future replacement/current-state design.
create unique index db_imp_01_one_active_installation
  on private.authorized_installations (active)
  where active;

-- ---------------------------------------------------------------------------
-- 2. Append-only enrollment / revocation audit (F2)
-- ---------------------------------------------------------------------------
-- Private, RLS-forced, no client grants. Previous/new pairs cover provisioning,
-- activation, session re-pin, revocation, replacement, recovery, capability
-- change and expiry. Rows are never updated or deleted.

create table private.enrollment_audit (
  audit_id bigint generated always as identity primary key,
  occurred_at timestamptz not null default now(),
  actor_type text not null
    check (actor_type in ('administrator','system')),
  actor_id text not null
    check (length(actor_id) between 1 and 200),
  action text not null
    check (action in (
      'provision','activate','session_repin','revoke','replace','recover',
      'capability_change','expire'
    )),
  outcome text not null
    check (outcome in ('applied','denied','failed')),
  -- Replacement requires both identities; provisioning uses only new_*.
  previous_auth_user_id uuid,
  new_auth_user_id uuid,
  previous_installation_id uuid,
  new_installation_id uuid,
  previous_device_id uuid,
  new_device_id uuid,
  previous_session_id uuid,
  new_session_id uuid,
  previous_activation_state text
    check (previous_activation_state is null
           or previous_activation_state in ('pending','active','revoked','replaced','expired')),
  new_activation_state text
    check (new_activation_state is null
           or new_activation_state in ('pending','active','revoked','replaced','expired')),
  previous_capabilities text[]
    check (
      previous_capabilities is null
      or (array_position(previous_capabilities, null) is null
          and previous_capabilities <@ array['submit_event','submit_reading','get_reconciliation']::text[])
    ),
  new_capabilities text[]
    check (
      new_capabilities is null
      or (array_position(new_capabilities, null) is null
          and new_capabilities <@ array['submit_event','submit_reading','get_reconciliation']::text[])
    ),
  previous_revision bigint
    check (previous_revision is null or previous_revision > 0),
  new_revision bigint
    check (new_revision is null or new_revision > 0),
  reason_code text
    check (reason_code is null or length(reason_code) <= 100),
  reason_detail text
    check (reason_detail is null or length(reason_detail) <= 500),
  request_id uuid not null,
  constraint db_imp_01_audit_revision_order
    check (
      previous_revision is null
      or new_revision is null
      or new_revision > previous_revision
    ),
  -- A replacement must identify what was replaced.
  constraint db_imp_01_audit_replace_scope
    check (
      action <> 'replace'
      or (previous_installation_id is not null and new_installation_id is not null)
    ),
  -- A capability change must carry the before/after sets.
  constraint db_imp_01_audit_capability_scope
    check (
      action <> 'capability_change'
      or (previous_capabilities is not null and new_capabilities is not null)
    )
);

alter table private.enrollment_audit enable row level security;
alter table private.enrollment_audit force row level security;
revoke all on table private.enrollment_audit from public, anon, authenticated;
revoke all on sequence private.enrollment_audit_audit_id_seq from public, anon, authenticated;

create index db_imp_01_audit_installation_time
  on private.enrollment_audit (new_installation_id, occurred_at desc);

create index db_imp_01_audit_device_time
  on private.enrollment_audit (new_device_id, occurred_at desc);

create function private.enrollment_audit_immutable()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception using
    errcode = '55000',
    message = 'ENROLLMENT_AUDIT_APPEND_ONLY';
end;
$$;

create trigger db_imp_01_enrollment_audit_no_update_delete
  before update or delete on private.enrollment_audit
  for each row execute function private.enrollment_audit_immutable();

-- ---------------------------------------------------------------------------
-- 3. Narrow grants and RLS policies for the function owner (F1)
-- ---------------------------------------------------------------------------
-- Only the NOLOGIN owner role is granted anything. anon/authenticated remain
-- fully revoked on every private table and policy. The owner may:
--   * read the two registry tables (needed for authorization decisions);
--   * insert audit rows (needed for state-change audit).
-- It may not update or delete audit rows, and it is not the table owner.

grant select on table private.authorized_installations to smart_hatch_bridge_owner;
grant select on table private.controllers to smart_hatch_bridge_owner;
grant insert on table private.enrollment_audit to smart_hatch_bridge_owner;

-- SELECT policies: registry reads are required for authorization. Row filtering
-- is not possible here because the owner must read the single pilot row before
-- it can compare identity; the scope restriction is the function contract.
create policy db_imp_01_owner_read_installations
  on private.authorized_installations
  for select
  to smart_hatch_bridge_owner
  using (true);

create policy db_imp_01_owner_read_controllers
  on private.controllers
  for select
  to smart_hatch_bridge_owner
  using (true);

-- INSERT-only audit policy. No UPDATE/DELETE policy exists, so even a future
-- accidental grant cannot rewrite history (the trigger is a second barrier).
create policy db_imp_01_owner_insert_audit
  on private.enrollment_audit
  for insert
  to smart_hatch_bridge_owner
  with check (true);

-- ---------------------------------------------------------------------------
-- 4. Audit writer
-- ---------------------------------------------------------------------------
-- Returns void on purpose: INSERT ... RETURNING would require SELECT privilege
-- and a SELECT policy on the audit table, which would widen the owner's access.
-- Correlation is carried by request_id.
--
-- Callers: future admin provisioning/activation/re-pin/revocation/replacement/
-- recovery functions. Those functions are NOT implemented here, so this helper
-- remains unexecutable by clients (EXECUTE revoked from everything).

create function private.record_enrollment_audit(
  p_actor_type text,
  p_actor_id text,
  p_action text,
  p_outcome text,
  p_previous_auth_user_id uuid,
  p_new_auth_user_id uuid,
  p_previous_installation_id uuid,
  p_new_installation_id uuid,
  p_previous_device_id uuid,
  p_new_device_id uuid,
  p_previous_session_id uuid,
  p_new_session_id uuid,
  p_previous_activation_state text,
  p_new_activation_state text,
  p_previous_capabilities text[],
  p_new_capabilities text[],
  p_previous_revision bigint,
  p_new_revision bigint,
  p_reason_code text,
  p_reason_detail text,
  p_request_id uuid
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into private.enrollment_audit (
    actor_type,
    actor_id,
    action,
    outcome,
    previous_auth_user_id,
    new_auth_user_id,
    previous_installation_id,
    new_installation_id,
    previous_device_id,
    new_device_id,
    previous_session_id,
    new_session_id,
    previous_activation_state,
    new_activation_state,
    previous_capabilities,
    new_capabilities,
    previous_revision,
    new_revision,
    reason_code,
    reason_detail,
    request_id
  ) values (
    p_actor_type,
    p_actor_id,
    p_action,
    p_outcome,
    p_previous_auth_user_id,
    p_new_auth_user_id,
    p_previous_installation_id,
    p_new_installation_id,
    p_previous_device_id,
    p_new_device_id,
    p_previous_session_id,
    p_new_session_id,
    p_previous_activation_state,
    p_new_activation_state,
    p_previous_capabilities,
    p_new_capabilities,
    p_previous_revision,
    p_new_revision,
    p_reason_code,
    p_reason_detail,
    p_request_id
  );
$$;

revoke all on function private.record_enrollment_audit(
  text,text,text,text,
  uuid,uuid,uuid,uuid,uuid,uuid,uuid,uuid,
  text,text,
  text[],text[],
  bigint,bigint,
  text,text,
  uuid
) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- 5. Private authorization implementation (F3, F4, F7, F8)
-- ---------------------------------------------------------------------------
-- Read-only: authorization creates no evidence, no receipt and no audit row.
-- Denial auditing decision (F8): this function deliberately does NOT write a row
-- per denied call. Authorize is unauthenticated-input, high-frequency and
-- read-only; writing on denial would let a client drive audit-table growth and
-- would mix access attempts with the state-change audit contract. Denials are
-- observable through Edge/PostgREST logs. State-change *attempts* that are
-- rejected by an admin action are audited with outcome = 'denied' by the admin
-- function, not here.

create function private.bridge_sync_authorize_impl(
  p_installation_id uuid,
  p_device_id uuid,
  p_lock boolean default false
)
returns table (
  allowed boolean,
  code text,
  installation_id uuid,
  device_id uuid,
  authorization_revision bigint,
  capabilities text[],
  authorization_expires_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_jwt jsonb := auth.jwt();
  v_session_id uuid;
  v_exp_text text;
  v_exp bigint;
  v_row private.authorized_installations%rowtype;
  v_controller private.controllers%rowtype;
  v_now timestamptz := now();
begin
  if v_uid is null or v_jwt is null then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;

  if (v_jwt ->> 'role') is distinct from 'authenticated' then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;

  -- ASSUMPTION TO VERIFY: Supabase access tokens carry is_anonymous = false for
  -- non-anonymous users. Missing or non-false values deny. Verify against a real
  -- isolated project before approval.
  if (v_jwt ->> 'is_anonymous') is distinct from 'false' then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;

  v_exp_text := v_jwt ->> 'exp';
  if v_exp_text is null or v_exp_text !~ '^[0-9]+$' then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;
  v_exp := v_exp_text::bigint;
  if v_exp <= extract(epoch from v_now)::bigint then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;

  begin
    v_session_id := (v_jwt ->> 'session_id')::uuid;
  exception when others then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end;

  if p_lock then
    select * into v_row
      from private.authorized_installations ai
      where ai.pilot_slot = 1
        and ai.installation_id = p_installation_id
        and ai.device_id = p_device_id
      for update;
  else
    select * into v_row
      from private.authorized_installations ai
      where ai.pilot_slot = 1
        and ai.installation_id = p_installation_id
        and ai.device_id = p_device_id;
  end if;

  if not found then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;

  -- F4: NULL-safe identity binding. is distinct from never yields NULL, so a
  -- future nullable column cannot turn the whole OR-chain into NULL and skip
  -- the denial branch.
  if v_row.auth_user_id is distinct from v_uid
     or v_row.authorized_session_id is distinct from v_session_id
     or v_row.active is distinct from true
     or v_row.revoked_at is not null
     or v_row.activation_state is distinct from 'active' then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;

  -- F3: the pending activation window is never applied to an active row.
  -- A pending/expired/revoked/replaced row was already rejected above; only the
  -- active authorization lifetime is evaluated here.
  if v_row.authorization_expires_at is not null
     and v_row.authorization_expires_at <= v_now then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;

  select * into v_controller
    from private.controllers c
    where c.device_id = v_row.device_id;

  if not found then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;

  if v_controller.active is distinct from true then
    return query select
      false, 'NOT_AUTHORIZED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;

  if v_controller.contract_enabled is distinct from true then
    return query select
      false, 'CONTRACT_DISABLED',
      null::uuid, null::uuid, null::bigint, null::text[], null::timestamptz;
    return;
  end if;

  return query select
    true, 'AUTHORIZED',
    v_row.installation_id,
    v_row.device_id,
    v_row.authorization_revision,
    v_row.capabilities,
    v_row.authorization_expires_at;
  return;
end;
$$;

revoke all on function private.bridge_sync_authorize_impl(uuid,uuid,boolean)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- 6. Ownership transfer (F1)
-- ---------------------------------------------------------------------------
-- SECURITY DEFINER runs with the owner's privileges, so the owner must be the
-- NOLOGIN role that holds the narrow policies above. Verify after applying:
--   select prosecdef, proowner::regrole, proconfig
--     from pg_proc where proname like 'bridge_sync%' or proname = 'record_enrollment_audit';
-- Expected: prosecdef = true, proowner = smart_hatch_bridge_owner,
--           proconfig contains search_path=.

alter function private.record_enrollment_audit(
  text,text,text,text,
  uuid,uuid,uuid,uuid,uuid,uuid,uuid,uuid,
  text,text,
  text[],text[],
  bigint,bigint,
  text,text,
  uuid
) owner to smart_hatch_bridge_owner;

alter function private.bridge_sync_authorize_impl(uuid,uuid,boolean)
  owner to smart_hatch_bridge_owner;

-- ---------------------------------------------------------------------------
-- 7. Required Edge mapping — DOCUMENTATION ONLY, Edge code not modified (F5, F6)
-- ---------------------------------------------------------------------------
-- The current Edge adapter maps any allowed <> true to 403 and any non-403/409
-- RPC failure to a RETRYABLE 503 SERVICE_UNAVAILABLE. That is wrong for:
--   * CONTRACT_DISABLED  -> must be 503 with a non-retryable "disabled" code;
--   * EVIDENCE_LEDGER_NOT_IMPLEMENTED (SQLSTATE 0A000) -> permanent, must NOT be
--     advertised as retryable.
-- Required later Edge changes (separate task, not done here):
--   authorize: code = AUTHORIZED -> 200/allow; NOT_AUTHORIZED -> 403;
--              CONTRACT_DISABLED -> 503, retryable = false, code = CONTRACT_DISABLED.
--   ingest/reconcile: 42501 -> 403 NOT_AUTHORIZED; 0A000 with message
--              EVIDENCE_LEDGER_NOT_IMPLEMENTED -> non-retryable NOT_IMPLEMENTED;
--              401 -> AUTHENTICATION_REQUIRED.
-- PostgREST status mapping for user-raised SQLSTATEs must be confirmed against
-- the real PostgREST build; see section 5 of the RPC draft.

-- ---------------------------------------------------------------------------
-- 8. Explicitly unresolved
-- ---------------------------------------------------------------------------
-- 1. Public wrappers are in DB-IMP-01_bridge_sync_rpcs_draft.sql; this file must
--    be applied first.
-- 2. is_anonymous / session_id / exp claim behavior, and whether session_id is
--    preserved across token refresh, must be verified against the isolated
--    project. This draft requires an exact session_id match.
-- 3. The hard active/contract locks remain. Authorization cannot succeed until a
--    separately reviewed enablement migration removes db_imp_01_installation_disabled
--    and db_imp_01_contract_disabled.
-- 4. Admin provisioning/activation/re-pin/revocation/replacement/recovery
--    functions are not implemented. Only the audit table and writer exist.
-- 5. Activation and authorization durations remain unset and unapproved; no
--    default TTL is invented anywhere in this file.
-- 6. The evidence ledger, receipts, deduplication, conflict projection and retry
--    reconciliation are not implemented.
-- 7. Legacy public grants, permissive RLS and direct-write bypasses on existing
--    application tables are not repaired here.
-- 8. Compatibility risk: CREATE ROLE, role membership and ownership transfer may
--    require privileges the isolated environment does not grant the migration
--    role. ALTER FUNCTION ... OWNER TO may also require the new owner to hold
--    CREATE on the containing schema on some PostgreSQL versions. If so, grant
--    that narrowly for the transfer only; do not widen the owner permanently.
--    The DO blocks fail closed with explicit messages instead of degrading.

commit;
