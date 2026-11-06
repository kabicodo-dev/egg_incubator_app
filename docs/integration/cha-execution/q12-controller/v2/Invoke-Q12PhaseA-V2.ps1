# LOCAL REVIEW CANDIDATE. Never invoke remotely without separate explicit consent.
[CmdletBinding()]
param(
  [switch]$ExecuteRemote,
  [string]$ApprovalReference = '',
  [string]$CertificateApprovalFile = ''
)
$ErrorActionPreference = 'Stop'
if (-not $ExecuteRemote) { throw 'Remote execution disabled. Local correction task grants no remote permission.' }
$journal = $null
$session = $null
$password = $null
$certLock = $null
$report = $null
try {
  Add-Type -Path @('ModelPolicy.cs','NativeBoundary.cs','DurableController.cs').ForEach({ Join-Path $PSScriptRoot $_ }) -ReferencedAssemblies 'System.Web.Extensions','System.Core'
  if ($ApprovalReference -cnotmatch '\AQ12-PA-[0-9]{8}-[0-9]{2}\z') { throw 'Invalid approval reference.' }
  $bytes = [IO.File]::ReadAllBytes((Join-Path $PSScriptRoot '..\..\Q12_Phase_A_Read_Only.sql'))
  $null = [SmartHatch.Q12.V2.Pin]::Sql($bytes)
  $target = [SmartHatch.Q12.V2.Target]::new()
  $target.Check()
  $context = [SmartHatch.Q12.V2.RunContext]::new()
  $context.ApprovalReference = $ApprovalReference
  $context.PowerShellVersion = $PSVersionTable.PSVersion.ToString()
  foreach ($name in [SmartHatch.Q12.V2.RunContext]::SourceNames) {
    $context.SourceHashes.Add($name,(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name) -Algorithm SHA256).Hash.ToLowerInvariant())
  }
  # Compare against exact preserved design drafts; not adoption/application approval.
  $repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..\..'))
  $drafts = @{
    'DB-IMP-01_disabled_registry.sql' = [SmartHatch.Q12.V2.RunContext]::RegistryHash
    'DB-IMP-01_authorization_schema_draft.sql' = [SmartHatch.Q12.V2.RunContext]::AuthorizationHash
    'DB-IMP-01_bridge_sync_rpcs_draft.sql' = [SmartHatch.Q12.V2.RunContext]::RpcHash
  }
  foreach ($name in $drafts.Keys) {
    $hash = (Get-FileHash -LiteralPath (Join-Path $repo ('supabase\drafts\' + $name)) -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -cne $drafts[$name]) { throw 'Design comparator changed; independent review required.' }
  }
  # Create and flush both evidence destinations BEFORE certificate/password/network.
  $run = Join-Path $PSScriptRoot ('run-' + [guid]::NewGuid().ToString('N'))
  $journal = [SmartHatch.Q12.V2.FileJournal]::new($run)
  $localPreflight = [SmartHatch.Q12.V2.SafeEvent]::new()
  $localPreflight.Kind = 'LOCAL_PREFLIGHT'
  $localPreflight.ApprovalReference = $ApprovalReference
  $localPreflight.PreparationSourceHashes = $context.SourceHashes
  $journal.Write($localPreflight)
  if (-not (Test-Path -LiteralPath $CertificateApprovalFile -PathType Leaf)) { throw 'Trusted-origin certificate approval missing.' }
  $proof = [SmartHatch.Q12.V2.CertificateApproval]::Read([IO.File]::ReadAllText($CertificateApprovalFile),$ApprovalReference)
  $certLock = [IO.File]::Open($target.Root,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
  $context.CertificateFileSha256 = (Get-FileHash -LiteralPath $target.Root -Algorithm SHA256).Hash.ToLowerInvariant()
  $cert = [Security.Cryptography.X509Certificates.X509Certificate2]::new($target.Root)
  try {
    $context.CertificateDerSha256 = [SmartHatch.Q12.V2.Pin]::Hash($cert.RawData)
    if ([DateTime]::UtcNow -lt $cert.NotBefore.ToUniversalTime() -or [DateTime]::UtcNow -gt $cert.NotAfter.ToUniversalTime()) { throw 'Certificate validity check failed.' }
  } finally { $cert.Reset() }
  if ($context.CertificateFileSha256 -cne $proof.FileSha256 -or $context.CertificateDerSha256 -cne $proof.DerSha256) { throw 'Certificate fingerprint mismatch.' }
  $context.Check()
  $api = [SmartHatch.Q12.V2.NativePq]::new()
  $session = [SmartHatch.Q12.V2.Session]::new($api,[SmartHatch.Q12.V2.RealClock]::new(),[SmartHatch.Q12.V2.FileRootGate]::new($proof.FileSha256),$true)
  $preparation = [SmartHatch.Q12.V2.SafeEvent]::new()
  $preparation.Kind = 'LOCAL_PREPARATION_COMPLETE'
  $journal.Write($preparation)
  $password = Read-Host 'Existing test-project database password (hidden, never saved)' -AsSecureString
  $report = [SmartHatch.Q12.V2.Controller]::Run($bytes,$target,$context,$session,$password,$journal)
  Write-Output ('Status: ' + $report.Status + '; rollback: ' + $report.Rollback + '; durable journal: ' + $report.JournalDurable)
} catch {
  # Never print $_, exception message, untrusted provenance values or credentials.
  if ($null -ne $journal) {
    $failure = [SmartHatch.Q12.V2.SafeEvent]::new()
    $failure.Kind = 'LAUNCHER_FAILURE'
    $failure.Status = 'UNEXPECTED_LOCAL_FAILURE'
    try { $journal.Write($failure) } catch { try { $journal.Emergency($failure) } catch {} }
  }
  Write-Output 'STOPPED: launcher/preflight/evidence failure. No raw error text emitted.'
} finally {
  if ($null -ne $password) { $password.Dispose() }
  if ($null -ne $session) { try { $session.Dispose() } catch {} }
  if ($null -ne $certLock) { $certLock.Dispose() }
  if ($null -ne $journal) { try { $journal.Dispose() } catch {} }
}
if ($null -eq $report -or $report.Status -ne 'EXECUTED_COMPARISON_PARTIAL_NOT_TASK_ACCEPTANCE' -or -not $report.JournalDurable) { exit 1 }
