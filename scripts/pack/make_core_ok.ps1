$ErrorActionPreference='SilentlyContinue'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root="C:\Users\DELL\Desktop\gw_stack"
$tag="v0.1.2-core"
$outDir=Join-Path $root "artifacts"
$out=Join-Path $outDir ("gw_stack_{0}.zip" -f $tag)

if(!(Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }
if(Test-Path $out){ Remove-Item $out -Force 2>$null }

$includes=@("docker-compose.yml","docker-compose.gateway.yml","infra","scripts","docs","docs\publish_checklist.md")
$excludeDirs=@("\.git\","\artifacts\","\__pycache__\","\node_modules\","\coverage\","\dist\","\build\")
$excludeExt=@(".log",".tmp",".tsbuildinfo")

$added=0;$miss=0;$scanned=0

$fs=[IO.File]::Open($out,[IO.FileMode]::Create,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
$zip=[IO.Compression.ZipArchive]::new($fs,[IO.Compression.ZipArchiveMode]::Create,$true)

function AddFile($p,$rel){
  try{
    $in=[IO.File]::OpenRead($p)
    try{
      $entry=$zip.CreateEntry($rel,[IO.Compression.CompressionLevel]::Optimal).Open()
      $in.CopyTo($entry)
      $entry.Dispose()
    }finally{ $in.Dispose() }
    $script:added++
  }catch{}
}

foreach($inc in $includes){
  $src=Join-Path $root $inc
  if(Test-Path $src -PathType Leaf){
    $rel=$inc -replace '\\','/'; $scanned++; AddFile $src $rel; continue
  }
  if(Test-Path $src -PathType Container){
    Get-ChildItem -LiteralPath $src -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
      $p=$_.FullName; $scanned++
      if($excludeDirs | Where-Object { $p -like ("*{0}*" -f $_) }) { return }
      if($excludeExt -contains $_.Extension) { return }
      $rel=$p.Substring($root.Length).TrimStart('\','/') -replace '\\','/'
      AddFile $p $rel
    }
    continue
  }
  $miss++
}

$zip.Dispose(); $fs.Dispose()
$size=(Get-Item $out -ErrorAction SilentlyContinue).Length
Write-Output ("ART={0} OK={1} SIZE={2} ADDED={3} SCANNED={4} MISS={5}" -f $out,($(if($size -gt 0){"YES"}else{"NO"})),$size,$added,$scanned,$miss)
exit ($(if($size -gt 0){0}else{1}))
