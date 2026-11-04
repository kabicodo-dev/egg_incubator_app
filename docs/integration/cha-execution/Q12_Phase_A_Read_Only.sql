-- Q12 PHASE A CANDIDATE: NOT AUTHORIZED / NOT EXECUTED.
-- Only after explicit approval and independent connection-target verification:
-- smarthatch-test / zbwntspdecngnicllwlw. No main/production use.
-- PostgreSQL cannot establish the Supabase project ref from database name alone.
-- Execute unchanged on ONE connection; on any error issue ROLLBACK and stop.
-- 501 rows is an overflow sentinel: >500 means incomplete; stop/report.
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL statement_timeout = '10s';
SET LOCAL lock_timeout = '2s';
SET LOCAL idle_in_transaction_session_timeout = '60s';

SELECT current_user AS connection_role,
       current_setting('server_version') AS server_version,
       current_setting('transaction_read_only') AS read_only,
       current_setting('transaction_isolation') AS isolation;

SELECT nspname, pg_get_userbyid(nspowner) AS owner, nspacl
FROM pg_namespace WHERE nspname IN ('public','private','auth')
ORDER BY nspname LIMIT 501;

SELECT n.nspname, c.relname, c.relkind, pg_get_userbyid(c.relowner) AS owner,
       c.relrowsecurity, c.relforcerowsecurity, c.relacl
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname IN ('public','private') AND c.relkind IN ('r','p','v','m','S','f')
ORDER BY n.nspname,c.relname LIMIT 501;

SELECT n.nspname,c.relname,a.attname,format_type(a.atttypid,a.atttypmod) AS type,
       a.attnotnull,a.attidentity,a.attgenerated,
       pg_get_expr(d.adbin,d.adrelid) AS default_expression
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
JOIN pg_attribute a ON a.attrelid=c.oid
LEFT JOIN pg_attrdef d ON d.adrelid=c.oid AND d.adnum=a.attnum
WHERE n.nspname IN ('public','private') AND c.relkind IN ('r','p','v','m','f')
  AND a.attnum>0 AND NOT a.attisdropped
ORDER BY n.nspname,c.relname,a.attnum LIMIT 501;

SELECT n.nspname,c.relname,k.conname,k.contype,
       pg_get_constraintdef(k.oid) AS definition
FROM pg_constraint k JOIN pg_class c ON c.oid=k.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname IN ('public','private')
ORDER BY n.nspname,c.relname,k.conname LIMIT 501;

SELECT n.nspname,c.relname,ic.relname AS index_name,i.indisunique,i.indisvalid,
       pg_get_indexdef(i.indexrelid) AS definition
FROM pg_index i JOIN pg_class c ON c.oid=i.indrelid
JOIN pg_class ic ON ic.oid=i.indexrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname IN ('public','private')
ORDER BY n.nspname,c.relname,ic.relname LIMIT 501;

SELECT n.nspname,c.relname,p.polname,p.polcmd,p.polpermissive,
       ARRAY(SELECT CASE WHEN r=0 THEN 'PUBLIC' ELSE pg_get_userbyid(r) END
             FROM unnest(p.polroles) AS r) AS roles,
       pg_get_expr(p.polqual,p.polrelid) AS using_expression,
       pg_get_expr(p.polwithcheck,p.polrelid) AS check_expression
FROM pg_policy p JOIN pg_class c ON c.oid=p.polrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname IN ('public','private')
ORDER BY n.nspname,c.relname,p.polname LIMIT 501;

SELECT n.nspname,c.relname,t.tgname,t.tgenabled,
       pg_get_triggerdef(t.oid) AS definition
FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname IN ('public','private') AND NOT t.tgisinternal
ORDER BY n.nspname,c.relname,t.tgname LIMIT 501;

SELECT n.nspname,p.proname,pg_get_function_identity_arguments(p.oid) AS arguments,
       pg_get_function_result(p.oid) AS result_type,
       pg_get_userbyid(p.proowner) AS owner,p.prosecdef,p.provolatile,
       p.proconfig,p.proacl
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE (n.nspname IN ('public','private') AND
         (p.proname LIKE 'bridge\_sync\_%' ESCAPE '\'
          OR p.proname IN ('record_enrollment_audit','enrollment_audit_immutable')))
   OR (n.nspname='auth' AND p.proname IN ('uid','jwt') AND p.pronargs=0)
ORDER BY n.nspname,p.proname,arguments LIMIT 501;

SELECT rolname,rolsuper,rolinherit,rolcreaterole,rolcreatedb,
       rolcanlogin,rolreplication,rolbypassrls
FROM pg_roles
WHERE rolname IN (current_user,'anon','authenticated','smart_hatch_bridge_owner')
ORDER BY rolname LIMIT 501;

SELECT parent.rolname AS granted_role,member.rolname AS member,m.admin_option
FROM pg_auth_members m JOIN pg_roles parent ON parent.oid=m.roleid
JOIN pg_roles member ON member.oid=m.member
WHERE parent.rolname IN (current_user,'anon','authenticated','smart_hatch_bridge_owner')
   OR member.rolname IN (current_user,'anon','authenticated','smart_hatch_bridge_owner')
ORDER BY parent.rolname,member.rolname LIMIT 501;

SELECT pg_get_userbyid(d.defaclrole) AS owner,
       CASE WHEN d.defaclnamespace=0 THEN '<global>' ELSE n.nspname END AS schema,
       d.defaclobjtype,d.defaclacl
FROM pg_default_acl d LEFT JOIN pg_namespace n ON n.oid=d.defaclnamespace
WHERE d.defaclnamespace=0 OR n.nspname IN ('public','private')
ORDER BY owner,schema,d.defaclobjtype LIMIT 501;

ROLLBACK;
