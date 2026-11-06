# Remote execution is NOT authorized by creating this script. No default connection.
[CmdletBinding()]
param(
  [switch]$ExecuteRemote,
  [string]$Approval = ''
)
$ErrorActionPreference = 'Stop'
if (-not $ExecuteRemote -or $Approval -cne 'Q12-PHASE-A-REMOTE-EXPLICITLY-APPROVED') {
  throw 'Remote execution disabled. Obtain explicit approval after independent review.'
}
$sqlPath = Join-Path $PSScriptRoot '..\Q12_Phase_A_Read_Only.sql'
$bytes = [IO.File]::ReadAllBytes($sqlPath)
$hash = (Get-FileHash -LiteralPath $sqlPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($hash -ne '9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc') { throw 'SQL integrity mismatch.' }
Add-Type -Path (Join-Path $PSScriptRoot 'Q12Controller.cs')
$null = [SmartHatch.Q12.ApprovedSql]::Load($bytes)
$target = [SmartHatch.Q12.Target]::Approved()
$target.Validate()
if (-not (Test-Path -LiteralPath $target.Root -PathType Leaf)) { throw 'Certificate missing.' }
# All local preparation, compilation and credential prompting precede BEGIN.
$runPath = Join-Path $PSScriptRoot ('local-evidence-' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $runPath -ErrorAction Stop
$password = Read-Host 'Existing test-project database password (hidden; never saved)' -AsSecureString
$session = [SmartHatch.Q12.LibpqSession]::new($true)
$certificateLock = $null
try {
  # Hold the chosen root file read-only against replacement while libpq uses it.
  $certificateLock = [IO.File]::Open($target.Root,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
  $sha = [Security.Cryptography.SHA256]::Create()
  try { $certHash = [BitConverter]::ToString($sha.ComputeHash($certificateLock)).Replace('-','').ToLowerInvariant() }
  finally { $sha.Dispose() }
  $report = [SmartHatch.Q12.Controller]::Run($bytes,$target,$session,$password,$true)
} finally {
  if ($null -ne $certificateLock) { $certificateLock.Dispose() }
  $password.Dispose()
  $session.Dispose()
}
# All cell values and server error strings are withheld by the controller.
$evidence = [ordered]@{
  observedAtUtc = [DateTime]::UtcNow.ToString('o')
  certificateSha256 = $certHash
  targetVerification = 'Pinned session-pooler host, port, database, project-specific user; libpq verify-full; no project-name API lookup'
  report = $report
  statusBoundary = 'Q12 and DB-IMP-01 remain incomplete; Phase B not authorized'
}
$evidence | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $runPath 'sanitized-evidence.json') -Encoding UTF8
Write-Output ('Sanitized evidence: ' + $runPath)
Write-Output ('Status: ' + $report.Status + '; rollback: ' + $report.Rollback + '; final state: ' + $report.FinalState)
if ($report.Status -ne 'INSPECTION_EXECUTED_NOT_TASK_ACCEPTANCE') { exit 1 }
