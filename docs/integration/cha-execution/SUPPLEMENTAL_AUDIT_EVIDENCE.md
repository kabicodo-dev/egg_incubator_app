# Supplemental audit evidence — CSVs (15)–(19) and supplied screenshots

**Task:** OCT26:C-01 · **Owner:** Mary Charlyn · **Status:** Completed audit,
with open security findings; no additional task status changed.

All five CSVs and eleven supplied screenshot panels were reviewed. Downloads
originals and screenshots were not edited. CSV bytes, SHA-256 hashes, every row,
checks and screenshot observations are retained in `supplemental-csv-review.json`.
Screenshots were visually reviewed from the conversation; their original image
files/byte hashes are not available to this local report.

## What the additional CSVs establish

| Export | Evidence | Important limitation |
|---|---|---|
| (15) | Four identity sequences owned by postgres; anon/authenticated USAGE and SELECT flags true | Sequence access alone does not prove table writes pass RLS. No sequence was advanced in this review. |
| (16) | Broad default grants for future tables/functions/sequences, including postgres-owned public objects; storage/extensions entries also present | Exactly **100 rows**: the export may be capped. Original SQL/limit must be checked before treating this as exhaustive. Default grants are role/schema/object-type specific and do not certify existing object access. Do not modify Supabase-managed storage defaults based on this sample. |
| (17) | anon/authenticated do not bypass RLS; postgres/service_role/supabase_admin do | Successful SQL Editor queries under postgres cannot establish ordinary-client isolation. These are exported role flags, not a fresh signed-token test. |
| (18) | Nine public objects owned by postgres: one helper function, four sequences and four tables | Ownership matches the independently targeted test catalog; not an installation/device ownership model. |
| (19) | authenticator can SET ROLE to anon/authenticated/service_role; memberships also listed for postgres | A normal platform role arrangement, not proof that any client can select service_role or that real JWT validation/revocation works. |

Five offline interpretation/consistency checks are run by
`review-supplemental-csvs.cjs`. No remote queries, database writes, auth
provisioning, policy/config changes or migrations are performed by this review.

## What the screenshots add

1. The selected project name is visibly **smarthatch-test**, improving context
   beyond the CSV filenames. Exact project ID/URL and execution identity/time
   are not shown; this does not automatically assign every CSV to a verified ref.
   The main-branch **PRODUCTION** badge does not mean the separate application
   project, egg incubator, was accessed.
2. Both private-schema lookups show no rows, including the pg_namespace lookup.
   This supports the observation that the proposed private registry/ledger
   schema was absent in the shown database at the time. Do not confuse the SQL
   Editor sidebar label “PRIVATE (18)” (private saved queries) with a database schema.
3. The corrected RLS query shows all four tables with RLS enabled and FORCE RLS
   false. The earlier error is a catalog-query mistake: pg_tables has no
   forcerowsecurity column. The correct fields are **pg_class.relrowsecurity**
   and **pg_class.relforcerowsecurity**, joined to pg_namespace. It does not
   require a schema migration to fix this inspection query.
4. `rls_auto_enable` is a SECURITY DEFINER event-trigger helper owned by postgres,
   with search_path=pg_catalog. Its null explicit ACL is **not** “no permissions”:
   PostgreSQL default function EXECUTE semantics must be considered. Event-trigger
   return type/context also differs from an ordinary Data API RPC. The screenshot
   showing 0/1 exposed functions is not a direct-RPC success/failure test.
5. The migration-history query returns SQLSTATE 42P01, and the namespace query
   shows no supabase_migrations schema. This establishes no history in that
   location in the shown database—not that no SQL or migration ever ran.
   Manual SQL, cloning/restoration or missing tracking are possible; no cause is
   established. Do not create a migration-history schema just to silence the query.
6. Data API settings show **public + graphql_public** exposed, **4/4 tables**,
   **0/1 functions**, automatic new-table exposure **on**, extra search path
   public/extensions and max rows 1000. This is useful configuration evidence,
   not a successful unauthorized-access test. Max rows 1000 is a Data API setting,
   not proof that the SQL Editor's separate 100-row export limit was absent.

## Effect on tasks and next work

These strengthen the two **already Completed audits**. They do not complete
secure ingestion, authorized installation enrollment, immutable event ledger,
the three RPCs, durable receipts/recovery or physical integration. A namespace
query returning no private schema supports an implementation gap, not completion
of creating that schema.

Keep the existing source/authorization gates disabled. No settings were toggled,
including automatic table exposure; changing that configuration or legacy
grants/policies needs separately scoped approval and compatibility review.
Kath/Ally-dependent decisions remain untouched.

The full HTML/report/handoff and additive import receive this distinct evidence
supplement without replacing earlier reports or changing saved browser statuses.
Existing counts remain 6 Completed, 7 Partial, 28 Not started and 1 Superseded
among 42 Cha-owned source records. New verification here is offline/static only;
earlier browser, live role-probe and physical-testing boundaries are unchanged.
