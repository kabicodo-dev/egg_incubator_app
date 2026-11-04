# C-02 — focused wire-family decision request

**Prepared:** 2026-11-02. **Status:** NOT SELECTED / NOT SENT / NO EXECUTION AUTHORIZATION.
This request is linked from the existing CONTRACT-FREEZE-01 ledger, not a new
competing decision register. Preserve HC-05/Android/Uno architecture and existing
manual-result/account-policy decisions; no architecture re-vote is requested.

Ally and Kath have delivered CHANGE reviews of the same historical provisional
contract/schema/examples. Do not request those unchanged reviews again. Ally's
full review is [preserved here](../integration/cha-execution/received-ally-c02-20261102.txt).

## One decision needed

Which scope should the next jointly reviewed C-02 revision describe?

| Choice | Meaning | Explicit limitations / remaining work |
|---|---|---|
| A — implemented numeric interim v1 | Document Ally's actual flat id/cmd numeric catalog, its ACK/RUNNING/event frames and 119-byte incoming content limit | Documentation is not trusted ingestion approval. No STOP, rich state recovery, source UTC, device/boot/sample/sequence identity or controller auth may be claimed. Raw source/catalog/fixtures must match; accepted numeric ranges and bounds require fixtures. Missing provenance must be quarantined or explicitly restricted, not invented. |
| B — richer target v2 | Give the richer family a distinct version/discriminator and explicitly label it unimplemented | Requires separately approved feasibility/migration work for parser, identities, durable manifest/retention, lifecycle/STOP/recovery, authorization, time and directional byte budgets. Existing v1 remains incompatible. No buffer expansion is implicitly authorized. |

These can coexist as documented current-versus-target generations, but the next
revision must state its primary scope and must not label both incompatible
envelopes as one implemented v1. No silent aliases or fallback parser are allowed.
Choosing A does not waive backend source-identity/security requirements. Choosing
B does not claim a v2 implementation or authorize writing/flashing it.

## Reply once, with concrete changes only

`Responder / role / date / A or B (or exact alternative) / ACCEPT, CHANGE or BLOCKED /
exact source+catalog hashes / limitations accepted / missing evidence and owner`.

- **Ally:** identify matching raw source, parser patch, catalog and fixtures already
  available, and exact numeric parser ranges. Do not restate the general C-02 review.
- **Kath:** accept/change the proposed scope and identify decoder/framing/recovery
  implications for those same bytes. Historical C-02 and result-only 0.2 review
  evidence need not be repeated.
- **Mary:** accept/change cloud mapping and reduced-guarantee boundaries. Numeric
  batch IDs alone must not become UUIDs, authenticated controller identity, trusted
  original manifests or authorization. State what remains disabled/quarantined.

All actual answers go in CONTRACT-FREEZE-01. Preparation does not supply any
member's acceptance, external delivery, source selection or execution permission.
No install, app/firmware/database change, deployment, USB/Bluetooth connection,
flashing, power cycle or occupied-batch intervention follows from this request.
