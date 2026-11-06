# Offline only. No database connection, chain building, network, imports or secrets.
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$controller = Join-Path $root 'docs\integration\cha-execution\q12-controller'
function Hash([string]$Path) { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function ReadJson([string]$Path) { return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json }
function Assert([bool]$Condition,[string]$Code) { if (-not $Condition) { throw $Code } }
$destination = Join-Path $PSScriptRoot 'local-review-evidence.json'
Assert (-not (Test-Path -LiteralPath $destination)) 'Existing evidence preserved'
$checks = [Collections.Generic.List[object]]::new()
foreach ($version in @('v2','v3')) {
  $directory = Join-Path $controller $version
  $inventory = ReadJson (Join-Path $directory 'review-inventory.json')
  foreach ($file in $inventory.files) {
    $path = Join-Path $directory $file.file
    Assert ((Hash $path) -ceq $file.sha256) 'Historical inventory hash mismatch'
    Assert ((Get-Item -LiteralPath $path).Length -eq $file.bytes) 'Historical size mismatch'
  }
  $checks.Add([ordered]@{ check = ($version + ' historical inventory'); files = @($inventory.files).Count; status = 'PASS'; inventorySha256 = Hash (Join-Path $directory 'review-inventory.json') })
}
$historical = ReadJson (Join-Path $controller 'v3\local-verification-fdf7956c5ace4af7bd47605d80d44f9d\test-results.json')
$fresh = ReadJson (Join-Path $controller 'v3\local-verification-d7b25ad8655a47318783ec987cee2859\test-results.json')
foreach ($report in @($historical,$fresh)) {
  Assert ($report.tests -eq 211 -and $report.passed -eq 211 -and $report.failed -eq 0 -and @($report.cases).Count -eq 211) 'Test count mismatch'
  Assert (@($report.cases | Where-Object { $_.Status -cne 'PASS' }).Count -eq 0) 'Failed case'
  foreach ($property in $report.inputHashes.PSObject.Properties) {
    Assert ((Hash (Join-Path $controller ('v3\' + $property.Name))) -ceq $property.Value) 'Current source differs from tested snapshot'
  }
  Assert (@($report.compilerInputReceipts).Count -eq 5) 'Missing compiler receipts'
  foreach ($receipt in $report.compilerInputReceipts) {
    Assert ((Hash $receipt.compilerInput) -ceq $receipt.exactCompilerFileSha256) 'Compiler file mismatch'
    $text = [IO.File]::ReadAllText($receipt.compilerInput,[Text.UTF8Encoding]::new($false,$true))
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $decoded = [BitConverter]::ToString($sha.ComputeHash([Text.UTF8Encoding]::new($false,$true).GetBytes($text))).Replace('-','').ToLowerInvariant() } finally { $sha.Dispose() }
    Assert ($decoded -ceq $receipt.capturedSourceSha256 -and $decoded -ceq $receipt.decodedCompilerTextSha256) 'Compiler decoded content mismatch'
  }
  $events = @(Get-Content -LiteralPath (Join-Path $report.emergencyOnlyRecovery 'emergency.jsonl') | ForEach-Object { (ConvertFrom-Json $_).event })
  $pre = @($events | Where-Object Kind -eq 'PREFLIGHT')[-1].Preflight
  $end = @($events | Where-Object Kind -eq 'FINAL_ROLLBACK_AND_CLOSE')[-1].Summary
  Assert ($pre.runId -ceq $report.runId -and $pre.executionMode -ceq 'LOCAL_SYNTHETIC' -and $end.RunId -ceq $report.runId) 'Emergency attribution mismatch'
  foreach ($property in $report.inputHashes.PSObject.Properties) { Assert ($pre.sourceHashes.($property.Name) -ceq $property.Value) 'Emergency source mismatch' }
  Assert ($end.Rollback -ceq 'SERVER_ROLLBACK_TAG_CONFIRMED' -and $end.FinalTransaction -ceq 'IDLE' -and $end.Closed -and $end.Status -ceq 'STOPPED' -and -not $end.JournalDurable) 'Emergency failure outcome mismatch'
  $checks.Add([ordered]@{ check = '211 cases, eight sources, five compiler receipts, emergency-only recovery'; runId = $report.runId; status = 'PASS' })
}
$sql = Join-Path $root 'docs\integration\cha-execution\Q12_Phase_A_Read_Only.sql'
$sqlHash = Hash $sql
Assert ($sqlHash -ceq '9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc') 'Approved SQL changed'
$jsonFiles = @(Get-ChildItem -LiteralPath (Join-Path $controller 'v3') -Recurse -File | Where-Object Extension -in @('.json','.jsonl'))
foreach ($file in $jsonFiles) {
  $text = [IO.File]::ReadAllText($file.FullName)
  Assert (-not $text.Contains('SENSITIVE_PASSWORD_AND_TOKEN') -and -not $text.Contains('SECRET_TOKEN')) 'Synthetic secret leaked into JSON evidence'
}
$certPath = 'C:\Users\Mary Charlyn\Downloads\prod-ca-2021.crt'
$cert = [Security.Cryptography.X509Certificates.X509Certificate2]::new($certPath)
try {
  $sha = [Security.Cryptography.SHA256]::Create()
  try { $der = [BitConverter]::ToString($sha.ComputeHash($cert.RawData)).Replace('-','').ToLowerInvariant() } finally { $sha.Dispose() }
  $extensions = @($cert.Extensions | ForEach-Object { [ordered]@{ oid = $_.Oid.Value; critical = $_.Critical; formatted = $_.Format($false) } })
  $certificate = [ordered]@{
    path = $certPath; fileSha256 = Hash $certPath; derSha256 = $der
    subject = $cert.Subject; issuer = $cert.Issuer; serialNumber = $cert.SerialNumber
    notBeforeUtc = $cert.NotBefore.ToUniversalTime().ToString('o'); notAfterUtc = $cert.NotAfter.ToUniversalTime().ToString('o')
    currentlyWithinValidity = ([DateTime]::UtcNow -ge $cert.NotBefore.ToUniversalTime() -and [DateTime]::UtcNow -le $cert.NotAfter.ToUniversalTime())
    signatureAlgorithm = $cert.SignatureAlgorithm.FriendlyName; extensions = $extensions
    trustedOrigin = 'NOT VERIFIED'; authoritativeExpectedDerSha256 = 'NOT PROVIDED'
    ownerAttestation = 'NOT PROVIDED'; hostnameVerification = 'NOT RUN'
    method = 'Local X509 parse only. No chain build, revocation fetch, trust-store import or Supabase contact.'
  }
} finally { $cert.Reset() }
$record = [ordered]@{
  observedAtUtc = [DateTime]::UtcNow.ToString('o'); scope = 'OFFLINE LOCAL REVIEW ONLY'
  checks = @($checks.ToArray()); approvedSqlSha256 = $sqlHash
  freshTestRun = $fresh.runId; categories = $fresh.categories; sourceHashes = $fresh.inputHashes
  syntheticSecretScan = [ordered]@{ status = 'PASS'; files = $jsonFiles.Count; limitation = 'Known synthetic markers only; not proof that arbitrary secrets cannot exist.' }
  certificateObservation = $certificate; remoteExecuted = $false
  reviewIndependence = 'Fresh source/evidence review by the same assistant in this workflow; no separate human or external reviewer acceptance is asserted.'
}
$record | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $destination -Encoding UTF8
Write-Output 'PASS: retained inventories, historical/fresh 211 cases, source/compiler/emergency fingerprints, SQL, synthetic leak scan. Certificate parsed offline; trust NOT established.'
