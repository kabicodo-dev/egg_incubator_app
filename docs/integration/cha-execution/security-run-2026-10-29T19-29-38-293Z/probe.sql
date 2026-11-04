-- Approved TEST-only probe. Ref zbwntspdecngnicllwlw; run 2026-10-29T19-29-38-293Z.
-- Synthetic role claims exercise PostgreSQL policies, NOT JWT verification.
-- No schema changes, Auth rows, automatic IDs, sessions, settings or existing data changes.
BEGIN;
SET LOCAL lock_timeout='2s';
SET LOCAL statement_timeout='20s';
LOCK TABLE public.sensor_readings IN SHARE ROW EXCLUSIVE MODE NOWAIT;
DO $probe$
DECLARE
 results jsonb='[]'::jsonb;
 role_name text;
 operation text;
 statement text;
 affected bigint;
 error_code text;
 id_a bigint=-10550452058665; id_b bigint=-10550452058666; id_insert bigint=-10550452058667;
BEGIN
 IF EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='public.sensor_readings'::regclass AND NOT tgisinternal)
 THEN RAISE EXCEPTION 'UNKNOWN_SENSOR_TRIGGER_STOP'; END IF;
 IF EXISTS(SELECT 1 FROM pg_constraint WHERE (conrelid='public.sensor_readings'::regclass OR confrelid='public.sensor_readings'::regclass) AND contype='f')
 THEN RAISE EXCEPTION 'SENSOR_FOREIGN_KEY_STOP'; END IF;
 IF EXISTS(SELECT 1 FROM public.sensor_readings WHERE id IN (id_a,id_b,id_insert))
 THEN RAISE EXCEPTION 'FIXTURE_ID_COLLISION_STOP'; END IF;
 FOREACH role_name IN ARRAY ARRAY['anon','authenticated'] LOOP
  FOREACH operation IN ARRAY ARRAY['select','insert','update','delete'] LOOP
   -- Reset only this transaction's own fixtures before each role/operation.
   DELETE FROM public.sensor_readings WHERE id IN (id_a,id_b,id_insert);
   INSERT INTO public.sensor_readings(id,current_temperature,current_humidity,recorded_at)
    VALUES(id_a,1,1,'2000-01-01'),(id_b,2,2,'2000-01-01');
   PERFORM set_config('request.jwt.claims',jsonb_build_object('role',role_name,'sub','895b805a-aa16-451c-a4b2-5fb1523289b8','is_anonymous',role_name='anon')::text,true);
   statement=CASE operation
    WHEN 'select' THEN format('SELECT count(*) FROM public.sensor_readings WHERE id IN (%s,%s)',id_a,id_b)
    WHEN 'insert' THEN format('INSERT INTO public.sensor_readings(id,current_temperature,current_humidity,recorded_at) VALUES (%s,3,3,''2000-01-01'')',id_insert)
    WHEN 'update' THEN format('UPDATE public.sensor_readings SET current_temperature=4 WHERE id=%s',id_b)
    WHEN 'delete' THEN format('DELETE FROM public.sensor_readings WHERE id=%s',id_b)
   END;
   affected=0;error_code=null;
   BEGIN
    EXECUTE format('SET LOCAL ROLE %I',role_name);
    IF operation='select' THEN EXECUTE statement INTO affected;
    ELSE EXECUTE statement; GET DIAGNOSTICS affected=ROW_COUNT; END IF;
    RESET ROLE;
   EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS error_code=RETURNED_SQLSTATE;
    RESET ROLE;
   END;
   results=results||jsonb_build_array(jsonb_build_object('role',role_name,'operation',operation,
     'affected_fixture_rows',affected,'sqlstate',error_code,
     'observation',CASE WHEN error_code='42501' THEN 'DENIED_BY_PRIVILEGE_OR_RLS'
       WHEN error_code IS NOT NULL THEN 'ERROR_NOT_A_SECURITY_PASS'
       WHEN affected>0 THEN 'ALLOWED_ON_SYNTHETIC_FIXTURE' ELSE 'ZERO_ROWS' END,
     'security_expectation','Unapproved identities must not obtain installation-owned pilot access; no ownership claim is assigned to these synthetic identities'));
  END LOOP;
 END LOOP;
 -- Prove these are real visible uncommitted fixtures before unconditional rollback.
 PERFORM set_config('smarthatch.security_probe_results',jsonb_build_object(
  'target_ref','zbwntspdecngnicllwlw','run_id','2026-10-29T19-29-38-293Z','fixture_ids',jsonb_build_array(id_a::text,id_b::text,id_insert::text),
  'claim_mode','SET LOCAL ROLE + synthetic request.jwt.claims; no JWT signature/Auth test',
  'results',results,'cleanup','unconditional ROLLBACK; separate exact-ID absence query required')::text,true);
END
$probe$;
SELECT current_setting('smarthatch.security_probe_results')::jsonb AS security_probe;
ROLLBACK;
