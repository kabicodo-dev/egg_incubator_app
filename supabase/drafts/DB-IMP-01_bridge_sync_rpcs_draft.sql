-- DRAFT — NOT APPROVED — DO NOT APPLY
-- CURRENT:DB-IMP-01 / Mary Charlyn / 2026-10-30
-- Revision 2: F1-F8 correction pass (owner transfer, not-found handling,
--             non-retryable ledger error, denial-code documentation).
--
-- Public bridge-sync RPC wrappers. Requires:
--   DB-IMP-01_disabled_registry.sql
--   DB-IMP-01_authorization_schema_draft.sql
-- to be reviewed and applied first in an isolated, explicitly authorized database.
--
-- No SQL in this file has been executed, parsed or applied. No production or
-- main-project use. Ingestion remains CONTRACT_NOT_ENABLED. Authorization rows
-- remain hard-locked.

begin;

do $$
begin
  if to_regclass('private.authorized_installations') is null
     or to_regclass('private.enrollment_audit') is null
     or to_regprocedure('private.bridge_sync_authorize_impl(uuid,uuid,boolean)') is null then
    raise exception 'DB-IMP-01 authorization schema draft must be applied first';
  end if;
  if to_regrole('smart_hatch_bridge_owner') is null then
    raise exception 'DB-IMP-01 bridge owner role is missing; apply the schema draft first';
  end if;
  if not pg_has_role(current_user, 'smart_hatch_bridge_owner', 'member') then
    raise exception 'BRIDGE_OWNER_MEMBERSHIP_REQUIRED';
  end if;
end
$$;

-- ---------------------------------------------------------------------------
-- 1. Public authorize wrapper
-- ---------------------------------------------------------------------------
-- PostgREST exposes the public schema. Private tables stay non-API-exposed.
-- Read-only. Returns a fixed denial shape; the caller never learns which
-- identity, session, installation or device check failed.

create function public.bridge_sync_authorize_v1(
  p_installation_id uuid,
  p_device_id uuid
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
language sql
security definer
set search_path = ''
as $$
  select *
  from private.bridge_sync_authorize_impl($1, $2, false);
$$;

revoke all on function public.bridge_sync_authorize_v1(uuid,uuid)
  from public, anon;
grant execute on function public.bridge_sync_authorize_v1(uuid,uuid)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 2. Public ingest wrapper
-- ---------------------------------------------------------------------------
-- Preserves the atomic authorization recheck but deliberately stops before
-- persistence: the immutable event ledger, receipt/revision model, dedup and
-- conflict projection are not yet approved/implemented.
--
-- Required before this branch can be replaced by a real write:
--   * recompute the canonical hash; never trust p_content_sha256;
--   * same entity + same core  -> return the original receipt (idempotent retry);
--   * same entity + changed core -> IDENTITY_CONTENT_CONFLICT;
--   * missing dependencies -> commit a waiting receipt, never a fake applied row;
--   * preserve first_installation_id and immutable source identity when a
--     replacement installation uploads old evidence;
--   * lock and recheck authorization in the same transaction as the write.

create function public.bridge_sync_ingest_v1(
  p_submission jsonb,
  p_content_sha256 text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_installation_id uuid;
  v_device_id uuid;
  v_operation text;
  v_allowed boolean;
  v_code text;
  v_capabilities text[];
begin
  if p_submission is null or jsonb_typeof(p_submission) <> 'object' then
    raise exception using errcode = '22023', message = 'INVALID_REQUEST';
  end if;

  if p_content_sha256 is null
     or p_content_sha256 !~ '^[0-9a-f]{64}$' then
    raise exception using errcode = '22023', message = 'INVALID_REQUEST';
  end if;

  begin
    v_installation_id := (p_submission ->> 'installation_id')::uuid;
    v_device_id := (p_submission ->> 'device_id')::uuid;
  exception when others then
    raise exception using errcode = '22023', message = 'INVALID_REQUEST';
  end;

  v_operation := p_submission ->> 'operation';
  if v_operation is null
     or v_operation not in ('submit_event','submit_reading') then
    raise exception using errcode = '22023', message = 'INVALID_REQUEST';
  end if;

  -- Authoritative recheck under lock. The Edge check alone is never sufficient.
  select a.allowed, a.code, a.capabilities
    into v_allowed, v_code, v_capabilities
    from private.bridge_sync_authorize_impl(
      v_installation_id,
      v_device_id,
      true
    ) a;

  -- F7: FOUND is tested on its own. The previous combined expression could
  -- dereference an unassigned record and raise 55000 instead of the intended
  -- 42501 denial.
  if not found then
    raise exception using errcode = '42501', message = 'NOT_AUTHORIZED';
  end if;

  if v_allowed is not true then
    raise exception using errcode = '42501', message = 'NOT_AUTHORIZED';
  end if;

  -- v_code is deliberately not surfaced here (F5). CONTRACT_DISABLED and every
  -- identity failure collapse to the same NOT_AUTHORIZED. Only
  -- bridge_sync_authorize_v1 returns the code, for the future Edge 503 mapping.
  if not (v_operation = any(v_capabilities)) then
    raise exception using errcode = '42501', message = 'NOT_AUTHORIZED';
  end if;

  -- Fail closed until the evidence/receipt schema is separately approved.
  -- F6: 0A000 (feature_not_supported) is a permanent condition, not a transient
  -- outage, so it must not reach the client as an indefinitely retryable 503.
  -- PostgREST is expected to surface 0A000 as a client-class 4xx; the Edge must
  -- additionally map it to a non-retryable NOT_IMPLEMENTED code (Edge change not
  -- part of this draft).
  raise exception using
    errcode = '0A000',
    message = 'EVIDENCE_LEDGER_NOT_IMPLEMENTED',
    detail = 'Permanent: the evidence ledger and receipt schema are not implemented.'
           || ' Do not retry until a reviewed migration is applied.',
    hint = 'NOT_RETRYABLE';
end;
$$;

revoke all on function public.bridge_sync_ingest_v1(jsonb,text)
  from public, anon;
grant execute on function public.bridge_sync_ingest_v1(jsonb,text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 3. Public reconcile wrapper
-- ---------------------------------------------------------------------------
-- Read-only, but must authorize before returning any receipt, mapping or scope
-- data. No physical commands are issued.

create function public.bridge_sync_reconcile_v1(
  p_query jsonb,
  p_request_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_installation_id uuid;
  v_device_id uuid;
  v_operation text;
  v_allowed boolean;
  v_code text;
  v_capabilities text[];
begin
  if p_query is null or jsonb_typeof(p_query) <> 'object' then
    raise exception using errcode = '22023', message = 'INVALID_REQUEST';
  end if;

  if p_request_id is null then
    raise exception using errcode = '22023', message = 'INVALID_REQUEST';
  end if;

  begin
    v_installation_id := (p_query ->> 'installation_id')::uuid;
    v_device_id := (p_query ->> 'device_id')::uuid;
  exception when others then
    raise exception using errcode = '22023', message = 'INVALID_REQUEST';
  end;

  v_operation := p_query ->> 'operation';
  if v_operation is distinct from 'get_reconciliation' then
    raise exception using errcode = '22023', message = 'INVALID_REQUEST';
  end if;

  select a.allowed, a.code, a.capabilities
    into v_allowed, v_code, v_capabilities
    from private.bridge_sync_authorize_impl(
      v_installation_id,
      v_device_id,
      false
    ) a;

  if not found then
    raise exception using errcode = '42501', message = 'NOT_AUTHORIZED';
  end if;

  if v_allowed is not true then
    raise exception using errcode = '42501', message = 'NOT_AUTHORIZED';
  end if;

  -- v_code is deliberately not surfaced here (F5); see the ingest wrapper note.
  if not ('get_reconciliation' = any(v_capabilities)) then
    raise exception using errcode = '42501', message = 'NOT_AUTHORIZED';
  end if;

  -- Fail closed until the receipt/reconciliation schema is separately approved.
  raise exception using
    errcode = '0A000',
    message = 'EVIDENCE_LEDGER_NOT_IMPLEMENTED',
    detail = 'Permanent: the evidence ledger and receipt schema are not implemented.'
           || ' Do not retry until a reviewed migration is applied.',
    hint = 'NOT_RETRYABLE';
end;
$$;

revoke all on function public.bridge_sync_reconcile_v1(jsonb,uuid)
  from public, anon;
grant execute on function public.bridge_sync_reconcile_v1(jsonb,uuid)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 4. Ownership transfer (F1)
-- ---------------------------------------------------------------------------
-- The wrappers are SECURITY DEFINER and must execute as the NOLOGIN owner that
-- holds the narrow policies and owns the private implementation. Ownership is
-- transferred after the EXECUTE grants above, which are preserved.

alter function public.bridge_sync_authorize_v1(uuid,uuid)
  owner to smart_hatch_bridge_owner;

alter function public.bridge_sync_ingest_v1(jsonb,text)
  owner to smart_hatch_bridge_owner;

alter function public.bridge_sync_reconcile_v1(jsonb,uuid)
  owner to smart_hatch_bridge_owner;

-- ---------------------------------------------------------------------------
-- 5. Explicitly unresolved
-- ---------------------------------------------------------------------------
-- 1. Function owner/role is now defined (smart_hatch_bridge_owner, NOLOGIN,
--    NOBYPASSRLS) but provisioning it requires CREATE ROLE and role membership in
--    the target environment; see the schema draft assumptions.
-- 2. HTTP mapping must be verified against the real PostgREST build. Expected,
--    NOT confirmed: 42501 -> 403, 0A000 -> 4xx, 22023 -> 400, P0001 -> 400.
--    The Edge must map 0A000 to a NON-retryable code (Edge change not done here).
-- 3. Session refresh/re-pin behavior is unverified. This draft requires an exact
--    session_id match; if Supabase rotates session_id on refresh, an audited
--    re-pin is required before a refreshed client can be authorized.
-- 4. Evidence ledger/receipts and admin enrollment/revocation RPCs are not
--    implemented by this draft.
-- 5. Legacy public grants, permissive RLS and direct-write bypasses are not
--    repaired by adding these functions.
-- 6. No client-side credential is created or stored here; no service-role key is
--    used by the mobile app.

commit;
