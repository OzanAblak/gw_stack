$ErrorActionPreference='SilentlyContinue'
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

$root="C:\Users\DELL\Desktop\gw_stack"
$tag="v0.1.2-core"
$outDir=Join-Path $root "artifacts"
$out=Join-Path $outDir ("gw_stack_{0}.zip" -f $tag)

if(!(Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }
if(Test-Path $out){ Remove-Item $out -Force 2>$null }

$includes=@(
  "docker-compose.yml",
  "docker-compose.gateway.yml",
  "infra",
  "scripts",
  "docs\publish_checklist.md",
  "docs"
)
$excludeDirs=@(".git","artifacts","core_stage","__pycache__","node_modules",".venv",".pytest_cache")
$excludeExt = @(".log",".tmp",".tsbuildinfo")

$added=0; $skipped=0; $scanned=0

$fs = [System.IO.File]::Open($out,[System.IO.FileMode]::CreateNew,[System.IO.FileAccess]::ReadWrite,[System.IO.FileShare]::None)
try {
  $zip = New-Object System.IO.Compression.ZipArchive($fs,[System.IO.Compression.ZipArchiveMode]::Create,$true)

  foreach($inc in $includes){
    $src = Join-Path $root $inc
    if(Test-Path $src -PathType Leaf){
      $rel = $src.Substring($root.Length).TrimStart('\','/')
      try {
        $entry = $zip.CreateEntry($rel,[System.IO.Compression.CompressionLevel]::Optimal)
        $in = [System.IO.File]::OpenRead($src)
        try { $in.CopyTo($entry.Open()) } finally { $in.Dispose() }
        $added++
      } catch { $skipped++ }
      $scanned++
      continue
    }
    if(Test-Path $src -PathType Container){
      Get-ChildItem -LiteralPath $src -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $p=$_.FullName; $scanned++
        if($excludeDirs | Where-Object { $p -like ("*{0}*" -f $_) }) { $skipped++; return }
        if($excludeExt -contains $_.Extension) { $skipped++; return }
        $rel = $p.Substring($root.Length).TrimStart('\','/')
        try {
          $entry = $zip.CreateEntry($rel,[System.IO.Compression.CompressionLevel]::Optimal)
          $in = [System.IO.File]::OpenRead($p)
          try { $in.CopyTo($entry.Open()) } finally { $in.Dispose() }
          $added++
        } catch { $skipped++ }
      }
      continue
    }
    $skipped++
  }
} finally {
  if($zip){ $zip.Dispose() }
  $fs.Dispose()
}

$size=(Get-Item $out -ErrorAction SilentlyContinue).Length
Write-Output ("ART={0} OK={1} SIZE={2} FILES_ADDED={3} SCANNED={4} SKIPPED={5}" -f $out, ($(if($size -gt 0){"YES"}else{"NO"})), ($size?$size:0), $added, $scanned, $skipped)
