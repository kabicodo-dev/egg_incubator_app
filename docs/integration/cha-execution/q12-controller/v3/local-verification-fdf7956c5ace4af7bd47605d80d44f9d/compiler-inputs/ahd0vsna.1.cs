using System;
using System.IO;
using System.Text;
using System.Security;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;

namespace SmartHatch.Q12.V3 {
  // Scalar native operations, not preconstructed Result objects: transport polling,
  // decoding, draining, state checks and deadlines are exercised above this boundary.
  public interface IPq : IDisposable {
    int Version { get; }
    void Start(Target t,SecureString password);
    int Poll(); int Status(); int Tx(); bool Ssl(); string Info(string name);
    int Nonblocking(); int Send(byte[] sql); int Flush(); int Consume(); int Busy();
    IntPtr Next(); int ResultStatus(IntPtr r); string Tag(IntPtr r); string SqlState(IntPtr r);
    int Rows(IntPtr r); int Fields(IntPtr r); string Name(IntPtr r,int column);
    int Oid(IntPtr r,int column); string Cell(IntPtr r,int row,int column);
    void Clear(IntPtr r);
  }
  public interface IClock { long Milliseconds { get; } void Pause(); }
  public sealed class RealClock : IClock {
    readonly Stopwatch clock=Stopwatch.StartNew();
    public long Milliseconds { get { return clock.ElapsedMilliseconds; } }
    public void Pause() { Thread.Sleep(10); }
  }
  public interface IRootGate { void Check(Target target); }
  public sealed class FileRootGate : IRootGate {
    readonly string approved;
    public FileRootGate(string approvedFileSha256) { approved=approvedFileSha256; }
    public void Check(Target t) {
      if(approved==null || !System.Text.RegularExpressions.Regex.IsMatch(approved,"\\A[0-9a-f]{64}\\z")) throw new Stop("CERTIFICATE_APPROVAL_MISSING");
      if(!File.Exists(t.Root) || Pin.Hash(File.ReadAllBytes(t.Root))!=approved) throw new Stop("CERTIFICATE_FINGERPRINT_MISMATCH");
    }
  }
  public interface ISession : IDisposable {
    void Connect(Target t,SecureString password);
    bool Usable { get; } bool Verified { get; } int State { get; } int LibraryVersion { get; }
    Result Execute(string exactSql);
  }
  public sealed class Session : ISession {
    readonly IPq api; readonly IClock clock; readonly IRootGate root; readonly bool permission;
    bool attempted,usable,verified,disposed;
    public Session(IPq native,IClock timer,IRootGate gate,bool explicitPermission) { api=native; clock=timer; root=gate; permission=explicitPermission; }
    public bool Usable { get { return usable && !disposed && api.Status()==0; } }
    public bool Verified { get { return verified; } }
    public int State { get { return disposed ? 4 : api.Tx(); } }
    public int LibraryVersion { get { return api.Version; } }
    public void Connect(Target t,SecureString password) {
      if(!permission) throw new Stop("EXECUTION_NOT_PERMITTED");
      if(attempted || disposed) throw new Stop("RECONNECT_FORBIDDEN");
      attempted=true; t.Check(); root.Check(t);
      long start=clock.Milliseconds; api.Start(t,password);
      while(true) {
        if(clock.Milliseconds-start>=10000) throw new Stop("CONNECT_DEADLINE");
        int status=api.Poll();
        if(status==3) break;
        if(status!=1 && status!=2 && status!=4) throw new Stop("AUTH_OR_TLS_REJECTED");
        clock.Pause();
      }
      if(api.Status()!=0 || !api.Ssl() || api.Info("host")!=Pin.Host || api.Info("port")!=Pin.Port ||
         api.Info("db")!=Pin.Database || api.Info("user")!=Pin.User || api.Info("readonly")!="on" || api.Tx()!=0)
        throw new Stop("CONNECTION_ATTESTATION_FAILED");
      if(api.Nonblocking()!=0) throw new Stop("NONBLOCKING_FAILED");
      usable=true; verified=true;
    }
    Result Decode(IntPtr r) {
      int status=api.ResultStatus(r); var result=new Result();
      if(status!=1 && status!=2) {
        result.Error=true; result.SqlState=CatalogPolicy.State(api.SqlState(r)); return result;
      }
      result.Tag=api.Tag(r); result.Count=api.Rows(r); int fields=api.Fields(r);
      if(result.Count<0 || fields<0 || fields>64) { result.Complete=false; return result; }
      if(result.Count>500) return result;
      result.Columns=new string[fields]; result.Oids=new int[fields]; result.Rows=new string[result.Count][];
      for(int j=0;j<fields;j++) { result.Columns[j]=api.Name(r,j); result.Oids[j]=api.Oid(r,j); }
      for(int i=0;i<result.Count;i++) {
        result.Rows[i]=new string[fields];
        for(int j=0;j<fields;j++) result.Rows[i][j]=api.Cell(r,i,j);
      }
      return result;
    }
    public Result Execute(string exactSql) {
      if(!Usable) throw new Stop("CONNECTION_LOST");
      if(api.Send(Encoding.UTF8.GetBytes(exactSql+"\0"))!=1) { usable=false; throw new Stop("SEND_FAILED"); }
      int count=0; Result result=null; long start=clock.Milliseconds;
      try {
        while(true) {
          if(clock.Milliseconds-start>=15000) throw new Stop("STATEMENT_CLIENT_DEADLINE");
          if(api.Flush()<0 || api.Consume()!=1 || api.Status()!=0) throw new Stop("CONNECTION_LOST");
          if(api.Busy()!=0) { clock.Pause(); continue; }
          IntPtr handle=api.Next(); if(handle==IntPtr.Zero) break;
          try { count++; if(count==1) result=Decode(handle); }
          finally { api.Clear(handle); }
        }
      } catch { usable=false; throw; }
      if(count!=1) throw new Stop("RESULT_STREAM_INVALID");
      return result;
    }
    public void Dispose() {
      if(disposed) return; disposed=true; usable=false; verified=false; api.Dispose();
    }
  }
  public sealed class NativePq : IPq {
    IntPtr conn=IntPtr.Zero; bool started;
    const string Dll="libpq.dll";
    [DllImport("kernel32",CharSet=CharSet.Unicode,SetLastError=true)] static extern IntPtr LoadLibraryEx(string p,IntPtr f,uint flags);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQlibVersion();
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQconnectStartParams(IntPtr[] k,IntPtr[] v,int expand);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQconnectPoll(IntPtr c);
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)] delegate void Notice(IntPtr arg,IntPtr r);
    static readonly Notice Discard=delegate(IntPtr a,IntPtr r) {};
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQsetNoticeReceiver(IntPtr c,Notice n,IntPtr a);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQstatus(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQtransactionStatus(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQsslInUse(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQhost(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQport(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQdb(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQuser(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQparameterStatus(IntPtr c,string name);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQsetnonblocking(IntPtr c,int on);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQsendQuery(IntPtr c,byte[] sql);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQflush(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQconsumeInput(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQisBusy(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQgetResult(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQresultStatus(IntPtr r);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQcmdStatus(IntPtr r);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQresultErrorField(IntPtr r,int code);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQntuples(IntPtr r);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQnfields(IntPtr r);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQfname(IntPtr r,int col);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQftype(IntPtr r,int col);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQgetisnull(IntPtr r,int row,int col);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQgetlength(IntPtr r,int row,int col);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQgetvalue(IntPtr r,int row,int col);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern void PQclear(IntPtr r);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern void PQfinish(IntPtr c);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQmakeEmptyPGresult(IntPtr c,int status);
    [StructLayout(LayoutKind.Sequential)] struct Attribute {
      public IntPtr name; public uint tableid; public int columnid,format; public uint typid; public int typlen,atttypmod;
    }
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQsetResultAttrs(IntPtr r,int count,Attribute[] attrs);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQsetvalue(IntPtr r,int row,int col,byte[] value,int length);
    static string Text(IntPtr p) { return p==IntPtr.Zero ? null : Marshal.PtrToStringAnsi(p); }
    static void Load() {
      if(LoadLibraryEx(Path.Combine(Pin.Bin,Dll),IntPtr.Zero,0x100|0x1000)==IntPtr.Zero) throw new Stop("LIBPQ_UNAVAILABLE");
    }
    public int Version { get { Load(); return PQlibVersion(); } }
    static IntPtr Password(SecureString secure) {
      IntPtr wide=Marshal.SecureStringToGlobalAllocUnicode(secure); var chars=new char[secure.Length]; byte[] bytes=null; IntPtr result=IntPtr.Zero;
      try {
        Marshal.Copy(wide,chars,0,chars.Length); foreach(char c in chars) if(c=='\0') throw new Stop("CREDENTIAL_INVALID");
        bytes=new UTF8Encoding(false,true).GetBytes(chars); result=Marshal.AllocHGlobal(bytes.Length+1);
        Marshal.Copy(bytes,0,result,bytes.Length); Marshal.WriteByte(result,bytes.Length,0); return result;
      } catch { if(result!=IntPtr.Zero) Marshal.ZeroFreeGlobalAllocAnsi(result); throw; }
      finally { Array.Clear(chars,0,chars.Length); if(bytes!=null) Array.Clear(bytes,0,bytes.Length); Marshal.ZeroFreeGlobalAllocUnicode(wide); }
    }
    public void Start(Target t,SecureString password) {
      if(started) throw new Stop("RECONNECT_FORBIDDEN"); started=true; t.Check();
      if(password==null || password.Length==0) throw new Stop("CREDENTIAL_MISSING");
      Load();
      string[] keys={"host","port","dbname","user","sslmode","sslrootcert","connect_timeout","options","application_name","client_encoding","passfile","password"};
      string[] values={t.Host,t.Port,t.Database,t.User,"verify-full",t.Root,"10","-c default_transaction_read_only=on","smarthatch-q12-phase-a-v2","UTF8","NUL",null};
      var k=new IntPtr[keys.Length+1]; var v=new IntPtr[keys.Length+1]; var env=new Dictionary<string,string>();
      try {
        foreach(System.Collections.DictionaryEntry e in Environment.GetEnvironmentVariables()) if(((string)e.Key).StartsWith("PG",StringComparison.OrdinalIgnoreCase)) env[(string)e.Key]=(string)e.Value;
        foreach(string name in env.Keys) Environment.SetEnvironmentVariable(name,null);
        for(int i=0;i<keys.Length;i++) { k[i]=Marshal.StringToHGlobalAnsi(keys[i]); v[i]=i==keys.Length-1 ? Password(password) : Marshal.StringToHGlobalAnsi(values[i]); }
        conn=PQconnectStartParams(k,v,0); if(conn==IntPtr.Zero) throw new Stop("NATIVE_START_FAILED");
        PQsetNoticeReceiver(conn,Discard,IntPtr.Zero);
      } finally {
        for(int i=0;i<keys.Length;i++) {
          if(k[i]!=IntPtr.Zero) Marshal.FreeHGlobal(k[i]);
          if(v[i]!=IntPtr.Zero) { if(i==keys.Length-1) Marshal.ZeroFreeGlobalAllocAnsi(v[i]); else Marshal.FreeHGlobal(v[i]); }
        }
        foreach(var pair in env) Environment.SetEnvironmentVariable(pair.Key,pair.Value);
      }
    }
    public int Poll() { return PQconnectPoll(conn); }
    public int Status() { return conn==IntPtr.Zero ? 1 : PQstatus(conn); }
    public int Tx() { return conn==IntPtr.Zero ? 4 : PQtransactionStatus(conn); }
    public bool Ssl() { return PQsslInUse(conn)==1; }
    public string Info(string n) {
      return Text(n=="host" ? PQhost(conn) : n=="port" ? PQport(conn) : n=="db" ? PQdb(conn) : n=="user" ? PQuser(conn) : PQparameterStatus(conn,"default_transaction_read_only"));
    }
    public int Nonblocking() { return PQsetnonblocking(conn,1); }
    public int Send(byte[] sql) { return PQsendQuery(conn,sql); }
    public int Flush() { return PQflush(conn); }
    public int Consume() { return PQconsumeInput(conn); }
    public int Busy() { return PQisBusy(conn); }
    public IntPtr Next() { return PQgetResult(conn); }
    public int ResultStatus(IntPtr r) { return PQresultStatus(r); }
    public string Tag(IntPtr r) { return Text(PQcmdStatus(r)); }
    public string SqlState(IntPtr r) { return Text(PQresultErrorField(r,67)); }
    public int Rows(IntPtr r) { return PQntuples(r); }
    public int Fields(IntPtr r) { return PQnfields(r); }
    public string Name(IntPtr r,int col) { return Text(PQfname(r,col)); }
    public int Oid(IntPtr r,int col) { return PQftype(r,col); }
    public string Cell(IntPtr r,int row,int col) {
      int length=PQgetlength(r,row,col); if(length<0 || length>16384) throw new Stop("NATIVE_CELL_LIMIT");
      if(PQgetisnull(r,row,col)==1) return null;
      var bytes=new byte[length]; Marshal.Copy(PQgetvalue(r,row,col),bytes,0,length); return new UTF8Encoding(false,true).GetString(bytes);
    }
    public void Clear(IntPtr r) { PQclear(r); }
    public void Dispose() { if(conn!=IntPtr.Zero) { PQfinish(conn); conn=IntPtr.Zero; } }
    // Actual local-native probe: NO PGconn, NO socket, NO SQL, NO credentials.
    public static int[] LocalProbe() {
      Load(); IntPtr r=PQmakeEmptyPGresult(IntPtr.Zero,2);
      if(r==IntPtr.Zero) throw new Stop("NATIVE_LOCAL_RESULT_FAILED");
      try { return new int[]{PQlibVersion(),PQresultStatus(r),PQntuples(r),PQnfields(r)}; }
      finally { PQclear(r); }
    }
    // Synthetic PGresult in local memory, NOT a database fixture or SQL operation.
    public static int[] LocalCountProbe(int count) {
      if(count!=500 && count!=501) throw new Stop("LOCAL_PROBE_COUNT_INVALID");
      Load(); IntPtr r=PQmakeEmptyPGresult(IntPtr.Zero,2); IntPtr name=Marshal.StringToHGlobalAnsi("local_probe");
      if(r==IntPtr.Zero) { Marshal.FreeHGlobal(name); throw new Stop("NATIVE_LOCAL_RESULT_FAILED"); }
      try {
        var attributes=new Attribute[]{new Attribute { name=name,typid=23,typlen=4,atttypmod=-1 }};
        if(PQsetResultAttrs(r,1,attributes)!=1) throw new Stop("NATIVE_LOCAL_RESULT_FAILED");
        for(int i=0;i<count;i++) if(PQsetvalue(r,i,0,new byte[]{49},1)!=1) throw new Stop("NATIVE_LOCAL_RESULT_FAILED");
        var api=new NativePq();
        return new int[]{api.Rows(r),api.Fields(r),api.Oid(r,0),api.Cell(r,count-1,0)=="1" ? 1 : 0};
      } finally { PQclear(r); Marshal.FreeHGlobal(name); }
    }
  }
}
