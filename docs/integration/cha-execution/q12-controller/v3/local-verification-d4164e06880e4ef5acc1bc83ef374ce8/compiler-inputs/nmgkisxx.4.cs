// New review regressions. Independent fixtures below do not derive schema from Shapes.
using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Web.Script.Serialization;

namespace SmartHatch.Q12.V3.Tests {
  public sealed class PrimaryFailureJournal : IJournal {
    readonly FileJournal files;
    public bool Failed;
    public PrimaryFailureJournal(string directory) { files=new FileJournal(directory); }
    public void Write(SafeEvent e) {
      if(e.Kind=="STATEMENT_RESULT" && e.Statement==6) Failed=true;
      if(Failed) throw new Stop("EVIDENCE_WRITE_FAILED");
      files.Write(e);
    }
    public void Emergency(SafeEvent e) { files.Emergency(e); }
    public void Dispose() { files.Dispose(); }
  }
  public static class Followup {
    public static List<Case> Cases=new List<Case>();
    public static Dictionary<string,object> References;
    public static string EmergencyOnlyDirectory;
    public static Dictionary<string,string> ActualSourceHashes;
    public static string ActualRunId;
    static RunContext AttributedContext() {
      var c=Fixtures.Context(); c.RunId=ActualRunId; c.SourceHashes=new Dictionary<string,string>(ActualSourceHashes); return c;
    }
    static void Require(bool condition) { if(!condition) throw new Exception("LOCAL_ASSERTION_FAILED"); }
    static void Test(string category,string name,Action body) {
      try { body(); Cases.Add(new Case { Category=category,Name=name,Status="PASS" }); }
      catch { Cases.Add(new Case { Category=category,Name=name,Status="FAIL" }); }
    }
    static void Reject(Action body,string code) {
      try { body(); throw new Exception("EXPECTED_REJECTION"); }
      catch(Stop s) { Require(s.Code==code); }
    }
    static Result DefaultAcl(string acl) {
      // PostgreSQL 17 bki: pg_get_userbyid returns name; CASE resolves name;
      // defaclobjtype char; defaclacl _aclitem FORCE NOT NULL.
      return new Result { Tag="SELECT 1",Count=1,
        Columns=new string[]{"owner","schema","defaclobjtype","defaclacl"},
        Oids=new int[]{19,19,18,1034},Rows=new string[][]{new string[]{"postgres","private","r",acl}} };
    }
    static Result Function(string resultType) {
      // Independent fixed 9-column shape from approved SELECT and PG17 catalogs.
      return new Result { Tag="SELECT 1",Count=1,
        Columns=new string[]{"nspname","proname","arguments","result_type","owner","prosecdef","provolatile","proconfig","proacl"},
        Oids=new int[]{19,19,25,25,19,16,18,1009,1034},
        Rows=new string[][]{new string[]{"public","bridge_sync_ingest_v1","p_submission jsonb, p_content_sha256 text",resultType,"smart_hatch_bridge_owner","t","v","{\"search_path=\\\"\\\"\"}",null}} };
    }
    static Result Constraint(string schema,string table,string name,string kind,string definition) {
      return new Result { Tag="SELECT 1",Count=1,Columns=new string[]{"nspname","relname","conname","contype","definition"},
        Oids=new int[]{19,19,19,18,25},Rows=new string[][]{new string[]{schema,table,name,kind,definition}} };
    }
    static int Line(string[] lines,string value) {
      for(int i=0;i<lines.Length;i++) if(lines[i].Contains(value)) return i+1;
      throw new Exception("REFERENCE_NOT_FOUND");
    }
    static Dictionary<string,object>[] Events(string path) {
      var result=new List<Dictionary<string,object>>();
      foreach(string line in File.ReadAllLines(path)) if(!String.IsNullOrWhiteSpace(line)) {
        var envelope=new JavaScriptSerializer().Deserialize<Dictionary<string,object>>(line);
        result.Add((Dictionary<string,object>)envelope["event"]);
      }
      return result.ToArray();
    }
    public static void Run(byte[] sql,string artifactDirectory) {
      Cases.Clear();
      Test("independent-pg17-reference","installed bki and manual confirm NOT NULL ACL, OIDs and procedure NULL",delegate {
        string bkiPath=@"C:\Program Files\PostgreSQL\17\share\postgres.bki";
        string infoPath=@"C:\Program Files\PostgreSQL\17\doc\src\sgml\html\functions-info.html";
        byte[] bkiBytes=File.ReadAllBytes(bkiPath), infoBytes=File.ReadAllBytes(infoPath);
        string full=new UTF8Encoding(false,true).GetString(bkiBytes);
        string[] bki=full.Replace("\r\n","\n").Split('\n'), info=new UTF8Encoding(false,true).GetString(infoBytes).Replace("\r\n","\n").Split('\n');
        int nonnull=Line(bki,"defaclacl = _aclitem FORCE NOT NULL");
        int procNull=Line(info,"FUNCTION</code>.  Returns <code class=\"literal\">NULL</code> for a procedure.");
        foreach(string pattern in new string[]{@"insert \( 19 name ",@"insert \( 25 text ",@"insert \( 18 char ",@"insert \( 1034 _aclitem ",@"insert \( 1009 _text "}) Require(Regex.IsMatch(full,pattern));
        Require(Encoding.UTF8.GetString(sql).Contains("pg_get_function_result(p.oid)") && !Encoding.UTF8.GetString(sql).Contains("p.prokind"));
        References=new Dictionary<string,object> {
          {"bkiPath",bkiPath},{"bkiSha256",Pin.Hash(bkiBytes)},{"notNullLine",nonnull},{"notNullExcerpt",bki[nonnull-1]},
          {"manualPath",infoPath},{"manualSha256",Pin.Hash(infoBytes)},{"procedureNullLine",procNull},{"procedureNullExcerpt",info[procNull-1]},
          {"interpretation","Approved SQL has no prokind filter: legitimate procedure rows can have NULL result_type. NULL alone does not prove kind."}
        };
      });
      Test("independent-schema","R1 independent default ACL NULL fixture rejected",delegate { Reject(delegate { Shapes.Check(DefaultAcl(null),15); },"RESULT_NULL_INVALID"); });
      Test("independent-schema","R1 independent non-null empty/default ACL fixtures accepted",delegate {
        Shapes.Check(DefaultAcl("{}"),15); Shapes.Check(DefaultAcl("{postgres=rw/postgres}"),15);
      });
      Test("independent-schema","procedure-compatible NULL result retained UNRESOLVED, not approved function",delegate {
        var r=Function(null); Shapes.Check(r,12); var cells=new CatalogPolicy().Export(r,12)[0].Cells;
        Require(cells[3].Value=="SQL_NULL_RETURN_TYPE_UNCLASSIFIED" && cells[3].Comparison=="UNRESOLVED");
        Require(cells[2].Comparison!="MATCH" && cells[4].Comparison!="MATCH" && cells[7].Comparison!="MATCH");
        ExportGuard.Check(new SafeEvent { Kind="STATEMENT_RESULT",Catalog=new CatalogPolicy().Export(r,12) });
      });
      foreach(int col in new int[]{0,1,2,4,5,6}) {
        int c=col; Test("independent-schema","procedure-compatible row still rejects unrelated NULL column "+c,delegate {
          var r=Function(null); r.Rows[0][c]=null; Reject(delegate { Shapes.Check(r,12); },"RESULT_NULL_INVALID");
        });
      }
      Test("independent-schema","procedure-compatible row rejects reordered and wrong-OID columns",delegate {
        var r=Function(null); r.Oids[3]=19; Reject(delegate { Shapes.Check(r,12); },"RESULT_COLUMNS_OR_TYPES_INVALID");
        r=Function(null); r.Columns[2]="result_type"; Reject(delegate { Shapes.Check(r,12); },"RESULT_COLUMNS_OR_TYPES_INVALID");
        r=Function(" "); Reject(delegate { Shapes.Check(r,12); },"RESULT_VALUE_INVALID");
      });
      foreach(string[] spec in new string[][] {
        new string[]{"controllers","db_imp_01_controller_disabled","CHECK ((active = false))"},
        new string[]{"controllers","db_imp_01_contract_disabled","CHECK ((contract_enabled = false))"},
        new string[]{"authorized_installations","db_imp_01_installation_disabled","CHECK ((active = false))"}
      }) {
        string[] s=spec; Test("constraint-full-identity","R2 exact identity and definition MATCH "+s[1],delegate {
          var r=Constraint("private",s[0],s[1],"c",s[2]); Shapes.Check(r,8); Require(new CatalogPolicy().Export(r,8)[0].Cells[4].Comparison=="MATCH");
        });
        foreach(int mode in new int[]{0,1,2,3}) {
          int m=mode; Test("constraint-full-identity","R2 wrong table/schema/kind/definition "+m+" "+s[1],delegate {
            var r=Constraint(m==1 ? "public" : "private",m==0 ? "wrong_relation" : s[0],s[1],m==2 ? "f" : "c",m==3 ? "CHECK (false)" : s[2]);
            Shapes.Check(r,8); Require(new CatalogPolicy().Export(r,8)[0].Cells[4].Comparison!="MATCH");
          });
        }
      }
      Test("constraint-full-identity","R2 cross-registry table and unsupported name never MATCH",delegate {
        var r=Constraint("private","authorized_installations","db_imp_01_controller_disabled","c","CHECK ((active = false))");
        Require(new CatalogPolicy().Export(r,8)[0].Cells[4].Comparison=="DIFFERENT");
        r=Constraint("private","controllers","unknown_constraint","c","CHECK ((active = false))");
        Require(new CatalogPolicy().Export(r,8)[0].Cells[4].Comparison=="UNRESOLVED");
      });
      Test("constraint-full-identity","R2 duplicate full identities are ambiguous even with matching text",delegate {
        var r=Constraint("private","controllers","db_imp_01_controller_disabled","c","CHECK ((active = false))");
        r.Count=2; r.Tag="SELECT 2"; r.Rows=new string[][]{r.Rows[0],(string[])r.Rows[0].Clone()};
        Shapes.Check(r,8); foreach(var row in new CatalogPolicy().Export(r,8)) Require(row.Cells[4].Comparison=="UNRESOLVED");
      });
      foreach(string version in new string[]{"17.11","15.8","17.6 (Debian 17.6-1.pgdg13+1)","17.6 (Ubuntu 17.6-1)","17.6 (Supabase 17.6.1)"}) {
        string v=version; Test("server-version","R4 valid server version numeric-only export "+v.Split(' ')[0],delegate {
          var api=new FakePq { AlterAt=4,Alter=delegate(Result r) { r.Rows[0][1]=v; } };
          var journal=new MemoryJournal(); var result=Controller.Run(sql,new Target(),Fixtures.Context(),new Session(api,new Clock(),new Root(),true),null,journal);
          Require(result.ServerVersion==v.Split(' ')[0] && result.Status=="EXECUTED_COMPARISON_PARTIAL_NOT_TASK_ACCEPTANCE");
          Require(!String.Join("\n",journal.Records.ToArray()).Contains("Debian"));
        });
      }
      foreach(string version in new string[]{"17.11 SECRET_TOKEN","17.11\nsecret","17","017.11","17.011","17.11 (untrusted secret)","17.11 (Debian SECRET_TOKEN)","17.11;DROP","secret",""}) {
        string v=version; Test("server-version","R4 malformed or unapproved server-version syntax rejected "+Array.IndexOf(new string[]{"17.11 SECRET_TOKEN","17.11\nsecret","17","017.11","17.011","17.11 (untrusted secret)","17.11 (Debian SECRET_TOKEN)","17.11;DROP","secret",""},v),delegate {
          var api=new FakePq { AlterAt=4,Alter=delegate(Result r) { r.Rows[0][1]=v; } };
          var journal=new MemoryJournal(); var result=Controller.Run(sql,new Target(),Fixtures.Context(),new Session(api,new Clock(),new Root(),true),null,journal);
          Require(result.Status=="STOPPED" && result.ServerVersion==null && api.Sent==6 && api.Statements[5]=="ROLLBACK;");
          string text=String.Join("\n",journal.Records.ToArray()); Require(!text.Contains("SECRET_TOKEN") && !text.Contains("DROP"));
        });
      }
      Test("emergency-file-only","R3 emergency preflight flushed before native start and survives primary unavailability",delegate {
        string directory=Path.Combine(artifactDirectory,"synthetic-emergency-only-recovery");
        var ctx=AttributedContext(); var api=new FakePq();
        api.BeforeStart=delegate {
          string text;
          // A concurrent reader must permit the already-open writer's access.
          using(var stream=new FileStream(Path.Combine(directory,"emergency.jsonl"),FileMode.Open,FileAccess.Read,FileShare.ReadWrite))
          using(var reader=new StreamReader(stream)) text=reader.ReadToEnd();
          Require(text.Contains(ctx.RunId) && text.Contains(ctx.ApprovalReference) && text.Contains(Pin.Project) && text.Contains(Pin.SqlHash));
        };
        Summary result;
        using(var journal=new PrimaryFailureJournal(directory)) result=Controller.Run(sql,new Target(),ctx,new Session(api,new Clock(),new Root(),true),null,journal);
        // Preserve the primary, but make it unavailable to the recovery assertion.
        File.Move(Path.Combine(directory,"journal.jsonl"),Path.Combine(directory,"primary-unavailable-preserved.jsonl"));
        Dictionary<string,object> preflight=null,terminal=null;
        foreach(var e in Events(Path.Combine(directory,"emergency.jsonl"))) {
          if((string)e["Kind"]=="PREFLIGHT") preflight=(Dictionary<string,object>)e["Preflight"];
          if((string)e["Kind"]=="FINAL_ROLLBACK_AND_CLOSE") terminal=(Dictionary<string,object>)e["Summary"];
        }
        Require(preflight!=null && terminal!=null && (string)preflight["runId"]==ctx.RunId && (string)terminal["RunId"]==ctx.RunId);
        Require((string)preflight["approvalReference"]==ctx.ApprovalReference && (string)preflight["sqlSha256"]==Pin.SqlHash);
        Require((string)preflight["host"]==Pin.Host && (string)preflight["user"]==Pin.User);
        var hashes=(Dictionary<string,object>)preflight["sourceHashes"]; Require(hashes.Count==RunContext.SourceNames.Length && hashes.ContainsKey("ModelPolicy.cs") && hashes.ContainsKey("Invoke-Q12PhaseA-V3.ps1"));
        foreach(var hash in ActualSourceHashes) Require((string)hashes[hash.Key]==hash.Value);
        Require((string)preflight["executionMode"]=="LOCAL_SYNTHETIC");
        Require((string)terminal["Rollback"]=="SERVER_ROLLBACK_TAG_CONFIRMED" && (string)terminal["FinalTransaction"]=="IDLE" && (bool)terminal["Closed"]);
        Require(!result.JournalDurable && result.Status=="STOPPED" && api.Sent==7);
        EmergencyOnlyDirectory=directory;
      });
      Test("emergency-file-only","R3 successful terminal state mirrored without primary failure",delegate {
        string dir=Path.Combine(artifactDirectory,"synthetic-emergency-success");
        using(var journal=new FileJournal(dir)) {
          var r=Controller.Run(sql,new Target(),AttributedContext(),new Session(new FakePq(),new Clock(),new Root(),true),null,journal);
          Require(r.JournalDurable);
        }
        bool preflight=false,terminal=false;
        foreach(var e in Events(Path.Combine(dir,"emergency.jsonl"))) { preflight|=(string)e["Kind"]=="PREFLIGHT"; terminal|=(string)e["Kind"]=="FINAL_ROLLBACK_AND_CLOSE"; }
        Require(preflight && terminal);
      });
      Test("emergency-file-only","R3 failed emergency attribution prevents any native start",delegate {
        var api=new FakePq(); var r=Controller.Run(sql,new Target(),Fixtures.Context(),new Session(api,new Clock(),new Root(),true),null,new MemoryJournal { FailEmergency=true });
        Require(api.Starts==0 && !r.JournalDurable && r.Status=="STOPPED");
      });
    }
  }
}
