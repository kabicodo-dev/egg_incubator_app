param(
  [string]$InputRoot = 'C:\Users\ACER\AppData\Local\Temp\opencode\manual-result-02-review-20261031',
  [string]$InputZip = 'C:\Users\ACER\Downloads\SmartHatch_Manual_Result_0.2_Review.zip'
)
$ErrorActionPreference = 'Stop'
function Hash($p) { (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant() }
$zipHash = Hash $InputZip
if ($zipHash -ne '983be83c12aa3550c69e8f17bd0a5642b1a92e5ea9d667368c6b0e2a75ad6772') { throw 'Wrong input ZIP' }
"ZIP SHA256 $zipHash"
$manifestPath = Join-Path $InputRoot 'manifest.json'
"MANIFEST SHA256 $(Hash $manifestPath)"
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($f in $manifest.files) {
  $p = Join-Path $InputRoot $f.file
  if (!(Test-Path -LiteralPath $p)) { throw "Missing $($f.file)" }
  if ((Get-Item -LiteralPath $p).Length -ne $f.bytes -or (Hash $p) -ne $f.sha256) { throw "Mismatch $($f.file)" }
  "PASS $($f.file) bytes=$($f.bytes) sha256=$($f.sha256)"
}
"PASS manifest entries=$($manifest.files.Count)"
$parent = Get-Content -LiteralPath (Join-Path $InputRoot 'docs\contract-review\manual-result-0.2-review\parent-and-change-manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($p in $parent.parents.PSObject.Properties) {
  if ((Hash (Join-Path $InputRoot $p.Name)) -ne $p.Value) { throw "Parent mismatch $($p.Name)" }
  "PASS preserved parent $($p.Name) sha256=$($p.Value)"
}
"PASS preserved parents=$(@($parent.parents.PSObject.Properties).Count)"
$old = 'C:\egg_incubator_app\docs\review-evidence\manual-result-2026-10-31\dart_manual_result_review.dart'
if ((Hash $old) -ne 'bcb7ab832eabd97092e6d22a983910cd4e32288e5777f3cd79adbbd1ee57b45e') { throw 'Old evidence script changed' }
"PASS old Dart evidence sha256=$(Hash $old)"
