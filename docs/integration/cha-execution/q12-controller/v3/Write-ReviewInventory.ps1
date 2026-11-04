# Local generated inventory only. Refuse overwrite; do not touch previous revisions.
$ErrorActionPreference = 'Stop'
$destination = Join-Path $PSScriptRoot 'review-inventory.json'
if (Test-Path -LiteralPath $destination) { throw 'Existing inventory preserved.' }
$oldRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'v2'
$oldInventory = Get-Content -LiteralPath (Join-Path $oldRoot 'review-inventory.json') -Raw | ConvertFrom-Json
foreach ($file in $oldInventory.files) {
  $actual = (Get-FileHash -LiteralPath (Join-Path $oldRoot $file.file) -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -cne $file.sha256) { throw 'Historical v2 file changed.' }
}
$latest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'local-verification-fdf7956c5ace4af7bd47605d80d44f9d/test-results.json') -Raw | ConvertFrom-Json
if ($latest.tests -ne 211 -or $latest.passed -ne 211 -or $latest.failed -ne 0) { throw 'Final test report mismatch.' }
foreach ($inputFile in $latest.inputHashes.PSObject.Properties) {
  if ((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $inputFile.Name) -Algorithm SHA256).Hash.ToLowerInvariant() -cne $inputFile.Value) { throw 'Final snapshot/source hash mismatch.' }
}
foreach ($receipt in $latest.compilerInputReceipts) {
  if ((Get-FileHash -LiteralPath $receipt.compilerInput -Algorithm SHA256).Hash.ToLowerInvariant() -cne $receipt.exactCompilerFileSha256 -or
      $receipt.capturedSourceSha256 -cne $receipt.decodedCompilerTextSha256) { throw 'Compiler receipt mismatch.' }
}
$sqlHash = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot '..\..\Q12_Phase_A_Read_Only.sql') -Algorithm SHA256).Hash.ToLowerInvariant()
if ($sqlHash -cne '9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc') { throw 'Approved SQL changed.' }
$files = @(Get-ChildItem -LiteralPath $PSScriptRoot -Recurse -File | Sort-Object FullName | ForEach-Object {
  [ordered]@{ file = $_.FullName.Substring($PSScriptRoot.Length + 1).Replace('\','/'); bytes = $_.Length; sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant() }
})
$record = [ordered]@{
  observedAtUtc = [DateTime]::UtcNow.ToString('o')
  scope = 'Q12 local follow-up revision 3 only'
  files = $files; excludes = 'This inventory itself'
  v2FileHashesPreserved = $true; v2InventorySha256 = (Get-FileHash -LiteralPath (Join-Path $oldRoot 'review-inventory.json') -Algorithm SHA256).Hash.ToLowerInvariant()
  approvedSqlSha256 = $sqlHash; finalSourceFingerprintsMatch = $true; compilerReceiptsMatch = $true
  remoteExecuted = $false; phaseAComplete = $false; dbImp01Complete = $false
}
$data = [Text.UTF8Encoding]::new($false).GetBytes(($record | ConvertTo-Json -Depth 8) + "`n")
$stream = [IO.File]::Open($destination,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::Read)
try { $stream.Write($data,0,$data.Length); $stream.Flush($true) } finally { $stream.Dispose() }
Write-Output ('PASS: ' + $files.Count + ' inventory files; v2 preserved; final 211 cases, source snapshots, compiler receipts and SQL verified.')
