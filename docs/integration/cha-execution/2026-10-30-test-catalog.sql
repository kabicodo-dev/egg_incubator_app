-- Read-only catalog audit. Run ONLY with explicit --project-ref zbwntspdecngnicllwlw.
-- No application rows, Auth rows, function bodies, credentials or changes.
BEGIN TRANSACTION READ ONLY;
SELECT jsonb_build_object(
  'observed_at', current_timestamp,
  'database', current_database(),
  'read_only', current_setting('transaction_read_only'),
  'tables', (SELECT coalesce(jsonb_agg(jsonb_build_object(
    'schema', n.nspname, 'name', c.relname, 'kind', c.relkind,
    'owner', pg_get_userbyid(c.relowner), 'rls', c.relrowsecurity,
    'force_rls', c.relforcerowsecurity, 'acl', c.relacl::text)
    ORDER BY n.nspname,c.relname), '[]'::jsonb)
    FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname IN ('public','private') AND c.relkind IN ('r','p','v','m','S')),
  'columns', (SELECT coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb) FROM
    (SELECT table_schema,table_name,column_name,data_type,is_nullable,column_default,is_identity
     FROM information_schema.columns WHERE table_schema IN ('public','private')
     ORDER BY table_schema,table_name,ordinal_position) x),
  'policies', (SELECT coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb) FROM
    (SELECT schemaname,tablename,policyname,permissive,roles,cmd,qual,with_check
     FROM pg_policies WHERE schemaname IN ('public','private') ORDER BY schemaname,tablename,policyname) x),
  'grants', (SELECT coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb) FROM
    (SELECT table_schema,table_name,grantee,privilege_type,is_grantable
     FROM information_schema.table_privileges WHERE table_schema IN ('public','private')
     ORDER BY table_schema,table_name,grantee,privilege_type) x),
  'routines', (SELECT coalesce(jsonb_agg(jsonb_build_object(
    'schema',n.nspname,'name',p.proname,'args',pg_get_function_identity_arguments(p.oid),
    'security_definer',p.prosecdef,'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text)), '[]'::jsonb)
    FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname IN ('public','private')),
  'default_acls', (SELECT coalesce(jsonb_agg(jsonb_build_object(
    'owner',pg_get_userbyid(d.defaclrole),'schema',n.nspname,'type',d.defaclobjtype,'acl',d.defaclacl::text)), '[]'::jsonb)
    FROM pg_default_acl d LEFT JOIN pg_namespace n ON n.oid=d.defaclnamespace
    WHERE n.nspname IN ('public','private') OR d.defaclnamespace=0),
  'constraints', (SELECT coalesce(jsonb_agg(jsonb_build_object(
    'schema',n.nspname,'table',c.relname,'name',con.conname,'definition',pg_get_constraintdef(con.oid))), '[]'::jsonb)
    FROM pg_constraint con JOIN pg_class c ON c.oid=con.conrelid
    JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname IN ('public','private')),
  'indexes', (SELECT coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb) FROM
    (SELECT schemaname,tablename,indexname,indexdef FROM pg_indexes
     WHERE schemaname IN ('public','private') ORDER BY schemaname,tablename,indexname) x)
) AS audit;
ROLLBACK;
