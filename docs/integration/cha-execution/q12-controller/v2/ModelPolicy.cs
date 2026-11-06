// Local correction candidate. No network or SQL execution on load.
using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Security;
using System.Security.Cryptography;
using System.Globalization;

namespace SmartHatch.Q12.V2 {
  public sealed class Stop : Exception {
    public readonly string Code;
    public Stop(string code) : base("Q12 stopped") { Code=code; }
  }
  public static class Pin {
    public const string SqlHash="9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc";
    public const string Project="zbwntspdecngnicllwlw", Host="aws-0-ap-northeast-1.pooler.supabase.com";
    public const string User="postgres.zbwntspdecngnicllwlw", Port="5432", Database="postgres";
    public const string Root=@"C:\Users\Mary Charlyn\Downloads\prod-ca-2021.crt";
    public const string Bin=@"C:\Program Files\PostgreSQL\17\bin";
    public static string Hash(byte[] b) { using(var s=SHA256.Create()) return BitConverter.ToString(s.ComputeHash(b)).Replace("-","").ToLowerInvariant(); }
    public static string[] Sql(byte[] b) {
      if(Hash(b)!=SqlHash) throw new Stop("SQL_HASH_MISMATCH");
      string text=new UTF8Encoding(false,true).GetString(b); var parts=new List<string>();
      int start=0; bool quote=false,line=false;
      for(int i=0;i<text.Length;i++) {
        char ch=text[i];
        if(line) { if(ch=='\n') line=false; continue; }
        if(quote) { if(ch=='\'') { if(i+1<text.Length && text[i+1]=='\'') i++; else quote=false; } continue; }
        if(ch=='-' && i+1<text.Length && text[i+1]=='-') { line=true; i++; continue; }
        if(ch=='\'') { quote=true; continue; }
        if(ch==';') { parts.Add(text.Substring(start,i-start+1)); start=i+1; }
      }
      if(quote || parts.Count!=17 || !String.IsNullOrWhiteSpace(text.Substring(start))) throw new Stop("SQL_SPLIT_FAILED");
      parts[16]+=text.Substring(start);
      if(String.Concat(parts)!=text) throw new Stop("SQL_BYTES_CHANGED");
      return parts.ToArray();
    }
  }
  public sealed class Target {
    public string Project=Pin.Project, Host=Pin.Host, Port=Pin.Port, Database=Pin.Database, User=Pin.User;
    public string SslMode="verify-full", Root=Pin.Root;
    public void Check() {
      if(Project!=Pin.Project || Host!=Pin.Host || Port!=Pin.Port || Database!=Pin.Database || User!=Pin.User) throw new Stop("TARGET_MISMATCH");
      if(SslMode!="verify-full" || Root!=Pin.Root) throw new Stop("TLS_CONFIGURATION_MISMATCH");
    }
  }
  public sealed class Result {
    public bool Error, Complete=true;
    public string SqlState, Tag;
    public string[] Columns=new string[0];
    public int[] Oids=new int[0];
    public int Count;
    public string[][] Rows=new string[0][];
  }
  public sealed class Field {
    public string Name, Kind;
    public bool Nullable;
    public int[] Oids;
    public Field(string name,string kind,bool nullable,params int[] oids) { Name=name; Kind=kind; Nullable=nullable; Oids=oids; }
  }
  public static class Shapes {
    static Field N(string n) { return new Field(n,"identifier",false,19); }
    static Field T(string n,bool nullable) { return new Field(n,"expression",nullable,25); }
    static Field B(string n) { return new Field(n,"boolean",false,16); }
    static Field E(string n,string values) { return new Field(n,"enum:"+values,false,18); }
    static Field A(string n,string kind,int oid) { return new Field(n,kind,true,oid); }
    public static readonly Field[][] Queries={
      new Field[]{N("connection_role"),T("server_version",false),T("read_only",false),T("isolation",false)},
      new Field[]{N("nspname"),N("owner"),A("nspacl","acl",1034)},
      new Field[]{N("nspname"),N("relname"),E("relkind","r|p|v|m|S|f"),N("owner"),B("relrowsecurity"),B("relforcerowsecurity"),A("relacl","acl",1034)},
      new Field[]{N("nspname"),N("relname"),N("attname"),T("type",false),B("attnotnull"),E("attidentity","|a|d"),E("attgenerated","|s|v"),T("default_expression",true)},
      new Field[]{N("nspname"),N("relname"),N("conname"),E("contype","c|f|p|u|t|x|n"),T("definition",false)},
      new Field[]{N("nspname"),N("relname"),N("index_name"),B("indisunique"),B("indisvalid"),T("definition",false)},
      new Field[]{N("nspname"),N("relname"),N("polname"),E("polcmd","r|a|w|d|*"),B("polpermissive"),new Field("roles","roles",false,1003),T("using_expression",true),T("check_expression",true)},
      new Field[]{N("nspname"),N("relname"),N("tgname"),E("tgenabled","O|D|R|A"),T("definition",false)},
      new Field[]{N("nspname"),N("proname"),T("arguments",false),T("result_type",false),N("owner"),B("prosecdef"),E("provolatile","i|s|v"),A("proconfig","config",1009),A("proacl","acl",1034)},
      new Field[]{N("rolname"),B("rolsuper"),B("rolinherit"),B("rolcreaterole"),B("rolcreatedb"),B("rolcanlogin"),B("rolreplication"),B("rolbypassrls")},
      new Field[]{N("granted_role"),N("member"),B("admin_option")},
      new Field[]{N("owner"),N("schema"),E("defaclobjtype","r|S|f|T|n"),A("defaclacl","acl",1034)}
    };
    public static void Check(Result r,int statement) {
      if(r==null || !r.Complete) throw new Stop("INCOMPLETE_RESULT");
      if(r.Error) throw new Stop("SQL_ERROR");
      if(statement<4 || statement==16) {
        string tag=statement==0 ? "BEGIN" : statement==16 ? "ROLLBACK" : "SET";
        if(r.Tag!=tag || r.Count!=0 || r.Columns.Length!=0 || r.Oids.Length!=0 || r.Rows.Length!=0) throw new Stop("COMMAND_SHAPE_INVALID");
        return;
      }
      if(r.Tag!="SELECT "+r.Count) throw new Stop("COMMAND_TAG_INVALID");
      if(r.Count<0 || r.Count>500) throw new Stop("QUERY_OVERFLOW");
      Field[] shape=Queries[statement-4];
      if(r.Columns.Length!=shape.Length || r.Oids.Length!=shape.Length || r.Rows.Length!=r.Count) throw new Stop("RESULT_SHAPE_INVALID");
      for(int j=0;j<shape.Length;j++) {
        if(r.Columns[j]!=shape[j].Name || Array.IndexOf(shape[j].Oids,r.Oids[j])<0) throw new Stop("RESULT_COLUMNS_OR_TYPES_INVALID");
      }
      foreach(var row in r.Rows) {
        if(row==null || row.Length!=shape.Length) throw new Stop("RESULT_SHAPE_INVALID");
        for(int j=0;j<shape.Length;j++) {
          string v=row[j]; Field f=shape[j];
          if(v==null) { if(!f.Nullable) throw new Stop("RESULT_NULL_INVALID"); continue; }
          if(v.Length>16384 || v.IndexOf('\0')>=0) throw new Stop("RESULT_VALUE_INVALID");
          if(f.Kind=="boolean" && v!="t" && v!="f") throw new Stop("RESULT_BOOLEAN_INVALID");
          if(f.Kind.StartsWith("enum:") && Array.IndexOf(f.Kind.Substring(5).Split('|'),v)<0) throw new Stop("RESULT_ENUM_INVALID");
          if(f.Kind=="identifier" && (v.Length==0 || Encoding.UTF8.GetByteCount(v)>63) && !(f.Name=="schema" && v=="<global>")) throw new Stop("RESULT_IDENTIFIER_INVALID");
          if(f.Kind=="acl" || f.Kind=="roles" || f.Kind=="config") PgArray.Parse(v);
        }
      }
      if(statement==4 && (r.Count!=1 || r.Rows[0][0]!="postgres" || r.Rows[0][2]!="on" || r.Rows[0][3]!="repeatable read")) throw new Stop("TRANSACTION_GUARD_FAILED");
    }
  }
  public static class PgArray {
    // One-dimensional PostgreSQL text-array lexer. Never split quoted commas.
    // Unsupported dimensions, NULL elements or malformed escapes fail closed.
    public static string[] Parse(string text) {
      if(text==null || text.Length<2 || text[0]!='{' || text[text.Length-1]!='}') throw new Stop("ARRAY_FORMAT_INVALID");
      var list=new List<string>(); if(text=="{}") return list.ToArray(); int i=1;
      while(i<text.Length-1) {
        var b=new StringBuilder(); bool quoted=text[i]=='"', closed=!quoted;
        if(quoted) i++;
        while(i<text.Length-1) {
          char c=text[i++];
          if(c=='\\') { if(i>=text.Length-1) throw new Stop("ARRAY_FORMAT_INVALID"); b.Append(text[i++]); continue; }
          if(quoted && c=='"') { closed=true; break; }
          if(!quoted && c==',') { i--; break; }
          if(!quoted && (c=='{' || c=='}' || c=='"')) throw new Stop("ARRAY_FORMAT_INVALID");
          b.Append(c);
        }
        string item=b.ToString();
        if(!closed || (!quoted && (item.Length==0 || item=="NULL"))) throw new Stop("ARRAY_FORMAT_INVALID");
        list.Add(item);
        if(i==text.Length-1) break;
        if(text[i++]!=',' || i==text.Length-1) throw new Stop("ARRAY_FORMAT_INVALID");
      }
      return list.ToArray();
    }
  }
  public sealed class SafeCell {
    public string Value, Comparison="UNRESOLVED", Baseline;
  }
  public sealed class SafeRow { public SafeCell[] Cells; }
  public sealed class CatalogPolicy {
    // Allowlisted NON-SECRET design vocabulary only. Not a grant/adoption approval.
    const string Vocabulary="public private auth <global> postgres anon authenticated PUBLIC service_role authenticator smart_hatch_bridge_owner controllers authorized_installations enrollment_audit device_id wire_alias active catalog_revision contract_enabled registered_at pilot_slot installation_id wire_installation_alias auth_user_id authorized_session_id authorization_revision activation_state activation_expires_at activated_at authorization_expires_at revoked_at revoked_by revocation_reason capabilities db_imp_01_controller_disabled db_imp_01_contract_disabled db_imp_01_installation_disabled db_imp_01_owner_read_installations db_imp_01_owner_read_controllers db_imp_01_owner_insert_audit bridge_sync_authorize_v1 bridge_sync_ingest_v1 bridge_sync_reconcile_v1 bridge_sync_authorize_impl record_enrollment_audit enrollment_audit_immutable uid jwt";
    readonly HashSet<string> known=new HashSet<string>(Vocabulary.Split(' '));
    readonly Dictionary<string,string> opaque=new Dictionary<string,string>();
    readonly HashSet<string> tables=new HashSet<string>();
    public static bool SafeValue(string value) {
      if(value==null) return false;
      if(new HashSet<string>(Vocabulary.Split(' ')).Contains(value)) return true;
      if(Array.IndexOf(new string[]{"","t","f","r","p","v","m","S","c","u","x","n","a","d","s","w","*","O","D","R","A","i","T","on","repeatable read","uuid","text","boolean","smallint","bigint","timestamp with time zone","text[]","SQL_NULL","WITHHELD","SQL_NULL_DEFAULT_ACL_NOT_EXPANDED","UNRESOLVED_ACL_ENTRY"},value)>=0) return true;
      if(Regex.IsMatch(value,"\\Aopaque-[1-9][0-9]*\\z")) return true;
      // Composite exports contain ONLY individually approved identifiers/opaque IDs
      // and canonical privilege symbols, never arbitrary original strings.
      if(value.IndexOf('=')>=0) {
        foreach(string entry in value.Split(';')) {
          if(entry=="UNRESOLVED_ACL_ENTRY") continue;
          int eq=entry.IndexOf('='), slash=entry.LastIndexOf('/');
          if(eq<=0 || slash<eq || !SafeIdentifier(entry.Substring(0,eq)) || !SafeIdentifier(entry.Substring(slash+1))) return false;
          string grants=entry.Substring(eq+1,slash-eq-1);
          if(grants!="") foreach(string g in grants.Split(',')) if(!Regex.IsMatch(g,"\\A[arwdDxtXUCTcm]\\*?\\z")) return false;
        }
        return true;
      }
      if(value.IndexOf(',')>=0) { foreach(string item in value.Split(',')) if(!SafeIdentifier(item)) return false; return true; }
      return false;
    }
    static bool SafeIdentifier(string value) { return new HashSet<string>(Vocabulary.Split(' ')).Contains(value) || Regex.IsMatch(value,"\\Aopaque-[1-9][0-9]*\\z"); }
    public string Id(string value) {
      if(known.Contains(value)) return value;
      string alias; if(!opaque.TryGetValue(value,out alias)) { alias="opaque-"+(opaque.Count+1); opaque[value]=alias; }
      return alias;
    }
    public static string State(string state) { return state!=null && Regex.IsMatch(state,"\\A[0-9A-Z]{5}\\z") ? state : null; }
    SafeCell Expression(string key,string value) {
      // Exact controlled baseline equality only; never export input or its hash.
      string[] expected=null; string baseline=null;
      if(key=="constraint:db_imp_01_controller_disabled" || key=="constraint:db_imp_01_installation_disabled") {
        expected=new string[]{"CHECK ((active = false))"}; baseline="disabled_registry:active_false";
      } else if(key=="constraint:db_imp_01_contract_disabled") {
        expected=new string[]{"CHECK ((contract_enabled = false))"}; baseline="disabled_registry:contract_false";
      } else if(key=="policy:db_imp_01_owner_read_installations:using_expression" || key=="policy:db_imp_01_owner_read_controllers:using_expression" || key=="policy:db_imp_01_owner_insert_audit:check_expression") {
        expected=new string[]{"true"}; baseline="authorization_draft:owner_policy_true";
      } else if(key=="default:active" || key=="default:contract_enabled") {
        expected=new string[]{"false"}; baseline="disabled_registry:default_false";
      }
      return new SafeCell { Value=value==null ? "SQL_NULL" : "WITHHELD", Baseline=baseline,
        Comparison=expected==null ? "UNRESOLVED" : Array.IndexOf(expected,value)>=0 ? "MATCH" : "DIFFERENT" };
    }
    SafeCell Acl(string value) {
      if(value==null) return new SafeCell { Value="SQL_NULL_DEFAULT_ACL_NOT_EXPANDED" };
      var safe=new List<string>();
      foreach(string item in PgArray.Parse(value)) {
        int eq=item.IndexOf('='), slash=item.LastIndexOf('/');
        // Only unquoted aclitem role grammar is supported. Everything else stays opaque.
        if(eq<0 || slash<eq || !Regex.IsMatch(item.Substring(0,eq),"\\A[a-zA-Z0-9_]*\\z") ||
           !Regex.IsMatch(item.Substring(slash+1),"\\A[a-zA-Z0-9_]+\\z")) { safe.Add("UNRESOLVED_ACL_ENTRY"); continue; }
        string priv=item.Substring(eq+1,slash-eq-1);
        if(!Regex.IsMatch(priv,"\\A(?:[arwdDxtXUCTcm]\\*?)*\\z")) { safe.Add("UNRESOLVED_ACL_ENTRY"); continue; }
        var normalized=new SortedSet<string>(); bool invalid=false;
        for(int i=0;i<priv.Length;i++) {
          string grant=priv[i].ToString(); if(i+1<priv.Length && priv[i+1]=='*') { grant+="*"; i++; }
          if(!normalized.Add(grant)) invalid=true;
        }
        if(invalid) { safe.Add("UNRESOLVED_ACL_ENTRY"); continue; }
        safe.Add(Id(eq==0 ? "PUBLIC" : item.Substring(0,eq))+"="+String.Join(",",new List<string>(normalized).ToArray())+"/"+Id(item.Substring(slash+1)));
      }
      return new SafeCell { Value=String.Join(";",safe.ToArray()), Comparison=Array.IndexOf(safe.ToArray(),"UNRESOLVED_ACL_ENTRY")>=0 ? "UNRESOLVED" : "OBSERVED_NOT_BASELINE_APPROVAL" };
    }
    public SafeRow[] Export(Result r,int index) {
      if(index<4 || index==16) return new SafeRow[0];
      Field[] fields=Shapes.Queries[index-4]; var output=new SafeRow[r.Count];
      for(int i=0;i<r.Count;i++) {
        var row=r.Rows[i]; var cells=new SafeCell[fields.Length];
        if(index==6) tables.Add(row[0]+"."+row[1]);
        for(int j=0;j<fields.Length;j++) {
          string value=row[j]; Field f=fields[j];
          if(f.Kind=="identifier") cells[j]=new SafeCell { Value=Id(value), Comparison=known.Contains(value) ? "ALLOWLISTED_IDENTIFIER" : "UNRESOLVED" };
          else if(f.Kind=="boolean" || f.Kind.StartsWith("enum:")) {
            cells[j]=new SafeCell { Value=value, Comparison="OBSERVED_NOT_BASELINE_APPROVAL" };
            if(index==6 && row[0]=="private" && Array.IndexOf(new string[]{"controllers","authorized_installations","enrollment_audit"},row[1])>=0 &&
               (f.Name=="relrowsecurity" || f.Name=="relforcerowsecurity")) {
              cells[j].Baseline="draft_private_tables_rls_forced"; cells[j].Comparison=value=="t" ? "MATCH" : "DIFFERENT";
            }
          }
          else if(f.Kind=="acl") cells[j]=Acl(value);
          else if(f.Kind=="roles") {
            var roles=new List<string>(); foreach(var role in PgArray.Parse(value)) roles.Add(Id(role));
            cells[j]=new SafeCell { Value=String.Join(",",roles.ToArray()), Comparison="OBSERVED_NOT_BASELINE_APPROVAL" };
          } else if(f.Kind=="config") {
            bool expected=value!=null && (value=="{\"search_path=\\\"\\\"\"}" || value=="{search_path=}");
            cells[j]=new SafeCell { Value=value==null ? "SQL_NULL" : "WITHHELD", Baseline="empty_function_search_path",
              Comparison=value==null ? "UNRESOLVED" : expected ? "MATCH" : "DIFFERENT" };
          } else {
            string key="";
            bool privateRegistry=row.Length>1 && row[0]=="private" && (row[1]=="controllers" || row[1]=="authorized_installations");
            if(index==8 && privateRegistry && f.Name=="definition") key="constraint:"+row[2];
            if(index==7 && privateRegistry && f.Name=="default_expression") key="default:"+row[2];
            if(index==10 && row[0]=="private" &&
              ((row[1]=="controllers" && row[2]=="db_imp_01_owner_read_controllers") ||
               (row[1]=="authorized_installations" && row[2]=="db_imp_01_owner_read_installations") ||
               (row[1]=="enrollment_audit" && row[2]=="db_imp_01_owner_insert_audit"))) key="policy:"+row[2]+":"+f.Name;
            cells[j]=Expression(key,value);
            if(index==4 && (f.Name=="read_only" || f.Name=="isolation")) cells[j]=new SafeCell { Value=value, Comparison="MATCH", Baseline="approved_transaction_guard" };
            if(index==7 && f.Name=="type" && Array.IndexOf(new string[]{"uuid","text","boolean","smallint","bigint","timestamp with time zone","text[]"},value)>=0)
              cells[j]=new SafeCell { Value=value, Comparison="ALLOWLISTED_TYPE" };
          }
        }
        if(index==12) {
          string args=null;
          if(row[0]=="public" && row[1]=="bridge_sync_authorize_v1") args="p_installation_id uuid, p_device_id uuid";
          if(row[0]=="public" && row[1]=="bridge_sync_ingest_v1") args="p_submission jsonb, p_content_sha256 text";
          if(row[0]=="public" && row[1]=="bridge_sync_reconcile_v1") args="p_query jsonb, p_request_id uuid";
          if(row[0]=="private" && row[1]=="bridge_sync_authorize_impl") args="p_installation_id uuid, p_device_id uuid, p_lock boolean";
          if(args!=null) {
            cells[2].Baseline="approved_function_identity_arguments"; cells[2].Comparison=row[2]==args ? "MATCH" : "DIFFERENT";
            cells[4].Baseline=row[0]=="public" ? "rpc_draft_function_owner" : "authorization_draft_function_owner";
            cells[4].Comparison=row[2]!=args ? "UNRESOLVED" : row[4]=="smart_hatch_bridge_owner" ? "MATCH" : "DIFFERENT";
          }
        }
        output[i]=new SafeRow { Cells=cells };
      }
      return output;
    }
    public string[] DraftPresence(bool tableQueryComplete) {
      var checks=new List<string>();
      foreach(string name in new string[]{"private.controllers","private.authorized_installations","private.enrollment_audit"})
        checks.Add(name+":"+(!tableQueryComplete ? "UNRESOLVED" : tables.Contains(name) ? "MATCH_PRESENT_NAME_ONLY" : "DIFFERENT_ABSENT_FROM_DRAFT"));
      return checks.ToArray();
    }
  }
}
