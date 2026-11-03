# Q12 phase A — Attempt 1 interrupted

Recorded 2026-10-31 from Mary's actual report. **PARTIAL / BLOCKED.**
This receipt records a user-performed remote attempt, not an agent-executed or
independently verified run. The actual evidence file was not supplied here.

## Reported observations

- Approved SQL SHA-256 verification passed.
- Existing smarthatch-test account connected through the Session pooler using
  PostgreSQL client 17.11 and SSL; session read-only setting enabled and verified.
- Approved transaction started; all three SET LOCAL timeout commands executed.
- Local evidence contains BEGIN, SET, SET, SET.
- Before the first SELECT, the original connection terminated due to the
  60-second idle-in-transaction timeout.
- Attempted ROLLBACK failed because the connection had terminated. The client
  subsequently reconnected; that new connection cannot confirm rollback of the
  original transaction.
- No catalog SELECTs or database modifications executed, per Mary's report.

## Evidence/cleanup boundary

**Explicit original-transaction rollback confirmation: UNAVAILABLE.** PostgreSQL
normally aborts an open transaction when its backend terminates, but no independent
final-state verification was provided. Do not claim verified cleanup from a
ROLLBACK on the replacement connection or infer TLS hostname verification from
encryption alone. No claim that this receipt independently establishes verify-full.

No fixture, schema, role, policy or application-data changes were reported. No
cleanup mutation or extra remote query is authorized by recording this event.
Any replacement connection still open should be closed with the client's quit
command; closing it is not evidence of the original transaction's state.

## Corrective procedure proposed, not implemented/executed

Retain the exact approved SQL bytes and timeouts. Replace manual statement entry
with a locally tested automated single-session controller. Before BEGIN, complete
target/TLS/hash verification, hidden-password authentication, output preparation
and controller readiness. Then send each approved statement unchanged and in order,
automatically validating its result before sending another. Read-only settings
must be confirmed by the first approved SELECT; each bounded SELECT must stop the
run on >500 rows. Never queue the remaining file ahead of those checks.

Capture exact results, command tags and errors locally with appropriate privacy
controls; create sanitized shareable evidence separately. Use trusted client row
counts/status, not text guessed from arbitrary metadata expressions. Stop on
connection loss, timeout, malformed/missing result, unexpected command status,
overflow, read-only/isolation mismatch or target/TLS uncertainty. No automatic
reconnect, retry or continuation of an interrupted transaction.

On a recoverable failure with the same live connection, issue only ROLLBACK and
require its server command tag. If it cannot be confirmed, close the connection
and report rollback unavailable. On success require the approved final ROLLBACK
tag and client confirmation of idle transaction state, then close the connection.
No extra database verification SQL is implied by this client-side check.

The controller must first be tested without remote access for SQL-byte fidelity,
statement boundaries, result framing, overflow (501 rows), error/timeout/disconnect,
rollback and no-reconnect behavior, and secret-safe password prompting. No driver
installation, password storage or new database account is authorized. A controller
is only a proposal at this point; do not retry with the old interactive procedure.

All later Q12 phases remain NOT APPROVED. Q12 and DB-IMP-01 are not Completed;
whole-task counts unchanged. No remote operation performed while making this record.
