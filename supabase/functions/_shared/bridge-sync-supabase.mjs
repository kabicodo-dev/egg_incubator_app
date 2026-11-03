import {BridgeError} from './bridge-sync-core.mjs';

// Real HTTP adapters for a separately provisioned isolated Supabase environment.
// No fake persistence fallback and no service-role credential. Required RPCs are
// not deployed by this source; missing schema/RPC/registry fails closed.
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
const MAIN_PROJECT='suopuhgtwyqkpupzvdng'; // public main project ref, NOT a credential
function unavailable() { return new BridgeError('SERVICE_UNAVAILABLE',503,{retryable:true}); }
function claimsFromVerifiedToken(token) {
  try {
    const parts=token.split('.');if(parts.length!==3)throw new Error();
    const base=parts[1].replace(/-/g,'+').replace(/_/g,'/');
    const bytes=Uint8Array.from(atob(base.padEnd(Math.ceil(base.length/4)*4,'=')),c=>c.charCodeAt(0));
    return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));
  } catch { throw new BridgeError('AUTHENTICATION_REQUIRED',401); }
}
export function createSupabasePorts({url,publishableKey,testProjectRef=null,fetchImpl=fetch,now=()=>Date.now()}) {
  let base;
  try {base=new URL(url);}catch {throw new Error('ISOLATED_SUPABASE_NOT_CONFIGURED');}
  const local=['127.0.0.1','localhost','[::1]'].includes(base.hostname);
  if(base.hostname===MAIN_PROJECT+'.supabase.co')throw new Error('MAIN_PROJECT_DISABLED_FOR_LOCAL_INTEGRATION');
  if(!local && (!testProjectRef || base.hostname!==testProjectRef+'.supabase.co' || base.protocol!=='https:'))throw new Error('ISOLATED_SUPABASE_NOT_CONFIGURED');
  if(local && !['http:','https:'].includes(base.protocol))throw new Error('ISOLATED_SUPABASE_NOT_CONFIGURED');
  if(base.username||base.password||base.search||base.hash||base.pathname!=='/'||!publishableKey)throw new Error('ISOLATED_SUPABASE_NOT_CONFIGURED');
  const origin=base.origin;
  async function rpc(identity,name,payload,{writing=false}={}) {
    let response;
    try {response=await fetchImpl(origin+'/rest/v1/rpc/'+name,{method:'POST',headers:{apikey:publishableKey,authorization:'Bearer '+identity.token,'content-type':'application/json'},body:JSON.stringify(payload)});}
    catch {throw new BridgeError(writing?'COMMIT_UNKNOWN':'SERVICE_UNAVAILABLE',503,{retryable:true,commitStatus:writing?'unknown':'not_persisted'});}
    if(response.status===401)throw new BridgeError('AUTHENTICATION_REQUIRED',401);
    if(response.status===403)throw new BridgeError('NOT_AUTHORIZED',403);
    // Map only fixed supported signals; never expose Postgres/PostgREST details.
    if(response.status===409)throw new BridgeError('IDENTITY_CONTENT_CONFLICT',409);
    if(!response.ok)throw new BridgeError('SERVICE_UNAVAILABLE',503,{retryable:true,commitStatus:writing?'unknown':'not_persisted'});
    try {return await response.json();}catch {throw new BridgeError('SERVICE_UNAVAILABLE',503,{retryable:true,commitStatus:writing?'unknown':'not_persisted'});}
  }
  return {
    async authenticate(request) {
      const header=request.headers.get('authorization')??'';
      if(!/^Bearer [A-Za-z0-9._~-]+$/.test(header))throw new BridgeError('AUTHENTICATION_REQUIRED',401);
      const token=header.slice(7);let response;
      try {response=await fetchImpl(origin+'/auth/v1/user',{headers:{apikey:publishableKey,authorization:'Bearer '+token}});}
      catch {throw unavailable();}
      if(response.status===401||response.status===403)throw new BridgeError('AUTHENTICATION_REQUIRED',401);
      if(!response.ok)throw unavailable();
      let user;try {user=await response.json();}catch {throw unavailable();}
      // Claims are decoded ONLY AFTER the trusted Supabase Auth server verified
      // this exact access token. Decoding by itself is never authentication.
      const claims=claimsFromVerifiedToken(token);
      if(!UUID.test(user.id??'')||user.is_anonymous!==false||claims.sub!==user.id||claims.role!=='authenticated'||!UUID.test(claims.session_id??'')||!Number.isFinite(claims.exp)||claims.exp*1000<=now()||claims.iss!==origin+'/auth/v1'||!(claims.aud==='authenticated'||Array.isArray(claims.aud)&&claims.aud.includes('authenticated')))throw new BridgeError('AUTHENTICATION_REQUIRED',401);
      return {userId:user.id,sessionId:claims.session_id,token};
    },
    async authorize(identity,body) {
      const result=await rpc(identity,'bridge_sync_authorize_v1',{p_installation_id:body.installation_id,p_device_id:body.device_id});
      if(result?.allowed!==true)throw new BridgeError('NOT_AUTHORIZED',403);
    },
    async ingest(identity,{body,hash}) {
      // The future reviewed PostgreSQL RPC must recheck Auth/session scope AND
      // canonical evidence/dependencies/dedup in one transaction. It must not
      // trust this supplied hash or a direct caller merely because Edge checked.
      return await rpc(identity,'bridge_sync_ingest_v1',{p_submission:body,p_content_sha256:hash},{writing:true});
    },
    async reconcile(identity,body,requestId) {
      return await rpc(identity,'bridge_sync_reconcile_v1',{p_query:body,p_request_id:requestId});
    },
  };
}
