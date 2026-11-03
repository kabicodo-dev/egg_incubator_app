// Candidate Edge entrypoint. NOT deployed. Active source adapters and PostgreSQL
// RPCs are not enabled/created by adding this file. No service-role key needed.
import {BridgeError, createBridgeSyncHandler} from '../_shared/bridge-sync-core.mjs';
import {createSupabasePorts} from '../_shared/bridge-sync-supabase.mjs';

let handler: (request: Request) => Promise<Response>;
try {
  const ports=createSupabasePorts({
    url:Deno.env.get('SUPABASE_URL')??'',
    publishableKey:Deno.env.get('SUPABASE_ANON_KEY')??'',
    testProjectRef:Deno.env.get('BRIDGE_TEST_PROJECT_REF')??null,
  });
  handler=createBridgeSyncHandler({ports}); // default source adapter FAILS CLOSED
} catch {
  handler=createBridgeSyncHandler({ports:{
    async authenticate() { throw new BridgeError('SERVICE_UNAVAILABLE',503,{retryable:true}); },
  }});
}
Deno.serve(handler);
