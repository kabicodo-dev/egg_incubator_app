// LOCAL ONLY. This file never instantiates LibpqSession or opens sockets.
using System;
using System.Text;
using System.Security;
using System.Collections.Generic;

namespace SmartHatch.Q12.Tests {
  public sealed class MockSession : ISession {
    public int Connections, State, Disposals;
    public bool Live, Verified=true, FailConnect, LoseConnection, Deadline, FailClose;
    public bool BadFinalState, Incomplete, Multiple, Malformed, InvalidTag, MissingResult;
    public bool FailCleanup, LoseBeforeCleanup;
    public int FailAt=-1, OverflowAt=-1, Rows=1;
    public string ErrorState, ReadOnly="on", Isolation="repeatable read", Role="postgres";
    public string Secret="MOCK_PASSWORD_DO_NOT_LOG", Token="Bearer MOCK_TOKEN_DO_NOT_LOG";
    public List<string> Sent=new List<string>();
    public Action BeforeFirstSql;
    public bool VerifiedConnection { get { return Verified; } }
    public bool Usable { get { return Live; } }
    public int TransactionState { get { return State; } }
    public void Connect(Target target,SecureString password) {
      Connections++;
      if(Connections!=1) throw new Exception("MOCK_RECONNECT_DETECTED");
      if(FailConnect) throw new SafetyException("AUTH_OR_TLS_CONNECTION_FAILED");
      Live=true;
    }
    public Result Execute(string sql) {
      if(Sent.Count==0 && BeforeFirstSql!=null) BeforeFirstSql();
      int index=Sent.Count; Sent.Add(sql);
      if(sql=="ROLLBACK;" || index==16) {
        if(FailAt==16 || FailCleanup) {
          if(LoseConnection || LoseBeforeCleanup) { Live=false; State=4; }
          throw new SafetyException("MOCK_ROLLBACK_FAILED");
        }
        State=BadFinalState ? 2 : 0;
        return new Result { Tag="ROLLBACK" };
      }
      if(index==FailAt) {
        if(LoseConnection || Deadline) {
          Live=false; State=4;
          throw new SafetyException(Deadline ? "CLIENT_DEADLINE_CONNECTION_UNUSABLE" : "CONNECTION_LOST");
        }
        State=3;
        return new Result { Error=true, SqlState=ErrorState, Tag=Secret+Token };
      }
      State=2;
      if(index==0) return new Result { Tag="BEGIN" };
      if(index<=3) return new Result { Tag="SET" };
      if(MissingResult && index==5) return null;
      int count=index==OverflowAt ? 501 : index==4 ? 1 : Rows;
      string[] columns=index==4 ? new string[]{"connection_role","server_version","read_only","isolation"} : new string[]{Secret,Token};
      var data=new string[count][];
      for(int i=0;i<count;i++) data[i]=index==4 ? new string[]{Role,Secret,ReadOnly,Isolation} : new string[]{Secret,Token};
      var result=new Result { Tag="SELECT "+count, Tuples=true, RowCount=count, Columns=columns, Rows=data };
      if(index==5) {
        if(Incomplete) result.Complete=false;
        if(Multiple) throw new SafetyException("INCOMPLETE_OR_MULTIPLE_RESULTS");
        if(Malformed) result.Rows=new string[0][];
        if(InvalidTag) result.Tag=Secret;
      }
      return result;
    }
    public void Dispose() { Disposals++; Live=false; if(FailClose) throw new Exception(Secret); }
  }
  public sealed class Case {
    public string Name, Status;
  }
  public static class Suite {
    public static List<Case> Results=new List<Case>();
    public static Report RedactionExample;
    private static byte[] bytes;
    private static void Require(bool condition,string code) { if(!condition) throw new Exception(code); }
    private static void Test(string name,Action action) {
      try { action(); Results.Add(new Case { Name=name, Status="PASS" }); }
      catch { Results.Add(new Case { Name=name, Status="FAIL" }); }
    }
    private static Report Run(MockSession mock) { return Controller.Run(bytes,Target.Approved(),mock,null,false); }
    private static void Stop(Report report,string code) {
      Require(report.Status=="STOPPED","NOT_STOPPED"); Require(report.FailureCode==code,"WRONG_FAILURE_CODE");
      Require(report.Closed,"NOT_CLOSED");
    }
    private static void AbortedAfter(MockSession m,int index) {
      Require(m.Connections==1,"CONNECT_COUNT");
      Require(m.Sent.Count==index+2,"CONTINUED_AFTER_FAILURE");
      Require(m.Sent[m.Sent.Count-1]=="ROLLBACK;","NO_FAILURE_ROLLBACK");
    }
    public static void RunAll(byte[] approvedBytes) {
      bytes=approvedBytes; Results.Clear();
      Test("exact approved hash and byte-perfect 17-statement reconstruction",delegate {
        var parsed=ApprovedSql.Load(bytes);
        Require(parsed.Statements.Length==17,"COUNT");
        Require(Encoding.UTF8.GetString(bytes)==String.Concat(parsed.Statements),"BYTES_CHANGED");
      });
      Test("successful sequence on one connection, explicit rollback and idle close",delegate {
        var m=new MockSession(); var r=Run(m); var parsed=ApprovedSql.Load(bytes);
        Require(r.Status=="INSPECTION_EXECUTED_NOT_TASK_ACCEPTANCE","NOT_SUCCESS");
        Require(m.Connections==1 && m.Disposals==1 && m.Sent.Count==17,"LIFECYCLE");
        for(int i=0;i<17;i++) Require(m.Sent[i]==parsed.Statements[i],"STATEMENT_CHANGED");
        Require(r.Rollback=="SERVER_ROLLBACK_TAG_CONFIRMED" && r.FinalState=="IDLE" && r.Closed,"CLEANUP");
        Require(r.Entries.Count==17 && !r.RemoteExecution,"EVIDENCE");
      });
      Test("SQL hash mismatch: zero connections and SQL",delegate {
        var altered=(byte[])bytes.Clone(); altered[0]^=1; var m=new MockSession();
        var r=Controller.Run(altered,Target.Approved(),m,null,false);
        Stop(r,"SQL_HASH_MISMATCH"); Require(m.Connections==0 && m.Sent.Count==0,"CONNECTED");
      });
      for(int field=0;field<8;field++) {
        int f=field;
        Test("target or TLS field mismatch "+f+": fail before connection",delegate {
          string[] v={Target.Ref,Target.Host,Target.User,"postgres","5432","verify-full",Target.Certificate};
          if(f<7) v[f]="wrong"; else v[0]="suopuhgtwyqkpupzvdng";
          var t=new Target(v[0],v[1],v[2],v[3],v[4],v[5],v[6]); var m=new MockSession();
          var r=Controller.Run(bytes,t,m,null,false);
          Stop(r,f==5 || f==6 ? "TLS_CONFIGURATION_MISMATCH" : "TARGET_MISMATCH");
          Require(m.Connections==0 && m.Sent.Count==0,"CONNECTED");
        });
      }
      Test("SSL/auth verification failure: no BEGIN",delegate {
        var m=new MockSession { FailConnect=true }; var r=Run(m);
        Stop(r,"AUTH_OR_TLS_CONNECTION_FAILED"); Require(m.Sent.Count==0,"SENT_SQL");
      });
      Test("connected but TLS/target attestation false: no BEGIN",delegate {
        var m=new MockSession { Verified=false }; var r=Run(m);
        Stop(r,"CONNECTION_NOT_VERIFIED_IDLE"); Require(m.Sent.Count==0,"SENT_SQL");
      });
      Test("connection not initially idle: no BEGIN",delegate {
        var m=new MockSession { State=2 }; var r=Run(m);
        Stop(r,"CONNECTION_NOT_VERIFIED_IDLE"); Require(m.Sent.Count==0,"SENT_SQL");
      });
      for(int setting=0;setting<3;setting++) {
        int s=setting;
        Test("incorrect transaction read-only/isolation/role "+s+": no catalog SELECT",delegate {
          var m=new MockSession();
          if(s==0) m.ReadOnly="off"; else if(s==1) m.Isolation="read committed"; else m.Role="other";
          var r=Run(m); Stop(r,"READ_ONLY_ISOLATION_OR_ROLE_MISMATCH"); AbortedAfter(m,4);
          Require(r.Rollback=="SERVER_ROLLBACK_TAG_CONFIRMED","ROLLBACK");
        });
      }
      Test("exactly 500 catalog rows allowed",delegate {
        var m=new MockSession { Rows=500 }; var r=Run(m);
        Require(r.Status=="INSPECTION_EXECUTED_NOT_TASK_ACCEPTANCE" && m.Sent.Count==17,"REJECTED_500");
      });
      for(int index=5;index<=15;index++) {
        int at=index;
        Test("501 row overflow in catalog statement "+(at+1)+": immediate rollback",delegate {
          var m=new MockSession { OverflowAt=at }; var r=Run(m);
          Stop(r,"QUERY_OVERFLOW"); AbortedAfter(m,at);
          Require(r.Entries[r.Entries.Count-1].Rows==501,"OVERFLOW_NOT_RECORDED");
        });
      }
      foreach(string state in new string[]{"42601","42501","57014","55P03"}) {
        string code=state;
        Test("SQL error/statement timeout/lock timeout "+code+": no continuation",delegate {
          var m=new MockSession { FailAt=7, ErrorState=code }; var r=Run(m);
          Stop(r,code=="57014" ? "STATEMENT_TIMEOUT_OR_CANCEL" : code=="55P03" ? "LOCK_TIMEOUT_OR_UNAVAILABLE" : "SQL_STATEMENT_FAILED");
          AbortedAfter(m,7); Require(r.FinalState=="IDLE","NOT_IDLE");
        });
      }
      Test("connection loss: no reconnect, resumption or unusable rollback",delegate {
        var m=new MockSession { FailAt=6, LoseConnection=true }; var r=Run(m);
        Stop(r,"CONNECTION_LOST"); Require(m.Connections==1 && m.Sent.Count==7,"RESUMED");
        Require(r.Rollback=="UNAVAILABLE" && r.FinalState=="UNAVAILABLE","FALSE_CLEANUP");
      });
      Test("client watchdog: pending connection unusable, close not rollback",delegate {
        var m=new MockSession { FailAt=6, Deadline=true }; var r=Run(m);
        Stop(r,"CLIENT_DEADLINE_CONNECTION_UNUSABLE"); Require(m.Connections==1 && m.Sent.Count==7,"RESUMED");
        Require(r.Rollback=="UNAVAILABLE","FALSE_CLEANUP");
      });
      Test("final rollback failure: not retried or falsely confirmed",delegate {
        var m=new MockSession { FailAt=16 }; var r=Run(m);
        Stop(r,"MOCK_ROLLBACK_FAILED"); Require(m.Sent.Count==17 && r.Rollback=="UNAVAILABLE","RETRIED");
      });
      Test("failure-cleanup rollback failure: unavailable, no retry",delegate {
        var m=new MockSession { FailAt=7, ErrorState="42501", FailCleanup=true }; var r=Run(m);
        Stop(r,"SQL_STATEMENT_FAILED"); AbortedAfter(m,7);
        Require(r.Rollback=="UNAVAILABLE" && r.FinalState=="UNAVAILABLE","FALSE_CLEANUP");
      });
      Test("connection loss during cleanup rollback: unavailable, no reconnect",delegate {
        var m=new MockSession { FailAt=7, ErrorState="42501", FailCleanup=true, LoseBeforeCleanup=true }; var r=Run(m);
        Stop(r,"SQL_STATEMENT_FAILED"); AbortedAfter(m,7);
        Require(r.Rollback=="UNAVAILABLE" && m.Connections==1,"FALSE_CLEANUP");
      });
      Test("first SELECT read-only shape incomplete: stop before catalogs",delegate {
        var m=new MockSession { ReadOnly=null }; var r=Run(m);
        Stop(r,"READ_ONLY_ISOLATION_OR_ROLE_MISMATCH"); AbortedAfter(m,4);
      });
      Test("rollback tag but non-idle state: stopped and distinguished",delegate {
        var m=new MockSession { BadFinalState=true }; var r=Run(m);
        Stop(r,"POST_ROLLBACK_NOT_IDLE"); Require(r.Rollback=="SERVER_ROLLBACK_TAG_CONFIRMED" && r.FinalState!="IDLE","FALSE_IDLE");
      });
      for(int kind=0;kind<5;kind++) {
        int k=kind;
        Test("incomplete/multiple/malformed/unexpected/missing result "+k+": stopped",delegate {
          var m=new MockSession();
          if(k==0) m.Incomplete=true; if(k==1) m.Multiple=true; if(k==2) m.Malformed=true;
          if(k==3) m.InvalidTag=true; if(k==4) m.MissingResult=true;
          var r=Run(m);
          Stop(r,k==1 ? "INCOMPLETE_OR_MULTIPLE_RESULTS" : k==3 ? "UNEXPECTED_COMMAND_STATUS" : "INCOMPLETE_RESULT");
          AbortedAfter(m,5);
        });
      }
      Test("close failure cannot be reported as success",delegate {
        var m=new MockSession { FailClose=true }; var r=Run(m);
        Require(r.Status=="STOPPED" && !r.Closed && r.FailureCode=="CONNECTION_CLOSE_UNCONFIRMED","FALSE_CLOSE");
      });
      Test("credential/token/metadata text fully withheld from evidence",delegate {
        var m=new MockSession(); var r=Run(m); RedactionExample=r;
        foreach(Entry e in r.Entries) foreach(string[] row in e.RedactedRows) foreach(string cell in row)
          Require(cell=="[WITHHELD]","RAW_CELL");
        Require(r.FailureCode==null,"FAILURE");
      });
      Test("server error/tag secret is never copied to report",delegate {
        var m=new MockSession { FailAt=5, ErrorState="SECRET" }; var r=Run(m);
        Stop(r,"SQL_STATEMENT_FAILED"); AbortedAfter(m,5);
        Require(r.Entries[r.Entries.Count-1].Tag=="[WITHHELD]","TAG_LEAK");
      });
      Test("native adapter remote-disabled guard: no DLL load or connection",delegate {
        var native=new LibpqSession(false);
        try { native.Connect(Target.Approved(),null); throw new Exception("DID_NOT_BLOCK"); }
        catch(SafetyException ex) { Require(ex.Code=="REMOTE_EXECUTION_NOT_PERMITTED","GUARD"); }
        finally { native.Dispose(); }
      });
      Test("native adapter rejects reconnect even after local preflight failure",delegate {
        var native=new LibpqSession(true);
        try {
          var wrong=new Target("wrong",Target.Host,Target.User,"postgres","5432","verify-full",Target.Certificate);
          try { native.Connect(wrong,null); throw new Exception("TARGET_ACCEPTED"); }
          catch(SafetyException ex) { Require(ex.Code=="TARGET_MISMATCH","FIRST_GUARD"); }
          try { native.Connect(Target.Approved(),null); throw new Exception("RECONNECTED"); }
          catch(SafetyException ex) { Require(ex.Code=="RECONNECT_FORBIDDEN","SECOND_GUARD"); }
        } finally { native.Dispose(); }
      });
      Test("native adapter rejects missing credential before DLL or network use",delegate {
        var native=new LibpqSession(true);
        try {
          try { native.Connect(Target.Approved(),null); throw new Exception("NO_CREDENTIAL_ACCEPTED"); }
          catch(SafetyException ex) { Require(ex.Code=="CREDENTIAL_UNAVAILABLE","CREDENTIAL_GUARD"); }
        } finally { native.Dispose(); }
      });
      Test("all preparation complete before first BEGIN",delegate {
        bool ready=false; var m=new MockSession();
        m.BeforeFirstSql=delegate { Require(ready,"NOT_READY"); };
        ready=true; var r=Run(m); Require(r.Status=="INSPECTION_EXECUTED_NOT_TASK_ACCEPTANCE","NOT_SUCCESS");
      });
    }
  }
}
