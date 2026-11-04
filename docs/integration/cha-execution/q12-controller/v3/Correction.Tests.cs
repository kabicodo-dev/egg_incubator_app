// Test categories are explicit. FakePq does not open sockets or load libpq.
using System;
using System.IO;
using System.Text;
using System.Security;
using System.Collections.Generic;
using System.Web.Script.Serialization;

namespace SmartHatch.Q12.V3.Tests {
  public sealed class Clock : IClock {
    public long Now; public int Pauses;
    public long Milliseconds { get { return Now; } }
    public void Pause() { Now+=1000; Pauses++; }
  }
  public sealed class Root : IRootGate {
    public bool Reject;
    public void Check(Target t) { if(Reject) throw new Stop("CERTIFICATE_FINGERPRINT_MISMATCH"); }
  }
  public static class Fixtures {
    public static Result Row(int index,int count) {
      if(index<4 || index==16) return new Result { Tag=index==0 ? "BEGIN" : index==16 ? "ROLLBACK" : "SET" };
      Field[] fields=Shapes.Queries[index-4]; var r=new Result { Tag="SELECT "+count, Count=count,Columns=new string[fields.Length],Oids=new int[fields.Length],Rows=new string[count][] };
      for(int j=0;j<fields.Length;j++) { r.Columns[j]=fields[j].Name; r.Oids[j]=fields[j].Oids[0]; }
      for(int i=0;i<count;i++) {
        var row=new string[fields.Length];
        for(int j=0;j<fields.Length;j++) {
          var f=fields[j];
          row[j]=f.Kind=="identifier" ? "postgres" : f.Kind=="boolean" ? "f" : f.Kind.StartsWith("enum:") ? f.Kind.Substring(5).Split('|')[0] : f.Kind=="roles" ? "{authenticated}" : f.Kind=="acl" ? "{postgres=rw/postgres,authenticated=r/postgres}" : f.Kind=="config" ? "{\"search_path=\\\"\\\"\"}" : "SENSITIVE_PASSWORD_AND_TOKEN";
        }
        if(index==4) row=new string[]{"postgres","17.11","on","repeatable read"};
        if(index==5) row[0]="private";
        if(index==6) { row[0]="private"; row[1]="controllers"; }
        if(index==7) { row[0]="private"; row[1]="controllers"; row[2]="active"; row[3]="boolean"; row[7]="false"; }
        if(index==8) { row[0]="private"; row[1]="controllers"; row[2]="db_imp_01_controller_disabled"; row[4]="CHECK ((active = false))"; }
        if(index==10) { row[0]="private"; row[1]="controllers"; row[2]="db_imp_01_owner_read_controllers"; row[6]="true"; row[7]=null; }
        r.Rows[i]=row;
      }
      return r;
    }
    public static RunContext Context() {
      var ctx=new RunContext { ApprovalReference="Q12-PA-20261031-01",CertificateFileSha256=new string('a',64),CertificateDerSha256=new string('b',64),PowerShellVersion="5.1.26100.9711",RunId="0123456789abcdef0123456789abcdef" };
      foreach(string name in RunContext.SourceNames) ctx.SourceHashes[name]=new string('c',64);
      return ctx;
    }
  }
  public sealed class FakePq : IPq {
    public int Starts,State,Closed,Sent,ClearCount,CountReads,CellReads,NonblockingCalls;
    public int AlterAt=-1,FailAt=-1,DisconnectAt=-1,BusyAt=-1,SendFailAt=-1,ExtraAt=-1,MissingAt=-1;
    public int PendingPolls=2;
    public bool RejectTls,NoSsl,WrongUser,BadReadonly,BadInitialState,BadNonblocking,FailRollback,BadFinalState,ThrowClose;
    public bool ConnectNeverReady,BadConnection;
    public string ErrorCode="42501";
    public Action<Result> Alter;
    public List<string> Statements=new List<string>();
    public Target SeenTarget;
    public Action BeforeStart;
    public Queue<int> PollSequence;
    Result current; int queued,position;
    public int Version { get { return 170011; } }
    public void Start(Target t,SecureString password) { if(BeforeStart!=null) BeforeStart(); Starts++; if(Starts>1) throw new Exception("RECONNECTED"); SeenTarget=t; State=BadInitialState ? 2 : 0; }
    public int Poll() { if(PollSequence!=null && PollSequence.Count>0) return PollSequence.Dequeue(); if(RejectTls) return 0; if(ConnectNeverReady) return 1; if(PendingPolls-->0) return PendingPolls%2==0 ? 2 : 1; return 3; }
    public int Status() { return BadConnection ? 1 : 0; }
    public int Tx() { return State; }
    public bool Ssl() { return !NoSsl; }
    public string Info(string name) { return name=="host" ? Pin.Host : name=="port" ? Pin.Port : name=="db" ? Pin.Database : name=="user" ? (WrongUser ? "wrong" : Pin.User) : BadReadonly ? "off" : "on"; }
    public int Nonblocking() { NonblockingCalls++; return BadNonblocking ? 1 : 0; }
    public int Send(byte[] sql) {
      string text=Encoding.UTF8.GetString(sql,0,sql.Length-1); position=Statements.Count; Statements.Add(text); Sent++;
      bool rollback=text.Trim()=="ROLLBACK;";
      int index=rollback ? 16 : position;
      if(index==SendFailAt) return 0;
      current=Fixtures.Row(index,index>=4 && index<=15 ? 1 : 0);
      State=1; // Native ACTIVE while the command/result stream is pending.
      if(index==FailAt || (rollback && FailRollback)) current=new Result { Error=true,SqlState=ErrorCode,Tag="SENSITIVE_PASSWORD_AND_TOKEN" };
      if(index==AlterAt && Alter!=null) Alter(current);
      queued=index==MissingAt ? 0 : index==ExtraAt ? 2 : 1;
      return 1;
    }
    public int Flush() { return 0; }
    public int Consume() { if(position==DisconnectAt) { BadConnection=true; State=4; return 0; } return 1; }
    public int Busy() { return position==BusyAt ? 1 : 0; }
    public IntPtr Next() {
      if(queued--<=0) { State=current.Error ? 3 : current.Tag=="ROLLBACK" ? (BadFinalState ? 2 : 0) : 2; return IntPtr.Zero; }
      State=current.Error ? 3 : current.Tag=="ROLLBACK" ? (BadFinalState ? 2 : 0) : 2;
      return new IntPtr(queued+1);
    }
    public int ResultStatus(IntPtr r) { return current.Error ? 7 : current.Columns.Length==0 ? 1 : 2; }
    public string Tag(IntPtr r) { return current.Tag; }
    public string SqlState(IntPtr r) { return current.SqlState; }
    public int Rows(IntPtr r) { CountReads++; return current.Count; }
    public int Fields(IntPtr r) { return current.Columns.Length; }
    public string Name(IntPtr r,int j) { return current.Columns[j]; }
    public int Oid(IntPtr r,int j) { return current.Oids[j]; }
    public string Cell(IntPtr r,int i,int j) { CellReads++; return current.Rows[i][j]; }
    public void Clear(IntPtr r) { ClearCount++; }
    public void Dispose() { Closed++; if(ThrowClose) throw new Exception("SENSITIVE_PASSWORD_AND_TOKEN"); }
  }
  public sealed class MemoryJournal : IJournal {
    public List<string> Records=new List<string>(); public int Writes,EmergencyWrites;
    public string FailKind; public bool FailAll,FailEmergency;
    public void Write(SafeEvent e) {
      Writes++; if(FailAll || e.Kind==FailKind) throw new Stop("EVIDENCE_WRITE_FAILED");
      ExportGuard.Check(e); Records.Add(new JavaScriptSerializer().Serialize(e));
    }
    public void Emergency(SafeEvent e) { EmergencyWrites++; if(FailEmergency) throw new Stop("EMERGENCY_EVIDENCE_FAILED"); ExportGuard.Check(e); Records.Add(new JavaScriptSerializer().Serialize(e)); }
    public void Dispose() {}
  }
  public sealed class Case { public string Category,Name,Status; }
  public static class Suite {
    public static List<Case> Cases=new List<Case>();
    public static int[] NativeProbe;
    public static Summary Example;
    public static string[] ExampleJournal;
    static byte[] bytes; static string directory;
    static void Require(bool v) { if(!v) throw new Exception("LOCAL_ASSERTION_FAILED"); }
    static void Test(string category,string name,Action action) {
      try { action(); Cases.Add(new Case { Category=category,Name=name,Status="PASS" }); }
      catch { Cases.Add(new Case { Category=category,Name=name,Status="FAIL" }); }
    }
    static void Stops(Action action,string code) {
      try { action(); throw new Exception("EXPECTED_STOP"); }
      catch(Stop ex) { Require(ex.Code==code); }
    }
    static Summary Run(FakePq api,MemoryJournal journal) {
      return Controller.Run(bytes,new Target(),Fixtures.Context(),new Session(api,new Clock(),new Root(),true),null,journal);
    }
    static string All(MemoryJournal j) { return String.Join("\n",j.Records.ToArray()); }
    public static void RunAll(byte[] approved,string artifactDirectory) {
      bytes=approved; directory=artifactDirectory; Cases.Clear();
      Test("controller","approved hash and 17 unchanged sequential statements",delegate {
        string[] statements=Pin.Sql(bytes); Require(statements.Length==17 && String.Concat(statements)==Encoding.UTF8.GetString(bytes));
        var api=new FakePq(); var journal=new MemoryJournal(); var r=Run(api,journal);
        Require(r.Status=="EXECUTED_COMPARISON_PARTIAL_NOT_TASK_ACCEPTANCE" && r.Rollback=="SERVER_ROLLBACK_TAG_CONFIRMED" && r.FinalTransaction=="IDLE");
        Require(api.Starts==1 && api.Closed==1 && api.Statements.Count==17);
        for(int i=0;i<17;i++) Require(api.Statements[i]==statements[i]);
        Example=r; ExampleJournal=journal.Records.ToArray();
      });
      Test("controller","hash mismatch prevents all connection attempts",delegate {
        var changed=(byte[])bytes.Clone(); changed[0]^=1; var api=new FakePq();
        var r=Controller.Run(changed,new Target(),Fixtures.Context(),new Session(api,new Clock(),new Root(),true),null,new MemoryJournal());
        Require(r.Failure=="SQL_HASH_MISMATCH" && api.Starts==0);
      });
      for(int f=0;f<7;f++) {
        int n=f; Test("controller","target/TLS fixed field rejection "+n,delegate {
          var t=new Target(); if(n==0)t.Project="suopuhgtwyqkpupzvdng"; if(n==1)t.Host="wrong"; if(n==2)t.User="wrong"; if(n==3)t.Port="6543"; if(n==4)t.Database="wrong"; if(n==5)t.SslMode="require"; if(n==6)t.Root="wrong";
          var api=new FakePq(); var r=Controller.Run(bytes,t,Fixtures.Context(),new Session(api,new Clock(),new Root(),true),null,new MemoryJournal()); Require(r.Status=="STOPPED" && api.Starts==0);
        });
      }
      for(int query=4;query<=15;query++) {
        int q=query;
        Test("shape","valid exact column/OID/value shape for query "+(q+1),delegate { Shapes.Check(Fixtures.Row(q,1),q); });
        for(int change=0;change<5;change++) {
          int c=change; Test("shape","rectangular missing/extra/reordered/type/representation "+c+" query "+(q+1),delegate {
            var r=Fixtures.Row(q,1);
            if(c==0) { r.Columns=new string[r.Columns.Length-1]; r.Oids=new int[r.Oids.Length-1]; r.Rows=new string[][]{new string[r.Columns.Length]}; }
            if(c==1) { Array.Resize(ref r.Columns,r.Columns.Length+1); Array.Resize(ref r.Oids,r.Oids.Length+1); r.Rows=new string[][]{new string[r.Columns.Length]}; }
            if(c==2) { string swap=r.Columns[0]; r.Columns[0]=r.Columns[1]; r.Columns[1]=swap; }
            if(c==3) r.Oids[0]=99999;
            if(c==4) r.Rows[0][0]=null;
            bool stopped=false; try { Shapes.Check(r,q); } catch(Stop) { stopped=true; } Require(stopped);
          });
        }
      }
      Test("shape","boolean, enum and array representations fail closed",delegate {
        var r=Fixtures.Row(6,1); r.Rows[0][4]="true"; Stops(delegate { Shapes.Check(r,6); },"RESULT_BOOLEAN_INVALID");
        r=Fixtures.Row(6,1); r.Rows[0][2]="secret"; Stops(delegate { Shapes.Check(r,6); },"RESULT_ENUM_INVALID");
        r=Fixtures.Row(10,1); r.Rows[0][5]="{\"unterminated}"; Stops(delegate { Shapes.Check(r,10); },"ARRAY_FORMAT_INVALID");
      });
      Test("shape","read-only and isolation mismatch stops before any catalog query",delegate {
        foreach(int col in new int[]{2,3}) {
          var api=new FakePq { AlterAt=4,Alter=delegate(Result rr) { rr.Rows[0][col]="off"; } };
          var r=Run(api,new MemoryJournal()); Require(r.Failure=="TRANSACTION_GUARD_FAILED" && api.Statements.Count==6 && api.Statements[5]=="ROLLBACK;");
        }
      });
      for(int mutation=0;mutation<4;mutation++) {
        int m=mutation; Test("native-api-mock","malformed rectangular catalog result stops whole controller "+m,delegate {
          var api=new FakePq { AlterAt=5,Alter=delegate(Result rr) {
            if(m==0) { Array.Resize(ref rr.Columns,2); Array.Resize(ref rr.Oids,2); rr.Rows=new string[][]{new string[]{"private","postgres"}}; }
            if(m==1) { Array.Resize(ref rr.Columns,4); Array.Resize(ref rr.Oids,4); rr.Rows=new string[][]{new string[4]}; }
            if(m==2) { string x=rr.Columns[0]; rr.Columns[0]=rr.Columns[1]; rr.Columns[1]=x; }
            if(m==3) rr.Oids[0]=25;
          } };
          var r=Run(api,new MemoryJournal()); Require(r.Status=="STOPPED" && api.Sent==7 && api.Statements[6]=="ROLLBACK;");
        });
      }
      Test("native-api-mock","poll reading/writing to ready and fixed TLS options reach boundary",delegate {
        var api=new FakePq(); var clock=new Clock(); var s=new Session(api,clock,new Root(),true);
        s.Connect(new Target(),null); Require(s.Verified && s.Usable && clock.Pauses==2 && api.NonblockingCalls==1 && api.SeenTarget.SslMode=="verify-full" && api.SeenTarget.Root==Pin.Root); s.Dispose();
      });
      Test("native-api-mock","poll ACTIVE and query ACTIVE states transition without reconnect",delegate {
        var api=new FakePq { PollSequence=new Queue<int>(new int[]{1,2,4,3}) };
        var clock=new Clock(); var s=new Session(api,clock,new Root(),true); s.Connect(new Target(),null);
        Require(clock.Pauses==3 && s.State==0); s.Execute(Pin.Sql(bytes)[0]); Require(s.State==2 && api.Starts==1); s.Dispose();
      });
      Test("native-api-mock","certificate fingerprint rejection before native start",delegate {
        var api=new FakePq(); var s=new Session(api,new Clock(),new Root { Reject=true },true);
        Stops(delegate { s.Connect(new Target(),null); },"CERTIFICATE_FINGERPRINT_MISMATCH"); Require(api.Starts==0); s.Dispose();
      });
      Test("native-api-mock","TLS handshake rejection has no SQL and cannot reconnect",delegate {
        var api=new FakePq { RejectTls=true }; var s=new Session(api,new Clock(),new Root(),true);
        Stops(delegate { s.Connect(new Target(),null); },"AUTH_OR_TLS_REJECTED");
        Stops(delegate { s.Connect(new Target(),null); },"RECONNECT_FORBIDDEN"); Require(api.Starts==1 && api.Sent==0); s.Dispose();
      });
      Test("native-api-mock","connection polling deadline with controlled monotonic clock",delegate {
        var api=new FakePq { ConnectNeverReady=true }; var clock=new Clock(); var s=new Session(api,clock,new Root(),true);
        Stops(delegate { s.Connect(new Target(),null); },"CONNECT_DEADLINE"); Require(clock.Now==10000 && api.Sent==0); s.Dispose();
      });
      for(int failure=0;failure<5;failure++) {
        int f=failure; Test("native-api-mock","connection attestation or nonblocking failure "+f,delegate {
          var api=new FakePq { NoSsl=f==0,WrongUser=f==1,BadReadonly=f==2,BadInitialState=f==3,BadNonblocking=f==4 };
          var r=Run(api,new MemoryJournal()); Require(r.Status=="STOPPED" && api.Sent==0 && api.Closed==1);
        });
      }
      Test("native-api-mock","result handles fully drained and individually cleared",delegate {
        var api=new FakePq { ExtraAt=5 }; var r=Run(api,new MemoryJournal());
        Require(r.Failure=="RESULT_STREAM_INVALID" && api.ClearCount==8 && api.Statements.Count==7);
      });
      Test("native-api-mock","missing result stops without subsequent catalog statements",delegate {
        var api=new FakePq { MissingAt=5 }; var r=Run(api,new MemoryJournal()); Require(r.Failure=="RESULT_STREAM_INVALID" && api.Statements.Count==7);
      });
      Test("native-api-mock","native row-count extraction accepts 500",delegate {
        var api=new FakePq { AlterAt=5,Alter=delegate(Result rr) { var f=Fixtures.Row(5,500); rr.Count=500; rr.Tag=f.Tag; rr.Rows=f.Rows; } };
        var r=Run(api,new MemoryJournal()); Require(r.Status=="EXECUTED_COMPARISON_PARTIAL_NOT_TASK_ACCEPTANCE" && api.CountReads==17);
      });
      for(int query=5;query<=15;query++) {
        int q=query; Test("native-api-mock","501 count stops before next query "+(q+1),delegate {
          var api=new FakePq { AlterAt=q,Alter=delegate(Result rr) { rr.Count=501; rr.Tag="SELECT 501"; } };
          var journal=new MemoryJournal(); var r=Run(api,journal);
          Require(r.Failure=="QUERY_OVERFLOW" && api.Statements.Count==q+2 && api.Statements[q+1]=="ROLLBACK;" && All(journal).Contains("501"));
        });
      }
      foreach(string sqlstate in new string[]{"42601","42501","57014","55P03"}) {
        string state=sqlstate; Test("native-api-mock","SQLSTATE retained and original connection rollback "+state,delegate {
          var api=new FakePq { FailAt=5,ErrorCode=state }; var j=new MemoryJournal(); var r=Run(api,j);
          Require(r.Failure=="SQL_ERROR" && r.Rollback=="SERVER_ROLLBACK_TAG_CONFIRMED" && r.FinalTransaction=="IDLE" && api.Statements.Count==7 && All(j).Contains(state));
        });
      }
      Test("native-api-mock","15s statement deadline invalidates pending connection without rollback",delegate {
        var api=new FakePq { BusyAt=5 }; var clock=new Clock(); var s=new Session(api,clock,new Root(),true);
        var r=Controller.Run(bytes,new Target(),Fixtures.Context(),s,null,new MemoryJournal());
        Require(r.Failure=="STATEMENT_CLIENT_DEADLINE" && r.Rollback=="UNAVAILABLE" && api.Sent==6 && clock.Now>=15000 && api.Starts==1);
      });
      Test("native-api-mock","connection loss cannot resume or send rollback",delegate {
        var api=new FakePq { DisconnectAt=5 }; var r=Run(api,new MemoryJournal());
        Require(r.Failure=="CONNECTION_LOST" && r.Rollback=="UNAVAILABLE" && api.Sent==6 && api.Starts==1);
      });
      Test("native-api-mock","send failure does not reuse uncertain connection",delegate {
        var api=new FakePq { SendFailAt=5 }; var r=Run(api,new MemoryJournal()); Require(r.Failure=="SEND_FAILED" && r.Rollback=="UNAVAILABLE" && api.Sent==6);
      });
      Test("native-api-mock","rollback SQL error is unavailable not retried",delegate {
        var api=new FakePq { FailRollback=true }; var r=Run(api,new MemoryJournal()); Require(r.Status=="STOPPED" && r.Rollback=="UNAVAILABLE" && api.Sent==17);
      });
      Test("native-api-mock","cleanup rollback error leaves outcome unavailable",delegate {
        var api=new FakePq { FailAt=5,FailRollback=true }; var r=Run(api,new MemoryJournal()); Require(r.Rollback=="UNAVAILABLE" && api.Sent==7);
      });
      Test("native-api-mock","rollback tag with nonidle transaction never succeeds",delegate {
        var api=new FakePq { BadFinalState=true }; var r=Run(api,new MemoryJournal()); Require(r.Status=="STOPPED" && r.Rollback=="SERVER_ROLLBACK_TAG_CONFIRMED" && r.FinalTransaction=="NOT_IDLE");
      });
      Test("native-api-mock","connection close exception is sanitized",delegate {
        var api=new FakePq { ThrowClose=true }; var j=new MemoryJournal(); var r=Run(api,j); Require(!r.Closed && r.Failure=="CONNECTION_CLOSE_UNCONFIRMED" && !All(j).Contains("SENSITIVE_PASSWORD"));
      });
      Test("evidence-policy","known identifiers owners flags and grants survive sanitized export",delegate {
        var r=Fixtures.Row(6,1); r.Rows[0][4]="t"; r.Rows[0][5]="t";
        var cells=new CatalogPolicy().Export(r,6)[0].Cells;
        Require(cells[0].Value=="private" && cells[1].Value=="controllers" && cells[3].Value=="postgres" && cells[4].Value=="t" && cells[6].Value.Contains("authenticated=r/postgres"));
      });
      Test("evidence-policy","sensitive identifiers use stable opaque IDs, not hashes or raw text",delegate {
        var p=new CatalogPolicy(); Require(p.Id("SENSITIVE_PASSWORD")==p.Id("SENSITIVE_PASSWORD") && p.Id("SENSITIVE_PASSWORD").StartsWith("opaque-") && p.Id("OTHER_TOKEN")!=p.Id("SENSITIVE_PASSWORD"));
      });
      Test("evidence-policy","controlled expression MATCH DIFFERENT UNRESOLVED without literal export",delegate {
        var p=new CatalogPolicy(); var r=Fixtures.Row(8,1); var cell=p.Export(r,8)[0].Cells[4]; Require(cell.Comparison=="MATCH" && cell.Value=="WITHHELD");
        r.Rows[0][4]="CHECK (SENSITIVE_PASSWORD)"; cell=p.Export(r,8)[0].Cells[4]; Require(cell.Comparison=="DIFFERENT" && cell.Value=="WITHHELD");
        r.Rows[0][2]="unknown_constraint"; cell=p.Export(r,8)[0].Cells[4]; Require(cell.Comparison=="UNRESOLVED");
        r=Fixtures.Row(10,1); r.Rows[0][1]="wrong_table"; Require(p.Export(r,10)[0].Cells[6].Comparison=="UNRESOLVED");
      });
      Test("evidence-policy","NULL ACL not reported as no privileges",delegate { var r=Fixtures.Row(5,1); r.Rows[0][2]=null; Require(new CatalogPolicy().Export(r,5)[0].Cells[2].Value=="SQL_NULL_DEFAULT_ACL_NOT_EXPANDED"); });
      Test("evidence-policy","quoted array commas preserved, ACL unknown roles opaque",delegate {
        Require(PgArray.Parse("{\"a,b\",c}")[0]=="a,b");
        var r=Fixtures.Row(5,1); r.Rows[0][2]="{SENSITIVE_PASSWORD=r/postgres}";
        var cell=new CatalogPolicy().Export(r,5)[0].Cells[2]; Require(!cell.Value.Contains("SENSITIVE") && cell.Value.Contains("opaque-"));
      });
      Test("evidence-policy","unrecognized quoted ACL grammar is unresolved, no text leakage",delegate {
        var r=Fixtures.Row(5,1); r.Rows[0][2]="{\"\\\"secret role\\\"=r/postgres\"}";
        var c=new CatalogPolicy().Export(r,5)[0].Cells[2]; Require(c.Comparison=="UNRESOLVED" && !c.Value.Contains("secret"));
      });
      Test("evidence-policy","malicious config and errors cannot leak to serialized journal",delegate {
        var api=new FakePq { AlterAt=12,Alter=delegate(Result rr) { rr.Rows[0][7]="{SENSITIVE_PASSWORD_AND_TOKEN}"; } };
        var j=new MemoryJournal(); var r=Run(api,j); Require(!All(j).Contains("SENSITIVE_PASSWORD_AND_TOKEN") && r.Status=="EXECUTED_COMPARISON_PARTIAL_NOT_TASK_ACCEPTANCE");
      });
      Test("evidence-policy","unknown exception codes not copied into evidence",delegate { Require(Controller.Failure(new Stop("SENSITIVE_PASSWORD"))=="UNEXPECTED_LOCAL_FAILURE"); });
      Test("evidence-policy","direct sensitive cell injection rejected before persistence",delegate {
        var e=new SafeEvent { Kind="STATEMENT_RESULT",Catalog=new SafeRow[]{new SafeRow { Cells=new SafeCell[]{new SafeCell { Value="SENSITIVE_PASSWORD" }} }} };
        Stops(delegate { ExportGuard.Check(e); },"EVIDENCE_SERIALIZATION_FAILED");
      });
      Test("durability","preflight failure prevents connection and uses emergency summary",delegate {
        var api=new FakePq(); var j=new MemoryJournal { FailAll=true }; var r=Run(api,j);
        Require(api.Starts==0 && !r.JournalDurable && j.EmergencyWrites>=1 && r.Status=="STOPPED");
      });
      Test("durability","journal failure after a result stops inspection and rolls back",delegate {
        var api=new FakePq(); var j=new MemoryJournal { FailKind="STATEMENT_RESULT" }; var r=Run(api,j);
        Require(api.Sent==2 && api.Statements[1]=="ROLLBACK;" && r.Rollback=="SERVER_ROLLBACK_TAG_CONFIRMED" && !r.JournalDurable);
      });
      Test("durability","final write failure has durable emergency rollback record",delegate {
        var api=new FakePq(); var j=new MemoryJournal { FailKind="FINAL_ROLLBACK_AND_CLOSE" }; var r=Run(api,j);
        Require(j.EmergencyWrites==3 && !r.JournalDurable && r.Status=="STOPPED" && All(j).Contains("SERVER_ROLLBACK_TAG_CONFIRMED"));
      });
      Test("durability","primary and emergency failure never claims durable evidence",delegate {
        var j=new MemoryJournal { FailAll=true,FailEmergency=true }; var r=Run(new FakePq(),j); Require(!r.JournalDurable && r.Failure=="EMERGENCY_EVIDENCE_FAILED");
      });
      Test("durability","actual file journal create-new flush and readable JSON records",delegate {
        string path=Path.Combine(directory,"journal-success");
        using(var j=new FileJournal(path)) { j.Write(new SafeEvent { Kind="LOCAL_PREPARATION_COMPLETE" }); }
        string[] lines=File.ReadAllLines(Path.Combine(path,"journal.jsonl")); Require(lines.Length==2);
        foreach(string line in lines) Require(new JavaScriptSerializer().DeserializeObject(line)!=null);
        Stops(delegate { new FileJournal(path); },"EVIDENCE_DESTINATION_UNWRITABLE");
      });
      Test("durability","actual filesystem failure before run creates no connection",delegate {
        string path=Path.Combine(directory,"not-a-directory"); File.WriteAllText(path,"local synthetic fixture");
        Stops(delegate { new FileJournal(path); },"EVIDENCE_DESTINATION_UNWRITABLE");
      });
      Test("durability","serialization/export failure writes no secret bytes",delegate {
        string path=Path.Combine(directory,"serialization-failure");
        using(var j=new FileJournal(path)) {
          Stops(delegate { j.Write(new SafeEvent { Kind="SENSITIVE_PASSWORD_AND_TOKEN" }); },"EVIDENCE_WRITE_FAILED");
        }
        Require(!File.ReadAllText(Path.Combine(path,"journal.jsonl")).Contains("SENSITIVE_PASSWORD"));
      });
      Test("provenance","missing source fingerprints and sensitive approval references reject",delegate {
        var c=Fixtures.Context(); c.SourceHashes.Clear(); Stops(delegate { c.Check(); },"PROVENANCE_INVALID");
        c=Fixtures.Context(); c.ApprovalReference="Bearer SENSITIVE_PASSWORD"; Stops(delegate { c.Check(); },"PROVENANCE_INVALID");
      });
      Test("provenance","preflight contains approved targets versions hashes and per-statement timing",delegate {
        var j=new MemoryJournal(); Run(new FakePq(),j); string text=All(j);
        foreach(string key in new string[]{"approvalReference","sourceHashes","libpqVersion","runtime","certificateFileSha256","sqlSha256","ElapsedMilliseconds","TransactionState"}) Require(text.Contains(key));
      });
      Test("evidence-policy","RLS and function-owner draft comparisons distinguish MATCH/DIFFERENT",delegate {
        var r=Fixtures.Row(6,1); r.Rows[0][4]="t"; r.Rows[0][5]="f";
        var cells=new CatalogPolicy().Export(r,6)[0].Cells;
        Require(cells[4].Comparison=="MATCH" && cells[5].Comparison=="DIFFERENT");
        r=Fixtures.Row(12,1); r.Rows[0][0]="public"; r.Rows[0][1]="bridge_sync_ingest_v1";
        Require(new CatalogPolicy().Export(r,12)[0].Cells[4].Comparison=="UNRESOLVED"); // Wrong overload: no false owner MATCH.
        r.Rows[0][2]="p_submission jsonb, p_content_sha256 text";
        Require(new CatalogPolicy().Export(r,12)[0].Cells[4].Comparison=="DIFFERENT");
        r.Rows[0][4]="smart_hatch_bridge_owner"; Require(new CatalogPolicy().Export(r,12)[0].Cells[4].Comparison=="MATCH");
      });
      Test("evidence-policy","raw timestamp/summary injection rejected by persistence guard",delegate {
        Stops(delegate { ExportGuard.Check(new SafeEvent { Kind="LAUNCHER_FAILURE",Utc="SENSITIVE_PASSWORD" }); },"EVIDENCE_SERIALIZATION_FAILED");
        Stops(delegate { ExportGuard.Check(new SafeEvent { Kind="FINAL_ROLLBACK_AND_CLOSE",Summary=new Summary { EndedUtc="SENSITIVE_PASSWORD" } }); },"EVIDENCE_SERIALIZATION_FAILED");
      });
      Test("provenance","synthetic owner attestation parsed without claiming trusted origin",delegate {
        var data=Proof(); string json=new JavaScriptSerializer().Serialize(data);
        var proof=CertificateApproval.Read(json,"Q12-PA-20261031-01"); Require(proof.FileSha256==new string('a',64));
      });
      foreach(string field in new string[]{"status","projectRef","sourceUrl","verificationMethod","verifiedAtUtc","approvalReference","fileSha256","derSha256"}) {
        string f=field; Test("provenance","certificate record invalid field rejected "+f,delegate {
          var data=Proof(); data[f]="SENSITIVE_PASSWORD_AND_TOKEN";
          Stops(delegate { CertificateApproval.Read(new JavaScriptSerializer().Serialize(data),"Q12-PA-20261031-01"); },"CERTIFICATE_APPROVAL_MISSING");
        });
      }
      Test("provenance","certificate record missing/extra/duplicate fields rejected",delegate {
        var data=Proof(); data.Remove("status"); Stops(delegate { CertificateApproval.Read(new JavaScriptSerializer().Serialize(data),"Q12-PA-20261031-01"); },"CERTIFICATE_APPROVAL_MISSING");
        data=Proof(); data["extra"]="SENSITIVE_PASSWORD"; Stops(delegate { CertificateApproval.Read(new JavaScriptSerializer().Serialize(data),"Q12-PA-20261031-01"); },"CERTIFICATE_APPROVAL_MISSING");
        string json=new JavaScriptSerializer().Serialize(Proof()); json=json.Substring(0,json.Length-1)+",\"status\":\"OWNER_VERIFIED_TRUSTED_ORIGIN\"}";
        Stops(delegate { CertificateApproval.Read(json,"Q12-PA-20261031-01"); },"CERTIFICATE_APPROVAL_MISSING");
      });
      Test("provenance","actual local fingerprint gate rejects altered synthetic file",delegate {
        string path=Path.Combine(directory,"synthetic-root-bytes.txt"); File.WriteAllText(path,"synthetic public certificate placeholder");
        var t=new Target { Root=path }; var gate=new FileRootGate(Pin.Hash(File.ReadAllBytes(path))); gate.Check(t);
        File.AppendAllText(path,"changed"); Stops(delegate { gate.Check(t); },"CERTIFICATE_FINGERPRINT_MISMATCH");
      });
      Test("local-native-no-connection","installed libpq version and local empty PGresult lifecycle only",delegate {
        NativeProbe=NativePq.LocalProbe(); Require(NativeProbe[0]>=170000 && NativeProbe[1]==2 && NativeProbe[2]==0 && NativeProbe[3]==0);
      });
      foreach(int count in new int[]{500,501}) {
        int n=count; Test("local-native-no-connection","native memory-only PGresult count/OID/cell probe "+n,delegate {
          int[] r=NativePq.LocalCountProbe(n); Require(r[0]==n && r[1]==1 && r[2]==23 && r[3]==1);
        });
      }
    }
    static Dictionary<string,object> Proof() {
      return new Dictionary<string,object> {
        {"status","OWNER_VERIFIED_TRUSTED_ORIGIN"},{"projectRef",Pin.Project},
        {"sourceUrl","https://supabase.com/dashboard/project/zbwntspdecngnicllwlw/database/settings"},
        {"verificationMethod","AUTHENTICATED_SOURCE_AND_INDEPENDENT_TRUSTED_FINGERPRINT"},
        {"verifiedAtUtc","2026-10-01T00:00:00Z"},{"approvalReference","Q12-PA-20261031-01"},
        {"fileSha256",new string('a',64)},{"derSha256",new string('b',64)}
      };
    }
  }
}
