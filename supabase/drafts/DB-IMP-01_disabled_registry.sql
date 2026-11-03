-- CURRENT:DB-IMP-01 / Mary Charlyn / 2026-10-29
-- CANDIDATE OFFLINE PATCH ONLY: NOT APPROVED, NOT PARSED/EXECUTED/DEPLOYED.
-- Deliberately outside supabase/migrations: not picked up by db push/reset.
-- Review against an explicitly authorized isolated Supabase database first.
-- This is only the disabled registry foundation from DB-02 0.1-review, NOT
-- the ingestion/RLS remediation migration or an implementation of the RPCs.
-- Aliases/catalog columns below are candidate metadata, not a selected protocol.
-- No mappings, identities, keys, profiles, policies or test rows are provisioned.

begin;

-- Intentionally no IF NOT EXISTS / OR REPLACE: an existing private schema or
-- registry requires inspection, not silent adoption/replacement of its objects.
-- Run in one transaction; on collision/error, roll back, do not skip statements.
create schema private;
revoke all on schema private from public, anon, authenticated;

create table private.controllers (
  device_id uuid primary key,
  wire_alias text unique not null
    check (wire_alias ~ '^[0-9A-F]{16}$'),
  active boolean not null default false,
  catalog_revision text not null check (length(catalog_revision) > 0),
  contract_enabled boolean not null default false,
  registered_at timestamptz not null default now(),
  -- Deliberate immutable-in-this-draft capability locks. UPDATE cannot enable
  -- anything. Replacing these requires a new reviewed migration + real tests.
  constraint db_imp_01_controller_disabled check (active = false),
  constraint db_imp_01_contract_disabled check (contract_enabled = false)
);

create table private.authorized_installations (
  pilot_slot smallint primary key check (pilot_slot = 1),
  installation_id uuid unique not null,
  wire_installation_alias text unique not null
    check (wire_installation_alias ~ '^[0-9a-f]{16}$'),
  auth_user_id uuid not null,
  authorized_session_id uuid not null,
  device_id uuid not null references private.controllers(device_id),
  active boolean not null default false,
  authorization_revision bigint not null check (authorization_revision > 0),
  constraint db_imp_01_installation_disabled check (active = false)
);

-- No FK into managed auth tables is assumed before actual environment review.
-- No client grants or allow policies; all future authorization must be verified
-- using trusted Auth claims and registry scope, never caller-supplied user IDs.
alter table private.controllers enable row level security;
alter table private.controllers force row level security;
alter table private.authorized_installations enable row level security;
alter table private.authorized_installations force row level security;
revoke all on table private.controllers from public, anon, authenticated;
revoke all on table private.authorized_installations from public, anon, authenticated;

-- Intentionally no public RPCs, security-definer functions, EXECUTE grants or
-- permissive policies. Existing public grants/default privileges are NOT fixed
-- by this foundation. Existing public tables/History/defaults remain untouched.
-- Pending: enrollment audit, session/reading provenance, immutable event/receipt
-- ledger, atomic RPCs, direct-write bypass remediation and real security tests.
commit;
