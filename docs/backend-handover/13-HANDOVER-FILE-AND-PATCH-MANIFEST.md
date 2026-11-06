# 13 — Handover file and patch manifest

Baseline: `C:/EggIncubator/egg_incubator_app` / `cha-branch2` / `2d2622e6b1b0c538dda3c3023e97ae467eaf53b6`. Inspection 2026-11-03. Local read-only Git/path/hash evidence; no transfer, patch export/application, commit or remote access. Hashes prove integrity, not authorship/approval/runtime compatibility.

## Transfer rules and inspection levels

Tracked means this local index/HEAD, not proof of hosted/Kath availability. Compare exact HEAD/file; obtain missing content only by separately agreed non-overwriting transfer. Local-only means initially untracked here, not absent everywhere. Review-package copies are not independent test results. Rows are inventoried/hash-checked only unless document 01/topic text explicitly records content inspection. Git last-touch is provenance, not sole authorship. Raw Q12 source was not independently audited.

`.env`, Git credential/remotes configuration, CLI link metadata and external certificates/credentials were not read. `supabase/config.toml` is path-inventoried only, not opened/hashed. Never transfer secret history from backup commit.

## Exact pre-existing working-tree status

3 unstaged tracked modifications + 689 untracked = 692 initial entries; staged/deleted/unmerged index entries zero. Every path below pre-existed this task.
```text
 M docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md
 M docs/validate-c02-provisional.cjs
 M supabase/functions/bridge-sync/README.md
?? SmartHatch_Cha_Backend_Handoff.md
?? SmartHatch_Cha_Backend_Task_Reports.md
?? SmartHatch_Cha_Backend_Updated.html
?? SmartHatch_Cha_Reports_Import.json
?? SmartHatch_D01-D06_Review_Package.zip
?? SmartHatch_D01-D06_Review_Package/Ally-2026-10-30-Packet-Review.md
?? SmartHatch_D01-D06_Review_Package/CONTRACT-FREEZE-01_Team_Decisions.md
?? SmartHatch_D01-D06_Review_Package/D04_D06_Mary_Backend_Position.md
?? SmartHatch_D01-D06_Review_Package/DB-02_30Oct_Consolidated_Alignment.md
?? SmartHatch_D01-D06_Review_Package/DB-02_Conflict_Receipt_And_Recovery.md
?? SmartHatch_D01-D06_Review_Package/DB-02_Exact_Bridge_Sync_API.md
?? SmartHatch_D01-D06_Review_Package/DB-02_Proposed_Schema_And_Security.md
?? SmartHatch_D01-D06_Review_Package/INTEGRATION-CONTRACT-03_Shared_Decision_Register.md
?? SmartHatch_D01-D06_Review_Package/ORIGINAL-C-02-Flutter-Compatibility-Review.md
?? SmartHatch_D01-D06_Review_Package/README.md
?? SmartHatch_D01-D06_Review_Package/SmartHatch_Shared_Communication_Contract_v1.3_DECISION_READY_DRAFT.md
?? SmartHatch_D01-D06_Review_Package/manifest.json
?? SmartHatch_Manual_Result_0.1_Review.zip
?? SmartHatch_Manual_Result_0.1_Review/README.md
?? SmartHatch_Manual_Result_0.1_Review/docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md
?? SmartHatch_Manual_Result_0.1_Review/docs/contract-review/D04_D06_Mary_Backend_Position.md
?? SmartHatch_Manual_Result_0.1_Review/docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md
?? SmartHatch_Manual_Result_0.1_Review/docs/contract-review/DB-02_Manual_Result_API_0.1-review.md
?? SmartHatch_Manual_Result_0.1_Review/docs/contract-review/manual-result-0.1.closure-matrix.json
?? SmartHatch_Manual_Result_0.1_Review/docs/contract-review/manual-result-0.1.fixtures.json
?? SmartHatch_Manual_Result_0.1_Review/docs/contract-review/manual-result-0.1.schema.json
?? SmartHatch_Manual_Result_0.1_Review/docs/integration/cha-execution/MANUAL_RESULT_PREPARATION_REPORT.md
?? SmartHatch_Manual_Result_0.1_Review/docs/integration/cha-execution/manual-result-proposal.tap
?? SmartHatch_Manual_Result_0.1_Review/docs/integration/cha-execution/manual-result-proposal.test.cjs
?? SmartHatch_Manual_Result_0.1_Review/docs/integration/cha-execution/manual-result-reference.cjs
?? SmartHatch_Manual_Result_0.1_Review/manifest.json
?? SmartHatch_Manual_Result_0.2_Review.zip
?? SmartHatch_Remaining_Tasks_Review_Packet.zip
?? docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.3.md
?? docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.4_Bluetooth_Android_Bridge.md
?? docs/contract-review/ARCH-05_K06_Architecture_Amendment_Record.md
?? docs/contract-review/ARCH-05_source_manifest.json
?? docs/contract-review/C02_Wire_Family_Decision_Request_2026-11-02.md
?? docs/contract-review/D04_D06_Mary_Backend_Position.md
?? docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md
?? docs/contract-review/DB-02_Manual_Result_API_0.1-review.md
?? docs/contract-review/DB-02_Manual_Result_API_0.2-review.md
?? docs/contract-review/IMMEDIATE_ACTION_Missing_Inputs_Checklist.md
?? docs/contract-review/MARY_Backend_Preparation_2026-11-01.inputs.json
?? docs/contract-review/MARY_Backend_Preparation_2026-11-01.md
?? docs/contract-review/Q06_Q07_Kath_Mary_Decision_Proposal_0.1.md
?? docs/contract-review/Q06_Q07_Kath_Response_Rev3_Receipt_2026-11-02.md
?? docs/contract-review/Q07_Plain_Language_Access_Proposal_0.1.md
?? docs/contract-review/Q07_Plain_Language_Access_Proposal_0.2.md
?? docs/contract-review/Q07_Provider_Session_Binding_Policy_0.1.md
?? docs/contract-review/Q07_Provider_Session_Binding_Policy_0.2.md
?? docs/contract-review/Q07_SMTP_Test_Project_Plan_0.1.md
?? docs/contract-review/SHARED_INSTRUCTIONS_Backend_Review_2026-11-01.md
?? docs/contract-review/manual-result-0.1.closure-matrix.json
?? docs/contract-review/manual-result-0.1.fixtures.json
?? docs/contract-review/manual-result-0.1.schema.json
?? docs/contract-review/manual-result-0.2-review/README.md
?? docs/contract-review/manual-result-0.2-review/fixtures.json
?? docs/contract-review/manual-result-0.2-review/generated-by.txt
?? docs/contract-review/manual-result-0.2-review/parent-and-change-manifest.json
?? docs/contract-review/manual-result-0.2-review/reference.cjs
?? docs/contract-review/manual-result-0.2-review/schema.json
?? docs/contract-review/verify-mary-backend-preparation.cjs
?? docs/instructions/BACKEND.md
?? docs/integration/cha-execution/2026-10-30-test-catalog.json
?? docs/integration/cha-execution/2026-10-30-test-catalog.sql
?? docs/integration/cha-execution/ALLY_C02_20261102_RECEIPT_AND_CLOSURE.md
?? docs/integration/cha-execution/ALLY_REPORT_REVIEW.md
?? docs/integration/cha-execution/ALLY_ZIP_C02B_REVIEW.md
?? docs/integration/cha-execution/ALLY_ZIP_REVIEW_VERIFICATION.md
?? docs/integration/cha-execution/APPROVED_SECURITY_TEST_REPORT.md
?? docs/integration/cha-execution/AUDIT_COMPLETION_REVIEW.md
?? docs/integration/cha-execution/COMPLETED_REPORT_ARCHIVE_VERIFICATION.md
?? docs/integration/cha-execution/INDEPENDENT_SCHEMA_VERIFICATION.md
?? docs/integration/cha-execution/INDEPENDENT_WORK_PORTAL_VERIFICATION.md
?? docs/integration/cha-execution/KATH_02_DELTA_ACCEPT_RECEIPT.md
?? docs/integration/cha-execution/KATH_CLOSURE_20261031_RECEIPT.md
?? docs/integration/cha-execution/KATH_DART_EVIDENCE_20261031_RECEIPT.md
?? docs/integration/cha-execution/KATH_FOCUSED_REVIEW_RECEIPT.md
?? docs/integration/cha-execution/KATH_REMAINING_DECISIONS_RECEIPT.md
?? docs/integration/cha-execution/MANUAL_RESULT_0.2_PREPARATION_REPORT.md
?? docs/integration/cha-execution/MANUAL_RESULT_PREPARATION_REPORT.md
?? docs/integration/cha-execution/OCT26_C03_ARCHITECTURE_ALIGNMENT.md
?? docs/integration/cha-execution/ORIGINAL_C09_MONITORING_BOUNDARIES.md
?? docs/integration/cha-execution/PORTFOLIO_EXECUTION_REPORT.md
?? docs/integration/cha-execution/Q12_CERTIFICATE_PROVENANCE_OWNER_UPDATE.md
?? docs/integration/cha-execution/Q12_CERTIFICATE_PUBLIC_REFERENCE_ASSESSMENT.md
?? docs/integration/cha-execution/Q12_PHASE_A_APPROVAL_AND_BLOCKER.md
?? docs/integration/cha-execution/Q12_PHASE_A_ATTEMPT_1_RECEIPT.md
?? docs/integration/cha-execution/Q12_PHASE_A_PREFLIGHT_20261031_103006Z.json
?? docs/integration/cha-execution/Q12_Phase_A_Read_Only.sql
?? docs/integration/cha-execution/Q12_Test_Project_Approval_Plan.md
?? docs/integration/cha-execution/REMAINING_QUEUE_AFTER_C03.md
?? docs/integration/cha-execution/SUPPLEMENTAL_AUDIT_EVIDENCE.md
?? docs/integration/cha-execution/TEAM_APPROVALS_AND_LOCAL_PLAN.md
?? docs/integration/cha-execution/ally-c02-receipt-verification-20261102.json
?? docs/integration/cha-execution/ally-c02-schema-revalidation-20261102.txt
?? docs/integration/cha-execution/ally-export-review/01-ORIGINAL_A-06.md
?? docs/integration/cha-execution/ally-export-review/02-ORIGINAL_A-08.md
?? docs/integration/cha-execution/ally-export-review/03-OCT26_HW-02.md
?? docs/integration/cha-execution/ally-export-review/04-OCT26_HW-03.md
?? docs/integration/cha-execution/ally-export-review/05-OCT26_HW-04.md
?? docs/integration/cha-execution/ally-export-review/06-OCT26_HW-05.md
?? docs/integration/cha-execution/ally-export-review/07-OCT26_HW-06.md
?? docs/integration/cha-execution/ally-export-review/08-OCT26_HW-07.md
?? docs/integration/cha-execution/ally-export-review/09-OCT26_HW-08.md
?? docs/integration/cha-execution/ally-export-review/10-OCT26_HW-09.md
?? docs/integration/cha-execution/ally-export-review/11-OCT26_HW-09.md
?? docs/integration/cha-execution/ally-export-review/12-OCT26_HW-10.md
?? docs/integration/cha-execution/ally-export-review/13-OCT26_HW-10.md
?? docs/integration/cha-execution/ally-export-review/14-OCT26_A-01.md
?? docs/integration/cha-execution/ally-export-review/15-OCT26_A-02.md
?? docs/integration/cha-execution/ally-export-review/16-OCT26_A-03.md
?? docs/integration/cha-execution/ally-export-review/17-OCT26_A-04.md
?? docs/integration/cha-execution/ally-export-review/18-OCT26_A-05.md
?? docs/integration/cha-execution/ally-export-review/19-OCT26_A-06.md
?? docs/integration/cha-execution/ally-export-review/20-OCT26_A-07.md
?? docs/integration/cha-execution/ally-export-review/21-OCT26_A-08.md
?? docs/integration/cha-execution/ally-export-review/22-OCT26_A-09.md
?? docs/integration/cha-execution/ally-export-review/23-OCT26_A-10.md
?? docs/integration/cha-execution/ally-export-review/24-OCT26_HW-01.md
?? docs/integration/cha-execution/ally-export-review/25-OCT26_HW-02.md
?? docs/integration/cha-execution/ally-export-review/26-NEW_PILOT-GATE-01.md
?? docs/integration/cha-execution/ally-export-review/index.json
?? docs/integration/cha-execution/ally-report-review-validation.json
?? docs/integration/cha-execution/ally-zip-progress.json
?? docs/integration/cha-execution/ally-zip-review-index.json
?? docs/integration/cha-execution/approved-security-results-validation.json
?? docs/integration/cha-execution/approved-security-test-latest.json
?? docs/integration/cha-execution/arch05-record-verification.json
?? docs/integration/cha-execution/audit-completion-browser-results.json
?? docs/integration/cha-execution/audit-completion.json
?? docs/integration/cha-execution/build-manual-result-0.2.cjs
?? docs/integration/cha-execution/build-portal.cjs
?? docs/integration/cha-execution/build-remaining-workqueue.cjs
?? docs/integration/cha-execution/c02-schema-revalidation.txt
?? docs/integration/cha-execution/completed-report-archive-browser.json
?? docs/integration/cha-execution/completed-report-archive-manifest.json
?? docs/integration/cha-execution/completed-report-archive-unit.tap
?? docs/integration/cha-execution/completed-report-archive.cjs
?? docs/integration/cha-execution/completed-report-archive.test.cjs
?? docs/integration/cha-execution/decision-consolidation-validation.json
?? docs/integration/cha-execution/independent-schema-verification.json
?? docs/integration/cha-execution/independent-task-completions.json
?? docs/integration/cha-execution/inspect-ally-export.cjs
?? docs/integration/cha-execution/kath-02-delta-evidence-verification.json
?? docs/integration/cha-execution/kath-closure-20261031-verification.json
?? docs/integration/cha-execution/kath-dart-evidence-20261031-verification.json
?? docs/integration/cha-execution/kath-focused-review-inputs/C02-provisional-communication-contract.md
?? docs/integration/cha-execution/kath-focused-review-inputs/C02-provisional.examples.json
?? docs/integration/cha-execution/kath-focused-review-inputs/C02-provisional.schema.json
?? docs/integration/cha-execution/kath-focused-review-inputs/CONTRACT-FREEZE-01_Team_Decisions.md
?? docs/integration/cha-execution/kath-focused-review-inputs/DB-02_30Oct_Consolidated_Alignment.md
?? docs/integration/cha-execution/kath-focused-review-inputs/Kath-C02-Provisional-Focused-Review-2026-10-30.md
?? docs/integration/cha-execution/kath-focused-review-validation.json
?? docs/integration/cha-execution/manual-result-0.2-local-recheck-20261031.tap
?? docs/integration/cha-execution/manual-result-0.2.tap
?? docs/integration/cha-execution/manual-result-0.2.test.cjs
?? docs/integration/cha-execution/manual-result-jsonschema.tap
?? docs/integration/cha-execution/manual-result-jsonschema.test.cjs
?? docs/integration/cha-execution/manual-result-proposal.tap
?? docs/integration/cha-execution/manual-result-proposal.test.cjs
?? docs/integration/cha-execution/manual-result-reference-revalidation.tap
?? docs/integration/cha-execution/manual-result-reference.cjs
?? docs/integration/cha-execution/mary-d04-d06-answers.json
?? docs/integration/cha-execution/mary-d04-d06-browser-publication.json
?? docs/integration/cha-execution/mary-d04-d06-validation.json
?? docs/integration/cha-execution/monitoring-backend-regression.tap
?? docs/integration/cha-execution/monitoring-boundary-probes.json
?? docs/integration/cha-execution/monitoring-boundary-targeted.tap
?? docs/integration/cha-execution/monitoring-verification.json
?? docs/integration/cha-execution/oct26-c03-architecture-targeted.tap
?? docs/integration/cha-execution/oct26-c03-backend-regression.tap
?? docs/integration/cha-execution/oct26-c03-validation.json
?? docs/integration/cha-execution/package-decision-consolidation.cjs
?? docs/integration/cha-execution/package-manual-result-0.2.cjs
?? docs/integration/cha-execution/package-manual-result-review.cjs
?? docs/integration/cha-execution/package-remaining-review.cjs
?? docs/integration/cha-execution/portal-browser-results.json
?? docs/integration/cha-execution/portal-static-results.json
?? docs/integration/cha-execution/portal-structural-results.json
?? docs/integration/cha-execution/portfolio-backend-regression.tap
?? docs/integration/cha-execution/portfolio-source-check.cjs
?? docs/integration/cha-execution/portfolio-source-observations.json
?? docs/integration/cha-execution/prepare-arch05-record.cjs
?? docs/integration/cha-execution/probe-monitoring-boundaries.cjs
?? docs/integration/cha-execution/q12-controller/Invoke-Q12PhaseA.ps1
?? docs/integration/cha-execution/q12-controller/Q12Controller.Tests.cs
?? docs/integration/cha-execution/q12-controller/Q12Controller.cs
?? docs/integration/cha-execution/q12-controller/README.md
?? docs/integration/cha-execution/q12-controller/Test-Q12Controller.ps1
?? docs/integration/cha-execution/q12-controller/local-test-1118803c180d42a88e5491410bb69584.json
?? docs/integration/cha-execution/q12-controller/local-test-8175115be7ba4e9ca1cad4a9fcec471f.json
?? docs/integration/cha-execution/q12-controller/v2/CERTIFICATE_PROVENANCE.md
?? docs/integration/cha-execution/q12-controller/v2/Correction.Tests.cs
?? docs/integration/cha-execution/q12-controller/v2/DurableController.cs
?? docs/integration/cha-execution/q12-controller/v2/Invoke-Q12PhaseA-V2.ps1
?? docs/integration/cha-execution/q12-controller/v2/ModelPolicy.cs
?? docs/integration/cha-execution/q12-controller/v2/NativeBoundary.cs
?? docs/integration/cha-execution/q12-controller/v2/README.md
?? docs/integration/cha-execution/q12-controller/v2/Test-Corrections.ps1
?? docs/integration/cha-execution/q12-controller/v2/Write-ReviewInventory.ps1
?? docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/not-a-directory
?? docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/synthetic-root-bytes.txt
?? docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/test-results.json
?? docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/not-a-directory
?? docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/test-results.json
?? docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/not-a-directory
?? docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/synthetic-root-bytes.txt
?? docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/test-results.json
?? docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/not-a-directory
?? docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/synthetic-root-bytes.txt
?? docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/test-results.json
?? docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/not-a-directory
?? docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/synthetic-root-bytes.txt
?? docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/test-results.json
?? docs/integration/cha-execution/q12-controller/v2/review-inventory.json
?? docs/integration/cha-execution/q12-controller/v3/CERTIFICATE_PROVENANCE.md
?? docs/integration/cha-execution/q12-controller/v3/Correction.Tests.cs
?? docs/integration/cha-execution/q12-controller/v3/DurableController.cs
?? docs/integration/cha-execution/q12-controller/v3/Followup.Tests.cs
?? docs/integration/cha-execution/q12-controller/v3/Invoke-Q12PhaseA-V3.ps1
?? docs/integration/cha-execution/q12-controller/v3/ModelPolicy.cs
?? docs/integration/cha-execution/q12-controller/v3/NativeBoundary.cs
?? docs/integration/cha-execution/q12-controller/v3/README.md
?? docs/integration/cha-execution/q12-controller/v3/SourceSnapshot.psm1
?? docs/integration/cha-execution/q12-controller/v3/Test-Corrections.ps1
?? docs/integration/cha-execution/q12-controller/v3/Write-ReviewInventory.ps1
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.1.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.2.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.3.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.4.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/not-a-directory
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/compiler/w1xninxq.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/compiler/w1xninxq.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/compiler/w1xninxq.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/compiler/w1xninxq.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/compiler/w1xninxq.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-memory-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-modification-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-emergency-only-recovery/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-emergency-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-emergency-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-root-bytes.txt
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/test-results.json
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.1.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.2.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.3.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.4.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/not-a-directory
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/compiler/4yoiy3y0.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/compiler/4yoiy3y0.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/compiler/4yoiy3y0.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/compiler/4yoiy3y0.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/compiler/4yoiy3y0.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-memory-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-modification-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-emergency-only-recovery/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-emergency-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-emergency-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-root-bytes.txt
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/test-results.json
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.1.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.2.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.3.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.4.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/not-a-directory
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/compiler/skunt1lh.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/compiler/skunt1lh.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/compiler/skunt1lh.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/compiler/skunt1lh.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/compiler/skunt1lh.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-memory-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-modification-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-emergency-only-recovery/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-emergency-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-emergency-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-root-bytes.txt
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/test-results.json
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.1.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.2.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.3.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.4.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/not-a-directory
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/compiler/tvdk0wkm.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/compiler/tvdk0wkm.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/compiler/tvdk0wkm.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/compiler/tvdk0wkm.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/compiler/tvdk0wkm.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-memory-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-modification-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-emergency-only-recovery/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-emergency-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-emergency-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-root-bytes.txt
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/test-results.json
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.1.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.2.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.3.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.4.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/not-a-directory
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/compiler/4asulfos.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/compiler/4asulfos.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/compiler/4asulfos.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/compiler/4asulfos.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/compiler/4asulfos.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-memory-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-modification-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-emergency-only-recovery/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-emergency-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-emergency-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-root-bytes.txt
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/test-results.json
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.1.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.2.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.3.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.4.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/journal-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/journal-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/not-a-directory
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/serialization-failure/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/serialization-failure/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/compiler/b4uqrthv.0.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/compiler/b4uqrthv.cmdline
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/compiler/b4uqrthv.err
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/compiler/b4uqrthv.out
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/compiler/b4uqrthv.tmp
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-memory-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-modification-test/Probe.cs
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-emergency-only-recovery/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-emergency-success/emergency.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-emergency-success/journal.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-root-bytes.txt
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-sanitized-example.jsonl
?? docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/test-results.json
?? docs/integration/cha-execution/q12-controller/v3/review-inventory.json
?? docs/integration/cha-execution/q12-execution-package/PENDING_REMOTE_AND_CLOSURE.md
?? docs/integration/cha-execution/q12-execution-package/README.md
?? docs/integration/cha-execution/q12-execution-package/REQUIREMENT_MATRIX.md
?? docs/integration/cha-execution/q12-execution-package/REVIEW.md
?? docs/integration/cha-execution/q12-execution-package/Verify-AdditionalControls.ps1
?? docs/integration/cha-execution/q12-execution-package/Verify-LocalEvidence.ps1
?? docs/integration/cha-execution/q12-execution-package/Write-PackageInventory.cjs
?? docs/integration/cha-execution/q12-execution-package/additional-controls.json
?? docs/integration/cha-execution/q12-execution-package/local-review-evidence.json
?? docs/integration/cha-execution/q12-execution-package/original-scope-extract.json
?? docs/integration/cha-execution/q12-execution-package/package-inventory.json
?? docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.0.cs
?? docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.1.cs
?? docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.2.cs
?? docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.cmdline
?? docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.err
?? docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.out
?? docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.tmp
?? docs/integration/cha-execution/q12-phase-a-status.json
?? docs/integration/cha-execution/received-ally-c02-20261102.txt
?? docs/integration/cha-execution/received-kath-02-20261031/RESPONSE.md
?? docs/integration/cha-execution/received-kath-02-20261031/dart-version.stderr.txt
?? docs/integration/cha-execution/received-kath-02-20261031/dart-version.stdout.txt
?? docs/integration/cha-execution/received-kath-02-20261031/dart.stderr.txt
?? docs/integration/cha-execution/received-kath-02-20261031/dart.stdout.txt
?? docs/integration/cha-execution/received-kath-02-20261031/dart_manual_result_02_review.dart
?? docs/integration/cha-execution/received-kath-02-20261031/evidence-manifest.json
?? docs/integration/cha-execution/received-kath-02-20261031/inputs.stderr.txt
?? docs/integration/cha-execution/received-kath-02-20261031/inputs.stdout.txt
?? docs/integration/cha-execution/received-kath-02-20261031/node.stderr.txt
?? docs/integration/cha-execution/received-kath-02-20261031/node.stdout.txt
?? docs/integration/cha-execution/received-kath-02-20261031/verify_inputs.ps1
?? docs/integration/cha-execution/received-kath-dart-20261031/README.md
?? docs/integration/cha-execution/received-kath-dart-20261031/TASK_CARD_MAPPING.md
?? docs/integration/cha-execution/received-kath-dart-20261031/dart_manual_result_review.dart
?? docs/integration/cha-execution/received-kath-dart-20261031/dart_manual_result_review.recorded-stdout.txt
?? docs/integration/cha-execution/received-kath-dart-20261031/manifest.json
?? docs/integration/cha-execution/remaining-decision-requests.json
?? docs/integration/cha-execution/remaining-portfolio-section.cjs
?? docs/integration/cha-execution/remaining-queue-after-c03.json
?? docs/integration/cha-execution/remaining-work-items.json
?? docs/integration/cha-execution/remaining-workqueue.tap
?? docs/integration/cha-execution/remaining-workqueue.test.cjs
?? docs/integration/cha-execution/review-kath-focused.cjs
?? docs/integration/cha-execution/review-supplemental-csvs.cjs
?? docs/integration/cha-execution/review-supplied-csvs.cjs
?? docs/integration/cha-execution/run-approved-security-test.cjs
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-06-412Z/error.json
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-18-577Z/cli-role-initialization-note.txt
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-18-577Z/fresh-catalog.json
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-18-577Z/status.json
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-18-577Z/verified-target.json
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/cleanup-results.json
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/cli-role-initialization-note.txt
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/fresh-catalog.json
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/probe-results.json
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/probe.sql
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/status.json
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/verified-target.json
?? docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/verify-cleanup.sql
?? docs/integration/cha-execution/security-test-plan-validation.json
?? docs/integration/cha-execution/security-test-plan.json
?? docs/integration/cha-execution/serve-portal.cjs
?? docs/integration/cha-execution/supplemental-csv-review.json
?? docs/integration/cha-execution/supplied-csv-review.json
?? docs/integration/cha-execution/task-recovery-c02-isolation.json
?? docs/integration/cha-execution/task-recovery-c02-isolation.txt
?? docs/integration/cha-execution/test-edge-functions-audit.json
?? docs/integration/cha-execution/validate-ally-export-review.cjs
?? docs/integration/cha-execution/validate-approved-security-results.cjs
?? docs/integration/cha-execution/validate-mary-d04-d06-answers.cjs
?? docs/integration/cha-execution/validate-oct26-c03.cjs
?? docs/integration/cha-execution/validate-security-test-plan.cjs
?? docs/integration/cha-execution/verify-ally-c02-receipt-20261102.cjs
?? docs/integration/cha-execution/verify-ally-zip-review.cjs
?? docs/integration/cha-execution/verify-completed-archive-browser.cjs
?? docs/integration/cha-execution/verify-independent-schema-work.cjs
?? docs/integration/cha-execution/verify-kath-02-delta-evidence.cjs
?? docs/integration/cha-execution/verify-kath-closure-20261031.cjs
?? docs/integration/cha-execution/verify-kath-dart-evidence-20261031.cjs
?? docs/integration/cha-execution/verify-monitoring-evidence.cjs
?? docs/integration/cha-execution/verify-portal.cjs
?? docs/integration/decision-consolidation-2026-10-30/Ally-2026-10-30-Packet-Review.md
?? docs/integration/decision-consolidation-2026-10-30/CONTRACT-FREEZE-01_Team_Decisions.md
?? docs/integration/decision-consolidation-2026-10-30/D04_D06_Mary_Backend_Position.md
?? docs/integration/decision-consolidation-2026-10-30/DB-02_30Oct_Consolidated_Alignment.md
?? docs/integration/decision-consolidation-2026-10-30/DB-02_Conflict_Receipt_And_Recovery.md
?? docs/integration/decision-consolidation-2026-10-30/DB-02_Exact_Bridge_Sync_API.md
?? docs/integration/decision-consolidation-2026-10-30/DB-02_Proposed_Schema_And_Security.md
?? docs/integration/decision-consolidation-2026-10-30/INTEGRATION-CONTRACT-03_Shared_Decision_Register.md
?? docs/integration/decision-consolidation-2026-10-30/ORIGINAL-C-02-Flutter-Compatibility-Review.md
?? docs/integration/decision-consolidation-2026-10-30/README.md
?? docs/integration/decision-consolidation-2026-10-30/SmartHatch_Shared_Communication_Contract_v1.3_DECISION_READY_DRAFT.md
?? docs/integration/decision-consolidation-2026-10-30/manifest.json
?? docs/integration/manual-result-0.1-review-package/README.md
?? docs/integration/manual-result-0.1-review-package/docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md
?? docs/integration/manual-result-0.1-review-package/docs/contract-review/D04_D06_Mary_Backend_Position.md
?? docs/integration/manual-result-0.1-review-package/docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md
?? docs/integration/manual-result-0.1-review-package/docs/contract-review/DB-02_Manual_Result_API_0.1-review.md
?? docs/integration/manual-result-0.1-review-package/docs/contract-review/manual-result-0.1.closure-matrix.json
?? docs/integration/manual-result-0.1-review-package/docs/contract-review/manual-result-0.1.fixtures.json
?? docs/integration/manual-result-0.1-review-package/docs/contract-review/manual-result-0.1.schema.json
?? docs/integration/manual-result-0.1-review-package/docs/integration/cha-execution/MANUAL_RESULT_PREPARATION_REPORT.md
?? docs/integration/manual-result-0.1-review-package/docs/integration/cha-execution/manual-result-proposal.tap
?? docs/integration/manual-result-0.1-review-package/docs/integration/cha-execution/manual-result-proposal.test.cjs
?? docs/integration/manual-result-0.1-review-package/docs/integration/cha-execution/manual-result-reference.cjs
?? docs/integration/manual-result-0.1-review-package/manifest.json
?? docs/integration/manual-result-0.2-review-package/README.md
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/D04_D06_Mary_Backend_Position.md
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/DB-02_Manual_Result_API_0.1-review.md
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/DB-02_Manual_Result_API_0.2-review.md
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.1.closure-matrix.json
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.1.fixtures.json
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.1.schema.json
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/README.md
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/fixtures.json
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/generated-by.txt
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/parent-and-change-manifest.json
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/reference.cjs
?? docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/schema.json
?? docs/integration/manual-result-0.2-review-package/docs/integration/cha-execution/MANUAL_RESULT_0.2_PREPARATION_REPORT.md
?? docs/integration/manual-result-0.2-review-package/docs/integration/cha-execution/manual-result-0.2.tap
?? docs/integration/manual-result-0.2-review-package/docs/integration/cha-execution/manual-result-0.2.test.cjs
?? docs/integration/manual-result-0.2-review-package/generated-by.txt
?? docs/integration/manual-result-0.2-review-package/manifest.json
?? docs/integration/remaining-task-review-package/README.md
?? docs/integration/remaining-task-review-package/docs/C02-provisional-communication-contract.md
?? docs/integration/remaining-task-review-package/docs/C02-provisional.examples.json
?? docs/integration/remaining-task-review-package/docs/C02-provisional.schema.json
?? docs/integration/remaining-task-review-package/docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.3.md
?? docs/integration/remaining-task-review-package/docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.4_Bluetooth_Android_Bridge.md
?? docs/integration/remaining-task-review-package/docs/contract-review/ARCH-05_K06_Architecture_Amendment_Record.md
?? docs/integration/remaining-task-review-package/docs/contract-review/ARCH-05_source_manifest.json
?? docs/integration/remaining-task-review-package/docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md
?? docs/integration/remaining-task-review-package/docs/contract-review/D04_D06_Mary_Backend_Position.md
?? docs/integration/remaining-task-review-package/docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md
?? docs/integration/remaining-task-review-package/docs/contract-review/DB-02_Manual_Result_API_0.1-review.md
?? docs/integration/remaining-task-review-package/docs/contract-review/manual-result-0.1.closure-matrix.json
?? docs/integration/remaining-task-review-package/docs/contract-review/manual-result-0.1.fixtures.json
?? docs/integration/remaining-task-review-package/docs/contract-review/manual-result-0.1.schema.json
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/ALLY_ZIP_C02B_REVIEW.md
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/INDEPENDENT_SCHEMA_VERIFICATION.md
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/KATH_FOCUSED_REVIEW_RECEIPT.md
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/KATH_REMAINING_DECISIONS_RECEIPT.md
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/ORIGINAL_C09_MONITORING_BOUNDARIES.md
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/PORTFOLIO_EXECUTION_REPORT.md
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/c02-schema-revalidation.txt
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/independent-schema-verification.json
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/manual-result-jsonschema.tap
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/portfolio-backend-regression.tap
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/portfolio-source-observations.json
?? docs/integration/remaining-task-review-package/docs/integration/cha-execution/remaining-workqueue.tap
?? docs/integration/remaining-task-review-package/docs/validate-c02-provisional.cjs
?? docs/integration/remaining-task-review-package/generated-by.txt
?? docs/integration/remaining-task-review-package/manifest.json
?? docs/integration/remaining-task-review-package/received-reviews/Ally-D02-D04-D06-response.md
?? docs/integration/remaining-task-review-package/received-reviews/Kath-C02-focused.md
?? docs/integration/remaining-task-review-package/received-reviews/Kath-remaining-proposal.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/README.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/REMAINING_DECISIONS_ALL_OWNERS.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/decision-index.json
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/evidence-index.json
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/distribution.csv
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/integration-observation.csv
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/pilot-observation.csv
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/profile-comparison.csv
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/security-matrix.json
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/usability-script.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/generated-by.txt
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/planned-test-records.json
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/preparation-summary.json
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/task-index.json
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/CURRENT_DB-IMP-01.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/CURRENT_INT-IMP-01.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_ARCH-05.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_ARCH-06.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-02A.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-02B.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-02C.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-04.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-05.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-06.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-07.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-08.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-09.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-10.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-11.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-01.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-02.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-03.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-04.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-05.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-06.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-07.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-08.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-09.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-10.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-11.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-02.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-03.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-04.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-05.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-06.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-07.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-08.md
?? docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-09.md
?? docs/integration/remaining-task-workqueue/README.md
?? docs/integration/remaining-task-workqueue/REMAINING_DECISIONS_ALL_OWNERS.md
?? docs/integration/remaining-task-workqueue/decision-index.json
?? docs/integration/remaining-task-workqueue/evidence-index.json
?? docs/integration/remaining-task-workqueue/forms/distribution.csv
?? docs/integration/remaining-task-workqueue/forms/integration-observation.csv
?? docs/integration/remaining-task-workqueue/forms/pilot-observation.csv
?? docs/integration/remaining-task-workqueue/forms/profile-comparison.csv
?? docs/integration/remaining-task-workqueue/forms/security-matrix.json
?? docs/integration/remaining-task-workqueue/forms/usability-script.md
?? docs/integration/remaining-task-workqueue/generated-by.txt
?? docs/integration/remaining-task-workqueue/planned-test-records.json
?? docs/integration/remaining-task-workqueue/preparation-summary.json
?? docs/integration/remaining-task-workqueue/task-index.json
?? docs/integration/remaining-task-workqueue/tasks/CURRENT_DB-IMP-01.md
?? docs/integration/remaining-task-workqueue/tasks/CURRENT_INT-IMP-01.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_ARCH-05.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_ARCH-06.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-02A.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-02B.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-02C.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-04.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-05.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-06.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-07.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-08.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-09.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-10.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_C-11.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-01.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-02.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-03.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-04.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-05.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-06.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-07.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-08.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-09.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-10.md
?? docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-11.md
?? docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-02.md
?? docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-03.md
?? docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-04.md
?? docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-05.md
?? docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-06.md
?? docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-07.md
?? docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-08.md
?? docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-09.md
?? supabase/AGENTS.md
?? supabase/README.md
?? supabase/dev/README.md
?? supabase/drafts/README.md
?? test/backend/architecture_alignment_test.mjs
?? test/backend/monitoring_boundary_test.mjs
```

## Available Git refs and divergence
```text
refs/heads/ally-branch3 b73d499d7f46f5914f25f5b56fca5a0101a182ac
refs/heads/cha-branch2 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6
refs/heads/development e5ee5d13d5531110435e143315a2cd8a66442cc2
refs/heads/kath-branch1 833c4b0443e9e2ff41d9ecf5b0ee144c617b9f76
refs/heads/main b73d499d7f46f5914f25f5b56fca5a0101a182ac
refs/heads/resolve-pr35 e5709214129c6c0f5966d549affbccf42c8f6835
refs/heads/staging 45f31f9380e234eb93796f676f5ec1a20dc78924
refs/remotes/origin/HEAD 12122865f9a860116bfc1f7cc211fe836f965fe1
refs/remotes/origin/ally-branch3 e5709214129c6c0f5966d549affbccf42c8f6835
refs/remotes/origin/cha-branch2 c7a26cfcaa619708aff4f793e8068ee176a6cf58
refs/remotes/origin/development c7a26cfcaa619708aff4f793e8068ee176a6cf58
refs/remotes/origin/kath-branch1 cab32382af2476a7983e9af82117eed478578de7
refs/remotes/origin/main 12122865f9a860116bfc1f7cc211fe836f965fe1
refs/remotes/origin/pr-57-review 18005ba09ed73d6846a3ce61c9ba813f288196e8
refs/remotes/origin/staging 300a4c0dfb73412502c1485ebb34a01a18c755b4
```
No other local branch has commits outside HEAD ancestry (`git log --branches --not HEAD` empty). Cached refs are stale evidence, not current hosted state. HEAD-only / ref-only divergence:
```text
refs/remotes/origin/HEAD: 16	0
refs/remotes/origin/ally-branch3: 33	0
refs/remotes/origin/cha-branch2: 2	0
refs/remotes/origin/development: 2	0
refs/remotes/origin/kath-branch1: 37	0
refs/remotes/origin/main: 16	0
refs/remotes/origin/pr-57-review: 13	2
  ref-only: 18005ba09ed73d6846a3ce61c9ba813f288196e8 kabicodo-dev APP-CONFIG: fail deployment when Supabase config is missing
  ref-only: 8db876d7aeaf2d6a3eb9efb30668dc486dd2ae10 kabicodo-dev APP-CONFIG: migrate Supabase config and add CI gates
refs/remotes/origin/staging: 35	0
```
Available beyond cached origin/cha-branch2: `035e8425af7b880c0351f672a875a5f689062d65` and `2d2622e6b1b0c538dda3c3023e97ae467eaf53b6`. No exported patches. Unstaged ledger +388/-12, validator +51/-1, bridge-sync README +2/-0 require separate review/transfer; no automatic application.

## Exact available source, SQL, contracts, tests and evidence

| Repository-relative path | Availability/source | Raw-byte SHA-256 / exclusion | Transfer requirement |
|---|---|---|---|
| `SmartHatch_Cha_Backend_Handoff.md` | Local-only; cha-branch2 working tree; no source commit | `923ee625043e0ef4327f29d5549c907779b7264d07507b0d81516b56c480ad59` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Cha_Backend_Task_Reports.md` | Local-only; cha-branch2 working tree; no source commit | `b8c0ca1f944a89b999da2c7bc9c9efa671642b0671bc4315eb7a3d9ecfbabe8a` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Cha_Backend_Updated.html` | Local-only; cha-branch2 working tree; no source commit | `f57ba0408f054ab198400b6e3047c642a34c2c322b3aa8f2b7ac59f4af5f0e74` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Cha_Reports_Import.json` | Local-only; cha-branch2 working tree; no source commit | `cd07bb3c64a573d6e2935ca730cac919ed9d2027aecbaef8feb92f6f368c41b6` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package.zip` | Local-only; cha-branch2 working tree; no source commit | `aa85d32baac3c97e81f9021f445faf8a9ab916d834fbaddec1a1ce7a7a7db72e` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/Ally-2026-10-30-Packet-Review.md` | Local-only; cha-branch2 working tree; no source commit | `939cc95c4ddcf831c9fbbb3c1ee01724e98ee641fe761c71c219db5fb2449f3a` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/CONTRACT-FREEZE-01_Team_Decisions.md` | Local-only; cha-branch2 working tree; no source commit | `1d500806e2c0d90d49f3e06b5710ba0648ebb61d94e78a6a24c19309ede13129` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/D04_D06_Mary_Backend_Position.md` | Local-only; cha-branch2 working tree; no source commit | `94877d61fe7b5ed8a49ececc5a17eb5609b45b5b658c635aab331b127d53a93d` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/DB-02_30Oct_Consolidated_Alignment.md` | Local-only; cha-branch2 working tree; no source commit | `ff08bdabc5ce01124e431db5fec7c1547e4b3a24aadc91931b3a9865d5d26777` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/DB-02_Conflict_Receipt_And_Recovery.md` | Local-only; cha-branch2 working tree; no source commit | `08e6f97c7c320769e223218fbea7ce52a1d4a1b0ec5d117a83965d5678f39f06` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/DB-02_Exact_Bridge_Sync_API.md` | Local-only; cha-branch2 working tree; no source commit | `5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/DB-02_Proposed_Schema_And_Security.md` | Local-only; cha-branch2 working tree; no source commit | `6322985031a82d25184bd0ebefc7e1a9016d74c22b7e8d587e94dafb16d3f230` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/INTEGRATION-CONTRACT-03_Shared_Decision_Register.md` | Local-only; cha-branch2 working tree; no source commit | `9ff4344b72c6005053ce0221212ca09806fc45466b0f9acbfc85f6d63643d2ec` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/ORIGINAL-C-02-Flutter-Compatibility-Review.md` | Local-only; cha-branch2 working tree; no source commit | `ca179502cbb54414bed7ee8ab36753cbb6523a0f3c6532192601b0a38ba0398b` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/README.md` | Local-only; cha-branch2 working tree; no source commit | `4e372238dd6255d278b6973f05c89e035bbb8d9dc5a228ff9a6d2317ad737f8a` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/SmartHatch_Shared_Communication_Contract_v1.3_DECISION_READY_DRAFT.md` | Local-only; cha-branch2 working tree; no source commit | `70987831890edb16daaccfb47f7188061b41c5ea66658ac45fe4866cd1074f66` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_D01-D06_Review_Package/manifest.json` | Local-only; cha-branch2 working tree; no source commit | `e7eb63fe6c89d77c4a4cee260e1eba0ccb4340c17521608896f28365452375ab` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review.zip` | Local-only; cha-branch2 working tree; no source commit | `994105faf0f2f859f5ae87d24c712f873aa04372b8ad4a6c36bec017f816a83a` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/README.md` | Local-only; cha-branch2 working tree; no source commit | `272881b9fa00e67ab44849d9b1454e99faf5125087f785b0f706228fe0cb078a` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md` | Local-only; cha-branch2 working tree; no source commit | `dfeae7398078fb91eefdfb39209e50a475f6a822dfd5623e95f0f5583e0a37e8` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/contract-review/D04_D06_Mary_Backend_Position.md` | Local-only; cha-branch2 working tree; no source commit | `c51f8d8b16400a80238367b69c1f6c3496bf70a63a2eaf9aeb1ff1c8d85e046c` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md` | Local-only; cha-branch2 working tree; no source commit | `4808510868e2ad57e35f9059dbcfa3e27bf1a54c6cf9d94a629037c35412e3db` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/contract-review/DB-02_Manual_Result_API_0.1-review.md` | Local-only; cha-branch2 working tree; no source commit | `be60e96696bcf6acde43727b2205410a81beed08907e7ce7a8a0c8770c20bb98` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/contract-review/manual-result-0.1.closure-matrix.json` | Local-only; cha-branch2 working tree; no source commit | `55c66ae00782dfdd4c255e2bfb9c2c984fdf0b2655cc42610f744ad9e31efbf2` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/contract-review/manual-result-0.1.fixtures.json` | Local-only; cha-branch2 working tree; no source commit | `a92cba4f788eb844bd04824db3fa14c8c963dc57397299a7ae4d624bc8952f77` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/contract-review/manual-result-0.1.schema.json` | Local-only; cha-branch2 working tree; no source commit | `c8a17ad20cc1bc6656ef2f4029c725916fb9fab4bb0b5085850f75f8c7909125` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/integration/cha-execution/MANUAL_RESULT_PREPARATION_REPORT.md` | Local-only; cha-branch2 working tree; no source commit | `45d8161b03b93c8649ad07313d57f67e4db52f05cb66d5bfeb927b471011fe07` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/integration/cha-execution/manual-result-proposal.tap` | Local-only; cha-branch2 working tree; no source commit | `e196f3e496ea5bf964c89f010dee01be638e2de97877b89f877a7405e6ff24c8` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/integration/cha-execution/manual-result-proposal.test.cjs` | Local-only; cha-branch2 working tree; no source commit | `98adb19cc8f30578c5a76a53544ed87b7ae0bcc1f00b32f0be467f76e9e34dc1` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/docs/integration/cha-execution/manual-result-reference.cjs` | Local-only; cha-branch2 working tree; no source commit | `2387b78c0c721562823423ffcf2e07afeaaaa4e0904359b4b3519e5d9e18b661` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.1_Review/manifest.json` | Local-only; cha-branch2 working tree; no source commit | `e78146184a6f3280afefe548e5ba8a4d6c453d8181d4c1f7ce36e297bffe3d55` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Manual_Result_0.2_Review.zip` | Local-only; cha-branch2 working tree; no source commit | `983be83c12aa3550c69e8f17bd0a5642b1a92e5ea9d667368c6b0e2a75ad6772` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Remaining_Tasks_Review_Packet.zip` | Local-only; cha-branch2 working tree; no source commit | `8b62234f8dfce68c1a9d84b7fe6ab9050ce5a348d071f6d978e46bd46d9c6ce9` | Receive missing reviewed local file; compare hash; no overwrite |
| `SmartHatch_Supabase_Actual_Schema_Inventory.md` | Tracked HEAD; last touch 035e842 | `4c1eb90b82b6425d9076b503516e5909fbc764a923363f368999eb67470f0589` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `arduino/SmartHatch_Combined/SmartHatch_Combined.ino` | Tracked HEAD; last touch 9744d17 | `a466a868e6c148cf4f9c3230378d5033d81db89dfb77a3e0fa53891d847a9598` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `arduino/SmartHatch_Uno/SmartHatch_Uno.ino` | Tracked HEAD; last touch dd8583d | `0365b18bc969d36547440b5e4299b946da03fa5aeccdbff0fff8dc8efeef01fc` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `arduino/arduino_usb_monitor.py` | Tracked HEAD; last touch 1b5c8a4 | `3609f22022fb7228453363f9e755f4f46c2578552cd137ac95f1c74b5655963d` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/BE-01-session-ownership-audit.md` | Tracked HEAD; last touch a9d68fe | `6f1965319f371ccfc4397a308b606c0ad84934db6f98689c7d9d23a67027ca70` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/C02-provisional-communication-contract.md` | Tracked HEAD; last touch 035e842 | `3559b60ace2b2d12e0a52304ed4ff1d9831a416b9a4edb5478d7ec359a69ddb7` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/C02-provisional.examples.json` | Tracked HEAD; last touch 035e842 | `155a44ed24f2c0627481822569c008b1ee332d315d72abe3bf9f09fc584275b5` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/C02-provisional.schema.json` | Tracked HEAD; last touch 035e842 | `9e95d34ca160cae8600548c5c4919ece26953d892d77bd786198d9e9e15461dd` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/C03-provisional-ingestion-security-plan.md` | Tracked HEAD; last touch 035e842 | `61946bf7164980b5cca6d44eb19ecd77b1390432be2f0602882a4c48a1da6386` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/SECURITY-TASKS.md` | Tracked HEAD; last touch cd481f3 | `cf4814cd77257b106162498fc9185996db468f1ff3728aff3fcc67f4d046aef1` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.3.md` | Local-only; cha-branch2 working tree; no source commit | `4c30bf58390fccfa94356fb7a285dd9284d642946582b5ab8fe7be958ee02176` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.4_Bluetooth_Android_Bridge.md` | Local-only; cha-branch2 working tree; no source commit | `28311c53ed9675232ee6a25e9e481f8af26a10182de8f765edbf884e6fb1eed2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/ARCH-05_K06_Architecture_Amendment_Record.md` | Local-only; cha-branch2 working tree; no source commit | `8a4c29c79e4980f439ea599c98cd979a0c117fc61822f5c6f03a0992f2e89ebc` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/ARCH-05_source_manifest.json` | Local-only; cha-branch2 working tree; no source commit | `cb76fce1361eb60cdad9fd74404d1bd5d46ca56310b04c61dff385671cd77eb5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/C02_Wire_Family_Decision_Request_2026-11-02.md` | Local-only; cha-branch2 working tree; no source commit | `ce5ecf7e1aa4c2d17bc03e72ad46eddcb40620df89b61dbaad860856df350fb7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md` | Tracked HEAD; last touch 035e842; pre-existing unstaged patch | `213497b44449489db119099a600e059079efe040e6444423df1a2dd3fb307bdd` | Review/receive diff separately; no auto-apply |
| `docs/contract-review/D04_D06_Mary_Backend_Position.md` | Local-only; cha-branch2 working tree; no source commit | `ba4ff1ec9dfb5f7b3168f3a805d891b83c265b96876274bb9bf0ab39552d0869` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md` | Local-only; cha-branch2 working tree; no source commit | `f94e651e6e8e6047c3cc26e2c178e215138ca24ef6994b1e2b8c2ca393bba497` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/DB-02_Conflict_Receipt_And_Recovery.md` | Tracked HEAD; last touch 035e842 | `08e6f97c7c320769e223218fbea7ce52a1d4a1b0ec5d117a83965d5678f39f06` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/contract-review/DB-02_Exact_Bridge_Sync_API.md` | Tracked HEAD; last touch 035e842 | `5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/contract-review/DB-02_Manual_Result_API_0.1-review.md` | Local-only; cha-branch2 working tree; no source commit | `be60e96696bcf6acde43727b2205410a81beed08907e7ce7a8a0c8770c20bb98` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/DB-02_Manual_Result_API_0.2-review.md` | Local-only; cha-branch2 working tree; no source commit | `304da072775686906e67ea77ce635794273869f8ba3d933dcae80bf3fcdeabd6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/DB-02_Proposed_Schema_And_Security.md` | Tracked HEAD; last touch 035e842 | `6322985031a82d25184bd0ebefc7e1a9016d74c22b7e8d587e94dafb16d3f230` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/contract-review/IMMEDIATE_ACTION_Missing_Inputs_Checklist.md` | Local-only; cha-branch2 working tree; no source commit | `3a0a149442ca17b21f5ce829bcdfb66391b1d684bd4771142898d664acc9de73` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/INTEGRATION-CONTRACT-03_Shared_Decision_Register.md` | Tracked HEAD; last touch 035e842 | `9ff4344b72c6005053ce0221212ca09806fc45466b0f9acbfc85f6d63643d2ec` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/contract-review/K-03B-02_Chicken_Profile_Record.md` | Tracked HEAD; last touch 2d2622e | `4a5726050eac1c8ba0c0ebabfa399792a1dcde4b99dfe1f6b7aedd6bb9938b42` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/contract-review/MARY_Backend_Preparation_2026-11-01.inputs.json` | Local-only; cha-branch2 working tree; no source commit | `915e345823c94518946bee02aa053ba7f6ffd3de6c493786ecf58a3c21914831` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/MARY_Backend_Preparation_2026-11-01.md` | Local-only; cha-branch2 working tree; no source commit | `2fd9c9e8fa77a5191d22ecd36b33b8dd9e7d65877090c19ca5c0164222a3385d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/Original-C02-candidate-1.examples.json` | Tracked HEAD; last touch 035e842 | `210ad58f94e090d8b92713f7ae57405954da9ca3d7811bd9f50899c4fe084f8c` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/contract-review/Original-C02-candidate-1.md` | Tracked HEAD; last touch 035e842 | `b8111634dd1a15dab865ee2529b13d24d21f176376b1f14d5120f219d4a9527c` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/contract-review/Original-C02-candidate-1.schema.json` | Tracked HEAD; last touch 035e842 | `8137550b5ae471c8d7b22b4d5ff8abbe31c61f5cdbbbef2722dea646606a6c0c` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/contract-review/Q06_Q07_Kath_Mary_Decision_Proposal_0.1.md` | Local-only; cha-branch2 working tree; no source commit | `205f2537026a28a513e387d17f390ba49828db24e92fbec6ff77ad771d95f213` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/Q06_Q07_Kath_Response_Rev3_Receipt_2026-11-02.md` | Local-only; cha-branch2 working tree; no source commit | `d7cbcc5698f1225e157b474c1ab69788b15e1f401f59638e961de1eb0b79ac09` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/Q07_Plain_Language_Access_Proposal_0.1.md` | Local-only; cha-branch2 working tree; no source commit | `620739e56eac59b4a8c5cace1a1c4602ab7c79e1a147f20d56748ff7cff53734` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/Q07_Plain_Language_Access_Proposal_0.2.md` | Local-only; cha-branch2 working tree; no source commit | `8200322da2118c8a76e0ae1e16fa29c493062033c390c1d3a03a30505dc8ed69` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/Q07_Provider_Session_Binding_Policy_0.1.md` | Local-only; cha-branch2 working tree; no source commit | `1455810ccd3e74ba321ae937f61e01b2e70fb566d9d82f22648059b42a3155ec` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/Q07_Provider_Session_Binding_Policy_0.2.md` | Local-only; cha-branch2 working tree; no source commit | `ba7f4d082ee9f7916829e7c44f75a5a192c26d6324b06e588b9b07b6992cad8c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/Q07_SMTP_Test_Project_Plan_0.1.md` | Local-only; cha-branch2 working tree; no source commit | `6e756e6a31bb128b369df0379b07a5687e2df0ad3c6d0441b4b2eec172370d28` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/SHARED_INSTRUCTIONS_Backend_Review_2026-11-01.md` | Local-only; cha-branch2 working tree; no source commit | `edc2c1af260c011a7e2e186fb93a35841bdcdda6ce29739b11908f7e42905b93` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/manual-result-0.1.closure-matrix.json` | Local-only; cha-branch2 working tree; no source commit | `55c66ae00782dfdd4c255e2bfb9c2c984fdf0b2655cc42610f744ad9e31efbf2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/manual-result-0.1.fixtures.json` | Local-only; cha-branch2 working tree; no source commit | `a92cba4f788eb844bd04824db3fa14c8c963dc57397299a7ae4d624bc8952f77` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/manual-result-0.1.schema.json` | Local-only; cha-branch2 working tree; no source commit | `c8a17ad20cc1bc6656ef2f4029c725916fb9fab4bb0b5085850f75f8c7909125` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/manual-result-0.2-review/README.md` | Local-only; cha-branch2 working tree; no source commit | `d9293fb3bf5e1b60587cd20d7da0166d619090a3f52fd9aca481b6037e0c1389` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/manual-result-0.2-review/fixtures.json` | Local-only; cha-branch2 working tree; no source commit | `5ec00ee6b891e6c21cb5c3a378fca9fa6ea1c06d60e4d6c1b36a07b036bf2afa` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/manual-result-0.2-review/generated-by.txt` | Local-only; cha-branch2 working tree; no source commit | `1a8de13b330f8aba1a267dfd72a66671767284ec9a45b72c6a99dcd061d6ca1a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/manual-result-0.2-review/parent-and-change-manifest.json` | Local-only; cha-branch2 working tree; no source commit | `a2c723c8e574fe4cf6c22bde5039c94e58d04a50d05f73502173fd713ea287a0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/manual-result-0.2-review/reference.cjs` | Local-only; cha-branch2 working tree; no source commit | `032f070b7e584729436a311aea4a8cd9d2223650d40e8f907698056c0763c209` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/manual-result-0.2-review/schema.json` | Local-only; cha-branch2 working tree; no source commit | `b2d739271a2a575536c6db8c18504477eac951f63bfb88828bdf0f1db42cc7c4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/contract-review/validate-original-c02-candidate-1.cjs` | Tracked HEAD; last touch 035e842 | `c9e98941c9988c7efd1268ddb337a38d8d23be8141d5530e4ebeeaf577df7d8d` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/contract-review/verify-mary-backend-preparation.cjs` | Local-only; cha-branch2 working tree; no source commit | `b7719edaeb9996698a7b77343a5ace38fede970b3135fe71f9e9204d03d7c7fb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/hardware_readiness.md` | Tracked HEAD; last touch 690b70d | `ded9583d62ce4b41e518418fc62ad7a47afc09feeaf955638be12fb7a185207f` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/hardware_sensor_validation.md` | Tracked HEAD; last touch 2a4974a | `cabc59039300623dee26dac964aa9409a2deed99dc55358525499d18fa5b3728` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/instructions/BACKEND.md` | Local-only; cha-branch2 working tree; no source commit | `4b71669c2cbb4e6310ec5deffd68d424bbc89176fc7b58bc7ec83afe1cbc2187` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/DB-IMP-01_Report.md` | Tracked HEAD; last touch 035e842 | `7751829e8f72eeb7011d67ca3099447381a5d93e8c62bc66d589c7b76909e1e4` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/integration/INT-IMP-01_Evidence.md` | Tracked HEAD; last touch 035e842 | `c206cb6152b8c87c588c03b10d4948939aee71dc66a67659c8f9d55d0a372d05` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/integration/cha-execution/2026-10-30-test-catalog.json` | Local-only; cha-branch2 working tree; no source commit | `b9ce51c110f7229ac5eaa6c6d68a30192c50e7bee4847a687ce43cecab412552` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/2026-10-30-test-catalog.sql` | Local-only; cha-branch2 working tree; no source commit | `242f3925873bbf06c428c509be2a51c7b6cbe270c9901583edd1092505708ff0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ALLY_C02_20261102_RECEIPT_AND_CLOSURE.md` | Local-only; cha-branch2 working tree; no source commit | `e068fb4c06fd302e568e270ef085569b334aed6c7e37f00868a793d60462e895` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ALLY_REPORT_REVIEW.md` | Local-only; cha-branch2 working tree; no source commit | `6f164f553edafecba565a77c48abacf3b345142ddd471c16e5e9ba316ff9c1ad` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ALLY_ZIP_C02B_REVIEW.md` | Local-only; cha-branch2 working tree; no source commit | `2250c3723211f1abe1d8812bdc8100df94ddbcfb399f08850ec2b32e56d3ef2a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ALLY_ZIP_REVIEW_VERIFICATION.md` | Local-only; cha-branch2 working tree; no source commit | `55b8cf01cdad6ba2ea2de4868bd4f075134dc90f3bd85358c71006d0cdc268a8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/APPROVED_SECURITY_TEST_REPORT.md` | Local-only; cha-branch2 working tree; no source commit | `6a29b2e066061a1127512911dc2203e740a5b5dec03be3770a74f5c3098c6793` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/AUDIT_COMPLETION_REVIEW.md` | Local-only; cha-branch2 working tree; no source commit | `a1f3661408a36f2ea4b9faa7185df2cfdb27a12458dc1b6f9805d4e34f7d27bb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/COMPLETED_REPORT_ARCHIVE_VERIFICATION.md` | Local-only; cha-branch2 working tree; no source commit | `f3f04d01ff0ed35f78f1e76c0e383bd483b9bf3b5be6b79c6e6c29064897bd45` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/INDEPENDENT_SCHEMA_VERIFICATION.md` | Local-only; cha-branch2 working tree; no source commit | `8b99d219b686c73a568f1a26d7dff77a6aa0e2ee8fc5a49c70139cead1a8b3db` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/INDEPENDENT_WORK_PORTAL_VERIFICATION.md` | Local-only; cha-branch2 working tree; no source commit | `0e865ce1518733b7646daf1927bdf87f77a05ed5fa03841b0ed8b814c22167b1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/KATH_02_DELTA_ACCEPT_RECEIPT.md` | Local-only; cha-branch2 working tree; no source commit | `c78dd9951b2cd76db367871acd9cd0d2b158158e72c3a470f82d02689e494fcb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/KATH_CLOSURE_20261031_RECEIPT.md` | Local-only; cha-branch2 working tree; no source commit | `34729f6775f8f72283d1df8b6c7a3e5e48050e687daf581e853e0d79de566e41` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/KATH_DART_EVIDENCE_20261031_RECEIPT.md` | Local-only; cha-branch2 working tree; no source commit | `537124f9954dcd4614075dc1073bf783d286ed0c79bd45264a9f4400af0504b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/KATH_FOCUSED_REVIEW_RECEIPT.md` | Local-only; cha-branch2 working tree; no source commit | `6f2b5b05d3e71bf94545c9b22db77107af8db5acb53fe9b4125e3596f0728ae6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/KATH_REMAINING_DECISIONS_RECEIPT.md` | Local-only; cha-branch2 working tree; no source commit | `43bcb06386f57ce6a7ab0c3a9bc33d25cd31acf556f56f06102fe0e0c8af57be` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/MANUAL_RESULT_0.2_PREPARATION_REPORT.md` | Local-only; cha-branch2 working tree; no source commit | `742998af3d282783421c809c90ce46ad1ac06f93759a7ca298685f71e5230eb7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/MANUAL_RESULT_PREPARATION_REPORT.md` | Local-only; cha-branch2 working tree; no source commit | `45d8161b03b93c8649ad07313d57f67e4db52f05cb66d5bfeb927b471011fe07` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/OCT26_C03_ARCHITECTURE_ALIGNMENT.md` | Local-only; cha-branch2 working tree; no source commit | `aa2dff8f8a6a0ea43db92c2f7772632382624e957211770c3d8eea798f1b4dd3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ORIGINAL_C09_MONITORING_BOUNDARIES.md` | Local-only; cha-branch2 working tree; no source commit | `01128459b51c1104399e66703b4abe5814d229d13796d5d95bfe6a1b1a6a1286` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/PORTFOLIO_EXECUTION_REPORT.md` | Local-only; cha-branch2 working tree; no source commit | `d0588c331a5389952d87ecb53675d1cf094558e568b319ba36e1cf9af064938b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/Q12_CERTIFICATE_PROVENANCE_OWNER_UPDATE.md` | Local-only; cha-branch2 working tree; no source commit | `ede9b61185a10fc48841d978d986a8f88c7c202ac6641095c34fd096f24e068c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/Q12_CERTIFICATE_PUBLIC_REFERENCE_ASSESSMENT.md` | Local-only; cha-branch2 working tree; no source commit | `d5b80a71b5f52946242e185eaaed376ac1ddc6460c5bb176c0b1ec0d9a42917b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/Q12_PHASE_A_APPROVAL_AND_BLOCKER.md` | Local-only; cha-branch2 working tree; no source commit | `acd24ee260b5d4724b93725c4ef8efdc69cb79d89e88867aa7533177c010f885` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/Q12_PHASE_A_ATTEMPT_1_RECEIPT.md` | Local-only; cha-branch2 working tree; no source commit | `11cdf66dbada5874fde06504f7d1b929b30080196849e47313d89871653d0913` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/Q12_PHASE_A_PREFLIGHT_20261031_103006Z.json` | Local-only; cha-branch2 working tree; no source commit | `1bf22e33e19679e80cb1e0020be22c93563289073a2cbb2eca007cbdb35912aa` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/Q12_Phase_A_Read_Only.sql` | Local-only; cha-branch2 working tree; no source commit | `9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/Q12_Test_Project_Approval_Plan.md` | Local-only; cha-branch2 working tree; no source commit | `7de0a687f51168e2f0f1928ec7d44a75b8b070afcce7c64de7ffb18128f27e37` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/REMAINING_QUEUE_AFTER_C03.md` | Local-only; cha-branch2 working tree; no source commit | `ad2833c47c545d569e7e24c9fbf4fa42767281858167e6f6273db361f8ccb041` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/SUPPLEMENTAL_AUDIT_EVIDENCE.md` | Local-only; cha-branch2 working tree; no source commit | `b867587d72e393fd333ae47d4f77d9eebe04058622458304b28bfc18ddd6ddac` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/TEAM_APPROVALS_AND_LOCAL_PLAN.md` | Local-only; cha-branch2 working tree; no source commit | `78496ff1ef689bdb01a26761141ca0e89861b80dbf022df177674539b54e8a7e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-c02-receipt-verification-20261102.json` | Local-only; cha-branch2 working tree; no source commit | `2d73f301911782bc1904ff32350bf3ccf2f75230d9197f79e69435eb5392cefe` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-c02-schema-revalidation-20261102.txt` | Local-only; cha-branch2 working tree; no source commit | `d580a05e219b861815fc132ff2b437a283e13955f682bf995ee0074255efb259` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/01-ORIGINAL_A-06.md` | Local-only; cha-branch2 working tree; no source commit | `ea3f3075c8a1f40631201d4f9e63a85749c6c31a736ff96da121e4564f0492e2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/02-ORIGINAL_A-08.md` | Local-only; cha-branch2 working tree; no source commit | `ec5c65aea8f01ec8f6da86fff3da983b19c4fc45372eabb66b2ff81539d481cc` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/03-OCT26_HW-02.md` | Local-only; cha-branch2 working tree; no source commit | `7f12880ec37599b5c5a6ca26b318cf63a1866d59daf33ce56ef187892c464e5c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/04-OCT26_HW-03.md` | Local-only; cha-branch2 working tree; no source commit | `abb4c112cca77fa3660d363a5c365c0991267f2e2233183042fe5c798843b069` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/05-OCT26_HW-04.md` | Local-only; cha-branch2 working tree; no source commit | `cbbf7c8a554aa16e15f14bd01fbb9bbdf42be2a4d89c7df299631787f3077f6c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/06-OCT26_HW-05.md` | Local-only; cha-branch2 working tree; no source commit | `8b765515abe7396c47040c2f570fe9b5c4db8af275b9fc674dfd6ece490f4224` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/07-OCT26_HW-06.md` | Local-only; cha-branch2 working tree; no source commit | `1ab02cce697e9f709ea7bad3cd84e405b2d3172b1878c73b8ea17afe240dd397` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/08-OCT26_HW-07.md` | Local-only; cha-branch2 working tree; no source commit | `877e4f653e7dde32f0ec13a8eb571c312f50154a3b07db3ad8516078f826dfa6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/09-OCT26_HW-08.md` | Local-only; cha-branch2 working tree; no source commit | `96eaa9cf57185bc9fa65774f5abb6b1f9518c9b2a77a88d91ea420a1774ae5e5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/10-OCT26_HW-09.md` | Local-only; cha-branch2 working tree; no source commit | `cdbb9bd5cc108ca7a683d00e5435d943548baa22c74851aad891579a7edf04f8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/11-OCT26_HW-09.md` | Local-only; cha-branch2 working tree; no source commit | `735913b286e07ce985c7ff597ac22a474299768bf4672faa0c711c0f7f6bed20` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/12-OCT26_HW-10.md` | Local-only; cha-branch2 working tree; no source commit | `be755792fc25dc36ba2cb937ac0b4e289633e370743bf1ccab83edee9b252eb7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/13-OCT26_HW-10.md` | Local-only; cha-branch2 working tree; no source commit | `b420cfa45269d1b6df4201ebeafedac4061f24fec5cc2e3a3d49a372882f58b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/14-OCT26_A-01.md` | Local-only; cha-branch2 working tree; no source commit | `960fa5002b427147bca0cabe180759f94b5f6e1fb24ab9d78876f1cbf27fe704` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/15-OCT26_A-02.md` | Local-only; cha-branch2 working tree; no source commit | `2471eab3a9193e4d9d796cc91b50999b27e51cc6e6bc2063306a165ad0062748` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/16-OCT26_A-03.md` | Local-only; cha-branch2 working tree; no source commit | `17e934f43551b506022fdeb810d45ed5dc9a6c8d2a4a4952e5a5c92e812f4361` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/17-OCT26_A-04.md` | Local-only; cha-branch2 working tree; no source commit | `152cbd9126a2593bf3393aea7a02eddfee9b1724f910c1847c73bc45c5260e85` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/18-OCT26_A-05.md` | Local-only; cha-branch2 working tree; no source commit | `6401e8f6526b1a87eeac7da1fe87e3c9af047cd1220d6b0fc2551ec52f801936` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/19-OCT26_A-06.md` | Local-only; cha-branch2 working tree; no source commit | `ef79a1c06c4a706a06a525a724b4971bf6aa585f6f2aa8e0f1f143c6a5f8f27d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/20-OCT26_A-07.md` | Local-only; cha-branch2 working tree; no source commit | `a478c20be28fd9ba90acf6cf49300c930eca90a22ab25c1280c0fb7f13b76717` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/21-OCT26_A-08.md` | Local-only; cha-branch2 working tree; no source commit | `1fced7f25a205e977ffe34dbc3c77851782239c8c6f0c787108f35d545348330` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/22-OCT26_A-09.md` | Local-only; cha-branch2 working tree; no source commit | `fc466ab438f7c149e5069be8c636d724cd31ccfcf81b835d0a7dadd65b7125ee` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/23-OCT26_A-10.md` | Local-only; cha-branch2 working tree; no source commit | `164a0f026d2628ad32885b78e2013d4074945a533c0804983f6100e7a939ee46` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/24-OCT26_HW-01.md` | Local-only; cha-branch2 working tree; no source commit | `801e6fbda67a2af642b0439ad9cd3e4fac15c990e62fac23e403a19e6f8c349d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/25-OCT26_HW-02.md` | Local-only; cha-branch2 working tree; no source commit | `359a411f0fcc8deb6d259499db8c5550151f4b47755b9d168fb672d9f7926128` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/26-NEW_PILOT-GATE-01.md` | Local-only; cha-branch2 working tree; no source commit | `fc64fb62fdd21195ea3c035cac96c5f63e03bd397e8a0b097c5a7a00c3efcfa7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-export-review/index.json` | Local-only; cha-branch2 working tree; no source commit | `fa18b3dac9c48d53a99e11cde7ecd03a82e78ec5a1d1bb503bba28a7571cf38f` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-report-review-validation.json` | Local-only; cha-branch2 working tree; no source commit | `9bd581f195df316256a6a97bf0f2c5aa37e2357c2c4a0f289e32da14e946f26d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-zip-progress.json` | Local-only; cha-branch2 working tree; no source commit | `7044c6b51c17f7d5fc46f728d20e4311d338dbff1a70c25d7aee804c158e0b37` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/ally-zip-review-index.json` | Local-only; cha-branch2 working tree; no source commit | `41ccebb4a196a816deee32e051064d65bf99a04abbeffbc5ed51538c804f2123` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/approved-security-results-validation.json` | Local-only; cha-branch2 working tree; no source commit | `d8f83fabb14593ac01103e269fc969c1f18b8e2c46939a7a1a7e99960472b24e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/approved-security-test-latest.json` | Local-only; cha-branch2 working tree; no source commit | `5d3b604289c464c728d9bef5d656affc21223c5a94dc38840dd5b5676063d71e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/arch05-record-verification.json` | Local-only; cha-branch2 working tree; no source commit | `cbcdc4b0585d847a55944aeebedc0cc2c5cebcc841b8fd19c9d9840464a574ff` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/audit-completion-browser-results.json` | Local-only; cha-branch2 working tree; no source commit | `7367488ef30247f2502303baaef404d4c09488a9cbd5524a63a0696075df9c40` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/audit-completion.json` | Local-only; cha-branch2 working tree; no source commit | `8e77df2cc56c565f46bd5a27fa28a5e16822f4144d97bda374d53e1926d76772` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/build-manual-result-0.2.cjs` | Local-only; cha-branch2 working tree; no source commit | `7c82bb40b32a928f39e58ff29d106a38b82fa9ba57e573777ab6294e1b56e491` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/build-portal.cjs` | Local-only; cha-branch2 working tree; no source commit | `840d21484e8746831fa7c3fe6583840e545244f97b1f462d90268ffdfb57699d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/build-remaining-workqueue.cjs` | Local-only; cha-branch2 working tree; no source commit | `8db03af242188d1e212ff73602a803d497643f05d0a5ce39bfffaf9574ea16db` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/c02-schema-revalidation.txt` | Local-only; cha-branch2 working tree; no source commit | `cb1c0f838b18c3ef9df572fe6986ef1619e4bf2547cba058b6939072e176379b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/completed-report-archive-browser.json` | Local-only; cha-branch2 working tree; no source commit | `8b8480a092c0caa8cefeb28753e1ac70e51096ef6f652eb4bc2388fc6a3b3bb7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/completed-report-archive-manifest.json` | Local-only; cha-branch2 working tree; no source commit | `aa244a25dec38c7e83f13fa9f2495bcbb41c883b8316ce06526d7d0091030124` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/completed-report-archive-unit.tap` | Local-only; cha-branch2 working tree; no source commit | `ef717cc5d50ae01424c3e4d9d2e8af956e235ae7ba6c8b865a721c9ecbbc9658` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/completed-report-archive.cjs` | Local-only; cha-branch2 working tree; no source commit | `d33fc18277dd0d62fabc9e9871fe68ba572ce7bd7baf768dfbdaf6b1b8d8bd15` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/completed-report-archive.test.cjs` | Local-only; cha-branch2 working tree; no source commit | `c0c448cef46639ca12b15eddc6907b33499ea5f5713bf35635d53e5de2bd05f7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/decision-consolidation-validation.json` | Local-only; cha-branch2 working tree; no source commit | `8bc21efb2d8ca1f417bd48f3ccbfd19242b380c478faee9c9a0474efc75478de` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/independent-schema-verification.json` | Local-only; cha-branch2 working tree; no source commit | `04f46915744557b4720395a9581f862654d5b68fdaa58c268b83de9a89ed90d2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/independent-task-completions.json` | Local-only; cha-branch2 working tree; no source commit | `74f635e85bc5b2ca4036f7b3039178c694caa3f4d625c087c42676f66cf4ae05` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/inspect-ally-export.cjs` | Local-only; cha-branch2 working tree; no source commit | `5909207d06ee7694d6ddd5bbb2533c9fdfcf2b94a3d265f918e3898c0203368e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/kath-02-delta-evidence-verification.json` | Local-only; cha-branch2 working tree; no source commit | `ed30f7f48eff3c7eb49b315998a7714930c0d447337008da9d2ddf69692d5dc2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/kath-closure-20261031-verification.json` | Local-only; cha-branch2 working tree; no source commit | `bbd58e9c3de8a65252e51fc85dbb93b857c6ebb2d4a2ee5f1160e73052d875bd` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/kath-dart-evidence-20261031-verification.json` | Local-only; cha-branch2 working tree; no source commit | `c2b3cf9d8d6519d3bf4656621c2aa8e241fddf2f219ac7e8c0331fbb29735b50` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/kath-focused-review-inputs/C02-provisional-communication-contract.md` | Local-only; cha-branch2 working tree; no source commit | `3559b60ace2b2d12e0a52304ed4ff1d9831a416b9a4edb5478d7ec359a69ddb7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/kath-focused-review-inputs/C02-provisional.examples.json` | Local-only; cha-branch2 working tree; no source commit | `155a44ed24f2c0627481822569c008b1ee332d315d72abe3bf9f09fc584275b5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/kath-focused-review-inputs/C02-provisional.schema.json` | Local-only; cha-branch2 working tree; no source commit | `9e95d34ca160cae8600548c5c4919ece26953d892d77bd786198d9e9e15461dd` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/kath-focused-review-inputs/CONTRACT-FREEZE-01_Team_Decisions.md` | Local-only; cha-branch2 working tree; no source commit | `2ecf175119fcff30f512a9988a104c498468205ad1598c36bb147e51eaac60fa` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/kath-focused-review-inputs/DB-02_30Oct_Consolidated_Alignment.md` | Local-only; cha-branch2 working tree; no source commit | `0c66ef938d5fd89628b70b14517f8ba602e766735fb87f381247d4dde4ca66a6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/kath-focused-review-inputs/Kath-C02-Provisional-Focused-Review-2026-10-30.md` | Local-only; cha-branch2 working tree; no source commit | `4473813552ef21a77fe57296f89fb7843a3b4f1ad19990c3e596b70f66e162e0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/kath-focused-review-validation.json` | Local-only; cha-branch2 working tree; no source commit | `f21e1508499e789944f5fdf15d6a5468cae0687da24c81acd4e0ac3e272d7d70` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/manual-result-0.2-local-recheck-20261031.tap` | Local-only; cha-branch2 working tree; no source commit | `8f0281032e0103ee33725fe1920432909a1f8263e7f01219b21d02a6d36df5d0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/manual-result-0.2.tap` | Local-only; cha-branch2 working tree; no source commit | `e3523db913ce185fae43b08429d860763e2db77f4924baeafdadfecbaedd7eeb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/manual-result-0.2.test.cjs` | Local-only; cha-branch2 working tree; no source commit | `6548f2c7dd291c816c7654bd73bde404ee9c75c0fda48563c97f2b97e0126139` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/manual-result-jsonschema.tap` | Local-only; cha-branch2 working tree; no source commit | `5e1a06ce41c74e9f4951a291c31537855d9cb8875997ead86efae350d737a3a2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/manual-result-jsonschema.test.cjs` | Local-only; cha-branch2 working tree; no source commit | `cb01ba640df5de5ccaf13f9a2ef674b87958a832392ace37f647c2bcb037eadc` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/manual-result-proposal.tap` | Local-only; cha-branch2 working tree; no source commit | `e196f3e496ea5bf964c89f010dee01be638e2de97877b89f877a7405e6ff24c8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/manual-result-proposal.test.cjs` | Local-only; cha-branch2 working tree; no source commit | `98adb19cc8f30578c5a76a53544ed87b7ae0bcc1f00b32f0be467f76e9e34dc1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/manual-result-reference-revalidation.tap` | Local-only; cha-branch2 working tree; no source commit | `1242bcbf4436c561f9d25f30a8c3de2588c3baabf8a643fdb837344cd92551da` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/manual-result-reference.cjs` | Local-only; cha-branch2 working tree; no source commit | `2387b78c0c721562823423ffcf2e07afeaaaa4e0904359b4b3519e5d9e18b661` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/mary-d04-d06-answers.json` | Local-only; cha-branch2 working tree; no source commit | `2c1f5eae7c6223a35c7312a6aa4297f4539b2e7ae61a79a091aad058d7e02e1b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/mary-d04-d06-browser-publication.json` | Local-only; cha-branch2 working tree; no source commit | `118deec46f2d84037f385afec9ccfca5a2945adf033b37a86e79494c51142132` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/mary-d04-d06-validation.json` | Local-only; cha-branch2 working tree; no source commit | `a2077efb6049f997ecdc9805cb22ea4144296aaec5ec2821083204dd2b726a57` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/monitoring-backend-regression.tap` | Local-only; cha-branch2 working tree; no source commit | `ba95c0dda8e95211e3dd8a7143ecef326d326d614b63d74299bbcd901f1d40e4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/monitoring-boundary-probes.json` | Local-only; cha-branch2 working tree; no source commit | `69bc124cea548de26787277abb16d85ced633f348d1fc5f1aa7155ee554999bb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/monitoring-boundary-targeted.tap` | Local-only; cha-branch2 working tree; no source commit | `79c11dd6d49bebf3b3688615f9b0204de3e76330c68dc6cb783dd73bdf433998` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/monitoring-verification.json` | Local-only; cha-branch2 working tree; no source commit | `0957cfdbcc8f1aa3fe691820d63c5b1e729cf4e0d2909945971616cf2dda4409` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/oct26-c03-architecture-targeted.tap` | Local-only; cha-branch2 working tree; no source commit | `c3f9b6393508fea29457b94766a8d799e943b4e0316f08b373dbef42089cb0aa` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/oct26-c03-backend-regression.tap` | Local-only; cha-branch2 working tree; no source commit | `4f5bbc84546d80c0b7b0bb8be9a8ea641685b5431992c2ec57755a68ea60b7bc` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/oct26-c03-validation.json` | Local-only; cha-branch2 working tree; no source commit | `ce8bd688a51ef0428a222c6486a628e430db20b0a1063da20b1a9604daa3a009` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/package-decision-consolidation.cjs` | Local-only; cha-branch2 working tree; no source commit | `d30121c2c984e4215b93a93f4258272c83114b911dfadc2b98d69223a21d6da2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/package-manual-result-0.2.cjs` | Local-only; cha-branch2 working tree; no source commit | `151f4749c654320c8b059add97265e98543c462f15b098ed0fdbf5805925340d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/package-manual-result-review.cjs` | Local-only; cha-branch2 working tree; no source commit | `9484a2bfa3f11b8301a92bb02dfe3deb735b621c577f28d6180095ece9f849e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/package-remaining-review.cjs` | Local-only; cha-branch2 working tree; no source commit | `fd70baaac5ee005ec6f2a7c6d2593c8c79d17076045ca73c3cb2838735050c89` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/portal-browser-results.json` | Local-only; cha-branch2 working tree; no source commit | `a2fda7d0614e0a9d0cc5198940d2437cdc139650647f126081ac588d5075491e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/portal-static-results.json` | Local-only; cha-branch2 working tree; no source commit | `349e435aeadc30321d183fed24a20be5dfd2ed95f652d8d8a0dc859255cfcf62` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/portal-structural-results.json` | Local-only; cha-branch2 working tree; no source commit | `906ad66d6d88aaac48007788d693c58b716e03fe96b11c04dc17a2b49026eaab` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/portfolio-backend-regression.tap` | Local-only; cha-branch2 working tree; no source commit | `ed23c4a5a5f810f3591712b756c5d52f6ae30dd0aed91dd2de4c4469f8f6fdd2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/portfolio-source-check.cjs` | Local-only; cha-branch2 working tree; no source commit | `6b9cd1bbbbc6b75811b66f931fa7bbcaedec7a1b2834119e9b4130868d4e4b13` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/portfolio-source-observations.json` | Local-only; cha-branch2 working tree; no source commit | `b10a2f6d2b2c5bad6253844573fcc7658025390d0cc52003247e98c914905a4e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/prepare-arch05-record.cjs` | Local-only; cha-branch2 working tree; no source commit | `be8df1e9d75cad6a1b7eccb3af720cac6be95df42f2fd58fa98226935c68b5dc` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/probe-monitoring-boundaries.cjs` | Local-only; cha-branch2 working tree; no source commit | `c5d3ee955cb27ebfee0987a901c46edf0534474a7d6e317981cffe532aaa04b0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/Invoke-Q12PhaseA.ps1` | Local-only; cha-branch2 working tree; no source commit | `79ba006b03068dc8c98903b9bdf8da1333f8d9d33ab1c61c43d9924c0f497bbb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/Q12Controller.Tests.cs` | Local-only; cha-branch2 working tree; no source commit | `393e5dfb81c9c755f0ba08c5250401d128ed1cdcc8f44b0c1cb88e4f4a4ddd50` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/Q12Controller.cs` | Local-only; cha-branch2 working tree; no source commit | `51c209d22c26c27286923a900936f97aca24fb6f96de16f6dae81bb720639bf4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/README.md` | Local-only; cha-branch2 working tree; no source commit | `eaf88b669a0d7eee152a50f9689beb10f2c5088dc234522a8b428f515f339600` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/Test-Q12Controller.ps1` | Local-only; cha-branch2 working tree; no source commit | `a95ed49d92cf29f81252e9996628188356a33715cc5baa5574607cb19c085bab` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/local-test-1118803c180d42a88e5491410bb69584.json` | Local-only; cha-branch2 working tree; no source commit | `0ee804b705dc1807e86530e259af10b8f49e614174e766e3dbdf8a7487f5f0b0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/local-test-8175115be7ba4e9ca1cad4a9fcec471f.json` | Local-only; cha-branch2 working tree; no source commit | `0128b5cc27675f1dee5fb612907e695a26f81e767d01fb01c012b0a74c027f79` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/CERTIFICATE_PROVENANCE.md` | Local-only; cha-branch2 working tree; no source commit | `f2dfe705e0eceb37f6ebcc843379e32ba6c6b51087d14d782a3dbf3e74d6c77e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/Correction.Tests.cs` | Local-only; cha-branch2 working tree; no source commit | `d5c1bad885b4229ec7df4072bec4b547d8743d6ae6e613d640511975cbf521eb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/DurableController.cs` | Local-only; cha-branch2 working tree; no source commit | `3141f9d815a3447192bf40d9a759a64412f3de7a4e6b526688829999c2eb1f86` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/Invoke-Q12PhaseA-V2.ps1` | Local-only; cha-branch2 working tree; no source commit | `a675216d4c54b68fade44a81e8648d2e08246bde0cda6b819997cb2508a6b34d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/ModelPolicy.cs` | Local-only; cha-branch2 working tree; no source commit | `b54ab5b0b4a9af30fecd2e6efcd9853064ef384b782f4e31cb7baa280d5a0373` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/NativeBoundary.cs` | Local-only; cha-branch2 working tree; no source commit | `9041ebef9a480b818b7bc8179453321cabe9652c9b471ccad973af5379ad0e39` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/README.md` | Local-only; cha-branch2 working tree; no source commit | `42326f6420f4c94c60294e61fadfd3c8fe93df27bdadb6dd0601dee220ba097f` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/Test-Corrections.ps1` | Local-only; cha-branch2 working tree; no source commit | `70370706ea0584231042a6945190d1ca1cdc286977000f4ee31fd45b1f30a741` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/Write-ReviewInventory.ps1` | Local-only; cha-branch2 working tree; no source commit | `cc3af5244273d397cae9dc4459741c8336adab05745ada6768330cc810a18683` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `db3c5324ccc8b37b7a712fb5165a8822cbcdf37eea0e60007e82c9caf258bf81` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `b95908b6b7796d93b31c1180308646247bb0ff1b4d67ea48508678446e5c013b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `2b0d40eba909f93631751d57aa225444c542abf312157b5ad9cb4f956f1f15d7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `905ab59a78689b5e2e2be544d5e3a6a00dea12f16e64c15b69b25b507d2de4c7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/synthetic-root-bytes.txt` | Local-only; cha-branch2 working tree; no source commit | `07e6171b62102a12611b0fc55ac766e9a32a5d8167b39087fd534d37592f84b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `26409e685534e715fa3fa2b2295edd4e82b450a77e269fdb232913bf51387e1f` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-2502e7780244458db0bb2647bf1b2e2c/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `662a0c383f9f0b2ca2a9914c5ba16f0e5b6341684428e32b1bc47f164a913ee1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `a02613a147424f4dc7ea7e9233882d4fad8e78fc302fe2053397cc9d29f3021f` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `2e1f95432d57a0c427a55033ea077a869107bc4f244640ad4e28172d732b223b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `85550581467f5964528fc4f99242255af2b235dc575712512906c0d11463efec` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `cc2f3bdb86629234c8f9a5165f6a38b0a9c8bd2159606cc5df5b9334ff8487b8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `0c6e6fad7a884233fbc0375f41eb9d5a6bfd21ef06fd08c68528eff5da9b9c0e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-472ac2f34962445a95c70fecdcb680c2/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `9495eefc2ac1dd6db6968bf56f7bb12fc2683c3f12c6df52a32f947f293b68c2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `69fb59259fa1e051a6d814d41247282b19515c30bd74324a1f6664eac5d64e80` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `851c3cdd029b34f97a9d5c1bf8be158fbbca9e60a4e72139b8aa99d09b908888` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `2fdb8b6f48e472dcbd89e1834cb0ff52a6fe66d2b0021d0a206f4fd7cff1290b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `a47df207d3593bc5da2d609b9ca3415d4db1f00d8f61eba88af1dc76670103c4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/synthetic-root-bytes.txt` | Local-only; cha-branch2 working tree; no source commit | `07e6171b62102a12611b0fc55ac766e9a32a5d8167b39087fd534d37592f84b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `a5570e847aceaf79f180b0d171ae4ec88b409d4a494206cd306781fd81025429` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-4de01d0b0506410d9304f50123e58647/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `f1aed959dc9ea83039a04878ea50ee39d59160fe0b14bc0d87b9f8d7814060b7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `821cc85b92a8b3319b6e3e6ba7435eb25526ac028ac3153e3989bd00c38dc4a9` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `77a4e96a40c8b37fae028ec54cf74260e069ae8eead76b97697994e0ad36d620` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `17d9585efaf8e2ed0d9d481c81d351553cea49e389d500cdc6fb9fb299c2053b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `ce7d6bde121ff2bd96a0e0453d96f65c433ae5c175f95b7071a0810dcab5715c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/synthetic-root-bytes.txt` | Local-only; cha-branch2 working tree; no source commit | `07e6171b62102a12611b0fc55ac766e9a32a5d8167b39087fd534d37592f84b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `781c05ba6fcc157df914453bf238c18ef06a8d6579300cac0bcced57f1a40ef4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-cdc2d6d37b14413889a8611c2c9e201f/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `8d4826966c4e4f18133df8d841bffd8869f283aeab16280891adca0b6348cd1b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `40308c98e9e7141c93a2e3afcb06ee69654a973e0c3db8fb2879b99692d556e0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `a2aea434e63fd716c126f0e3a71573a5a0c72e85b284ab671d337cd2b7a8fbfd` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `ae5c15c51801b85daaa0519da7620b194430186e517af73688e01c4bde691bca` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `7dd20b188141a65ba1307ae11eb07d0eee182ba4eb9948a85530281a44c36bf9` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/synthetic-root-bytes.txt` | Local-only; cha-branch2 working tree; no source commit | `07e6171b62102a12611b0fc55ac766e9a32a5d8167b39087fd534d37592f84b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `01afb736811a57e273ccf4359a55e1dc3226cef142e24ddb843f86027ba193f7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/local-verification-ee9acc30dabd49e0a5805776649865ce/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `ac4e8af836b861a1b7103ab66297037c66efecf3b176971c551eb0fbf2cb92e8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v2/review-inventory.json` | Local-only; cha-branch2 working tree; no source commit | `c1ff03b2787271dd416b3148bad75f14228e8496ddd7f94af8ccf1f22991c924` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/CERTIFICATE_PROVENANCE.md` | Local-only; cha-branch2 working tree; no source commit | `f2dfe705e0eceb37f6ebcc843379e32ba6c6b51087d14d782a3dbf3e74d6c77e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/Correction.Tests.cs` | Local-only; cha-branch2 working tree; no source commit | `dd8e5a6fd0d2e286ddfc91701187d930ad59719fb12aad48fe46509656b1d113` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/DurableController.cs` | Local-only; cha-branch2 working tree; no source commit | `a9ffb06222e53f31f1cda4fc848dc646257b83790ffd067ae87473790fb4bcb9` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/Followup.Tests.cs` | Local-only; cha-branch2 working tree; no source commit | `dd012010cb1f6fb86c98dfc1c10a973c13e355455841466096561b8de1ff8fc1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/Invoke-Q12PhaseA-V3.ps1` | Local-only; cha-branch2 working tree; no source commit | `004b5468b3e0fda8c52cd4efe1edd70fefd33de9424b8ce516c21dd28b761ae9` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/ModelPolicy.cs` | Local-only; cha-branch2 working tree; no source commit | `d94cb03cb1d61a5251d7b6e3c211288553cd3688d7a93fe859352c531dfb9fd8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/NativeBoundary.cs` | Local-only; cha-branch2 working tree; no source commit | `381f705c0892d7b8f93278e14da545ba013e0afce77642d10e2b4f9b044b5268` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/README.md` | Local-only; cha-branch2 working tree; no source commit | `eea740d5b27e272d4bc385119f5ba8680f6d2dc4e7a4bd332c1d04ef16dee54f` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/SourceSnapshot.psm1` | Local-only; cha-branch2 working tree; no source commit | `8998819dbf1458e83d80c537066cd7c5ab16d044e5954a823b61c8b4c26a9be2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/Test-Corrections.ps1` | Local-only; cha-branch2 working tree; no source commit | `b6838eb5942fe96ae7dc2684e9f2bc8f57b54b5429274f34ebf6ab98881eeba4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/Write-ReviewInventory.ps1` | Local-only; cha-branch2 working tree; no source commit | `757cb552dd9b5e29f32fb40fcfc52e064f00fd14896cab38e734bc1f16b342a4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.0.cs` | Local-only; cha-branch2 working tree; no source commit | `0f484796be10314137296f165cf647c187d95ee5d62fff5886f58f1f0700489d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.1.cs` | Local-only; cha-branch2 working tree; no source commit | `c6b62533b22b4466fc99a7f227cdf88f9b2f440564701fbfe4c563f386520194` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.2.cs` | Local-only; cha-branch2 working tree; no source commit | `261975ef68e63b4d84d9465fdafba93f5bd3e8ea8da856906b4150586bc3bcd6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.3.cs` | Local-only; cha-branch2 working tree; no source commit | `3d82f103d3f46f6a1221a316181ef22b0d18c9c7867b0abd99ffd45259786686` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.4.cs` | Local-only; cha-branch2 working tree; no source commit | `a036d89b16322ddaf965582546601eed7fc89dbf9a16c131ecd24a3b2f172b51` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.cmdline` | Local-only; cha-branch2 working tree; no source commit | `67347df680a1b84eb85c1f3c59ba672f82ab57f34258534543a88fe03a2cf6a1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.out` | Local-only; cha-branch2 working tree; no source commit | `2cef36978afa7f8e68c68d561f0d9333aac42955fa0d446c9ef69997bbcfb434` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/compiler-inputs/iodccsre.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `a8bab46324dfef743b634ed8820f543cb67a9f2e751cb5712dc16f16fb7e28c6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `78f78f7b5db8c2ea6030cbdad30267554ad663bc7c94c3cdfb21baa780808dd5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `29d79b992bc7cc29c602bd218918ad874fe4684cf81e1c4cf7d092d3f2c18e6c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `3c4303bbd46aea901132b4b90de5dcc4e3315f31ba9d6873ba772e09a13a91c6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `46ef3d320160fe4e429cab25de7fe6347ad6b5fc69748c4ed5d6458d318a9d61` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/compiler/w1xninxq.0.cs` | Local-only; cha-branch2 working tree; no source commit | `220aa7a0f375722deaeec32dc28c104f5516f48379a4ad0bb774d8e830430cf9` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/compiler/w1xninxq.cmdline` | Local-only; cha-branch2 working tree; no source commit | `3325b74cf8676c3570a93bd6b2c00a219d967af2c8ed7d5f5b5afcbc70c0f6d3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/compiler/w1xninxq.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/compiler/w1xninxq.out` | Local-only; cha-branch2 working tree; no source commit | `fc2c4389e8e49c5cd7e4e3409781d1bd0f5ac31b003d04fa739ecc1ef2ab05d3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-lock-test/compiler/w1xninxq.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-memory-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `4c28b9d73fefbd6371dd75a42ab14a1b35bc14ca3143b66449a676e15d240839` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/snapshot-modification-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `6dd55c431b2ee58748327c4e11dfa43eadcab39d62e336776f95e89678ec7ed2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-emergency-only-recovery/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `0e7e8acea4f6682d8faea9bf0322559267a8ae8088e93abbd4eec65a535528f2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl` | Local-only; cha-branch2 working tree; no source commit | `ea4a915d6eb60cb983c33f684ab22be74309dedb11b18f4892b74d209a684ea4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-emergency-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `a89aa6eb26993df77534de5600509fb195ecc9e93760e72abc3db5ebe6193820` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-emergency-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `56bc84603f0274ebf5c1f03ec295967ba205beaa75fbef71f9bc346f5b2b0d4e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-root-bytes.txt` | Local-only; cha-branch2 working tree; no source commit | `07e6171b62102a12611b0fc55ac766e9a32a5d8167b39087fd534d37592f84b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `f39612731c68fe71efb1033d0f5eb0ba8cd6aa30e77ba437d198baa38b910212` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-3892609edcbf4448ad25a1f28eb99fe8/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `5477a87aee6fe4334b6f6381568302d390a0e1c6b5bb257b0b414a2be88474fa` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.0.cs` | Local-only; cha-branch2 working tree; no source commit | `0f484796be10314137296f165cf647c187d95ee5d62fff5886f58f1f0700489d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.1.cs` | Local-only; cha-branch2 working tree; no source commit | `c6b62533b22b4466fc99a7f227cdf88f9b2f440564701fbfe4c563f386520194` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.2.cs` | Local-only; cha-branch2 working tree; no source commit | `a65f941eb6236859a21fc12aa7c8138f54b7a9e0bd550fe01cc60fa0f3bab32b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.3.cs` | Local-only; cha-branch2 working tree; no source commit | `3d82f103d3f46f6a1221a316181ef22b0d18c9c7867b0abd99ffd45259786686` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.4.cs` | Local-only; cha-branch2 working tree; no source commit | `7e2fc55d84d12d491ff6ad26c870df1cd0c9f68f04177f011bda86ed05a81151` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.cmdline` | Local-only; cha-branch2 working tree; no source commit | `1eb8cc0a36b33b8ecc35e2830d15c131f543cb0daf87847e79207ab0930bd054` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.out` | Local-only; cha-branch2 working tree; no source commit | `6e5988dc5ad86b6a9b3c2de26e8214fbc3094d3c9a9accca7a3fa9a8b732667a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/compiler-inputs/xkn45nb5.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `e2dabc1d919a9e13f2d39ec0b5eae592c4b1182bac234646908518c3545de9b5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `8327a91e038582e035f9c80e76ecbff40b42add0be6f4e385227b2569065194f` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `af5bb04634a7818240c78bf178b19b252fe2ae93d072293407e42fa675e1e19e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `1da152b280d86867d974fd2bd6fe94560feba15cd53cd1597962d7f4b9be6118` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `deee44bfad52df50d9216becdd9edb5ec67085bbcf10f4f2d54e801222239b4a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/compiler/4yoiy3y0.0.cs` | Local-only; cha-branch2 working tree; no source commit | `00acef227c13dd852819b891a7d5cd5d5787fb594d378eb7ee2bba6c62573e22` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/compiler/4yoiy3y0.cmdline` | Local-only; cha-branch2 working tree; no source commit | `080dee9d91385a52261f7da1f239e4a9f062eb09b56ca8931b7c3a4de6efc8a5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/compiler/4yoiy3y0.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/compiler/4yoiy3y0.out` | Local-only; cha-branch2 working tree; no source commit | `6ed25cb2fa60941a2bb41ae9ca4fa42fe4b6325d4265178e78c162ea7ca4ed42` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-lock-test/compiler/4yoiy3y0.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-memory-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `4c28b9d73fefbd6371dd75a42ab14a1b35bc14ca3143b66449a676e15d240839` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/snapshot-modification-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `6dd55c431b2ee58748327c4e11dfa43eadcab39d62e336776f95e89678ec7ed2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-emergency-only-recovery/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `4828134d8e5455cf3bff76cffc26959e12348ad23a42ffae5cf4f3da21e1053f` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl` | Local-only; cha-branch2 working tree; no source commit | `515326f7977eba6f4f8a36682d7ce41fa101b95c8aa76f02033ddca4353b0ee2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-emergency-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `1ccda47aa6e49229bd7863c944a74cedffbbc92b6de6cbf700632c132ae8397d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-emergency-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `aabbcdeed405af3b88797592085e80bcdef8616b93406582bef7d883f65e78b8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-root-bytes.txt` | Local-only; cha-branch2 working tree; no source commit | `07e6171b62102a12611b0fc55ac766e9a32a5d8167b39087fd534d37592f84b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `e534e01ba9ccd22495b632378b25797b54d8134d338f8cad68da4590482d21d0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-bebd27bce9604f5788913b8b6278d28f/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `5e18457e43f78076b1872af303887597418609dda1759abded66d33740cb3a1f` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.0.cs` | Local-only; cha-branch2 working tree; no source commit | `0f484796be10314137296f165cf647c187d95ee5d62fff5886f58f1f0700489d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.1.cs` | Local-only; cha-branch2 working tree; no source commit | `c6b62533b22b4466fc99a7f227cdf88f9b2f440564701fbfe4c563f386520194` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.2.cs` | Local-only; cha-branch2 working tree; no source commit | `261975ef68e63b4d84d9465fdafba93f5bd3e8ea8da856906b4150586bc3bcd6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.3.cs` | Local-only; cha-branch2 working tree; no source commit | `3d82f103d3f46f6a1221a316181ef22b0d18c9c7867b0abd99ffd45259786686` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.4.cs` | Local-only; cha-branch2 working tree; no source commit | `adf168f286a320ca2b269a723ccbe8acb5fa4945ab28d1836dfb7c5e72617a3d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.cmdline` | Local-only; cha-branch2 working tree; no source commit | `5be372314fc048adf91e2589ed021f91082ee13adb8581464110e3bfcc9af83e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.out` | Local-only; cha-branch2 working tree; no source commit | `a6b2d0caa729815bce7363ede93a5d23905b8f2c46e85edf53d589dc7cdf6f69` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/compiler-inputs/nr1pfszj.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `5ac6e08c1e0fd82c67ec2efa361430d0e8f4dc8f2e2761b95ce793c269bbdd12` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `9bd7194603e568a472bebee0b8becb13fb53cad30635288b18a3104799c22b89` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `138ebaf270c5c5eb13877e0a02f4cd32b3b48073566f3e899420d35daaf53f38` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `364d8f83c3c1fc5a2b3ae6ab4741a05e5596e63086e1e9b4f3fe1938e96fb8eb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `1ce2f7fcd7d270074d3373a652bbbd1b801f8ef9e81404158f6bbda61ab168fb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/compiler/skunt1lh.0.cs` | Local-only; cha-branch2 working tree; no source commit | `7108d6dcf669387dd8ffc76c7a0ba3f3a05e83f1ad6e91405be1c54de1cbfc5a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/compiler/skunt1lh.cmdline` | Local-only; cha-branch2 working tree; no source commit | `26d2381dab417c3d4d40bf89a441fe35a5cf10443f0ddeb8fa71e82936f0ec66` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/compiler/skunt1lh.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/compiler/skunt1lh.out` | Local-only; cha-branch2 working tree; no source commit | `82b06727b737c7437f990c3643ef85002f918e5491e2f869440b0107c3e63f9d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-lock-test/compiler/skunt1lh.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-memory-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `4c28b9d73fefbd6371dd75a42ab14a1b35bc14ca3143b66449a676e15d240839` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/snapshot-modification-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `6dd55c431b2ee58748327c4e11dfa43eadcab39d62e336776f95e89678ec7ed2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-emergency-only-recovery/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `b7fa64d46a9e55d773db750e0acd94a42f7bd9c8f44fc5a39f9d2aaddf619901` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl` | Local-only; cha-branch2 working tree; no source commit | `2290fc61e85ca98450e9fab5cfb1685ba5c0cc18bfd7c56e08906bbaff9aedc8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-emergency-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `b72f42b688427eba3a7ffbab80e677db2347497be640a3002e44f551000bd467` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-emergency-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `a723f851a3e31aac8a05587e9b5a352c6fa09d4fa852d179c663f68586eebdea` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-root-bytes.txt` | Local-only; cha-branch2 working tree; no source commit | `07e6171b62102a12611b0fc55ac766e9a32a5d8167b39087fd534d37592f84b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `ec3bdc2c9949480b0451613f1958b6193b4ccaff095f7097d0551972520f54ac` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `6e44614e709861a98d87480ad9041c67ac6955e41f5d1bc34983d501dc81653e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.0.cs` | Local-only; cha-branch2 working tree; no source commit | `0f484796be10314137296f165cf647c187d95ee5d62fff5886f58f1f0700489d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.1.cs` | Local-only; cha-branch2 working tree; no source commit | `c6b62533b22b4466fc99a7f227cdf88f9b2f440564701fbfe4c563f386520194` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.2.cs` | Local-only; cha-branch2 working tree; no source commit | `a65f941eb6236859a21fc12aa7c8138f54b7a9e0bd550fe01cc60fa0f3bab32b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.3.cs` | Local-only; cha-branch2 working tree; no source commit | `3d82f103d3f46f6a1221a316181ef22b0d18c9c7867b0abd99ffd45259786686` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.4.cs` | Local-only; cha-branch2 working tree; no source commit | `251907c4d88bedbcaf4e0a5447ce93f3d8ee389c13e15a4601debae5d7a0fd11` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.cmdline` | Local-only; cha-branch2 working tree; no source commit | `32df5f80ee7924c70a858cd544cc0172153f945343b45bc2ad267658d7914c88` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.out` | Local-only; cha-branch2 working tree; no source commit | `d5fe0318a6b8337688fbf76e28a000309d5774ebf4121316ecf8d96b58824fb7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/compiler-inputs/nmgkisxx.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `8c24c9bb6205e187a8ac0f9a5a7ea221eac0f5a1e0a06f7ca6b83abb9d97d775` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `3be8f3f553798824af0f69b319217114b562e47fe86efcbff27341a9c2702067` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `ea8ee91ec9ec47ef4b698e3ba3c0c308772929d1ebc6358c0265b39f5b6395ee` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `786459ded698f904a1ea8ff5536341706bcc6df8204f2ef4deb88c1cc9fc7249` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `801f06504f37a959734d01aadac12142c778d26803edef17cc89575680ddc195` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/compiler/tvdk0wkm.0.cs` | Local-only; cha-branch2 working tree; no source commit | `77c4b6e492f1252f146e2726490b40930081128f4fd36f41b3c549e5134af9f1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/compiler/tvdk0wkm.cmdline` | Local-only; cha-branch2 working tree; no source commit | `a21c7d94949ca1e6331a4651fa462d2cccf15bcfdb6fde041299d181181dfe96` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/compiler/tvdk0wkm.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/compiler/tvdk0wkm.out` | Local-only; cha-branch2 working tree; no source commit | `f6e7ca78d0b0d5e28ed40d43267bebdfe927463d24c64786c37bfe0e88fc3d34` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-lock-test/compiler/tvdk0wkm.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-memory-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `4c28b9d73fefbd6371dd75a42ab14a1b35bc14ca3143b66449a676e15d240839` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/snapshot-modification-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `6dd55c431b2ee58748327c4e11dfa43eadcab39d62e336776f95e89678ec7ed2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-emergency-only-recovery/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `9ebbb70b9aa122e63fde996ea6c23e01af0e8d01a14625c958fb6069bf34e600` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl` | Local-only; cha-branch2 working tree; no source commit | `669d955059a7db4ce7512be808d15e5d5719a71930cb82f62bd30cad949b9b8c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-emergency-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `cfae553b27b2f8544de32294b5573e93d105e51d3375f3e22b4495dff70cce71` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-emergency-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `d6afa2180e2a7405aa2473f7ad541a1f5afdd4ede5ebb741e02a37cf375e06fb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-root-bytes.txt` | Local-only; cha-branch2 working tree; no source commit | `07e6171b62102a12611b0fc55ac766e9a32a5d8167b39087fd534d37592f84b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `b805b70039b9ceb3690af5ff11074d7344f9d1083a55c7be8bf6dbbcfcdb9fdb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d4164e06880e4ef5acc1bc83ef374ce8/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `e8a646951cc4e7bbb884c1656ec21d4b3aab7bd4677373e2e23b324bf06af05e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.0.cs` | Local-only; cha-branch2 working tree; no source commit | `0f484796be10314137296f165cf647c187d95ee5d62fff5886f58f1f0700489d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.1.cs` | Local-only; cha-branch2 working tree; no source commit | `c6b62533b22b4466fc99a7f227cdf88f9b2f440564701fbfe4c563f386520194` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.2.cs` | Local-only; cha-branch2 working tree; no source commit | `a65f941eb6236859a21fc12aa7c8138f54b7a9e0bd550fe01cc60fa0f3bab32b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.3.cs` | Local-only; cha-branch2 working tree; no source commit | `3d82f103d3f46f6a1221a316181ef22b0d18c9c7867b0abd99ffd45259786686` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.4.cs` | Local-only; cha-branch2 working tree; no source commit | `7e2fc55d84d12d491ff6ad26c870df1cd0c9f68f04177f011bda86ed05a81151` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.cmdline` | Local-only; cha-branch2 working tree; no source commit | `dcad5795b4d08f6d878caba3875ede2c574eccc0db9258037f37d5a54573ed15` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.out` | Local-only; cha-branch2 working tree; no source commit | `7b91c93903e847debb0cfee7fd9976adf1e0e59488a7db5d315158187f4d31f2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/compiler-inputs/dsm3hbvw.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `70af79dfa0e8c032c29b15ea3c8b7c02d3ae584222f839e98f49bd56e71632ad` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `cf42b349d40bd85ad91dceeab3911024a7a18acc9a20985e195ccfce33a5d484` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `d91f608bacb894f9b05268191c7fd705c6e516eb03a583b7cf0e984558651f99` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `bb8018960661bf0c018a7ebf9e6c4ec8e72497551bf7db70f0aa0441784c1400` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `4035db69cb4ea505310ec4eff0bbf274d6182eeaea43ee6cba9a1e5412aed65b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/compiler/4asulfos.0.cs` | Local-only; cha-branch2 working tree; no source commit | `18825f45a2283fed49ec375cf66debfdaad7833488b415fb513840d8f5cfd7b7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/compiler/4asulfos.cmdline` | Local-only; cha-branch2 working tree; no source commit | `5dba827136d59d5103bfd5787f5809d735ff4dc27e5c63ce918f99d02a0ccbaa` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/compiler/4asulfos.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/compiler/4asulfos.out` | Local-only; cha-branch2 working tree; no source commit | `a455791f796d529192ca67351046ea9a86249366e0057faef26bae2fa634b267` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-lock-test/compiler/4asulfos.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-memory-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `4c28b9d73fefbd6371dd75a42ab14a1b35bc14ca3143b66449a676e15d240839` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/snapshot-modification-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `6dd55c431b2ee58748327c4e11dfa43eadcab39d62e336776f95e89678ec7ed2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-emergency-only-recovery/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `60488e1ccb76659f62ead71bd68af638d9ccdec6bed26711611fce0097213890` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl` | Local-only; cha-branch2 working tree; no source commit | `2be1ae1c4d348b7ee513171c2bce4c134a8609cb9e173d1f21a25761dea1361c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-emergency-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `478573acf2c8a9584002b9c10f3aa97b30765d067138d3f023062b1b5bd3614c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-emergency-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `8470d1d8dd6d33e24bfdd29e05ab640a7e48cbfe7a50636cf19a297937e47cf4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-root-bytes.txt` | Local-only; cha-branch2 working tree; no source commit | `07e6171b62102a12611b0fc55ac766e9a32a5d8167b39087fd534d37592f84b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `6715f4b652cfa9e822ecebb12fd450a1f0dafb29a382b2d8818260b9f1f7a0e8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `4882652349926f6e3a158f1b9af4d2bef195478748e0e7e2395951b9401c7fd3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.0.cs` | Local-only; cha-branch2 working tree; no source commit | `0f484796be10314137296f165cf647c187d95ee5d62fff5886f58f1f0700489d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.1.cs` | Local-only; cha-branch2 working tree; no source commit | `c6b62533b22b4466fc99a7f227cdf88f9b2f440564701fbfe4c563f386520194` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.2.cs` | Local-only; cha-branch2 working tree; no source commit | `a65f941eb6236859a21fc12aa7c8138f54b7a9e0bd550fe01cc60fa0f3bab32b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.3.cs` | Local-only; cha-branch2 working tree; no source commit | `3d82f103d3f46f6a1221a316181ef22b0d18c9c7867b0abd99ffd45259786686` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.4.cs` | Local-only; cha-branch2 working tree; no source commit | `7e2fc55d84d12d491ff6ad26c870df1cd0c9f68f04177f011bda86ed05a81151` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.cmdline` | Local-only; cha-branch2 working tree; no source commit | `25c3272edc8a84a4ecde84567844d8161e0344f58177f60ab29b6c29bc4d173b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.out` | Local-only; cha-branch2 working tree; no source commit | `d49c030164d55560bbd3d6a8e31c660dc3a026e53a6f76c13021e161a308562f` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/compiler-inputs/ahd0vsna.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/journal-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `ca5c458be090216ed9ce5cc524c653b434519198d09f16d04fb2410b6d7fb04b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/journal-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `cbf8dbd77dbfda188bc463c76fa537fe19367c443da35b930374fc6b83ebc64b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/not-a-directory` | Local-only; cha-branch2 working tree; no source commit | `0b7a15ad83623728049a733f4241f3692131c1fa8c3db2a342fde771e40c16e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/serialization-failure/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `da246e0a1ed54f166918a5dad2089de20b9bbb8411ba19a188c761973ef96c76` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/serialization-failure/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `00ce8bf5613485c091bf5bcefab48d82fc5cd2161a360b2181da42b51ca47e4c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `a963b9216f3684f7cb3f047a6506420872a43f38e501757cf2e78ea88e2fa1be` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/compiler/b4uqrthv.0.cs` | Local-only; cha-branch2 working tree; no source commit | `5d5503ab4e241d6e87863792b6e185240a7976884560a9dd522f569243880679` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/compiler/b4uqrthv.cmdline` | Local-only; cha-branch2 working tree; no source commit | `81ec4aaf37dde3d271fb835842809e6825f4c84e2f048434520d89c07dfee800` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/compiler/b4uqrthv.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/compiler/b4uqrthv.out` | Local-only; cha-branch2 working tree; no source commit | `19f6287488e9bd50ce5ade86635bfeb1ba07f65b5e798f99f5ca1166c43cc712` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-lock-test/compiler/b4uqrthv.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-memory-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `4c28b9d73fefbd6371dd75a42ab14a1b35bc14ca3143b66449a676e15d240839` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/snapshot-modification-test/Probe.cs` | Local-only; cha-branch2 working tree; no source commit | `6dd55c431b2ee58748327c4e11dfa43eadcab39d62e336776f95e89678ec7ed2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-emergency-only-recovery/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `df31b288896e057deee718b76644c1645ee52dc0c67aee6a76b93266851f5301` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-emergency-only-recovery/primary-unavailable-preserved.jsonl` | Local-only; cha-branch2 working tree; no source commit | `a2c88b084b05face0da55fa45044523de923a71ac0cbbd1b7dc752a7a4db4258` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-emergency-success/emergency.jsonl` | Local-only; cha-branch2 working tree; no source commit | `ddfa1593bca6e7a045cf7758ef940e9a001fa68857e13710df46c0ffde235606` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-emergency-success/journal.jsonl` | Local-only; cha-branch2 working tree; no source commit | `53086fb5621df5c1959a21bc2b5dbc50f23cb0230e1538772d775aa9efb6ccd8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-root-bytes.txt` | Local-only; cha-branch2 working tree; no source commit | `07e6171b62102a12611b0fc55ac766e9a32a5d8167b39087fd534d37592f84b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-sanitized-example.jsonl` | Local-only; cha-branch2 working tree; no source commit | `6c361f82774023cccfd2a452c4699d3ed1b33e034a281da5942bcaf55d44302a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-fdf7956c5ace4af7bd47605d80d44f9d/test-results.json` | Local-only; cha-branch2 working tree; no source commit | `93362bf8b29eb2cc608d3dfe0cdbf51fd018b484a624d8a9a9652f62a5be5e80` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-controller/v3/review-inventory.json` | Local-only; cha-branch2 working tree; no source commit | `6f8adf82413ca2f5188fc1fef91a3171b9d71f0c58c12d042852e800617ced0d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/PENDING_REMOTE_AND_CLOSURE.md` | Local-only; cha-branch2 working tree; no source commit | `0748a45e1b8c0dd7cc34db476e51fc49c18e2c34eaa367cb1e85aa1dfefd972b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/README.md` | Local-only; cha-branch2 working tree; no source commit | `a1b3f085711a896da55ea9ad4dd0bad84081a1bdce523bae97771412461c83e7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/REQUIREMENT_MATRIX.md` | Local-only; cha-branch2 working tree; no source commit | `0f1b79328ba7b6e4e85d16f349460657e6da4ee9374b042aeb074770defd1dbd` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/REVIEW.md` | Local-only; cha-branch2 working tree; no source commit | `aa8951f2726e336934929798b4d84a948437b8aa1f81fed87100827a330e02eb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/Verify-AdditionalControls.ps1` | Local-only; cha-branch2 working tree; no source commit | `c7478f3c8a80704e91258ccab2d7ab36d0ab20d02db31df53e25f0094617d884` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/Verify-LocalEvidence.ps1` | Local-only; cha-branch2 working tree; no source commit | `00beb7b557f88c7b2ea8ea8cb5d6068cf5b7820bab5d774482479a2c01edec89` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/Write-PackageInventory.cjs` | Local-only; cha-branch2 working tree; no source commit | `aaec2cce9b20eeee1591dfa4091ef3adf0f07a73ff01b0d8ba340a78bb64ca01` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/additional-controls.json` | Local-only; cha-branch2 working tree; no source commit | `b5f439f813e7f9659f26a078064c6b085b5bb4621f22df8a9a8011ce0ed98c1e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/local-review-evidence.json` | Local-only; cha-branch2 working tree; no source commit | `72bfcfabde4e7f3fc42fc41cc27d13ba08bf4c6d0cc88d23ce3b333ace482551` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/original-scope-extract.json` | Local-only; cha-branch2 working tree; no source commit | `676c1b16cfbc80d2d1e74119cc7bbf43fe569cb6f9ee97100b6c51a3a5196ef4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/package-inventory.json` | Local-only; cha-branch2 working tree; no source commit | `b19f1a05c1a9000756365ceea30d6809a5d803bff5bf7cf77dfd8621ca700834` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.0.cs` | Local-only; cha-branch2 working tree; no source commit | `0f484796be10314137296f165cf647c187d95ee5d62fff5886f58f1f0700489d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.1.cs` | Local-only; cha-branch2 working tree; no source commit | `c6b62533b22b4466fc99a7f227cdf88f9b2f440564701fbfe4c563f386520194` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.2.cs` | Local-only; cha-branch2 working tree; no source commit | `a65f941eb6236859a21fc12aa7c8138f54b7a9e0bd550fe01cc60fa0f3bab32b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.cmdline` | Local-only; cha-branch2 working tree; no source commit | `c81e27707a72aec6c154aa72fc8b1df61d103356694968fe4a4e34eb887e6367` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.err` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.out` | Local-only; cha-branch2 working tree; no source commit | `d208d5b22b7a4ed50028d2a1a84c686867eb6f837d09eb87baa00561328aeadb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-execution-package/production-subset-compiler-inputs/r3rngxf1.tmp` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/q12-phase-a-status.json` | Local-only; cha-branch2 working tree; no source commit | `341a49d2a5193878252e65357484fb6e6eaafd68232f9b5345f73e1db712b0fb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-ally-c02-20261102.txt` | Local-only; cha-branch2 working tree; no source commit | `9751a0ee6bae3da807798c6f047589ca1b05349a466e6e0aa3f808ff50472436` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/RESPONSE.md` | Local-only; cha-branch2 working tree; no source commit | `0286f8ed0b32047eb4685b891d103417592f18fa443f54e06ca12970c3f789d0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/dart-version.stderr.txt` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/dart-version.stdout.txt` | Local-only; cha-branch2 working tree; no source commit | `ec311d60ac82411553348b5995b2f09e0fbf926df824102f12c35ba83c2788e5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/dart.stderr.txt` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/dart.stdout.txt` | Local-only; cha-branch2 working tree; no source commit | `deaa0cf482cbf7a85a7def464a117fe9bbd2fea8a9a6db3e733c3dd828b1536a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/dart_manual_result_02_review.dart` | Local-only; cha-branch2 working tree; no source commit | `a7f3744a19905651f6562350d92fa373401506a79990f85630c0b028178ff269` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/evidence-manifest.json` | Local-only; cha-branch2 working tree; no source commit | `be9a9b8b9ffa73a3ea428a3148b792c24ee6d64733ac569bc7278e9bd9e8ac99` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/inputs.stderr.txt` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/inputs.stdout.txt` | Local-only; cha-branch2 working tree; no source commit | `8b444c7dd119d99a6ba59ac931dbc6795b1a2149ad4b5d182f600d5801dd8df0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/node.stderr.txt` | Local-only; cha-branch2 working tree; no source commit | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/node.stdout.txt` | Local-only; cha-branch2 working tree; no source commit | `487616b5779f36305be41eacf536212f65d18ab05e0d1b186d56a28bc66c2eca` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-02-20261031/verify_inputs.ps1` | Local-only; cha-branch2 working tree; no source commit | `bb8814207722b03f8136859f9de52f541ac65694cd917c216091ab2ff79ce010` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-dart-20261031/README.md` | Local-only; cha-branch2 working tree; no source commit | `5895bbe5703337543794f40c36b4375997cfc1fbc41ad6943870d468c0742536` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-dart-20261031/TASK_CARD_MAPPING.md` | Local-only; cha-branch2 working tree; no source commit | `14138ff36db64ac393ac74e817206a3518e5177e35940b76f86e4615d0996314` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-dart-20261031/dart_manual_result_review.dart` | Local-only; cha-branch2 working tree; no source commit | `bcb7ab832eabd97092e6d22a983910cd4e32288e5777f3cd79adbbd1ee57b45e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-dart-20261031/dart_manual_result_review.recorded-stdout.txt` | Local-only; cha-branch2 working tree; no source commit | `4eb32381e37ba6b345302773898b0f7f240ad3d96c39d3122df7267fc3231704` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/received-kath-dart-20261031/manifest.json` | Local-only; cha-branch2 working tree; no source commit | `fa94355ddc6c755ea40fbd624eb06d23e2ff1b217314e529bfb349c88c26c6ca` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/remaining-decision-requests.json` | Local-only; cha-branch2 working tree; no source commit | `b5e579814e79242e0deeee72bc8642c5e0d05f1df0e43009624f2863cb59d220` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/remaining-portfolio-section.cjs` | Local-only; cha-branch2 working tree; no source commit | `43864a6b98dca06c3a16706bac7ad03939f09ec4ef7933d39c47a45b918dad71` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/remaining-queue-after-c03.json` | Local-only; cha-branch2 working tree; no source commit | `2bf9498c28015c492005fd69b87cae5f0a89be7b1796976e23e573b12e177a55` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/remaining-work-items.json` | Local-only; cha-branch2 working tree; no source commit | `b578bfaf06df0dd210b8901b45b528c1ed5f1c7298e901f10cf04e48c2b193ec` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/remaining-workqueue.tap` | Local-only; cha-branch2 working tree; no source commit | `adf2aaf18e290081183c0bce3dda99902468dc97b251b35cda6bb2f4fd06e193` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/remaining-workqueue.test.cjs` | Local-only; cha-branch2 working tree; no source commit | `eaadebff5ffb4a6b5edd3adb961190c430970991f92aa7d25bccd2ad3facc9ba` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/review-kath-focused.cjs` | Local-only; cha-branch2 working tree; no source commit | `7e5f24dd36b65d4ad85c21b11079e8d6531be3af2feb23c11f5d301303d477e2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/review-supplemental-csvs.cjs` | Local-only; cha-branch2 working tree; no source commit | `56852bb919c349fe48657b79010fcf6b9a5c4cecc02aad79605bc0f947636caf` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/review-supplied-csvs.cjs` | Local-only; cha-branch2 working tree; no source commit | `7d490a4ff4ec861fbb28ab7ea79f8ed7026012f73d7f4d1429620ce97e0e354e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/run-approved-security-test.cjs` | Local-only; cha-branch2 working tree; no source commit | `d4e3e67cce0c710da707a879eee0c02ac5039c98f8e0659c7b8cd9b1f1f2a697` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-06-412Z/error.json` | Local-only; cha-branch2 working tree; no source commit | `c1e1bd63a9377395389a59578afed6d546f539166fba0fd88f24a6a482156506` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-18-577Z/cli-role-initialization-note.txt` | Local-only; cha-branch2 working tree; no source commit | `8c64c6875f5ef55d63bbb65b22510ca73de343b2194732ef6033b966f77fd0eb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-18-577Z/fresh-catalog.json` | Local-only; cha-branch2 working tree; no source commit | `f1ab448e9360004a039dc96eac9f3474e70d70b3ed3c069b8570bb2c1d9c7f5d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-18-577Z/status.json` | Local-only; cha-branch2 working tree; no source commit | `9bfcf98193dda7a28b96c4a9d094c4a7e711af1b00c70112bbb1a3ba4c81bcc1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-18-577Z/verified-target.json` | Local-only; cha-branch2 working tree; no source commit | `b4ac0f73aaba6c9e73aea0a8dd0b048bffd71fd1a5b531ee1b6ba2a9f9385f2f` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/cleanup-results.json` | Local-only; cha-branch2 working tree; no source commit | `9bb75c51ba1bf7ba24601ce89de35741ed68dba03300fed100e2dc2c0d0c13ff` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/cli-role-initialization-note.txt` | Local-only; cha-branch2 working tree; no source commit | `8c64c6875f5ef55d63bbb65b22510ca73de343b2194732ef6033b966f77fd0eb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/fresh-catalog.json` | Local-only; cha-branch2 working tree; no source commit | `23684fb9de3a5523c444cf51d525de106f87d81fbdf808acb6d6bd8d234b2e46` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/probe-results.json` | Local-only; cha-branch2 working tree; no source commit | `a8f9fe74f2bec8df1e9483053b47449dc26ab0fa31ede3f5c0f85fd68536a349` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/probe.sql` | Local-only; cha-branch2 working tree; no source commit | `c5cfb622e9af87db04a60d5df035bb15ff99367dc75eafe82d3946ecd86956fc` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/status.json` | Local-only; cha-branch2 working tree; no source commit | `536174b2ad89663c7bb091f8ec2782aaa8a5ac3d9a62a465891e3dee4c214e42` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/verified-target.json` | Local-only; cha-branch2 working tree; no source commit | `b1023076fc84495aee1d71b15039cee3f0ecec0b1f68816d37d1ef73b246a489` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/verify-cleanup.sql` | Local-only; cha-branch2 working tree; no source commit | `e92ac1e10fa25b77074842e127417344742d0a3cafbbe8d0805b96f6107f723a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-test-plan-validation.json` | Local-only; cha-branch2 working tree; no source commit | `5c40f4eb4504d2ea0538e8b252c4333738744d00e1bae9c4dec12a22881a500a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/security-test-plan.json` | Local-only; cha-branch2 working tree; no source commit | `98c75be91e495f299a0931508d4097efe1e7cafc48fd32230bad1b4f57a4938c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/serve-portal.cjs` | Local-only; cha-branch2 working tree; no source commit | `b06e23b59f0cb354bb3cedc23b87bf271234b2da956a8b4c8e2c6c9bf822d262` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/supplemental-csv-review.json` | Local-only; cha-branch2 working tree; no source commit | `aaaecd308fbd4f8dae8fdbb13cd674533d93c0c2a44c58c5037038c1c0aa73bd` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/supplied-csv-review.json` | Local-only; cha-branch2 working tree; no source commit | `e044f010aa52e04cf56c7073ec33f21ec8e8e4afd8888ba51ada55737755c9f6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/task-recovery-c02-isolation.json` | Local-only; cha-branch2 working tree; no source commit | `0ec91c0fc39ce1f978655a4c4231ef8b0ae2c945487291e19562404550919517` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/task-recovery-c02-isolation.txt` | Local-only; cha-branch2 working tree; no source commit | `c823c4e2a4074a11983465917116dde3f729855dc31b09d64e336777fa27c2c5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/test-edge-functions-audit.json` | Local-only; cha-branch2 working tree; no source commit | `50056c08ce479cc2f54c4d6595a4264bdf32bf84f2995d59ff3bd513897ab414` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/validate-ally-export-review.cjs` | Local-only; cha-branch2 working tree; no source commit | `0c91e5f92da2513d9fa69b5da5eb601a9ae776e18578192374d88fcb75e8c84e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/validate-approved-security-results.cjs` | Local-only; cha-branch2 working tree; no source commit | `bc9d752de71ad420022ab27d4b150ae4b74915b606b9c15e9f9951a67b17ffe0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/validate-mary-d04-d06-answers.cjs` | Local-only; cha-branch2 working tree; no source commit | `4334fc2f16ad218b0f8fcfbc4c03103ab596e66b5068a7df71978f7d2c9c856a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/validate-oct26-c03.cjs` | Local-only; cha-branch2 working tree; no source commit | `8c21a50c3e1434712a7a70c229ab6802019f8e0a855cc4daebeae9b400a759f6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/validate-security-test-plan.cjs` | Local-only; cha-branch2 working tree; no source commit | `904b28b4259e08c18e00d2520098c085c5ad21ac1549e851f63d8ece663b7c2e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/verify-ally-c02-receipt-20261102.cjs` | Local-only; cha-branch2 working tree; no source commit | `f3101331e5270a80ba2a468845cc076b63377ad59908937108799447f36bfac3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/verify-ally-zip-review.cjs` | Local-only; cha-branch2 working tree; no source commit | `4071bbf740a5f384669eb8e8e4444da88c82808228b55619fa28f24c5e307973` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/verify-completed-archive-browser.cjs` | Local-only; cha-branch2 working tree; no source commit | `86ca9e379485d5eae3d0325414473c7dc95ba3024e426da5750a34164d04975d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/verify-independent-schema-work.cjs` | Local-only; cha-branch2 working tree; no source commit | `f0560296514b4f273c5fef32837229ee6018771af6c83c4008f97b27b4fd1105` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/verify-kath-02-delta-evidence.cjs` | Local-only; cha-branch2 working tree; no source commit | `e8e08b53f9d273b1b51a5f98f9f92c62ba0e26ba980c891762281657e5e59387` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/verify-kath-closure-20261031.cjs` | Local-only; cha-branch2 working tree; no source commit | `c46210d1d40076e8c6527de8c67d2ccf564e2ed23d3766657340cbe660507377` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/verify-kath-dart-evidence-20261031.cjs` | Local-only; cha-branch2 working tree; no source commit | `33eade6166c6e1dd8fa343c4c8360766e57366d4d6bf332ff121f0c35ab1c372` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/verify-monitoring-evidence.cjs` | Local-only; cha-branch2 working tree; no source commit | `4dbc8eb5baa6d64f82489af602366bf1c8595d49be751520c369c7db1f57ad38` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/cha-execution/verify-portal.cjs` | Local-only; cha-branch2 working tree; no source commit | `3a4fb75a9a3e3a49003ea8617256af04532867594dd7b4c28fecb32a563434c6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/Ally-2026-10-30-Packet-Review.md` | Local-only; cha-branch2 working tree; no source commit | `939cc95c4ddcf831c9fbbb3c1ee01724e98ee641fe761c71c219db5fb2449f3a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/CONTRACT-FREEZE-01_Team_Decisions.md` | Local-only; cha-branch2 working tree; no source commit | `1d500806e2c0d90d49f3e06b5710ba0648ebb61d94e78a6a24c19309ede13129` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/D04_D06_Mary_Backend_Position.md` | Local-only; cha-branch2 working tree; no source commit | `94877d61fe7b5ed8a49ececc5a17eb5609b45b5b658c635aab331b127d53a93d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/DB-02_30Oct_Consolidated_Alignment.md` | Local-only; cha-branch2 working tree; no source commit | `ff08bdabc5ce01124e431db5fec7c1547e4b3a24aadc91931b3a9865d5d26777` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/DB-02_Conflict_Receipt_And_Recovery.md` | Local-only; cha-branch2 working tree; no source commit | `08e6f97c7c320769e223218fbea7ce52a1d4a1b0ec5d117a83965d5678f39f06` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/DB-02_Exact_Bridge_Sync_API.md` | Local-only; cha-branch2 working tree; no source commit | `5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/DB-02_Proposed_Schema_And_Security.md` | Local-only; cha-branch2 working tree; no source commit | `6322985031a82d25184bd0ebefc7e1a9016d74c22b7e8d587e94dafb16d3f230` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/INTEGRATION-CONTRACT-03_Shared_Decision_Register.md` | Local-only; cha-branch2 working tree; no source commit | `9ff4344b72c6005053ce0221212ca09806fc45466b0f9acbfc85f6d63643d2ec` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/ORIGINAL-C-02-Flutter-Compatibility-Review.md` | Local-only; cha-branch2 working tree; no source commit | `ca179502cbb54414bed7ee8ab36753cbb6523a0f3c6532192601b0a38ba0398b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/README.md` | Local-only; cha-branch2 working tree; no source commit | `4e372238dd6255d278b6973f05c89e035bbb8d9dc5a228ff9a6d2317ad737f8a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/SmartHatch_Shared_Communication_Contract_v1.3_DECISION_READY_DRAFT.md` | Local-only; cha-branch2 working tree; no source commit | `70987831890edb16daaccfb47f7188061b41c5ea66658ac45fe4866cd1074f66` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/decision-consolidation-2026-10-30/manifest.json` | Local-only; cha-branch2 working tree; no source commit | `e7eb63fe6c89d77c4a4cee260e1eba0ccb4340c17521608896f28365452375ab` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/logs/2026-10-29-db-imp-01-node.tap` | Tracked HEAD; last touch 035e842 | `8f5b672ba09551301e5c85cc6404306a126718045b3e874e581316d12e2c48ac` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/integration/logs/2026-10-29-repository-inspection.md` | Tracked HEAD; last touch 035e842 | `b4f57c85dced5aa62ecc6c4cf44ec9b5f6447b4f1f90a42101c195bbb494a744` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/integration/logs/2026-10-29-supplied-checks.md` | Tracked HEAD; last touch 035e842 | `3011be90760b381a84878ca5211c8a3364710cc3312927f305db3ed51d8e4b73` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `docs/integration/manual-result-0.1-review-package/README.md` | Local-only; cha-branch2 working tree; no source commit | `272881b9fa00e67ab44849d9b1454e99faf5125087f785b0f706228fe0cb078a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md` | Local-only; cha-branch2 working tree; no source commit | `dfeae7398078fb91eefdfb39209e50a475f6a822dfd5623e95f0f5583e0a37e8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/contract-review/D04_D06_Mary_Backend_Position.md` | Local-only; cha-branch2 working tree; no source commit | `c51f8d8b16400a80238367b69c1f6c3496bf70a63a2eaf9aeb1ff1c8d85e046c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md` | Local-only; cha-branch2 working tree; no source commit | `4808510868e2ad57e35f9059dbcfa3e27bf1a54c6cf9d94a629037c35412e3db` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/contract-review/DB-02_Manual_Result_API_0.1-review.md` | Local-only; cha-branch2 working tree; no source commit | `be60e96696bcf6acde43727b2205410a81beed08907e7ce7a8a0c8770c20bb98` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/contract-review/manual-result-0.1.closure-matrix.json` | Local-only; cha-branch2 working tree; no source commit | `55c66ae00782dfdd4c255e2bfb9c2c984fdf0b2655cc42610f744ad9e31efbf2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/contract-review/manual-result-0.1.fixtures.json` | Local-only; cha-branch2 working tree; no source commit | `a92cba4f788eb844bd04824db3fa14c8c963dc57397299a7ae4d624bc8952f77` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/contract-review/manual-result-0.1.schema.json` | Local-only; cha-branch2 working tree; no source commit | `c8a17ad20cc1bc6656ef2f4029c725916fb9fab4bb0b5085850f75f8c7909125` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/integration/cha-execution/MANUAL_RESULT_PREPARATION_REPORT.md` | Local-only; cha-branch2 working tree; no source commit | `45d8161b03b93c8649ad07313d57f67e4db52f05cb66d5bfeb927b471011fe07` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/integration/cha-execution/manual-result-proposal.tap` | Local-only; cha-branch2 working tree; no source commit | `e196f3e496ea5bf964c89f010dee01be638e2de97877b89f877a7405e6ff24c8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/integration/cha-execution/manual-result-proposal.test.cjs` | Local-only; cha-branch2 working tree; no source commit | `98adb19cc8f30578c5a76a53544ed87b7ae0bcc1f00b32f0be467f76e9e34dc1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/docs/integration/cha-execution/manual-result-reference.cjs` | Local-only; cha-branch2 working tree; no source commit | `2387b78c0c721562823423ffcf2e07afeaaaa4e0904359b4b3519e5d9e18b661` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.1-review-package/manifest.json` | Local-only; cha-branch2 working tree; no source commit | `e78146184a6f3280afefe548e5ba8a4d6c453d8181d4c1f7ce36e297bffe3d55` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/README.md` | Local-only; cha-branch2 working tree; no source commit | `1992aa7b449125c1fe9049fe981fb1ecda8ff38d131078151c831210eb5431af` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md` | Local-only; cha-branch2 working tree; no source commit | `3a02ef85c675df2fd244482bc0c6e103d81a7721ebd7cc74cde93af4d13103c3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/D04_D06_Mary_Backend_Position.md` | Local-only; cha-branch2 working tree; no source commit | `ba4ff1ec9dfb5f7b3168f3a805d891b83c265b96876274bb9bf0ab39552d0869` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/DB-02_Manual_Result_API_0.1-review.md` | Local-only; cha-branch2 working tree; no source commit | `be60e96696bcf6acde43727b2205410a81beed08907e7ce7a8a0c8770c20bb98` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/DB-02_Manual_Result_API_0.2-review.md` | Local-only; cha-branch2 working tree; no source commit | `304da072775686906e67ea77ce635794273869f8ba3d933dcae80bf3fcdeabd6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.1.closure-matrix.json` | Local-only; cha-branch2 working tree; no source commit | `55c66ae00782dfdd4c255e2bfb9c2c984fdf0b2655cc42610f744ad9e31efbf2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.1.fixtures.json` | Local-only; cha-branch2 working tree; no source commit | `a92cba4f788eb844bd04824db3fa14c8c963dc57397299a7ae4d624bc8952f77` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.1.schema.json` | Local-only; cha-branch2 working tree; no source commit | `c8a17ad20cc1bc6656ef2f4029c725916fb9fab4bb0b5085850f75f8c7909125` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/README.md` | Local-only; cha-branch2 working tree; no source commit | `d9293fb3bf5e1b60587cd20d7da0166d619090a3f52fd9aca481b6037e0c1389` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/fixtures.json` | Local-only; cha-branch2 working tree; no source commit | `5ec00ee6b891e6c21cb5c3a378fca9fa6ea1c06d60e4d6c1b36a07b036bf2afa` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/generated-by.txt` | Local-only; cha-branch2 working tree; no source commit | `1a8de13b330f8aba1a267dfd72a66671767284ec9a45b72c6a99dcd061d6ca1a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/parent-and-change-manifest.json` | Local-only; cha-branch2 working tree; no source commit | `a2c723c8e574fe4cf6c22bde5039c94e58d04a50d05f73502173fd713ea287a0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/reference.cjs` | Local-only; cha-branch2 working tree; no source commit | `032f070b7e584729436a311aea4a8cd9d2223650d40e8f907698056c0763c209` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/contract-review/manual-result-0.2-review/schema.json` | Local-only; cha-branch2 working tree; no source commit | `b2d739271a2a575536c6db8c18504477eac951f63bfb88828bdf0f1db42cc7c4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/integration/cha-execution/MANUAL_RESULT_0.2_PREPARATION_REPORT.md` | Local-only; cha-branch2 working tree; no source commit | `742998af3d282783421c809c90ce46ad1ac06f93759a7ca298685f71e5230eb7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/integration/cha-execution/manual-result-0.2.tap` | Local-only; cha-branch2 working tree; no source commit | `e3523db913ce185fae43b08429d860763e2db77f4924baeafdadfecbaedd7eeb` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/docs/integration/cha-execution/manual-result-0.2.test.cjs` | Local-only; cha-branch2 working tree; no source commit | `6548f2c7dd291c816c7654bd73bde404ee9c75c0fda48563c97f2b97e0126139` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/generated-by.txt` | Local-only; cha-branch2 working tree; no source commit | `96953b4f6abca93f62a4cd33532750d0d9eaa7070ad7b44fd2245723c4510659` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/manual-result-0.2-review-package/manifest.json` | Local-only; cha-branch2 working tree; no source commit | `cbdcfdda10b266432d3b8abed2dcb4ca0bebdbfdefe34990f8fb8849f9c5426d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/README.md` | Local-only; cha-branch2 working tree; no source commit | `5a7e1b7dae5a73a901c43183f99297517e23f16818040e92682631d41da2977a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/C02-provisional-communication-contract.md` | Local-only; cha-branch2 working tree; no source commit | `3559b60ace2b2d12e0a52304ed4ff1d9831a416b9a4edb5478d7ec359a69ddb7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/C02-provisional.examples.json` | Local-only; cha-branch2 working tree; no source commit | `155a44ed24f2c0627481822569c008b1ee332d315d72abe3bf9f09fc584275b5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/C02-provisional.schema.json` | Local-only; cha-branch2 working tree; no source commit | `9e95d34ca160cae8600548c5c4919ece26953d892d77bd786198d9e9e15461dd` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.3.md` | Local-only; cha-branch2 working tree; no source commit | `4c30bf58390fccfa94356fb7a285dd9284d642946582b5ab8fe7be958ee02176` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.4_Bluetooth_Android_Bridge.md` | Local-only; cha-branch2 working tree; no source commit | `28311c53ed9675232ee6a25e9e481f8af26a10182de8f765edbf884e6fb1eed2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/contract-review/ARCH-05_K06_Architecture_Amendment_Record.md` | Local-only; cha-branch2 working tree; no source commit | `8a4c29c79e4980f439ea599c98cd979a0c117fc61822f5c6f03a0992f2e89ebc` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/contract-review/ARCH-05_source_manifest.json` | Local-only; cha-branch2 working tree; no source commit | `cb76fce1361eb60cdad9fd74404d1bd5d46ca56310b04c61dff385671cd77eb5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md` | Local-only; cha-branch2 working tree; no source commit | `55491aa83761bee5825beb3d3df231f87b0b88efb2fc18625c7cc7f5520e1de3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/contract-review/D04_D06_Mary_Backend_Position.md` | Local-only; cha-branch2 working tree; no source commit | `c51f8d8b16400a80238367b69c1f6c3496bf70a63a2eaf9aeb1ff1c8d85e046c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/contract-review/DB-02_30Oct_Consolidated_Alignment.md` | Local-only; cha-branch2 working tree; no source commit | `4808510868e2ad57e35f9059dbcfa3e27bf1a54c6cf9d94a629037c35412e3db` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/contract-review/DB-02_Manual_Result_API_0.1-review.md` | Local-only; cha-branch2 working tree; no source commit | `be60e96696bcf6acde43727b2205410a81beed08907e7ce7a8a0c8770c20bb98` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/contract-review/manual-result-0.1.closure-matrix.json` | Local-only; cha-branch2 working tree; no source commit | `55c66ae00782dfdd4c255e2bfb9c2c984fdf0b2655cc42610f744ad9e31efbf2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/contract-review/manual-result-0.1.fixtures.json` | Local-only; cha-branch2 working tree; no source commit | `a92cba4f788eb844bd04824db3fa14c8c963dc57397299a7ae4d624bc8952f77` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/contract-review/manual-result-0.1.schema.json` | Local-only; cha-branch2 working tree; no source commit | `c8a17ad20cc1bc6656ef2f4029c725916fb9fab4bb0b5085850f75f8c7909125` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/ALLY_ZIP_C02B_REVIEW.md` | Local-only; cha-branch2 working tree; no source commit | `2250c3723211f1abe1d8812bdc8100df94ddbcfb399f08850ec2b32e56d3ef2a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/INDEPENDENT_SCHEMA_VERIFICATION.md` | Local-only; cha-branch2 working tree; no source commit | `8b99d219b686c73a568f1a26d7dff77a6aa0e2ee8fc5a49c70139cead1a8b3db` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/KATH_FOCUSED_REVIEW_RECEIPT.md` | Local-only; cha-branch2 working tree; no source commit | `6f2b5b05d3e71bf94545c9b22db77107af8db5acb53fe9b4125e3596f0728ae6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/KATH_REMAINING_DECISIONS_RECEIPT.md` | Local-only; cha-branch2 working tree; no source commit | `43bcb06386f57ce6a7ab0c3a9bc33d25cd31acf556f56f06102fe0e0c8af57be` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/ORIGINAL_C09_MONITORING_BOUNDARIES.md` | Local-only; cha-branch2 working tree; no source commit | `01128459b51c1104399e66703b4abe5814d229d13796d5d95bfe6a1b1a6a1286` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/PORTFOLIO_EXECUTION_REPORT.md` | Local-only; cha-branch2 working tree; no source commit | `d0588c331a5389952d87ecb53675d1cf094558e568b319ba36e1cf9af064938b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/c02-schema-revalidation.txt` | Local-only; cha-branch2 working tree; no source commit | `cb1c0f838b18c3ef9df572fe6986ef1619e4bf2547cba058b6939072e176379b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/independent-schema-verification.json` | Local-only; cha-branch2 working tree; no source commit | `acebafd38a1a0084401522cbbfc396031e45065aa67f5de3d28c93506b55af5e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/manual-result-jsonschema.tap` | Local-only; cha-branch2 working tree; no source commit | `f955dc7e9f834b37bd3b89de8d07ee31fcc9e285df93acca18077d4acf66f3ee` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/portfolio-backend-regression.tap` | Local-only; cha-branch2 working tree; no source commit | `ed23c4a5a5f810f3591712b756c5d52f6ae30dd0aed91dd2de4c4469f8f6fdd2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/portfolio-source-observations.json` | Local-only; cha-branch2 working tree; no source commit | `b10a2f6d2b2c5bad6253844573fcc7658025390d0cc52003247e98c914905a4e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/integration/cha-execution/remaining-workqueue.tap` | Local-only; cha-branch2 working tree; no source commit | `adf2aaf18e290081183c0bce3dda99902468dc97b251b35cda6bb2f4fd06e193` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/docs/validate-c02-provisional.cjs` | Local-only; cha-branch2 working tree; no source commit | `5d7d6185c1802923901770090f5537ba196f063f8a663c24a4faeae113373c1c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/generated-by.txt` | Local-only; cha-branch2 working tree; no source commit | `6cea396fbc4aed1a8e0ffaacf115955e2c8f3c623005712e93c6465746d36dc6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/manifest.json` | Local-only; cha-branch2 working tree; no source commit | `b988552a68df82ac6f066e92b29a6f07ccea4b90efa074f24ca961aae39d0dc1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/received-reviews/Ally-D02-D04-D06-response.md` | Local-only; cha-branch2 working tree; no source commit | `fa4294421c24a40a259cb2cc8cb6a68463777ed440a6c677f06d9321141787e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/received-reviews/Kath-C02-focused.md` | Local-only; cha-branch2 working tree; no source commit | `4473813552ef21a77fe57296f89fb7843a3b4f1ad19990c3e596b70f66e162e0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/received-reviews/Kath-remaining-proposal.md` | Local-only; cha-branch2 working tree; no source commit | `fcac95a70cbce94d6fe7e244310eea8b26ba92d3a7d34b436cf2a1c0faaf8fc7` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/README.md` | Local-only; cha-branch2 working tree; no source commit | `9932eeadf4cef46c7bb7f51f2571a782cb83ae5708b85af60469ea6f01e9d67e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/REMAINING_DECISIONS_ALL_OWNERS.md` | Local-only; cha-branch2 working tree; no source commit | `f3dc83b1ca0e99600760dd447c45c29def8615462893978ece90a72da7a57056` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/decision-index.json` | Local-only; cha-branch2 working tree; no source commit | `0098ea33d1b48d8ca6abe6b72351b27ba3da540ca4b8120da01acf82c8115f9e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/evidence-index.json` | Local-only; cha-branch2 working tree; no source commit | `f4cae759eb48023a60614ad6993b53510d20c4fd1b3ac6028adbc0c8425d4121` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/distribution.csv` | Local-only; cha-branch2 working tree; no source commit | `acddcffab99c957b4d53fe9d7ec7f683d24c70b746bafcba1c12a9f17f5b3ca1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/integration-observation.csv` | Local-only; cha-branch2 working tree; no source commit | `cabd50f426d8c0297f178682e082e0561194584af670e3432309a377b1d20f0e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/pilot-observation.csv` | Local-only; cha-branch2 working tree; no source commit | `1fa8b970cb896d722b63e3c7899fe81c046e47b1a14beb36572896f6e142455a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/profile-comparison.csv` | Local-only; cha-branch2 working tree; no source commit | `714e0717afef88e277b56e9ac36dd192ab2cd074bcffaf3ac29300dd04e53a59` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/security-matrix.json` | Local-only; cha-branch2 working tree; no source commit | `a6f0ae3e3403d75b877a6b333a2be9fc86d8aef0b071d7e8f76749e04dba5a01` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/forms/usability-script.md` | Local-only; cha-branch2 working tree; no source commit | `4aeea7652c38a8035e59aa26bcb62197b36884e7109abed78e91fc0c5f88522d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/generated-by.txt` | Local-only; cha-branch2 working tree; no source commit | `1dbbde9394792be159f86d4553f8901798e0841f38cfb735a7759613117b12e9` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/planned-test-records.json` | Local-only; cha-branch2 working tree; no source commit | `7072425481461528cfd0b0ce73546080c242f473c386cb1b029033d09a178db4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/preparation-summary.json` | Local-only; cha-branch2 working tree; no source commit | `14ef2d74a1ae7a2e22376b897b3e7bfbbd43131c071f09387dff35e3bf4526ff` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/task-index.json` | Local-only; cha-branch2 working tree; no source commit | `4f6fd782f39f31983c794b61c604c2d74b493c036fcb93ac7435e3e0f1a76752` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/CURRENT_DB-IMP-01.md` | Local-only; cha-branch2 working tree; no source commit | `3f6f560bd355e8661be8fc7e286500a85b0eee6dfa92fdbbbd9d638cadf51022` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/CURRENT_INT-IMP-01.md` | Local-only; cha-branch2 working tree; no source commit | `2f9d546498bc889ea202e9e5f3947f38012328129d1549f8330b7aab048788a3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_ARCH-05.md` | Local-only; cha-branch2 working tree; no source commit | `3ca23cd96e8ea63b42e0d556aaae03c4ae06803074c98d9a1fea722cae0268e8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_ARCH-06.md` | Local-only; cha-branch2 working tree; no source commit | `88cb5ee2edaa41a07c01ce6ed35bd08814f0de4f1f63a1fcb2f8449a41a9b671` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-02A.md` | Local-only; cha-branch2 working tree; no source commit | `6d520ee819120adfcbbede3ce6c27473f222392d859f734c2d04581e90ad3701` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-02B.md` | Local-only; cha-branch2 working tree; no source commit | `151efb439c65232e085c153407d38cb9805c445565b6cb8ba0f8ca1978890678` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-02C.md` | Local-only; cha-branch2 working tree; no source commit | `f85bcc3f021a21c9505127ed15a963dde24b8c3c941b575c434363058366260a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-04.md` | Local-only; cha-branch2 working tree; no source commit | `7b828ed9230daf846eb5ce0ef0c4b69eabcf26d8ccb63fd12ee3b519d081380b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-05.md` | Local-only; cha-branch2 working tree; no source commit | `1e58ca1fbf6d67f5a6d09e2fad26a8a9594f75343fdfbefcf85ee9ae9a00a3b8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-06.md` | Local-only; cha-branch2 working tree; no source commit | `26b68f5387cd704bda942181e71c48f14ae1a0089db6ea4667eab0c1b2024a79` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-07.md` | Local-only; cha-branch2 working tree; no source commit | `ec95efae12092224233a5c48f79b477bfeb35515b64d63a95327f2f6b192a8e0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-08.md` | Local-only; cha-branch2 working tree; no source commit | `957dccfd5062766f55fe37ffbc91c9d4520d861472f7d44fce9a826f67ea582c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-09.md` | Local-only; cha-branch2 working tree; no source commit | `6d718cb8b7462f39d7d03aa27e2cd694e24c1d64a685b91a50ba360db05e0d5e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-10.md` | Local-only; cha-branch2 working tree; no source commit | `90fa40a45d935352950698ae606103a492275ddddb4ed31a08c75afcf996242d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_C-11.md` | Local-only; cha-branch2 working tree; no source commit | `a637d7fc63647fe0e7e4c6e3e5702ddf5d745bf4db2baf226789f3c00c46c897` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-01.md` | Local-only; cha-branch2 working tree; no source commit | `223458a32cab786ca29ad70485cb29caae6e0878c3b9efda52b380008115155c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-02.md` | Local-only; cha-branch2 working tree; no source commit | `13b299f7e64a546c3df5ab485efd0813d2b424cde131a3c19164e99c90000227` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-03.md` | Local-only; cha-branch2 working tree; no source commit | `80f107c6624447802784904a93f2178bb115576b32cf7d19965b2e47975fb735` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-04.md` | Local-only; cha-branch2 working tree; no source commit | `ba40ca54e3dfa1f0a27e75a6470655d92cdca9bd8f78d1bac2a9085c016b19b5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-05.md` | Local-only; cha-branch2 working tree; no source commit | `0766c4a1aa51edc3df2afe06fef00813bcbdd1d8b5b13a3d70a77a9a2c4b9b5a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-06.md` | Local-only; cha-branch2 working tree; no source commit | `78e18657591ea4e3afe179a68009b10822594e1061ad3dbfab1b8a2d5a62ae0c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-07.md` | Local-only; cha-branch2 working tree; no source commit | `4187ea89163895641f56a9de91d1d44b964cdaec7abac6056a1a2a486c4b65c1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-08.md` | Local-only; cha-branch2 working tree; no source commit | `bbe52827df73e05e4f9e9fca9ab67034fbe0d4dabc88c0d15f87c5e0557395d2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-09.md` | Local-only; cha-branch2 working tree; no source commit | `5f7c0355ba3f98163c70f491ba2d25222cfed8aaf1cbd932a160c7d5b67e3462` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-10.md` | Local-only; cha-branch2 working tree; no source commit | `64e18898f3506538cd72282ed39ffafe3dfa803a462eead5086fb17e1b13fea1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/OCT26_TEST-11.md` | Local-only; cha-branch2 working tree; no source commit | `17687d77d09de500e6ce1bfd8d929768bdc2c281a3810f2df3cccceb8bea4d65` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-02.md` | Local-only; cha-branch2 working tree; no source commit | `b06cd3157f13eeb2ab272c6c4973d4859e3d782e1422efa0b883112b401fe2cc` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-03.md` | Local-only; cha-branch2 working tree; no source commit | `dd35b2da6699fbd59bce1930ec553b925a7bc03ec7e37c89625984243f56f0e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-04.md` | Local-only; cha-branch2 working tree; no source commit | `0ac327db23232ca1ecebf4e4ba8602b824189d4148d09dfc2fbd79479e2fbcaf` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-05.md` | Local-only; cha-branch2 working tree; no source commit | `36421ce2bb37000d041f460e07186277c2676678b5259d8b478ebb7fafb367df` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-06.md` | Local-only; cha-branch2 working tree; no source commit | `a92b94cccb6b08da0a55287c8cb3ff174673bffa9f94fc4b1ef851c45505504e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-07.md` | Local-only; cha-branch2 working tree; no source commit | `46de066633b958100f947126010f9761319fbb5632e645833f732d447a0bce5c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-08.md` | Local-only; cha-branch2 working tree; no source commit | `8c300fba169df3688de232f03a64a91934a44b7f97b75782263df6371f75c9f8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-review-package/remaining-task-workqueue/tasks/ORIGINAL_C-09.md` | Local-only; cha-branch2 working tree; no source commit | `0ece0628d2e69608882d17c4089c32c94d606dffc778c3b9a7bd4d03c6d3490c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/README.md` | Local-only; cha-branch2 working tree; no source commit | `9932eeadf4cef46c7bb7f51f2571a782cb83ae5708b85af60469ea6f01e9d67e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/REMAINING_DECISIONS_ALL_OWNERS.md` | Local-only; cha-branch2 working tree; no source commit | `e3c831337342485253c7e0a2c8c202bc8c00cb13e77bf30abd79d0acadce3563` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/decision-index.json` | Local-only; cha-branch2 working tree; no source commit | `0098ea33d1b48d8ca6abe6b72351b27ba3da540ca4b8120da01acf82c8115f9e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/evidence-index.json` | Local-only; cha-branch2 working tree; no source commit | `f4cae759eb48023a60614ad6993b53510d20c4fd1b3ac6028adbc0c8425d4121` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/forms/distribution.csv` | Local-only; cha-branch2 working tree; no source commit | `acddcffab99c957b4d53fe9d7ec7f683d24c70b746bafcba1c12a9f17f5b3ca1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/forms/integration-observation.csv` | Local-only; cha-branch2 working tree; no source commit | `cabd50f426d8c0297f178682e082e0561194584af670e3432309a377b1d20f0e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/forms/pilot-observation.csv` | Local-only; cha-branch2 working tree; no source commit | `1fa8b970cb896d722b63e3c7899fe81c046e47b1a14beb36572896f6e142455a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/forms/profile-comparison.csv` | Local-only; cha-branch2 working tree; no source commit | `714e0717afef88e277b56e9ac36dd192ab2cd074bcffaf3ac29300dd04e53a59` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/forms/security-matrix.json` | Local-only; cha-branch2 working tree; no source commit | `a6f0ae3e3403d75b877a6b333a2be9fc86d8aef0b071d7e8f76749e04dba5a01` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/forms/usability-script.md` | Local-only; cha-branch2 working tree; no source commit | `4aeea7652c38a8035e59aa26bcb62197b36884e7109abed78e91fc0c5f88522d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/generated-by.txt` | Local-only; cha-branch2 working tree; no source commit | `1dbbde9394792be159f86d4553f8901798e0841f38cfb735a7759613117b12e9` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/planned-test-records.json` | Local-only; cha-branch2 working tree; no source commit | `7072425481461528cfd0b0ce73546080c242f473c386cb1b029033d09a178db4` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/preparation-summary.json` | Local-only; cha-branch2 working tree; no source commit | `14ef2d74a1ae7a2e22376b897b3e7bfbbd43131c071f09387dff35e3bf4526ff` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/task-index.json` | Local-only; cha-branch2 working tree; no source commit | `4f6fd782f39f31983c794b61c604c2d74b493c036fcb93ac7435e3e0f1a76752` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/CURRENT_DB-IMP-01.md` | Local-only; cha-branch2 working tree; no source commit | `3f6f560bd355e8661be8fc7e286500a85b0eee6dfa92fdbbbd9d638cadf51022` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/CURRENT_INT-IMP-01.md` | Local-only; cha-branch2 working tree; no source commit | `2f9d546498bc889ea202e9e5f3947f38012328129d1549f8330b7aab048788a3` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_ARCH-05.md` | Local-only; cha-branch2 working tree; no source commit | `3ca23cd96e8ea63b42e0d556aaae03c4ae06803074c98d9a1fea722cae0268e8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_ARCH-06.md` | Local-only; cha-branch2 working tree; no source commit | `88cb5ee2edaa41a07c01ce6ed35bd08814f0de4f1f63a1fcb2f8449a41a9b671` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-02A.md` | Local-only; cha-branch2 working tree; no source commit | `29e8a770e0b1d8baec88777da18184a6e9f27bb3ec1886f38b43355d2d60fbc5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-02B.md` | Local-only; cha-branch2 working tree; no source commit | `3d2d3c976b27ef96f2ecb5aa0bb1bcb948666c67d607ea204bb6469e1a2a374d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-02C.md` | Local-only; cha-branch2 working tree; no source commit | `f85bcc3f021a21c9505127ed15a963dde24b8c3c941b575c434363058366260a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-04.md` | Local-only; cha-branch2 working tree; no source commit | `7b828ed9230daf846eb5ce0ef0c4b69eabcf26d8ccb63fd12ee3b519d081380b` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-05.md` | Local-only; cha-branch2 working tree; no source commit | `1e58ca1fbf6d67f5a6d09e2fad26a8a9594f75343fdfbefcf85ee9ae9a00a3b8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-06.md` | Local-only; cha-branch2 working tree; no source commit | `26b68f5387cd704bda942181e71c48f14ae1a0089db6ea4667eab0c1b2024a79` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-07.md` | Local-only; cha-branch2 working tree; no source commit | `ec95efae12092224233a5c48f79b477bfeb35515b64d63a95327f2f6b192a8e0` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-08.md` | Local-only; cha-branch2 working tree; no source commit | `957dccfd5062766f55fe37ffbc91c9d4520d861472f7d44fce9a826f67ea582c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-09.md` | Local-only; cha-branch2 working tree; no source commit | `6d718cb8b7462f39d7d03aa27e2cd694e24c1d64a685b91a50ba360db05e0d5e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-10.md` | Local-only; cha-branch2 working tree; no source commit | `90fa40a45d935352950698ae606103a492275ddddb4ed31a08c75afcf996242d` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_C-11.md` | Local-only; cha-branch2 working tree; no source commit | `a637d7fc63647fe0e7e4c6e3e5702ddf5d745bf4db2baf226789f3c00c46c897` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-01.md` | Local-only; cha-branch2 working tree; no source commit | `223458a32cab786ca29ad70485cb29caae6e0878c3b9efda52b380008115155c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-02.md` | Local-only; cha-branch2 working tree; no source commit | `13b299f7e64a546c3df5ab485efd0813d2b424cde131a3c19164e99c90000227` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-03.md` | Local-only; cha-branch2 working tree; no source commit | `80f107c6624447802784904a93f2178bb115576b32cf7d19965b2e47975fb735` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-04.md` | Local-only; cha-branch2 working tree; no source commit | `ba40ca54e3dfa1f0a27e75a6470655d92cdca9bd8f78d1bac2a9085c016b19b5` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-05.md` | Local-only; cha-branch2 working tree; no source commit | `0766c4a1aa51edc3df2afe06fef00813bcbdd1d8b5b13a3d70a77a9a2c4b9b5a` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-06.md` | Local-only; cha-branch2 working tree; no source commit | `78e18657591ea4e3afe179a68009b10822594e1061ad3dbfab1b8a2d5a62ae0c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-07.md` | Local-only; cha-branch2 working tree; no source commit | `4187ea89163895641f56a9de91d1d44b964cdaec7abac6056a1a2a486c4b65c1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-08.md` | Local-only; cha-branch2 working tree; no source commit | `bbe52827df73e05e4f9e9fca9ab67034fbe0d4dabc88c0d15f87c5e0557395d2` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-09.md` | Local-only; cha-branch2 working tree; no source commit | `5f7c0355ba3f98163c70f491ba2d25222cfed8aaf1cbd932a160c7d5b67e3462` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-10.md` | Local-only; cha-branch2 working tree; no source commit | `64e18898f3506538cd72282ed39ffafe3dfa803a462eead5086fb17e1b13fea1` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/OCT26_TEST-11.md` | Local-only; cha-branch2 working tree; no source commit | `17687d77d09de500e6ce1bfd8d929768bdc2c281a3810f2df3cccceb8bea4d65` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-02.md` | Local-only; cha-branch2 working tree; no source commit | `b06cd3157f13eeb2ab272c6c4973d4859e3d782e1422efa0b883112b401fe2cc` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-03.md` | Local-only; cha-branch2 working tree; no source commit | `dd35b2da6699fbd59bce1930ec553b925a7bc03ec7e37c89625984243f56f0e6` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-04.md` | Local-only; cha-branch2 working tree; no source commit | `0ac327db23232ca1ecebf4e4ba8602b824189d4148d09dfc2fbd79479e2fbcaf` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-05.md` | Local-only; cha-branch2 working tree; no source commit | `36421ce2bb37000d041f460e07186277c2676678b5259d8b478ebb7fafb367df` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-06.md` | Local-only; cha-branch2 working tree; no source commit | `a92b94cccb6b08da0a55287c8cb3ff174673bffa9f94fc4b1ef851c45505504e` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-07.md` | Local-only; cha-branch2 working tree; no source commit | `46de066633b958100f947126010f9761319fbb5632e645833f732d447a0bce5c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-08.md` | Local-only; cha-branch2 working tree; no source commit | `8c300fba169df3688de232f03a64a91934a44b7f97b75782263df6371f75c9f8` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/integration/remaining-task-workqueue/tasks/ORIGINAL_C-09.md` | Local-only; cha-branch2 working tree; no source commit | `0ece0628d2e69608882d17c4089c32c94d606dffc778c3b9a7bd4d03c6d3490c` | Receive missing reviewed local file; compare hash; no overwrite |
| `docs/validate-c02-provisional.cjs` | Tracked HEAD; last touch 035e842; pre-existing unstaged patch | `40c7bd4444612c317f72058ad6fb74c0710d0a95098bd67fab352bd235395e63` | Review/receive diff separately; no auto-apply |
| `lib/services/arduino_protocol.dart` | Tracked HEAD; last touch 8092ba3 | `b5b836bb0b038dddf23025a60fd9c892dd08367e9aa125203450285af5acdd1d` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `lib/services/arduino_readiness.dart` | Tracked HEAD; last touch 690b70d | `45f36b2388dac18d37394aec71fbb009e843495a254a13c988ee6e784a32a036` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `lib/services/arduino_serial_factory.dart` | Tracked HEAD; last touch 7b9885b | `c218f3bbad630ddc4623a891d034b8717a8732e7ad29956e5a683a45b24ee427` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `lib/services/arduino_serial_io.dart` | Tracked HEAD; last touch 8092ba3 | `d45611ee0c85bbbaf68f133491c0b72ce1cb506740fb0622ff692c50cec09822` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `lib/services/arduino_serial_service.dart` | Tracked HEAD; last touch 8092ba3 | `4b3d706cd343bfc5567b0978b62e2b3a536d9d8263756c206b3548229ff8f5e9` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `lib/services/arduino_serial_stub.dart` | Tracked HEAD; last touch 8092ba3 | `6e7dde7feb0c257262495449fb53c1b753e793919bdde3cffb549fc682e1c511` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `lib/services/supabase_service.dart` | Tracked HEAD; last touch e2c392d | `8af0b3288bd605bd1a8493c88df6ece83e68e52102190cbb3fc6f41800076c5b` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/AGENTS.md` | Local-only; cha-branch2 working tree; no source commit | `d04d0fdacd0f3ee75893179c8aed54efe8a5f1e534a43376863e5f11e98f17ea` | Receive missing reviewed local file; compare hash; no overwrite |
| `supabase/README.md` | Local-only; cha-branch2 working tree; no source commit | `fa3b4f901fbf64c337ce668cd3d3643a4d7b2480764f5f1d4c7e4efc51b832b3` | Receive missing reviewed local file; compare hash; no overwrite |
| `supabase/config.toml` | Tracked HEAD; last touch d50dafb | `Excluded configuration / unavailable` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/dev/README.md` | Local-only; cha-branch2 working tree; no source commit | `0c66ece512d9b8b994459efb89a5b0f79280b67703a75ed06fa027aae3a09f49` | Receive missing reviewed local file; compare hash; no overwrite |
| `supabase/dev/serve-bridge-sync.mjs` | Tracked HEAD; last touch 035e842 | `73f3bcff120c87d91c3f606d6507e0b8c096894be462265f6147f2d56739074d` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/drafts/DB-IMP-01_authorization_schema_draft.sql` | Tracked HEAD; last touch 035e842 | `258fad0aa091e6e5b7ba6bb660df84a2269aa0f326ecb72706eec6fb26e764d0` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/drafts/DB-IMP-01_bridge_sync_rpcs_draft.sql` | Tracked HEAD; last touch 035e842 | `dcb065fac25e2b26366d424bb236020185aaba92d23115e49fdd2584289eec4a` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/drafts/DB-IMP-01_disabled_registry.sql` | Tracked HEAD; last touch 035e842 | `6d8e11d72f28bb6291184fea2227d20adb3dc9d73761517d86a87abe5517644b` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/drafts/README.md` | Local-only; cha-branch2 working tree; no source commit | `16017be17336b32e36985ad4229a8b4ab10b48622b44ffe1760a9db74de82cd9` | Receive missing reviewed local file; compare hash; no overwrite |
| `supabase/functions/_shared/bridge-monitoring.mjs` | Tracked HEAD; last touch 035e842 | `863447ee1c8a869cff380a7d55e99d6ce5ae207b9bf8237dc849efbdb0b434ec` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/functions/_shared/bridge-sync-core.mjs` | Tracked HEAD; last touch 035e842 | `b7a9aa133ce46d180b84de0c2f712c5dc9229cf59c8b24c42f4dd661750850d2` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/functions/_shared/bridge-sync-supabase.mjs` | Tracked HEAD; last touch 035e842 | `f2f047c1826b02aef5b39c4c25f841a887440a9a9b95182076af00abc1e49f04` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/functions/bridge-sync/README.md` | Tracked HEAD; last touch 035e842; pre-existing unstaged patch | `034358a48400e1e8be4fd9a55d1ed694602e713d08c1ce8aca0f29efe70e3433` | Review/receive diff separately; no auto-apply |
| `supabase/functions/bridge-sync/index.ts` | Tracked HEAD; last touch 035e842 | `e6d6fb79ddd31cf31796608457ea92efdf182f4e54912b5244e619c511c501c6` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/migrations/20260929070513_remote_schema.sql` | Tracked HEAD; last touch d50dafb | `6a1e3560f1d5afea60787c3639bbc170fc21adfe7b3418a2be371ede643b9425` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/migrations/20260929204930_remote_schema.sql` | Tracked HEAD; last touch 7f578af | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `supabase/migrations/20261012090000_incubator_sessions_single_active.sql` | Tracked HEAD; last touch cd481f3 | `7b2ecca0e41eac1832fa451550faab65b234570968878e0d903d56c8dbde162b` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/backend/architecture_alignment_test.mjs` | Local-only; cha-branch2 working tree; no source commit | `f5ad1a3f2dd75c9b39245dc951cd908eeb427e2926b9f53cfd0703e7729f0f5b` | Receive missing reviewed local file; compare hash; no overwrite |
| `test/backend/bridge_monitoring_test.mjs` | Tracked HEAD; last touch 035e842 | `16980ca19914755b82ec3890261183b41a386c6d03f246428270ab5f7377e4dd` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/backend/bridge_sync_http_test.mjs` | Tracked HEAD; last touch 035e842 | `b35c443438b22d32e56bc61fff2841c81a383006fe040c4f94e71db0e1210493` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/backend/monitoring_boundary_test.mjs` | Local-only; cha-branch2 working tree; no source commit | `4d586db6580d30a5b71a3ae996df439d648c4cfd517f35d29ab5acabb45c0b5e` | Receive missing reviewed local file; compare hash; no overwrite |
| `test/fixtures/integration/db_imp_01_closed_gate.json` | Tracked HEAD; last touch 035e842 | `19ff6314a0955eed6e2dee35ee683aa9b8b2e156328524baebe03b62119312e7` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/fixtures/integration/hw02_batch_review.ndjson` | Tracked HEAD; last touch 035e842 | `e6c9ad858db1610a9aa3daab87c25ea575e42e282c033faed364bb7d0d654035` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/fixtures/integration/hw02_corrected_review.ndjson` | Tracked HEAD; last touch 035e842 | `c4c38f41d8aaaf24cc713b799641d9b8c8fb23c8f1d4f967daf69b4773bb9f11` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/fixtures/integration/int_imp_01_sources.json` | Tracked HEAD; last touch 035e842 | `0bd3132aabd4a90989290e7ee226d5b7750bb9a264dab9f88c514a270029fcbe` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/int_imp_01_parser_compatibility_test.dart` | Tracked HEAD; last touch 035e842 | `168eb9b58b9d659d8eed8f13ab2407d1b00e512c81fbd3554fff038dcf3b81b4` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/integration/export_int_imp_01_fixtures.cjs` | Tracked HEAD; last touch 035e842 | `36a58827d2213699f1da6999b02147de01b674db599590f22253b7229b159f07` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/integration/int_imp_01.test.cjs` | Tracked HEAD; last touch 035e842 | `1aef6eafe347e21105e729e52ee94d4ef98e1ed74ea65580fceefc43ecefc834` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/integration/support/int_imp_01_mocks.cjs` | Tracked HEAD; last touch 035e842 | `7bcf31c3dc5dc978e157e4475e9de438858b72da214c5ba5842e317fce8e1fa0` | Compare exact HEAD/file; hosted/Kath availability unverified |
| `test/session_ownership_audit_test.dart` | Tracked HEAD; last touch cd481f3 | `e5cdbe29ccfdc2cb7a4c259181700f87758021f385df561aa110acb0e7e479d9` | Compare exact HEAD/file; hosted/Kath availability unverified |

## Missing or inaccessible items

| Referenced path/item | Availability/evidence | Transfer requirement |
|---|---|---|
| `docs/instructions/GLOBAL.md` | Unavailable in checkout; referenced historically | Ask supplying owner for existing matching bytes/provenance; no automatic copy |
| `docs/instructions/PROJECT_CONTEXT.md` | Unavailable in checkout; referenced historically | Ask supplying owner for existing matching bytes/provenance; no automatic copy |
| `docs/instructions/DECISIONS.md` | Unavailable in checkout; referenced historically | Ask supplying owner for existing matching bytes/provenance; no automatic copy |
| `docs/instructions/ARCHITECTURE.md` | Unavailable in checkout; referenced historically | Ask supplying owner for existing matching bytes/provenance; no automatic copy |
| `docs/handoff/2026-11-01/running-batch/README.md` | Unavailable in checkout; referenced historically | Ask supplying owner for existing matching bytes/provenance; no automatic copy |
| `docs/oct26_a02_firmware_interface.md` | Unavailable in checkout; referenced historically | Ask supplying owner for existing matching bytes/provenance; no automatic copy |
| `docs/oct26_a03_a01_findings_for_cha.md` | Unavailable in checkout; referenced historically | Ask supplying owner for existing matching bytes/provenance; no automatic copy |
| `docs/oct26_a04_final_ndjson_format_decision.md` | Unavailable in checkout; referenced historically | Ask supplying owner for existing matching bytes/provenance; no automatic copy |
| `docs/evidence/oct26-a04/2026-10-30/format_decisions.csv` | Unavailable in checkout; referenced historically | Ask supplying owner for existing matching bytes/provenance; no automatic copy |
| Ally `80971f902d5634f7fed78ff073fcb78fa31be460` / patched source `7106ebfe...` | Commit lookup unavailable; raw matching source/patch/catalog/build packet not verified present | Ally supplies existing exact packet; local sketch no substitute; no fetch |
| Original Q12 Attempt 1 evidence/rollback | Original file not supplied per receipt; original rollback unavailable | Obtain sanitized original if available; no synthetic/reconnected substitute |
| Kath external native/device/SDK artifacts and Downloads response | References in receipts; external originals not accessed | Reconcile existing paths/versions; do not assume never existed |
| Certificate owner record / authoritative expected DER | Full provenance not accepted in latest assessment; external certificate not accessed | Owner supplies approved non-secret evidence separately; no remote action here |
| Earlier exact twelve-title plan / human acceptance | Unavailable in current conversation; Kath signature/date absent | Reconcile naming preferences and obtain separate acceptance |

## New review package

README and documents 01–13 under `docs/backend-handover/` are 14 new untracked Markdown files. Exact linked filenames in README. Not part of pre-existing inventory; no stage/commit. No self-hash.

## Final validation record

Final expected/verified status: same three unstaged tracked modifications; zero staged/deleted/unmerged entries; 703 untracked (689 pre-existing + 14 new Markdown), 706 total porcelain entries. Exact outside-directory status and tracked diff statistics compared unchanged; inventoried non-secret hashes compared before/after generation.
All 14 files/local Markdown links checked; acceptance boxes unchecked; all 51 source-task/decision/current-change entries include authorization/tests/missing-approved-rollback. No implementation tests run.
Only new Markdown under this directory written. No network/remote/database/configuration/credentials/application/firmware/index operation. Hash validation covers inventoried non-secret files; ignored files/secrets deliberately not accessed.
Documentation ready for Kath review; transfer, responsibility acceptance, missing evidence and backend implementation pending.
