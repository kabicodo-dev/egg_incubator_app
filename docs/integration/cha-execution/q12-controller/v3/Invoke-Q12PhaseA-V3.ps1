# Revision 3. Creation/testing grants NO remote permission. Default deny before load.
[CmdletBinding()]
param([switch]$ExecuteRemote,[string]$ApprovalReference = '',[string]$CertificateApprovalFile = '')
$ErrorActionPreference = 'Stop'
if (-not $ExecuteRemote) { throw 'Remote execution disabled. Local correction task grants no remote permission.' }
$journal = $null; $session = $null; $password = $null; $certLock = $null; $snapshot = $null; $report = $null
try {
  Import-Module (Join-Path $PSScriptRoot 'SourceSnapshot.psm1') -Force -DisableNameChecking
  $names = @('ModelPolicy.cs','NativeBoundary.cs','DurableController.cs','Invoke-Q12PhaseA-V3.ps1','Correction.Tests.cs','Followup.Tests.cs','Test-Corrections.ps1','SourceSnapshot.psm1')
  $snapshot = New-Q12SourceSnapshot -Directory $PSScriptRoot -Names $names
  $runId = [guid]::NewGuid().ToString('N')
  $run = Join-Path $PSScriptRoot ('run-' + $runId)
  $null = Compile-Q12SourceSnapshot -Snapshot $snapshot -CompileNames @('ModelPolicy.cs','NativeBoundary.cs','DurableController.cs') -CompilerEvidenceDirectory (Join-Path $run 'compiler-inputs')
  if ($ApprovalReference -cnotmatch '\AQ12-PA-[0-9]{8}-[0-9]{2}\z') { throw 'Invalid approval reference.' }
  $bytes = [IO.File]::ReadAllBytes((Join-Path $PSScriptRoot '..\..\Q12_Phase_A_Read_Only.sql'))
  $null = [SmartHatch.Q12.V3.Pin]::Sql($bytes)
  $target = [SmartHatch.Q12.V3.Target]::new()
  $target.Check()
  $context = [SmartHatch.Q12.V3.RunContext]::new()
  $context.ApprovalReference = $ApprovalReference
  $context.RunId = $runId
  $context.ExecutionMode = 'REMOTE_AUTHORIZED' # Only after separate actual consent, never inferred here.
  $context.PowerShellVersion = $PSVersionTable.PSVersion.ToString()
  $context.SourceHashes = $snapshot.Hashes
  $repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..\..'))
  $drafts = @{
    'DB-IMP-01_disabled_registry.sql' = [SmartHatch.Q12.V3.RunContext]::RegistryHash
    'DB-IMP-01_authorization_schema_draft.sql' = [SmartHatch.Q12.V3.RunContext]::AuthorizationHash
    'DB-IMP-01_bridge_sync_rpcs_draft.sql' = [SmartHatch.Q12.V3.RunContext]::RpcHash
  }
  foreach ($name in $drafts.Keys) {
    if ((Get-FileHash -LiteralPath (Join-Path $repo ('supabase\drafts\' + $name)) -Algorithm SHA256).Hash.ToLowerInvariant() -cne $drafts[$name]) { throw 'Design comparator changed.' }
  }
  $journal = [SmartHatch.Q12.V3.FileJournal]::new($run)
  $localPreflight = [SmartHatch.Q12.V3.SafeEvent]::new()
  $localPreflight.Kind = 'LOCAL_PREFLIGHT'
  $localPreflight.RunId = $runId
  $localPreflight.ApprovalReference = $ApprovalReference
  $localPreflight.PreparationSourceHashes = $snapshot.Hashes
  $journal.Write($localPreflight); $journal.Emergency($localPreflight)
  if (-not (Test-Path -LiteralPath $CertificateApprovalFile -PathType Leaf)) { throw 'Trusted-origin certificate approval missing.' }
  $proof = [SmartHatch.Q12.V3.CertificateApproval]::Read([IO.File]::ReadAllText($CertificateApprovalFile),$ApprovalReference)
  $certLock = [IO.File]::Open($target.Root,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
  $context.CertificateFileSha256 = (Get-FileHash -LiteralPath $target.Root -Algorithm SHA256).Hash.ToLowerInvariant()
  $cert = [Security.Cryptography.X509Certificates.X509Certificate2]::new($target.Root)
  try {
    $context.CertificateDerSha256 = [SmartHatch.Q12.V3.Pin]::Hash($cert.RawData)
    if ([DateTime]::UtcNow -lt $cert.NotBefore.ToUniversalTime() -or [DateTime]::UtcNow -gt $cert.NotAfter.ToUniversalTime()) { throw 'Certificate validity check failed.' }
  } finally { $cert.Reset() }
  if ($context.CertificateFileSha256 -cne $proof.FileSha256 -or $context.CertificateDerSha256 -cne $proof.DerSha256) { throw 'Certificate fingerprint mismatch.' }
  $context.Check()
  Assert-Q12SourceSnapshot $snapshot
  $api = [SmartHatch.Q12.V3.NativePq]::new()
  $session = [SmartHatch.Q12.V3.Session]::new($api,[SmartHatch.Q12.V3.RealClock]::new(),[SmartHatch.Q12.V3.FileRootGate]::new($proof.FileSha256),$true)
  $password = Read-Host 'Existing test-project database password (hidden, never saved)' -AsSecureString
  $report = [SmartHatch.Q12.V3.Controller]::Run($bytes,$target,$context,$session,$password,$journal)
  Write-Output ('Status: ' + $report.Status + '; rollback: ' + $report.Rollback + '; durable journal: ' + $report.JournalDurable)
} catch {
  # No raw exception, proof content, credential or server text is printed.
  if ($null -ne $journal) {
    $failure = [SmartHatch.Q12.V3.SafeEvent]::new()
    $failure.Kind = 'LAUNCHER_FAILURE'; $failure.Status = 'UNEXPECTED_LOCAL_FAILURE'; $failure.RunId = $runId
    try { $journal.Write($failure) } catch { try { $journal.Emergency($failure) } catch {} }
  }
  Write-Output 'STOPPED: launcher/preflight/evidence failure. No raw error text emitted.'
} finally {
  if ($null -ne $password) { $password.Dispose() }
  if ($null -ne $session) { try { $session.Dispose() } catch {} }
  if ($null -ne $certLock) { $certLock.Dispose() }
  if ($null -ne $journal) { try { $journal.Dispose() } catch {} }
  if ($null -ne $snapshot) { Close-Q12SourceSnapshot $snapshot }
}
if ($null -eq $report -or $report.Status -ne 'EXECUTED_COMPARISON_PARTIAL_NOT_TASK_ACCEPTANCE' -or -not $report.JournalDurable) { exit 1 }
