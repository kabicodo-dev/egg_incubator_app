# Local controller/native-API substitutes + no-connection native-library probe only.
$ErrorActionPreference = 'Stop'
$sourceNames = @('ModelPolicy.cs','NativeBoundary.cs','DurableController.cs','Correction.Tests.cs')
Add-Type -Path ($sourceNames | ForEach-Object { Join-Path $PSScriptRoot $_ }) -ReferencedAssemblies 'System.Web.Extensions','System.Core'
$sql = Join-Path $PSScriptRoot '..\..\Q12_Phase_A_Read_Only.sql'
$bytes = [IO.File]::ReadAllBytes($sql)
$null = [SmartHatch.Q12.V2.Pin]::Sql($bytes)
$run = Join-Path $PSScriptRoot ('local-verification-' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $run
[SmartHatch.Q12.V2.Tests.Suite]::RunAll($bytes,$run)
$cases = @([SmartHatch.Q12.V2.Tests.Suite]::Cases)
$failed = @($cases | Where-Object { $_.Status -ne 'PASS' })
$hashes = [ordered]@{}
foreach ($file in @('ModelPolicy.cs','NativeBoundary.cs','DurableController.cs','Correction.Tests.cs','Invoke-Q12PhaseA-V2.ps1','Test-Corrections.ps1')) {
  $hashes[$file] = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $file) -Algorithm SHA256).Hash.ToLowerInvariant()
}
$errorsFound = $null
$tokens = $null
$null = [Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'Invoke-Q12PhaseA-V2.ps1'),[ref]$tokens,[ref]$errorsFound)
if ($errorsFound.Count -gt 0) { throw 'Launcher syntax check failed.' }
# Exercise real launcher default-deny before compilation/password/network.
$saved = $ErrorActionPreference
try {
  $ErrorActionPreference = 'Continue'
  $guard = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Invoke-Q12PhaseA-V2.ps1') 2>&1
  $guardExit = $LASTEXITCODE
} finally { $ErrorActionPreference = $saved }
if ($guardExit -ne 1 -or ($guard | Out-String) -notmatch 'Remote execution disabled') { throw 'Launcher default-deny check failed.' }
$guard = $null
$report = [ordered]@{
  observedAtUtc = [DateTime]::UtcNow.ToString('o')
  scope = 'LOCAL ONLY. No Supabase connections, SQL, users or database fixtures.'
  tests = $cases.Count; passed = $cases.Count - $failed.Count; failed = $failed.Count
  categories = @($cases | Group-Object Category | ForEach-Object { [ordered]@{ category = $_.Name; count = $_.Count } })
  cases = $cases
  inputHashes = $hashes
  approvedSqlSha256 = [SmartHatch.Q12.V2.Pin]::Hash([IO.File]::ReadAllBytes($sql))
  nativeProbe = [SmartHatch.Q12.V2.Tests.Suite]::NativeProbe
  actualNativeCoverage = 'PQlibVersion; PQmakeEmptyPGresult(NULL); PQsetResultAttrs/PQsetvalue memory-only fixtures with 500/501 rows; count/OID/UTF8-cell getters; PQclear. No PGconn, sockets or SQL.'
  runtime = [Environment]::Version.ToString(); powershell = $PSVersionTable.PSVersion.ToString()
  launcherDefaultDeny = 'PASS'; launcherSyntax = 'PASS'
  realTLS = 'NOT RUN'; realAuthentication = 'NOT RUN'; realPooler = 'NOT RUN'; realRollback = 'NOT RUN'
  certificateProvenance = 'BLOCKED: actual trusted source/fingerprint not verified'
  taskStatus = 'Q12 Phase A incomplete; DB-IMP-01 incomplete; no task Completed'
}
$report | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $run 'test-results.json') -Encoding UTF8
[SmartHatch.Q12.V2.Tests.Suite]::ExampleJournal | Set-Content -LiteralPath (Join-Path $run 'synthetic-sanitized-example.jsonl') -Encoding UTF8
$cases | Format-Table -AutoSize
Write-Output ('Evidence: ' + $run)
Write-Output ('Tests ' + $cases.Count + '; passed ' + ($cases.Count-$failed.Count) + '; failed ' + $failed.Count)
if ($report.approvedSqlSha256 -cne [SmartHatch.Q12.V2.Pin]::SqlHash -or $failed.Count -ne 0) { exit 1 }
