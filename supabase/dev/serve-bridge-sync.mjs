// Actual loopback HTTP adapter for the shared handler. No .env file is loaded,
// no Supabase project is resumed/migrated, and no physical transport exists.
import http from 'node:http';
import {Readable} from 'node:stream';
import {pathToFileURL} from 'node:url';
import {BridgeError,createBridgeSyncHandler} from '../functions/_shared/bridge-sync-core.mjs';
import {createSupabasePorts} from '../functions/_shared/bridge-sync-supabase.mjs';

export async function listenBridge(handler,{port=0,afterHandle=null}={}) {
  const server=http.createServer(async(incoming,outgoing)=>{
    try {
      if(incoming.url!=='/functions/v1/bridge-sync'){outgoing.writeHead(404);outgoing.end();return;}
      const headers=new Headers();
      for(const [key,value] of Object.entries(incoming.headers))if(value!==undefined)headers.set(key,Array.isArray(value)?value.join(','):value);
      const init={method:incoming.method,headers};
      if(!['GET','HEAD'].includes(incoming.method)){init.body=Readable.toWeb(incoming);init.duplex='half';}
      const request=new Request('http://127.0.0.1'+incoming.url,init);
      const response=await handler(request);
      if(afterHandle&&await afterHandle(response)===false){outgoing.destroy();incoming.socket.destroy();return;}
      outgoing.writeHead(response.status,Object.fromEntries(response.headers));
      outgoing.end(Buffer.from(await response.arrayBuffer()));
    } catch {
      if(!outgoing.headersSent)outgoing.writeHead(503,{'content-type':'application/json','cache-control':'no-store'});
      outgoing.end(JSON.stringify({error:{code:'SERVICE_UNAVAILABLE'}}));
    }
  });
  await new Promise((resolve,reject)=>{server.once('error',reject);server.listen(port,'127.0.0.1',resolve);});
  const address=server.address();
  return {url:`http://127.0.0.1:${address.port}/functions/v1/bridge-sync`,close:()=>new Promise((resolve,reject)=>{
    server.close(error=>error?reject(error):resolve());server.closeAllConnections();
  })};
}

if(process.argv[1]&&import.meta.url===pathToFileURL(process.argv[1]).href) {
  let ports;
  try {ports=createSupabasePorts({url:process.env.SUPABASE_URL??'',publishableKey:process.env.SUPABASE_ANON_KEY??'',testProjectRef:process.env.BRIDGE_TEST_PROJECT_REF??null});}
  catch {ports={async authenticate(){throw new BridgeError('SERVICE_UNAVAILABLE',503,{retryable:true});}};}
  const port=Number(process.env.BRIDGE_PORT??8787);
  if(!Number.isInteger(port)||port<1||port>65535)throw new Error('INVALID_LOCAL_PORT');
  const service=await listenBridge(createBridgeSyncHandler({ports}),{port});
  console.log('Local bridge listening at '+service.url+'; controller source acceptance remains disabled.');
  for(const signal of ['SIGINT','SIGTERM'])process.once(signal,()=>{service.close().then(()=>process.exit(0));});
}
