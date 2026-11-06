# Manual-result 0.2 candidate artifacts

Review-only, not enabled or jointly approved. Read ../DB-02_Manual_Result_API_0.2-review.md for the exact delta. Mary approved only M08 draft UUID reservation/reuse; other unresolved choices remain.

schema.json enforces shapes/error flags. reference.cjs is a parsed-object TEST-ONLY oracle with separate relational checks, not a client/server/Auth/database implementation. fixtures.json contains alternative synthetic scenarios and NEW versioned hashes; never upload or silently migrate 0.1 actions. parent-and-change-manifest.json pins unchanged 0.1 bytes.

Optional local checks require existing Ajv8/ajv-formats tooling via NODE_PATH; no app dependency install authorized. From repository/package root: node --test docs/integration/cha-execution/manual-result-0.2.test.cjs
