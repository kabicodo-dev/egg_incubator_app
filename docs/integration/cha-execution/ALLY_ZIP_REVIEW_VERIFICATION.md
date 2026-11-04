# Direct Ally ZIP progress — actual verification

Date: 2026-10-30. Source ZIP unchanged; extracted only into a unique approved
temporary directory. Its 34 entries were checked for allowed Markdown paths
before extraction, then individually indexed and hashed.

- `verify-ally-zip-review.cjs <isolated extracted 01 directory>`: **8/8 passed**.
  Verifies original ZIP hash, file inventory, 13 dispositions, four conditions,
  ten findings/responses, task dependencies and document/source-gate boundaries.
- `verify-portal.cjs`: **9/9 passed**, including the new Partial-only update and
  preserved original task dependencies, original source records and storage rules.
- `completed-report-archive.test.cjs`: **10/10 passed**, retained TAP output.
- `verify-completed-archive-browser.cjs`: **10/10 check groups passed**, including
  new review rendering as Partial, seven completed tasks unchanged, archive body
  preservation, navigation/filter/export, four viewport widths and byte-preserved
  synthetic storage in a fresh isolated Chrome profile. Zero runtime exceptions.
- `git diff --check`: passed (existing LF/CRLF advisory only). Tracked lib,
  arduino, supabase and test source were unchanged by this work.

Two initial document assertions used mismatched/line-wrapped explanatory text;
the checker was corrected and rerun. A new browser assertion first targeted the
older supplied-report section instead of the Cha execution section; its selector
was corrected and all checks rerun. No user data or application behavior was
changed to make those tests pass. Failed patch-context attempts applied no edits.

These are local document/portal checks, not firmware compilation, Flutter tests,
database security, physical integration or approval. No reported Ally build,
host capture, Dart handshake or JCS test was rerun. No new full task is Completed.

Current source record progression: OCT26:C-02B Not started → Partial. Counts:
7 Completed / 8 Partial / 26 Not started / 1 Superseded. The document comparison
is performed, but C-02A's exact-schema review prerequisite still prevents claiming
the complete dependent task. All other owners' task statuses remain unchanged.

The earlier SmartHatch_D01-D06_Review_Package.zip is a preserved pre-direct-ZIP
snapshot; it is not silently overwritten. The current ledger and amendment in
docs/contract-review/ and the rebuilt full portal carry this later review.
