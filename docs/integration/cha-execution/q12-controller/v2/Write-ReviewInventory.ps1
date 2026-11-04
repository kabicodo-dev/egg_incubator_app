# Generated evidence inventory only. No source edits, database calls or overwrite.
$ErrorActionPreference = 'Stop'
$destination = Join-Path $PSScriptRoot 'review-inventory.json'
if (Test-Path -LiteralPath $destination) { throw 'Existing inventory preserved; refusing overwrite.' }
$parent = Split-Path -Parent $PSScriptRoot
$old = Get-Content -LiteralPath (Join-Path $parent 'local-test-1118803c180d42a88e5491410bb69584.json') -Raw | ConvertFrom-Json
foreach ($p in $old.inputHashes.PSObject.Properties) {
  $actual = (Get-FileHash -LiteralPath (Join-Path $parent $p.Name) -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -cne $p.Value) { throw 'Original reviewed source changed.' }
}
$latestPath = Join-Path $PSScriptRoot 'local-verification-ee9acc30dabd49e0a5805776649865ce\test-results.json'
$latest = Get-Content -LiteralPath $latestPath -Raw | ConvertFrom-Json
foreach ($p in $latest.inputHashes.PSObject.Properties) {
  $actual = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $p.Name) -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -cne $p.Value) { throw 'Final evidence/source fingerprint mismatch.' }
}
$sql = Join-Path $PSScriptRoot '..\..\Q12_Phase_A_Read_Only.sql'
$sqlHash = (Get-FileHash -LiteralPath $sql -Algorithm SHA256).Hash.ToLowerInvariant()
if ($sqlHash -cne '9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc') { throw 'SQL changed.' }
$files = @(Get-ChildItem -LiteralPath $PSScriptRoot -Recurse -File | Sort-Object FullName | ForEach-Object {
  [ordered]@{
    file = $_.FullName.Substring($PSScriptRoot.Length + 1).Replace('\','/')
    bytes = $_.Length
    sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
  }
})
$inventory = [ordered]@{
  observedAtUtc = [DateTime]::UtcNow.ToString('o')
  scope = 'LOCAL Q12 controller corrections only; no existing files modified'
  files = $files
  excludes = 'This generated inventory itself; no recursive self hash'
  previousReviewedSourcesUnchanged = $true
  approvedSqlSha256 = $sqlHash
  finalSourceHashesMatchTestEvidence = $true
  remoteExecuted = $false
  phaseAComplete = $false
  dbImp01Complete = $false
}
$json = $inventory | ConvertTo-Json -Depth 8
$stream = [IO.File]::Open($destination,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::Read)
try {
  $data = [Text.UTF8Encoding]::new($false).GetBytes($json + "`n")
  $stream.Write($data,0,$data.Length)
  $stream.Flush($true)
} finally { $stream.Dispose() }
Write-Output ('PASS: complete inventory of ' + $files.Count + ' files; original sources and SQL preserved; final test fingerprints verified.')
