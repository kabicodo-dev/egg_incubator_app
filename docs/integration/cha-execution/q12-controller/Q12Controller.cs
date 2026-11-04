// Q12 Phase A only. No application imports, installations, automatic reconnect,
// extra SQL, or remote work at module load. Compile with Windows PowerShell Add-Type.
using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Security;
using System.Security.Cryptography;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;

namespace SmartHatch.Q12 {
  public sealed class SafetyException : Exception {
    public readonly string Code;
    public SafetyException(string code) : base(code) { Code = code; }
  }
  public sealed class Target {
    public const string Ref = "zbwntspdecngnicllwlw";
    public const string Host = "aws-0-ap-northeast-1.pooler.supabase.com";
    public const string User = "postgres.zbwntspdecngnicllwlw";
    public const string Certificate = @"C:\Users\Mary Charlyn\Downloads\prod-ca-2021.crt";
    public readonly string Project, Server, Username, Database, Port, SslMode, Root;
    public Target(string project, string server, string user, string database,
                  string port, string sslMode, string root) {
      Project=project; Server=server; Username=user; Database=database;
      Port=port; SslMode=sslMode; Root=root;
    }
    public static Target Approved() {
      return new Target(Ref,Host,User,"postgres","5432","verify-full",Certificate);
    }
    public void Validate() {
      if(Project!=Ref || Server!=Host || Username!=User || Database!="postgres" || Port!="5432")
        throw new SafetyException("TARGET_MISMATCH");
      if(SslMode!="verify-full" || Root!=Certificate)
        throw new SafetyException("TLS_CONFIGURATION_MISMATCH");
    }
  }
  public sealed class ApprovedSql {
    public const string Hash = "9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc";
    public readonly string[] Statements;
    private ApprovedSql(string[] statements) { Statements=statements; }
    public static string Digest(byte[] bytes) {
      using(var sha=SHA256.Create()) return BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-","").ToLowerInvariant();
    }
    public static ApprovedSql Load(byte[] bytes) {
      if(Digest(bytes)!=Hash) throw new SafetyException("SQL_HASH_MISMATCH");
      string text=new UTF8Encoding(false,true).GetString(bytes);
      // Intentionally limited lexer for the ONE hash-pinned script, not arbitrary SQL.
      // Preserve every byte (including comments/whitespace), splitting only at
      // semicolons outside single quotes and line comments. Unsupported syntax fails.
      var pieces=new List<string>(); bool quoted=false, comment=false; int start=0;
      for(int i=0;i<text.Length;i++) {
        char ch=text[i];
        if(comment) { if(ch=='\n') comment=false; continue; }
        if(quoted) {
          if(ch=='\'') { if(i+1<text.Length && text[i+1]=='\'') i++; else quoted=false; }
          continue;
        }
        if(ch=='-' && i+1<text.Length && text[i+1]=='-') { comment=true; i++; continue; }
        if(ch=='\'') { quoted=true; continue; }
        if(ch==';') { pieces.Add(text.Substring(start,i-start+1)); start=i+1; }
      }
      if(quoted || !String.IsNullOrWhiteSpace(text.Substring(start))) throw new SafetyException("SQL_BOUNDARY_INVALID");
      // Attach trailing whitespace so concatenation is byte-identical to input.
      if(pieces.Count!=17) throw new SafetyException("SQL_STATEMENT_COUNT_INVALID");
      pieces[pieces.Count-1]+=text.Substring(start);
      string[] statements=pieces.ToArray();
      if(String.Concat(statements)!=text) throw new SafetyException("SQL_RECONSTRUCTION_FAILED");
      return new ApprovedSql(statements);
    }
  }
  // libpq transaction states: idle=0, active=1, in-transaction=2, failed=3, unknown=4.
  public sealed class Result {
    public string Tag, SqlState;
    public bool Tuples, Complete=true, Error;
    public int RowCount;
    public string[] Columns=new string[0];
    public string[][] Rows=new string[0][];
  }
  public interface ISession : IDisposable {
    void Connect(Target target, SecureString password);
    bool VerifiedConnection { get; }
    bool Usable { get; }
    int TransactionState { get; }
    Result Execute(string exactStatement);
  }
  public sealed class Entry {
    public int Statement, Rows;
    public string Tag, Status;
    // No server strings, errors, identifiers, expressions or credentials are saved.
    // Fully withheld cell values are deliberate, not a complete semantic catalog audit.
    public string[][] RedactedRows;
  }
  public sealed class Report {
    public string Scope="Q12 PHASE A ONLY", SqlSha256=ApprovedSql.Hash;
    public string Status="NOT_STARTED", FailureCode, Rollback="NOT_APPLICABLE";
    public string FinalState="UNAVAILABLE", EvidencePolicy="All returned cell values withheld; counts and validated command tags only";
    public string ProjectRef=Target.Ref;
    public bool RemoteExecution=false, ConnectionVerified, Closed;
    public int LastAttemptedStatement;
    public List<Entry> Entries=new List<Entry>();
  }
  public static class Controller {
    private static string[][] Redact(Result r) {
      // Do not attempt regex-based secret discovery in arbitrary catalog metadata.
      var rows=new string[r.Rows.Length][];
      for(int i=0;i<rows.Length;i++) {
        rows[i]=new string[r.Columns.Length];
        for(int j=0;j<rows[i].Length;j++) rows[i][j]="[WITHHELD]";
      }
      return rows;
    }
    private static void CheckResult(Result r, int index) {
      if(r==null || !r.Complete) throw new SafetyException("INCOMPLETE_RESULT");
      if(r.Error) {
        string state=r.SqlState;
        throw new SafetyException(state=="57014" ? "STATEMENT_TIMEOUT_OR_CANCEL" :
                                  state=="55P03" ? "LOCK_TIMEOUT_OR_UNAVAILABLE" : "SQL_STATEMENT_FAILED");
      }
      bool select=index>=4 && index<=15;
      string expected=index==0 ? "BEGIN" : index<=3 ? "SET" : index==16 ? "ROLLBACK" : "SELECT "+r.RowCount;
      if(r.Tuples!=select || r.Tag!=expected) throw new SafetyException("UNEXPECTED_COMMAND_STATUS");
      if(select) {
        if(r.RowCount<0 || r.RowCount>500) throw new SafetyException("QUERY_OVERFLOW");
        if(r.Columns==null || r.Columns.Length==0 || r.Columns.Length>64 ||
           r.Rows==null || r.Rows.Length!=r.RowCount) throw new SafetyException("INCOMPLETE_RESULT");
        foreach(string[] row in r.Rows) if(row==null || row.Length!=r.Columns.Length)
          throw new SafetyException("INCOMPLETE_RESULT");
      } else if(r.RowCount!=0) throw new SafetyException("UNEXPECTED_COMMAND_STATUS");
    }
    public static Report Run(byte[] bytes, Target target, ISession session,
                             SecureString password, bool isRemote) {
      var report=new Report(); report.RemoteExecution=isRemote;
      bool connected=false, started=false, rollbackAttempted=false;
      try {
        var sql=ApprovedSql.Load(bytes); target.Validate();
        session.Connect(target,password); connected=true;
        if(!session.VerifiedConnection || !session.Usable || session.TransactionState!=0)
          throw new SafetyException("CONNECTION_NOT_VERIFIED_IDLE");
        report.ConnectionVerified=true;
        for(int i=0;i<sql.Statements.Length;i++) {
          if(!session.Usable) throw new SafetyException("CONNECTION_LOST");
          if(i>0 && session.TransactionState!=2) throw new SafetyException("TRANSACTION_STATE_INVALID");
          if(i==0) started=true;
          if(i==16) rollbackAttempted=true;
          report.LastAttemptedStatement=i+1;
          Result r=session.Execute(sql.Statements[i]);
          report.Entries.Add(new Entry { Statement=i+1, Rows=r==null ? 0 : r.RowCount,
            Tag=r!=null && r.Tag!=null && Regex.IsMatch(r.Tag,"^(BEGIN|SET|ROLLBACK|SELECT [0-9]+)$") ? r.Tag : "[WITHHELD]",
            Status="RECEIVED_NOT_VALIDATED", RedactedRows=new string[0][] });
          CheckResult(r,i);
          if(i==4) {
            if(r.RowCount!=1 || r.Columns.Length!=4 ||
               r.Columns[0]!="connection_role" || r.Columns[1]!="server_version" ||
               r.Columns[2]!="read_only" || r.Columns[3]!="isolation" ||
               r.Rows[0][0]!="postgres" || r.Rows[0][2]!="on" || r.Rows[0][3]!="repeatable read")
              throw new SafetyException("READ_ONLY_ISOLATION_OR_ROLE_MISMATCH");
          }
          int state=session.TransactionState;
          if(i==16) {
            report.Rollback="SERVER_ROLLBACK_TAG_CONFIRMED";
            if(state!=0) throw new SafetyException("POST_ROLLBACK_NOT_IDLE");
            report.FinalState="IDLE";
          } else if(state!=2) throw new SafetyException("TRANSACTION_STATE_INVALID");
          report.Entries[report.Entries.Count-1].Status="VALIDATED";
          report.Entries[report.Entries.Count-1].RedactedRows=Redact(r);
        }
        report.Status="INSPECTION_EXECUTED_NOT_TASK_ACCEPTANCE";
      } catch(SafetyException ex) {
        report.Status="STOPPED"; report.FailureCode=ex.Code;
      } catch {
        report.Status="STOPPED"; report.FailureCode="UNEXPECTED_LOCAL_FAILURE";
      } finally {
        if(started && report.Rollback!="SERVER_ROLLBACK_TAG_CONFIRMED") {
          report.Rollback="UNAVAILABLE";
          try {
            if(connected && !rollbackAttempted && session.Usable &&
               (session.TransactionState==2 || session.TransactionState==3)) {
              rollbackAttempted=true;
              Result cleanup=session.Execute("ROLLBACK;"); // Sole permitted failure cleanup.
              CheckResult(cleanup,16);
              report.Rollback="SERVER_ROLLBACK_TAG_CONFIRMED";
              if(session.TransactionState==0) report.FinalState="IDLE";
              else report.FinalState="NOT_IDLE";
            }
          } catch { report.Rollback="UNAVAILABLE"; }
        }
        try { session.Dispose(); report.Closed=true; }
        catch { report.Closed=false; report.Status="STOPPED"; report.FailureCode="CONNECTION_CLOSE_UNCONFIRMED"; }
      }
      return report;
    }
  }

  // Native adapter: uses existing PostgreSQL 17 libpq, not psql text parsing.
  // No network call occurs until Connect; caller must explicitly permit remote use.
  public sealed class LibpqSession : ISession {
    private const string Bin=@"C:\Program Files\PostgreSQL\17\bin";
    private const string Dll="libpq.dll";
    private IntPtr conn=IntPtr.Zero;
    private bool verified, usable, attempted;
    private readonly bool permitted;
    public LibpqSession(bool explicitRemotePermission) { permitted=explicitRemotePermission; }
    [DllImport("kernel32",CharSet=CharSet.Unicode,SetLastError=true)]
    static extern IntPtr LoadLibraryEx(string path,IntPtr file,uint flags);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQconnectStartParams(IntPtr[] keys,IntPtr[] values,int expand);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQconnectPoll(IntPtr c);
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)] delegate void NoticeReceiver(IntPtr arg,IntPtr result);
    private static readonly NoticeReceiver DiscardNotice=delegate(IntPtr arg,IntPtr result) {};
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQsetNoticeReceiver(IntPtr c,NoticeReceiver callback,IntPtr arg);
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
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQgetisnull(IntPtr r,int row,int col);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern int PQgetlength(IntPtr r,int row,int col);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern IntPtr PQgetvalue(IntPtr r,int row,int col);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern void PQclear(IntPtr r);
    [DllImport(Dll,CallingConvention=CallingConvention.Cdecl)] static extern void PQfinish(IntPtr c);
    private static string Text(IntPtr ptr) {
      return ptr==IntPtr.Zero ? null : Marshal.PtrToStringAnsi(ptr);
    }
    public bool Usable { get { return usable && conn!=IntPtr.Zero && PQstatus(conn)==0; } }
    public bool VerifiedConnection { get { return verified; } }
    public int TransactionState { get { return conn==IntPtr.Zero ? 4 : PQtransactionStatus(conn); } }
    private static IntPtr PasswordUtf8(SecureString password) {
      IntPtr wide=Marshal.SecureStringToGlobalAllocUnicode(password);
      var chars=new char[password.Length]; byte[] bytes=null;
      try {
        Marshal.Copy(wide,chars,0,chars.Length);
        foreach(char ch in chars) if(ch=='\0') throw new SafetyException("CREDENTIAL_ENCODING_UNSUPPORTED");
        bytes=new UTF8Encoding(false,true).GetBytes(chars);
        IntPtr ptr=Marshal.AllocHGlobal(bytes.Length+1);
        Marshal.Copy(bytes,0,ptr,bytes.Length); Marshal.WriteByte(ptr,bytes.Length,0);
        return ptr;
      } finally {
        Array.Clear(chars,0,chars.Length);
        if(bytes!=null) Array.Clear(bytes,0,bytes.Length);
        Marshal.ZeroFreeGlobalAllocUnicode(wide);
      }
    }
    public void Connect(Target target,SecureString password) {
      if(!permitted) throw new SafetyException("REMOTE_EXECUTION_NOT_PERMITTED");
      if(attempted) throw new SafetyException("RECONNECT_FORBIDDEN");
      attempted=true; target.Validate();
      if(password==null || password.Length==0) throw new SafetyException("CREDENTIAL_UNAVAILABLE");
      if(!File.Exists(target.Root)) throw new SafetyException("CERTIFICATE_UNAVAILABLE");
      // Pin DLL directory, including dependencies. Never use a repository DLL.
      if(LoadLibraryEx(Path.Combine(Bin,Dll),IntPtr.Zero,0x00000100|0x00001000)==IntPtr.Zero)
        throw new SafetyException("LIBPQ_UNAVAILABLE");
      string[] keys={"host","port","dbname","user","sslmode","sslrootcert","connect_timeout",
                     "options","application_name","client_encoding","passfile","password"};
      string[] vals={target.Server,target.Port,target.Database,target.Username,"verify-full",target.Root,"10",
                     "-c default_transaction_read_only=on","smarthatch-q12-phase-a","UTF8","NUL",null};
      var k=new IntPtr[keys.Length+1]; var v=new IntPtr[keys.Length+1];
      // Clear inherited PG* settings only for connection setup, restore afterwards.
      // Password remains a SecureString/unmanaged temporary, never a managed string.
      var env=new Dictionary<string,string>();
      try {
        foreach(System.Collections.DictionaryEntry e in Environment.GetEnvironmentVariables()) {
          string name=(string)e.Key;
          if(name.StartsWith("PG",StringComparison.OrdinalIgnoreCase)) env[name]=(string)e.Value;
        }
        foreach(string name in env.Keys) Environment.SetEnvironmentVariable(name,null);
        for(int i=0;i<keys.Length;i++) {
          k[i]=Marshal.StringToHGlobalAnsi(keys[i]);
          v[i]=i==keys.Length-1 ? PasswordUtf8(password) : Marshal.StringToHGlobalAnsi(vals[i]);
        }
        conn=PQconnectStartParams(k,v,0);
        if(conn==IntPtr.Zero) throw new SafetyException("AUTH_OR_TLS_CONNECTION_FAILED");
        // Install before authentication polling so even startup notices cannot leak.
        PQsetNoticeReceiver(conn,DiscardNotice,IntPtr.Zero);
        var connectClock=Stopwatch.StartNew();
        while(true) {
          if(connectClock.ElapsedMilliseconds>10000) throw new SafetyException("CONNECTION_TIMEOUT");
          int poll=PQconnectPoll(conn);
          if(poll==3) break;
          if(poll==0) throw new SafetyException("AUTH_OR_TLS_CONNECTION_FAILED");
          Thread.Sleep(10);
        }
      } finally {
        for(int i=0;i<keys.Length;i++) {
          if(k[i]!=IntPtr.Zero) Marshal.FreeHGlobal(k[i]);
          if(v[i]!=IntPtr.Zero) { if(i==keys.Length-1) Marshal.ZeroFreeGlobalAllocAnsi(v[i]); else Marshal.FreeHGlobal(v[i]); }
        }
        foreach(var e in env) Environment.SetEnvironmentVariable(e.Key,e.Value);
      }
      // Never call PQerrorMessage: libpq errors may include sensitive server text.
      if(conn==IntPtr.Zero || PQstatus(conn)!=0) throw new SafetyException("AUTH_OR_TLS_CONNECTION_FAILED");
      if(PQsslInUse(conn)!=1 || Text(PQhost(conn))!=target.Server || Text(PQport(conn))!=target.Port ||
         Text(PQdb(conn))!=target.Database || Text(PQuser(conn))!=target.Username ||
         Text(PQparameterStatus(conn,"default_transaction_read_only"))!="on")
        throw new SafetyException("CONNECTION_VERIFICATION_FAILED");
      if(PQsetnonblocking(conn,1)!=0) throw new SafetyException("NONBLOCKING_MODE_FAILED");
      usable=true; verified=true;
    }
    private void Pump(Stopwatch clock) {
      if(clock.ElapsedMilliseconds>15000) { usable=false; throw new SafetyException("CLIENT_DEADLINE_CONNECTION_UNUSABLE"); }
      if(PQflush(conn)<0 || PQconsumeInput(conn)!=1 || PQstatus(conn)!=0) {
        usable=false; throw new SafetyException("CONNECTION_LOST");
      }
    }
    private static Result ReadResult(IntPtr r) {
      int status=PQresultStatus(r);
      var result=new Result();
      if(status!=1 && status!=2) {
        result.Error=true;
        string state=Text(PQresultErrorField(r,67)); // PG_DIAG_SQLSTATE only.
        result.SqlState=state!=null && Regex.IsMatch(state,"^[0-9A-Z]{5}$") ? state : null;
        return result;
      }
      result.Tuples=status==2; result.Tag=Text(PQcmdStatus(r));
      int count=PQntuples(r), fields=PQnfields(r); result.RowCount=count;
      if(count>500) return result; // Count from protocol, never a parsed footer.
      if(fields>64 || count<0) { result.Complete=false; return result; }
      result.Columns=new string[fields]; result.Rows=new string[count][];
      for(int j=0;j<fields;j++) result.Columns[j]=Text(PQfname(r,j));
      for(int i=0;i<count;i++) {
        result.Rows[i]=new string[fields];
        for(int j=0;j<fields;j++) {
          int length=PQgetlength(r,i,j);
          if(length>16384) { result.Complete=false; return result; }
          if(PQgetisnull(r,i,j)!=1) {
            var bytes=new byte[length]; Marshal.Copy(PQgetvalue(r,i,j),bytes,0,length);
            result.Rows[i][j]=new UTF8Encoding(false,true).GetString(bytes);
          }
        }
      }
      return result;
    }
    public Result Execute(string sql) {
      if(!Usable) throw new SafetyException("CONNECTION_LOST");
      var bytes=Encoding.UTF8.GetBytes(sql+"\0");
      if(PQsendQuery(conn,bytes)!=1) { usable=false; throw new SafetyException("QUERY_SEND_FAILED"); }
      var clock=Stopwatch.StartNew(); Result result=null; int count=0;
      try {
        while(true) {
          Pump(clock);
          if(PQisBusy(conn)==1) { Thread.Sleep(10); continue; }
          IntPtr r=PQgetResult(conn); if(r==IntPtr.Zero) break;
          try { count++; if(count==1) result=ReadResult(r); }
          finally { PQclear(r); }
        }
      } catch { usable=false; throw; }
      if(count!=1 || result==null) throw new SafetyException("INCOMPLETE_OR_MULTIPLE_RESULTS");
      return result;
    }
    public void Dispose() {
      usable=false; verified=false;
      if(conn!=IntPtr.Zero) { PQfinish(conn); conn=IntPtr.Zero; }
    }
  }
}
