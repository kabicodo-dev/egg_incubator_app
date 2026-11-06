# Local-only compilation/mocks. Does not call the remote runner or load libpq.
$ErrorActionPreference = 'Stop'
Add-Type -Path @((Join-Path $PSScriptRoot 'Q12Controller.cs'), (Join-Path $PSScriptRoot 'Q12Controller.Tests.cs'))
$sqlPath = Join-Path $PSScriptRoot '..\Q12_Phase_A_Read_Only.sql'
$before = (Get-FileHash -LiteralPath $sqlPath -Algorithm SHA256).Hash.ToLowerInvariant()
[SmartHatch.Q12.Tests.Suite]::RunAll([IO.File]::ReadAllBytes($sqlPath))
$cases = @([SmartHatch.Q12.Tests.Suite]::Results)
$json = [SmartHatch.Q12.Tests.Suite]::RedactionExample | ConvertTo-Json -Depth 12
if ($json.Contains('MOCK_PASSWORD_DO_NOT_LOG') -or $json.Contains('MOCK_TOKEN_DO_NOT_LOG')) { throw 'Redaction regression.' }
$after = (Get-FileHash -LiteralPath $sqlPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($before -ne $after) { throw 'Approved SQL changed.' }
# Verify the real entrypoint refuses execution without BOTH explicit gates.
# No-switch fails before compilation, credential prompt, native load or network.
$entrypoint = Join-Path $PSScriptRoot 'Invoke-Q12PhaseA.ps1'
$savedPreference = $ErrorActionPreference
try {
  $ErrorActionPreference = 'Continue' # Expected native stderr is captured, not a harness failure.
  $guardOutput = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $entrypoint 2>&1
  $guardExit = $LASTEXITCODE
} finally { $ErrorActionPreference = $savedPreference }
if ($guardExit -ne 1 -or ($guardOutput | Out-String) -notmatch 'Remote execution disabled') { throw 'Entrypoint guard regression.' }
$guardOutput = $null
$inputs = @{}
foreach ($name in @('Q12Controller.cs','Q12Controller.Tests.cs','Test-Q12Controller.ps1','Invoke-Q12PhaseA.ps1')) {
  $inputs[$name] = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $name) -Algorithm SHA256).Hash.ToLowerInvariant()
}
$failures = @($cases | Where-Object { $_.Status -ne 'PASS' })
$report = [ordered]@{
  observedAtUtc = [DateTime]::UtcNow.ToString('o')
  scope = 'LOCAL MOCKS ONLY; no sockets, libpq load, Supabase or remote SQL'
  sqlSha256 = $after
  tests = $cases.Count
  passed = $cases.Count - $failures.Count
  failed = $failures.Count
  serializedEvidenceRedaction = 'PASS'
  remoteEntrypointDefaultDeny = 'PASS: child PowerShell exited 1 before credential/native access'
  powershellVersion = $PSVersionTable.PSVersion.ToString()
  inputHashes = $inputs
  cases = $cases
  taskStatus = 'Q12 Phase A incomplete; DB-IMP-01 not Completed; remote execution awaiting explicit approval'
}
$destination = Join-Path $PSScriptRoot ('local-test-' + [guid]::NewGuid().ToString('N') + '.json')
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $destination -Encoding UTF8
$cases | Format-Table -AutoSize
Write-Output ('Evidence: ' + $destination)
Write-Output ('Tests: ' + $cases.Count + '; passed: ' + ($cases.Count - $failures.Count) + '; failed: ' + $failures.Count)
if ($failures.Count -ne 0) { exit 1 }
