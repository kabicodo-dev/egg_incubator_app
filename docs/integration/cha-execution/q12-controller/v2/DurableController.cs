using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Diagnostics;
using System.Security;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;
using System.Globalization;

namespace SmartHatch.Q12.V2 {
  public sealed class RunContext {
    public string ApprovalReference, CertificateFileSha256, CertificateDerSha256, PowerShellVersion;
    public Dictionary<string,string> SourceHashes=new Dictionary<string,string>();
    public const string RegistryHash="6d8e11d72f28bb6291184fea2227d20adb3dc9d73761517d86a87abe5517644b";
    public const string AuthorizationHash="258fad0aa091e6e5b7ba6bb660df84a2269aa0f326ecb72706eec6fb26e764d0";
    public const string RpcHash="dcb065fac25e2b26366d424bb236020185aaba92d23115e49fdd2584289eec4a";
    public static readonly string[] SourceNames={"ModelPolicy.cs","NativeBoundary.cs","DurableController.cs","Invoke-Q12PhaseA-V2.ps1","Correction.Tests.cs","Test-Corrections.ps1"};
    public void Check() {
      if(ApprovalReference==null || !Regex.IsMatch(ApprovalReference,"\\AQ12-PA-[0-9]{8}-[0-9]{2}\\z")) throw new Stop("PROVENANCE_INVALID");
      if(!Hex(CertificateFileSha256) || !Hex(CertificateDerSha256) || SourceHashes.Count!=SourceNames.Length || PowerShellVersion==null || !Regex.IsMatch(PowerShellVersion,"\\A[0-9]+(?:\\.[0-9]+){1,3}\\z")) throw new Stop("PROVENANCE_INVALID");
      foreach(string n in SourceNames) if(!SourceHashes.ContainsKey(n) || !Hex(SourceHashes[n])) throw new Stop("PROVENANCE_INVALID");
    }
    public static bool Hex(string s) { return s!=null && Regex.IsMatch(s,"\\A[0-9a-f]{64}\\z"); }
  }
  public sealed class Summary {
    public string Status="STOPPED", Failure, Rollback="NOT_APPLICABLE", FinalTransaction="UNAVAILABLE";
    public string StartedUtc=DateTime.UtcNow.ToString("o"), EndedUtc;
    public bool Closed, JournalDurable=true, TableQueryComplete, CompleteCatalogVerification=false;
    public int LastStatement;
    public string[] DraftPresence;
  }
  public sealed class SafeEvent {
    public string Kind, Utc=DateTime.UtcNow.ToString("o"), Status, SqlState, CommandTag;
    public int Statement, Rows, TransactionState=4;
    public long ElapsedMilliseconds;
    public string[] Columns;
    public SafeRow[] Catalog;
    public Summary Summary;
    public Dictionary<string,object> Preflight;
    public string ApprovalReference;
    public Dictionary<string,string> PreparationSourceHashes;
  }
  public interface IJournal : IDisposable { void Write(SafeEvent record); void Emergency(SafeEvent record); }
  public sealed class FileJournal : IJournal {
    FileStream main,emergency;
    readonly JavaScriptSerializer json=new JavaScriptSerializer { MaxJsonLength=8388608 };
    int sequence;
    public FileJournal(string freshDirectory) {
      try {
        Directory.CreateDirectory(freshDirectory);
        main=new FileStream(Path.Combine(freshDirectory,"journal.jsonl"),FileMode.CreateNew,FileAccess.Write,FileShare.Read);
        emergency=new FileStream(Path.Combine(freshDirectory,"emergency.jsonl"),FileMode.CreateNew,FileAccess.Write,FileShare.Read);
        // Prove both destinations accept flushed writes BEFORE any connection.
        WriteTo(main,new SafeEvent { Kind="EVIDENCE_DESTINATION_READY" });
        WriteTo(emergency,new SafeEvent { Kind="EMERGENCY_DESTINATION_READY" });
      } catch { Dispose(); throw new Stop("EVIDENCE_DESTINATION_UNWRITABLE"); }
    }
    void WriteTo(FileStream stream,SafeEvent record) {
      ExportGuard.Check(record);
      string encoded=json.Serialize(new Dictionary<string,object> { {"sequence",++sequence},{"event",record} });
      byte[] data=new UTF8Encoding(false,true).GetBytes(encoded+"\n");
      if(data.Length>8388608) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
      stream.Write(data,0,data.Length); stream.Flush(true);
    }
    public void Write(SafeEvent record) { try { WriteTo(main,record); } catch { throw new Stop("EVIDENCE_WRITE_FAILED"); } }
    public void Emergency(SafeEvent record) { try { WriteTo(emergency,record); } catch { throw new Stop("EMERGENCY_EVIDENCE_FAILED"); } }
    public void Dispose() { if(main!=null) { main.Dispose(); main=null; } if(emergency!=null) { emergency.Dispose(); emergency=null; } }
  }
  public static class Controller {
    static readonly HashSet<string> Codes=new HashSet<string>(("SQL_HASH_MISMATCH SQL_SPLIT_FAILED SQL_BYTES_CHANGED TARGET_MISMATCH TLS_CONFIGURATION_MISMATCH PROVENANCE_INVALID EXECUTION_NOT_PERMITTED RECONNECT_FORBIDDEN CERTIFICATE_APPROVAL_MISSING CERTIFICATE_FINGERPRINT_MISMATCH CONNECT_DEADLINE AUTH_OR_TLS_REJECTED CONNECTION_ATTESTATION_FAILED NONBLOCKING_FAILED CONNECTION_LOST SEND_FAILED STATEMENT_CLIENT_DEADLINE RESULT_STREAM_INVALID NATIVE_CELL_LIMIT CREDENTIAL_MISSING CREDENTIAL_INVALID LIBPQ_UNAVAILABLE NATIVE_START_FAILED INCOMPLETE_RESULT SQL_ERROR COMMAND_SHAPE_INVALID COMMAND_TAG_INVALID QUERY_OVERFLOW RESULT_SHAPE_INVALID RESULT_COLUMNS_OR_TYPES_INVALID RESULT_NULL_INVALID RESULT_VALUE_INVALID RESULT_BOOLEAN_INVALID RESULT_ENUM_INVALID RESULT_IDENTIFIER_INVALID ARRAY_FORMAT_INVALID TRANSACTION_GUARD_FAILED TRANSACTION_STATE_INVALID POST_ROLLBACK_NOT_IDLE EVIDENCE_WRITE_FAILED EVIDENCE_SERIALIZATION_FAILED EVIDENCE_DESTINATION_UNWRITABLE EMERGENCY_EVIDENCE_FAILED CONNECTION_CLOSE_UNCONFIRMED").Split(' '));
    public static string Failure(Exception ex) { var stop=ex as Stop; return stop!=null && Codes.Contains(stop.Code) ? stop.Code : "UNEXPECTED_LOCAL_FAILURE"; }
    public static bool SafeStatus(string s) { return s==null || Codes.Contains(s) || s=="UNEXPECTED_LOCAL_FAILURE" || s=="VALIDATED" || s=="SERVER_ROLLBACK_TAG_CONFIRMED"; }
    static int State(ISession session) { try { return session.State; } catch { return 4; } }
    static Dictionary<string,object> Manifest(RunContext ctx,int version) {
      return new Dictionary<string,object> {
        {"approvalReference",ctx.ApprovalReference},{"phase","Q12 A ONLY"},{"project",Pin.Project},{"host",Pin.Host},
        {"port",Pin.Port},{"database",Pin.Database},{"user",Pin.User},{"sslmode","verify-full"},{"certificatePath",Pin.Root},
        {"certificateFileSha256",ctx.CertificateFileSha256},{"certificateDerSha256",ctx.CertificateDerSha256},
        {"sqlSha256",Pin.SqlHash},{"sourceHashes",ctx.SourceHashes},{"runtime",Environment.Version.ToString()},{"powershell",ctx.PowerShellVersion},
        {"libpqVersion",version},{"registryDraftSha256",RunContext.RegistryHash},{"authorizationDraftSha256",RunContext.AuthorizationHash},
        {"rpcDraftSha256",RunContext.RpcHash},{"baselineStatus","UNAPPROVED_DRAFT_COMPARATOR_NOT_ADOPTION"}
      };
    }
    public static Summary Run(byte[] sqlBytes,Target target,RunContext ctx,ISession session,SecureString password,IJournal journal) {
      var summary=new Summary(); var policy=new CatalogPolicy();
      bool connected=false,started=false,rollbackAttempted=false;
      try {
        string[] sql=Pin.Sql(sqlBytes); target.Check(); ctx.Check();
        journal.Write(new SafeEvent { Kind="PREFLIGHT",Preflight=Manifest(ctx,session.LibraryVersion) });
        session.Connect(target,password); connected=true;
        if(!session.Verified || !session.Usable || session.State!=0) throw new Stop("CONNECTION_ATTESTATION_FAILED");
        journal.Write(new SafeEvent { Kind="CONNECTED_VERIFIED",TransactionState=0 });
        for(int index=0;index<sql.Length;index++) {
          if(!session.Usable) throw new Stop("CONNECTION_LOST");
          if(index>0 && session.State!=2) throw new Stop("TRANSACTION_STATE_INVALID");
          journal.Write(new SafeEvent { Kind="STATEMENT_INTENT", Statement=index+1,TransactionState=State(session) });
          summary.LastStatement=index+1;
          if(index==0) started=true;
          if(index==16) rollbackAttempted=true;
          Result result=null; var timer=Stopwatch.StartNew();
          try {
            result=session.Execute(sql[index]); Shapes.Check(result,index);
            if(index==16) {
              summary.Rollback="SERVER_ROLLBACK_TAG_CONFIRMED";
              if(session.State!=0) { summary.FinalTransaction="NOT_IDLE"; throw new Stop("POST_ROLLBACK_NOT_IDLE"); }
              summary.FinalTransaction="IDLE";
            } else if(session.State!=2) throw new Stop("TRANSACTION_STATE_INVALID");
            SafeRow[] rows=policy.Export(result,index);
            journal.Write(new SafeEvent { Kind="STATEMENT_RESULT",Statement=index+1,Rows=result.Count,Status="VALIDATED",
              SqlState=CatalogPolicy.State(result.SqlState),CommandTag=result.Tag,ElapsedMilliseconds=timer.ElapsedMilliseconds,TransactionState=State(session),
              Columns=index>=4 && index<=15 ? Array.ConvertAll(Shapes.Queries[index-4],delegate(Field f) { return f.Name; }) : new string[0],Catalog=rows });
            if(index==6) summary.TableQueryComplete=true;
          } catch(Exception ex) {
            try { journal.Write(new SafeEvent { Kind="STATEMENT_FAILURE",Statement=index+1,Status=Failure(ex),
              Rows=result==null ? 0 : result.Count,SqlState=result==null ? null : CatalogPolicy.State(result.SqlState),
              ElapsedMilliseconds=timer.ElapsedMilliseconds,TransactionState=State(session) }); }
            catch { summary.JournalDurable=false; }
            throw;
          }
        }
        summary.Status="EXECUTED_COMPARISON_PARTIAL_NOT_TASK_ACCEPTANCE";
      } catch(Exception ex) {
        summary.Failure=Failure(ex); summary.Status="STOPPED";
        if(summary.Failure.StartsWith("EVIDENCE") || summary.Failure=="EMERGENCY_EVIDENCE_FAILED") summary.JournalDurable=false;
      } finally {
        if(started && summary.Rollback!="SERVER_ROLLBACK_TAG_CONFIRMED") {
          summary.Rollback="UNAVAILABLE";
          try {
            if(connected && !rollbackAttempted && session.Usable && (session.State==2 || session.State==3)) {
              rollbackAttempted=true;
              Result rollback=session.Execute("ROLLBACK;"); Shapes.Check(rollback,16);
              summary.Rollback="SERVER_ROLLBACK_TAG_CONFIRMED";
              summary.FinalTransaction=session.State==0 ? "IDLE" : "NOT_IDLE";
              var rb=new SafeEvent { Kind="FAILURE_CLEANUP_ROLLBACK",CommandTag="ROLLBACK",Status=summary.Rollback,TransactionState=State(session) };
              try { journal.Write(rb); }
              catch {
                summary.JournalDurable=false;
                try { journal.Emergency(rb); } catch { /* final summary explicitly reports durable evidence failure */ }
              }
            }
          } catch { summary.Rollback="UNAVAILABLE"; }
        }
        try { session.Dispose(); summary.Closed=true; }
        catch { summary.Closed=false; summary.Status="STOPPED"; summary.Failure="CONNECTION_CLOSE_UNCONFIRMED"; }
        summary.EndedUtc=DateTime.UtcNow.ToString("o");
        summary.DraftPresence=policy.DraftPresence(summary.TableQueryComplete);
        if(summary.FinalTransaction=="NOT_IDLE") summary.Status="STOPPED";
        var final=new SafeEvent { Kind="FINAL_ROLLBACK_AND_CLOSE",Summary=summary };
        try { journal.Write(final); }
        catch {
          summary.JournalDurable=false; summary.Status="STOPPED"; summary.Failure="EVIDENCE_WRITE_FAILED";
          try { journal.Emergency(final); } catch { summary.Failure="EMERGENCY_EVIDENCE_FAILED"; }
        }
        if(!summary.JournalDurable && summary.Status!="STOPPED") { summary.Status="STOPPED"; summary.Failure="EVIDENCE_WRITE_FAILED"; }
      }
      return summary;
    }
  }
  public static class ExportGuard {
    static bool Utc(string value) {
      DateTime time; return value!=null && DateTime.TryParseExact(value,"o",CultureInfo.InvariantCulture,DateTimeStyles.RoundtripKind,out time) && time.Kind==DateTimeKind.Utc;
    }
    public static void Check(SafeEvent e) {
      if(e==null || !Utc(e.Utc) || Array.IndexOf(new string[]{"EVIDENCE_DESTINATION_READY","EMERGENCY_DESTINATION_READY","LOCAL_PREFLIGHT","PREFLIGHT","CONNECTED_VERIFIED","STATEMENT_INTENT","STATEMENT_RESULT","STATEMENT_FAILURE","FAILURE_CLEANUP_ROLLBACK","FINAL_ROLLBACK_AND_CLOSE","LOCAL_PREPARATION_COMPLETE","LAUNCHER_FAILURE"},e.Kind)<0 ||
        !Controller.SafeStatus(e.Status) || (e.SqlState!=null && CatalogPolicy.State(e.SqlState)==null) ||
        (e.CommandTag!=null && !Regex.IsMatch(e.CommandTag,"\\A(?:BEGIN|SET|ROLLBACK|SELECT [0-9]{1,3})\\z"))) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
      if(e.Columns!=null) foreach(string col in e.Columns) {
        bool known=false; foreach(var query in Shapes.Queries) foreach(var f in query) if(f.Name==col) known=true;
        if(!known) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
      }
      if(e.Catalog!=null) foreach(var row in e.Catalog) foreach(var cell in row.Cells) {
        if(!CatalogPolicy.SafeValue(cell.Value) || Array.IndexOf(new string[]{"MATCH","DIFFERENT","UNRESOLVED","ALLOWLISTED_IDENTIFIER","ALLOWLISTED_TYPE","OBSERVED_NOT_BASELINE_APPROVAL"},cell.Comparison)<0 ||
          (cell.Baseline!=null && Array.IndexOf(new string[]{"disabled_registry:active_false","disabled_registry:contract_false","disabled_registry:default_false","authorization_draft:owner_policy_true","empty_function_search_path","approved_transaction_guard","draft_private_tables_rls_forced","authorization_draft_function_owner","rpc_draft_function_owner","approved_function_identity_arguments"},cell.Baseline)<0)) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
      }
      if(e.Preflight!=null) {
        string[] names={"approvalReference","phase","project","host","port","database","user","sslmode","certificatePath","certificateFileSha256","certificateDerSha256","sqlSha256","sourceHashes","runtime","powershell","libpqVersion","registryDraftSha256","authorizationDraftSha256","rpcDraftSha256","baselineStatus"};
        if(e.Preflight.Count!=names.Length) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
        foreach(string n in names) if(!e.Preflight.ContainsKey(n)) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
        var p=e.Preflight;
        if((string)p["phase"]!="Q12 A ONLY" || (string)p["project"]!=Pin.Project || (string)p["host"]!=Pin.Host || (string)p["port"]!=Pin.Port || (string)p["database"]!=Pin.Database || (string)p["user"]!=Pin.User || (string)p["sslmode"]!="verify-full" || (string)p["certificatePath"]!=Pin.Root || (string)p["sqlSha256"]!=Pin.SqlHash || (string)p["baselineStatus"]!="UNAPPROVED_DRAFT_COMPARATOR_NOT_ADOPTION" ||
          !Regex.IsMatch((string)p["approvalReference"],"\\AQ12-PA-[0-9]{8}-[0-9]{2}\\z") || !Regex.IsMatch((string)p["runtime"],"\\A[0-9]+(?:\\.[0-9]+){1,3}\\z") || !Regex.IsMatch((string)p["powershell"],"\\A[0-9]+(?:\\.[0-9]+){1,3}\\z") || !(p["libpqVersion"] is int)) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
        foreach(string name in new string[]{"certificateFileSha256","certificateDerSha256","registryDraftSha256","authorizationDraftSha256","rpcDraftSha256"}) if(!RunContext.Hex((string)p[name])) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
        var hashes=(Dictionary<string,string>)p["sourceHashes"];
        if(hashes.Count!=RunContext.SourceNames.Length) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
        foreach(string name in RunContext.SourceNames) if(!hashes.ContainsKey(name) || !RunContext.Hex(hashes[name])) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
      }
      if(e.ApprovalReference!=null && !Regex.IsMatch(e.ApprovalReference,"\\AQ12-PA-[0-9]{8}-[0-9]{2}\\z")) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
      if(e.PreparationSourceHashes!=null) {
        if(e.PreparationSourceHashes.Count!=RunContext.SourceNames.Length) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
        foreach(string name in RunContext.SourceNames) if(!e.PreparationSourceHashes.ContainsKey(name) || !RunContext.Hex(e.PreparationSourceHashes[name])) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
      }
      if(e.Summary!=null) {
        var s=e.Summary;
        if(!Utc(s.StartedUtc) || !Utc(s.EndedUtc) || Array.IndexOf(new string[]{"STOPPED","EXECUTED_COMPARISON_PARTIAL_NOT_TASK_ACCEPTANCE"},s.Status)<0 || !Controller.SafeStatus(s.Failure) ||
           Array.IndexOf(new string[]{"NOT_APPLICABLE","UNAVAILABLE","SERVER_ROLLBACK_TAG_CONFIRMED"},s.Rollback)<0 ||
           Array.IndexOf(new string[]{"UNAVAILABLE","IDLE","NOT_IDLE"},s.FinalTransaction)<0) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
        if(s.DraftPresence!=null) foreach(string presence in s.DraftPresence) if(!Regex.IsMatch(presence,"\\Aprivate\\.(?:controllers|authorized_installations|enrollment_audit):(?:UNRESOLVED|MATCH_PRESENT_NAME_ONLY|DIFFERENT_ABSENT_FROM_DRAFT)\\z")) throw new Stop("EVIDENCE_SERIALIZATION_FAILED");
      }
    }
  }
  // Validates an OWNER ATTESTATION's structure; cannot authenticate its origin.
  // The independent trusted-origin procedure remains a separate human gate.
  public sealed class CertificateApproval {
    public string FileSha256,DerSha256;
    public static CertificateApproval Read(string json,string approvalReference) {
      try {
        // Deliberately narrow flat-string record: no escaped/duplicate keys,
        // nested values, comments or ambiguous last-key-wins interpretation.
        string pair="\"[A-Za-z0-9]+\"\\s*:\\s*\"[^\"\\\\\\x00-\\x1f]*\"";
        if(json==null || !Regex.IsMatch(json,"\\A\\s*\\{\\s*"+pair+"(?:\\s*,\\s*"+pair+")*\\s*\\}\\s*\\z")) throw new Stop("CERTIFICATE_APPROVAL_MISSING");
        var seen=new HashSet<string>();
        foreach(Match m in Regex.Matches(json,"\"([A-Za-z0-9]+)\"\\s*:")) if(!seen.Add(m.Groups[1].Value)) throw new Stop("CERTIFICATE_APPROVAL_MISSING");
        var data=new JavaScriptSerializer().Deserialize<Dictionary<string,object>>(json);
        string[] keys={"status","projectRef","sourceUrl","verificationMethod","verifiedAtUtc","approvalReference","fileSha256","derSha256"};
        if(data==null || data.Count!=keys.Length) throw new Stop("CERTIFICATE_APPROVAL_MISSING");
        foreach(string key in keys) if(!data.ContainsKey(key) || !(data[key] is string)) throw new Stop("CERTIFICATE_APPROVAL_MISSING");
        DateTime when;
        if((string)data["status"]!="OWNER_VERIFIED_TRUSTED_ORIGIN" || (string)data["projectRef"]!=Pin.Project ||
          (string)data["sourceUrl"]!="https://supabase.com/dashboard/project/zbwntspdecngnicllwlw/database/settings" ||
          (string)data["verificationMethod"]!="AUTHENTICATED_SOURCE_AND_INDEPENDENT_TRUSTED_FINGERPRINT" ||
          (string)data["approvalReference"]!=approvalReference || !Regex.IsMatch(approvalReference,"\\AQ12-PA-[0-9]{8}-[0-9]{2}\\z") ||
          !DateTime.TryParseExact((string)data["verifiedAtUtc"],"yyyy-MM-dd'T'HH:mm:ss'Z'",CultureInfo.InvariantCulture,DateTimeStyles.AdjustToUniversal|DateTimeStyles.AssumeUniversal,out when) ||
          when>DateTime.UtcNow || !RunContext.Hex((string)data["fileSha256"]) || !RunContext.Hex((string)data["derSha256"])) throw new Stop("CERTIFICATE_APPROVAL_MISSING");
        return new CertificateApproval { FileSha256=(string)data["fileSha256"],DerSha256=(string)data["derSha256"] };
      } catch { throw new Stop("CERTIFICATE_APPROVAL_MISSING"); }
    }
  }
}
