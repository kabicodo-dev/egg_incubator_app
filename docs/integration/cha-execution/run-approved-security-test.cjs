// Explicitly approved TEST-only PostgreSQL role/RLS probe. No credentials are read/logged.
// All fixture writes use explicit negative IDs, one transaction and unconditional ROLLBACK.
const fs=require('node:fs');
const path=require('node:path');
const cp=require('node:child_process');
const crypto=require('node:crypto');
const assert=require('node:assert/strict');
const REF='zbwntspdecngnicllwlw',FORBIDDEN='suopuhgtwyqkpupzvdng';
const runId=new Date().toISOString().replace(/[:.]/g,'-');
const dir=path.join(__dirname,'security-run-'+runId);
fs.mkdirSync(dir);
const save=(name,x)=>fs.writeFileSync(path.join(dir,name),typeof x==='string'?x:JSON.stringify(x,null,2)+'\n');
function cli(args){
 // Arguments are constants or generated safe file paths; no tokens or user SQL strings.
 const quoted=args.map(a=>'"'+a.replace(/"/g,'')+'"').join(' ');
 const r=cp.spawnSync('powershell.exe',['-NoProfile','-NonInteractive','-Command','& supabase.cmd '+quoted],{encoding:'utf8',timeout:90000,maxBuffer:4*1024*1024});
 if(r.status!==0)throw new Error('CLI_FAILED: '+args[0]+' '+args[1]+'; exit='+r.status+'; '+String(r.stderr).replace(/Bearer\s+\S+/g,'[redacted]').slice(0,1200));
 if(r.stderr.includes('Initialising login role'))save('cli-role-initialization-note.txt','CLI emitted Initialising login role. This test requested no end-user provisioning; CLI-internal role side effects are not independently audited.\n');
 return JSON.parse(r.stdout.replace(/^\uFEFF/,''));
}
try{
 const projects=cli(['projects','list','--output','json']);
 const target=projects.find(p=>p.id===REF),application=projects.find(p=>p.id===FORBIDDEN);
 assert(target&&application,'Both exact project refs must be accessible in current CLI account');
 assert.equal(target.name,'smarthatch-test');assert.equal(target.status,'ACTIVE_HEALTHY');
 assert.equal(target.database.host,'db.'+REF+'.supabase.co');assert.equal(target.linked,false);
 assert.equal(application.name,'egg incubator');assert.equal(application.linked,true);
 assert.notEqual(target.id,application.id);
 save('verified-target.json',{observedAt:new Date().toISOString(),target:{id:target.id,name:target.name,status:target.status,host:target.database.host,url:'https://'+REF+'.supabase.co',linked:target.linked},application:{id:application.id,name:application.name,linked:application.linked},authorization:'User approved temporary test identities/records and exact-fixture cleanup; no migrations/RLS/RPC activation/deployment/production access. This probe requires no Auth user creation.'});
 const inventory=cli(['db','query','--linked','--project-ref',REF,'--file',path.join(__dirname,'2026-10-30-test-catalog.sql'),'--output','json']);
 save('fresh-catalog.json',inventory);
 const fresh=inventory.rows[0].audit;
 const previous=JSON.parse(fs.readFileSync(path.join(__dirname,'2026-10-30-test-catalog.json'),'utf8')).rows[0].audit;
 for(const k of ['tables','columns','policies','grants','default_acls','constraints','indexes']){
  const sorted=x=>JSON.stringify(x.map(v=>JSON.stringify(v)).sort());
  assert.equal(sorted(fresh[k]),sorted(previous[k]),'Unknown schema/security drift: '+k+'; stop before writes');
 }
 assert.equal(fresh.read_only,'on');
 if(process.argv[2]!=='--execute-approved-probe'){
  save('status.json',{status:'PREFLIGHT_PASSED',remote:'Catalog query only; no fixtures written',next:'Explicit --execute-approved-probe flag required'});
  console.log('PREFLIGHT_PASSED '+dir);process.exit(0);
 }
 const base=BigInt('0x'+crypto.randomBytes(6).toString('hex'))+100n;
 const ids=[0n,1n,2n].map(n=>String(-base-n));
 const userId=crypto.randomUUID();
 const sql=`-- Approved TEST-only probe. Ref ${REF}; run ${runId}.
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
 id_a bigint=${ids[0]}; id_b bigint=${ids[1]}; id_insert bigint=${ids[2]};
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
   PERFORM set_config('request.jwt.claims',jsonb_build_object('role',role_name,'sub','${userId}','is_anonymous',role_name='anon')::text,true);
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
  'target_ref','${REF}','run_id','${runId}','fixture_ids',jsonb_build_array(id_a::text,id_b::text,id_insert::text),
  'claim_mode','SET LOCAL ROLE + synthetic request.jwt.claims; no JWT signature/Auth test',
  'results',results,'cleanup','unconditional ROLLBACK; separate exact-ID absence query required')::text,true);
END
$probe$;
SELECT current_setting('smarthatch.security_probe_results')::jsonb AS security_probe;
ROLLBACK;
`;
 save('probe.sql',sql);
 const result=cli(['db','query','--linked','--project-ref',REF,'--file',path.join(dir,'probe.sql'),'--output','json']);
 save('probe-results.json',result);
 const probe=result.rows.find(r=>r.security_probe)?.security_probe;
 assert(probe&&probe.results.length===8,'Incomplete probe results');
 const verifySql=`BEGIN TRANSACTION READ ONLY;\nSELECT count(*)::int AS remaining_fixture_rows FROM public.sensor_readings WHERE id IN (${ids.join(',')});\nROLLBACK;\n`;
 save('verify-cleanup.sql',verifySql);
 const cleanup=cli(['db','query','--linked','--project-ref',REF,'--file',path.join(dir,'verify-cleanup.sql'),'--output','json']);
 save('cleanup-results.json',cleanup);
 assert.equal(cleanup.rows[0].remaining_fixture_rows,0,'Fixture cleanup not verified');
 const unexpected=probe.results.filter(r=>r.sqlstate&&r.sqlstate!=='42501');
 const allowed=probe.results.filter(r=>r.affected_fixture_rows>0);
 const status={status:unexpected.length?'PROBE_ERRORS':allowed.length?'SECURITY_GAPS_OBSERVED':'ROLE_PROBE_DENIED',
  count:8,allowedOnFixtures:allowed.length,denied:probe.results.filter(r=>r.sqlstate==='42501').length,
  zeroRows:probe.results.filter(r=>!r.sqlstate&&!r.affected_fixture_rows).length,unexpectedErrors:unexpected.length,
  rollbackCleanupVerified:true,remainingFixtureRows:0,authUsersCreated:0,scope:'Actual PostgreSQL roles/RLS on synthetic sensor fixtures; not Auth/JWT, approved installation, other tables, RPC behavior or end-to-end certification',
  stop:'Shared identity/source decisions and missing RPC implementation remain blocked. No grants/policies changed.'};
 save('status.json',status);console.log(JSON.stringify({directory:dir,...status},null,2));
}catch(e){save('error.json',{error:e.message,stopped:true,notes:'No broad cleanup attempted. If probe failed before result, transaction closes/rolls back; absence must be separately verified for any generated fixture IDs.'});console.error(e.message);process.exitCode=1;}
