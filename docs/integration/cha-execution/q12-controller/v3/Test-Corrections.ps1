# LOCAL ONLY: snapshot compilation, synthetic native calls, and no-connection probes.
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'SourceSnapshot.psm1') -Force -DisableNameChecking
$names = @('ModelPolicy.cs','NativeBoundary.cs','DurableController.cs','Invoke-Q12PhaseA-V3.ps1','Correction.Tests.cs','Followup.Tests.cs','Test-Corrections.ps1','SourceSnapshot.psm1')
$runId = [guid]::NewGuid().ToString('N')
$run = Join-Path $PSScriptRoot ('local-verification-' + $runId)
$null = New-Item -ItemType Directory -Path $run
$snapshot = $null
try {
  $snapshot = New-Q12SourceSnapshot -Directory $PSScriptRoot -Names $names
  $null = Compile-Q12SourceSnapshot -Snapshot $snapshot -CompileNames @('ModelPolicy.cs','NativeBoundary.cs','DurableController.cs','Correction.Tests.cs','Followup.Tests.cs') -CompilerEvidenceDirectory (Join-Path $run 'compiler-inputs')
  $sql = Join-Path $PSScriptRoot '..\..\Q12_Phase_A_Read_Only.sql'
  $bytes = [IO.File]::ReadAllBytes($sql)
  $null = [SmartHatch.Q12.V3.Pin]::Sql($bytes)
  [SmartHatch.Q12.V3.Tests.Suite]::RunAll($bytes,$run)
  [SmartHatch.Q12.V3.Tests.Followup]::ActualSourceHashes = $snapshot.Hashes
  [SmartHatch.Q12.V3.Tests.Followup]::ActualRunId = $runId
  [SmartHatch.Q12.V3.Tests.Followup]::Run($bytes,$run)
  $cases = @([SmartHatch.Q12.V3.Tests.Suite]::Cases) + @([SmartHatch.Q12.V3.Tests.Followup]::Cases)
  # Actual filesystem/compilation regressions for the source-input snapshot.
  $snapshotCases = [Collections.Generic.List[object]]::new()
  function Test-SnapshotCase([string]$Name,[scriptblock]$Body) {
    try { & $Body; $status = 'PASS' } catch { $status = 'FAIL' }
    $snapshotCases.Add([pscustomobject]@{ Category = 'source-snapshot'; Name = $Name; Status = $status })
  }
  Test-SnapshotCase 'R5 compiler input receipts match all five captured CSharp units' {
    if ($snapshot.CompilationReceipts.Count -ne 5) { throw 'Missing compilation receipt.' }
    foreach ($receipt in $snapshot.CompilationReceipts) {
      if ($receipt.capturedSourceSha256 -cne $receipt.decodedCompilerTextSha256 -or $receipt.capturedSourceSha256 -cne $snapshot.Hashes[$receipt.source]) { throw 'Compiler receipt mismatch.' }
    }
  }
  Test-SnapshotCase 'R5 captured bytes compile with matching fingerprint; source write blocked by lock' {
    $dir = Join-Path $run 'snapshot-lock-test'
    $null = New-Item -ItemType Directory -Path $dir
    $path = Join-Path $dir 'Probe.cs'
    $type = 'Probe' + [guid]::NewGuid().ToString('N')
    [IO.File]::WriteAllText($path,('namespace SnapshotTests { public static class ' + $type + ' { public const int Value = 7; } }'),[Text.UTF8Encoding]::new($false))
    $image = New-Q12SourceSnapshot -Directory $dir -Names @('Probe.cs')
    try {
      $blocked = $false
      try { [IO.File]::WriteAllText($path,'modified after fingerprinting') } catch [IO.IOException] { $blocked = $true }
      if (-not $blocked) { throw 'Source write was not blocked.' }
      $assembly = Compile-Q12SourceSnapshot -Snapshot $image -CompileNames @('Probe.cs') -CompilerEvidenceDirectory (Join-Path $dir 'compiler')
      if ($assembly.GetType(('SnapshotTests.' + $type)).GetField('Value').GetRawConstantValue() -ne 7) { throw 'Wrong compiler input.' }
      if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $image.Hashes['Probe.cs']) { throw 'Hash mismatch.' }
    } finally { Close-Q12SourceSnapshot $image }
  }
  Test-SnapshotCase 'R5 physical modification after fingerprinting with broken lock rejects before compilation' {
    $dir = Join-Path $run 'snapshot-modification-test'; $null = New-Item -ItemType Directory -Path $dir
    $path = Join-Path $dir 'Probe.cs'
    [IO.File]::WriteAllText($path,'public class BeforeMutation {}',[Text.UTF8Encoding]::new($false))
    $image = New-Q12SourceSnapshot -Directory $dir -Names @('Probe.cs')
    try {
      $image.Streams['Probe.cs'].Dispose() # Simulated broken input-lock invariant.
      [IO.File]::WriteAllText($path,'public class AfterMutation {}',[Text.UTF8Encoding]::new($false))
      $rejected = $false
      try { $null = Compile-Q12SourceSnapshot -Snapshot $image -CompileNames @('Probe.cs') -CompilerEvidenceDirectory (Join-Path $dir 'must-not-compile') } catch { $rejected = $true }
      if (-not $rejected -or (Test-Path -LiteralPath (Join-Path $dir 'must-not-compile'))) { throw 'Changed source reached compiler.' }
    } finally { Close-Q12SourceSnapshot $image }
  }
  Test-SnapshotCase 'R5 in-memory source text tampering rejects before compilation' {
    $dir = Join-Path $run 'snapshot-memory-test'; $null = New-Item -ItemType Directory -Path $dir
    [IO.File]::WriteAllText((Join-Path $dir 'Probe.cs'),'public class Unchanged {}',[Text.UTF8Encoding]::new($false))
    $image = New-Q12SourceSnapshot -Directory $dir -Names @('Probe.cs')
    try {
      $image.Texts['Probe.cs'] = 'public class Injected {}'
      $rejected = $false
      try { $null = Compile-Q12SourceSnapshot -Snapshot $image -CompileNames @('Probe.cs') -CompilerEvidenceDirectory (Join-Path $dir 'must-not-compile') } catch { $rejected = $true }
      if (-not $rejected -or (Test-Path -LiteralPath (Join-Path $dir 'must-not-compile'))) { throw 'Tampered source reached compiler.' }
    } finally { Close-Q12SourceSnapshot $image }
  }
  Test-SnapshotCase 'R5 uncaptured compilation unit rejected' {
    $rejected = $false
    try { $null = Compile-Q12SourceSnapshot -Snapshot $snapshot -CompileNames @('Uncaptured.cs') -CompilerEvidenceDirectory (Join-Path $run 'must-not-compile') } catch { $rejected = $true }
    if (-not $rejected) { throw 'Uncaptured input accepted.' }
  }
  $cases += @($snapshotCases.ToArray())
  Assert-Q12SourceSnapshot $snapshot
  $errorsFound = $null; $tokens = $null
  $null = [Management.Automation.Language.Parser]::ParseInput($snapshot.Texts['Invoke-Q12PhaseA-V3.ps1'],[ref]$tokens,[ref]$errorsFound)
  if ($errorsFound.Count -gt 0) { throw 'Launcher syntax check failed.' }
  $saved = $ErrorActionPreference
  try {
    $ErrorActionPreference = 'Continue'
    $guard = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Invoke-Q12PhaseA-V3.ps1') 2>&1
    $guardExit = $LASTEXITCODE
  } finally { $ErrorActionPreference = $saved }
  if ($guardExit -ne 1 -or ($guard | Out-String) -notmatch 'Remote execution disabled') { throw 'Launcher default-deny check failed.' }
  $guard = $null
  $failed = @($cases | Where-Object { $_.Status -ne 'PASS' })
  $report = [ordered]@{
    runId = $runId; observedAtUtc = [DateTime]::UtcNow.ToString('o')
    scope = 'LOCAL ONLY. No Supabase connections, SQL, users or database fixtures.'
    tests = $cases.Count; passed = $cases.Count - $failed.Count; failed = $failed.Count
    categories = @($cases | Group-Object Category | ForEach-Object { [ordered]@{ category = $_.Name; count = $_.Count } })
    cases = $cases; inputHashes = $snapshot.Hashes
    compilation = 'CompileAssemblyFromSource over locked, hashed UTF-8 snapshot strings; never compile by source pathname'
    compilerInputReceipts = @($snapshot.CompilationReceipts.ToArray())
    independentSchemaReferences = [SmartHatch.Q12.V3.Tests.Followup]::References
    emergencyOnlyRecovery = [SmartHatch.Q12.V3.Tests.Followup]::EmergencyOnlyDirectory
    approvedSqlSha256 = [SmartHatch.Q12.V3.Pin]::Hash([IO.File]::ReadAllBytes($sql))
    nativeProbe = [SmartHatch.Q12.V3.Tests.Suite]::NativeProbe
    actualNativeCoverage = 'Local libpq version/PGresult memory operations only. No PGconn, sockets or SQL.'
    runtime = [Environment]::Version.ToString(); powershell = $PSVersionTable.PSVersion.ToString()
    launcherDefaultDeny = 'PASS'; launcherSyntax = 'PASS'
    realTLS = 'NOT RUN'; realAuthentication = 'NOT RUN'; realPooler = 'NOT RUN'; realRollback = 'NOT RUN'
    certificateProvenance = 'BLOCKED: actual trusted source/fingerprint not verified'
    taskStatus = 'Q12 Phase A incomplete; DB-IMP-01 incomplete; no task Completed'
  }
  $report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $run 'test-results.json') -Encoding UTF8
  [SmartHatch.Q12.V3.Tests.Suite]::ExampleJournal | Set-Content -LiteralPath (Join-Path $run 'synthetic-sanitized-example.jsonl') -Encoding UTF8
  $cases | Where-Object { $_.Status -ne 'PASS' } | Format-Table -AutoSize
  Write-Output ('Evidence: ' + $run)
  Write-Output ('Tests ' + $cases.Count + '; passed ' + ($cases.Count-$failed.Count) + '; failed ' + $failed.Count)
  if ($report.approvedSqlSha256 -cne [SmartHatch.Q12.V3.Pin]::SqlHash -or $failed.Count -ne 0) { exit 1 }
} finally { if ($null -ne $snapshot) { Close-Q12SourceSnapshot $snapshot } }
