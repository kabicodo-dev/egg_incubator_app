# Offline production-subset compilation and original v1/reference checks only.
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$controller = Join-Path $root 'docs\integration\cha-execution\q12-controller'
$destination = Join-Path $PSScriptRoot 'additional-controls.json'
if (Test-Path -LiteralPath $destination) { throw 'Existing evidence preserved.' }
function Hash([string]$Path) { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
$old = Get-Content -LiteralPath (Join-Path $controller 'local-test-1118803c180d42a88e5491410bb69584.json') -Raw | ConvertFrom-Json
foreach ($p in $old.inputHashes.PSObject.Properties) {
  if ((Hash (Join-Path $controller $p.Name)) -cne $p.Value) { throw 'v1 source mismatch.' }
}
$v3 = Join-Path $controller 'v3'
Import-Module (Join-Path $v3 'SourceSnapshot.psm1') -Force -DisableNameChecking
$names = @('ModelPolicy.cs','NativeBoundary.cs','DurableController.cs','Invoke-Q12PhaseA-V3.ps1','Correction.Tests.cs','Followup.Tests.cs','Test-Corrections.ps1','SourceSnapshot.psm1')
$snapshot = New-Q12SourceSnapshot -Directory $v3 -Names $names
try {
  $assembly = Compile-Q12SourceSnapshot -Snapshot $snapshot -CompileNames @('ModelPolicy.cs','NativeBoundary.cs','DurableController.cs') -CompilerEvidenceDirectory (Join-Path $PSScriptRoot 'production-subset-compiler-inputs')
  if ($null -eq $assembly.GetType('SmartHatch.Q12.V3.Controller')) { throw 'Missing production type.' }
  $reference = 'C:\Program Files\PostgreSQL\17\doc\src\sgml\html\libpq-status.html'
  $line = @(Select-String -LiteralPath $reference -SimpleMatch 'default_transaction_read_only' | Where-Object { $_.Line.Contains('simplelist') })
  if ($line.Count -ne 1) { throw 'Independent ParameterStatus reference missing.' }
  $result = [ordered]@{
    observedAtUtc = [DateTime]::UtcNow.ToString('o'); status = 'PASS'; scope = 'OFFLINE ONLY'
    v1OriginalInputHashesMatch = $true; v1HistoricalTests = $old.tests
    productionSubsetCompilation = 'PASS: three runtime units, without test assemblies; no NativePq instance/connection'
    compilerInputReceipts = @($snapshot.CompilationReceipts.ToArray()); sourceHashes = $snapshot.Hashes
    parameterStatusReference = [ordered]@{ path = $reference; sha256 = Hash $reference; line = $line[0].LineNumber; interpretation = 'Installed PostgreSQL 17 manual lists default_transaction_read_only as reported parameter. Actual remote response NOT RUN.' }
    remoteExecuted = $false
  }
  $result | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $destination -Encoding UTF8
} finally { Close-Q12SourceSnapshot $snapshot }
Write-Output 'PASS: original v1 input hashes; three-unit runtime snapshot compilation/receipts; local PG17 ParameterStatus reference. No connection.'
