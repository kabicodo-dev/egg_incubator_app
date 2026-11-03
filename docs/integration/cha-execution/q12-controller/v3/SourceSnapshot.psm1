# R5: capture once under read-sharing locks, fingerprint and compile those strings.
# No mutable original pathname is supplied to CodeDom; original files are not reread for compilation.
Set-StrictMode -Version 2

function Get-Q12BytesHash {
  param([byte[]]$Bytes)
  $sha = [Security.Cryptography.SHA256]::Create()
  try { return [BitConverter]::ToString($sha.ComputeHash($Bytes)).Replace('-','').ToLowerInvariant() }
  finally { $sha.Dispose() }
}

function New-Q12SourceSnapshot {
  param([string]$Directory,[string[]]$Names)
  $snapshot = [pscustomobject]@{
    Streams = @{}
    Texts = @{}
    Hashes = [Collections.Generic.Dictionary[string,string]]::new()
    CompilationReceipts = [Collections.Generic.List[object]]::new()
    Closed = $false
  }
  try {
    foreach ($name in $Names) {
      if ([IO.Path]::GetFileName($name) -cne $name -or $snapshot.Streams.ContainsKey($name)) { throw 'Invalid source name.' }
      $stream = [IO.File]::Open((Join-Path $Directory $name),[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
      $snapshot.Streams.Add($name,$stream)
      $buffer = [IO.MemoryStream]::new()
      try { $stream.CopyTo($buffer); $bytes = $buffer.ToArray() } finally { $buffer.Dispose() }
      $text = [Text.UTF8Encoding]::new($false,$true).GetString($bytes)
      # Require UTF-8 without BOM: the exact hashed bytes and compiler strings have
      # a unique round trip. Fail rather than stripping BOM or normalizing newlines.
      if ($text.Length -gt 0 -and [int]$text[0] -eq 0xfeff) { throw 'Source BOM unsupported.' }
      $snapshot.Texts.Add($name,$text)
      $snapshot.Hashes.Add($name,(Get-Q12BytesHash $bytes))
    }
    Assert-Q12SourceSnapshot $snapshot
    return $snapshot
  } catch {
    Close-Q12SourceSnapshot $snapshot
    throw 'Source snapshot capture failed.'
  }
}

function Assert-Q12SourceSnapshot {
  param($Snapshot)
  if ($Snapshot.Closed -or $Snapshot.Texts.Count -ne $Snapshot.Hashes.Count -or $Snapshot.Streams.Count -ne $Snapshot.Hashes.Count) { throw 'Source snapshot integrity failure.' }
  foreach ($name in $Snapshot.Hashes.Keys) {
    $textBytes = [Text.UTF8Encoding]::new($false,$true).GetBytes([string]$Snapshot.Texts[$name])
    if ((Get-Q12BytesHash $textBytes) -cne $Snapshot.Hashes[$name]) { throw 'Source snapshot text changed.' }
    $stream = $Snapshot.Streams[$name]
    $stream.Position = 0
    $buffer = [IO.MemoryStream]::new()
    try { $stream.CopyTo($buffer); $bytes = $buffer.ToArray() } finally { $buffer.Dispose() }
    if ((Get-Q12BytesHash $bytes) -cne $Snapshot.Hashes[$name]) { throw 'Source snapshot file changed.' }
  }
}

function Compile-Q12SourceSnapshot {
  param($Snapshot,[string[]]$CompileNames,[string]$CompilerEvidenceDirectory)
  Assert-Q12SourceSnapshot $Snapshot
  $inputs = [Collections.Generic.List[string]]::new()
  foreach ($name in $CompileNames) {
    if (-not $Snapshot.Texts.ContainsKey($name)) { throw 'Uncaptured compiler input.' }
    $inputs.Add([string]$Snapshot.Texts[$name])
  }
  $null = [IO.Directory]::CreateDirectory($CompilerEvidenceDirectory)
  $provider = [Microsoft.CSharp.CSharpCodeProvider]::new()
  $parameters = [CodeDom.Compiler.CompilerParameters]::new()
  $parameters.GenerateInMemory = $true
  $parameters.GenerateExecutable = $false
  $parameters.IncludeDebugInformation = $false
  $parameters.TempFiles = [CodeDom.Compiler.TempFileCollection]::new($CompilerEvidenceDirectory,$true)
  foreach ($assembly in @('System.dll','System.Core.dll','System.Web.Extensions.dll')) { $null = $parameters.ReferencedAssemblies.Add($assembly) }
  try {
    # CompileAssemblyFromSource receives each captured string intact as a separate
    # compilation unit. No concatenation, include, text rewriting or path reread.
    $compiled = $provider.CompileAssemblyFromSource($parameters,$inputs.ToArray())
    if ($compiled.Errors.HasErrors) { throw 'Snapshot compilation failed.' }
    Assert-Q12SourceSnapshot $Snapshot
    # CodeDom's internal compiler writes its own source files (possibly with BOM).
    # Retain exact compiler-file hashes AND prove decoded text equals our frozen
    # units. These are not hashes calculated later from mutable original paths.
    $compilerFiles = @(Get-ChildItem -LiteralPath $CompilerEvidenceDirectory -Filter '*.cs' -File | Sort-Object Name)
    if ($compilerFiles.Count -ne $CompileNames.Count) { throw 'Compiler-input receipt mismatch.' }
    for ($i = 0; $i -lt $CompileNames.Count; $i++) {
      $name = $CompileNames[$i]
      $compilerText = [IO.File]::ReadAllText($compilerFiles[$i].FullName,[Text.UTF8Encoding]::new($false,$true))
      $contentHash = Get-Q12BytesHash ([Text.UTF8Encoding]::new($false,$true).GetBytes($compilerText))
      if ($contentHash -cne $Snapshot.Hashes[$name]) { throw 'Compiler input differs from captured source.' }
      $Snapshot.CompilationReceipts.Add([pscustomobject]@{
        source = $name
        capturedSourceSha256 = $Snapshot.Hashes[$name]
        compilerInput = $compilerFiles[$i].FullName
        exactCompilerFileSha256 = Get-Q12BytesHash ([IO.File]::ReadAllBytes($compilerFiles[$i].FullName))
        decodedCompilerTextSha256 = $contentHash
      })
    }
    return $compiled.CompiledAssembly
  } finally { $provider.Dispose() }
}

function Close-Q12SourceSnapshot {
  param($Snapshot)
  foreach ($stream in $Snapshot.Streams.Values) { $stream.Dispose() }
  $Snapshot.Closed = $true
}

Export-ModuleMember -Function Get-Q12BytesHash,New-Q12SourceSnapshot,Assert-Q12SourceSnapshot,Compile-Q12SourceSnapshot,Close-Q12SourceSnapshot
