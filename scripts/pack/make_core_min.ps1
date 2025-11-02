$ErrorActionPreference='SilentlyContinue'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root="C:\Users\DELL\Desktop\gw_stack"
$outDir=Join-Path $root "artifacts"
$out=Join-Path $outDir "gw_stack_core_min.zip"
$files=@(
  "docker-compose.yml",
  "scripts\ci_smoke_local.ps1",
  "scripts\git\detect_git.ps1",
  "scripts\git\status.ps1",
  "docs\publish_checklist.md"
)
if(!(Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }
if(Test-Path $out){ Remove-Item $out -Force 2>$null }
$fs=[IO.File]::Open($out,[IO.FileMode]::Create,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
$zip=New-Object IO.Compression.ZipArchive($fs,[IO.Compression.ZipArchiveMode]::Create,$true)
$added=0;$miss=0
foreach($f in $files){
  $src=Join-Path $root $f
  if(Test-Path $src -PathType Leaf){
    $rel=$f -replace '\\','/'
    try{
      $entry=$zip.CreateEntry($rel,[IO.Compression.CompressionLevel]::Optimal).Open()
      $in=[IO.File]::OpenRead($src); $in.CopyTo($entry); $entry.Dispose(); $in.Dispose()
      $added++
    }catch{}
  } else { $miss++ }
}
$zip.Dispose(); $fs.Dispose()
$size=(Get-Item $out -ErrorAction SilentlyContinue).Length
if($added -gt 0 -and $size -gt 0){
  Write-Output ("ART_MIN={0} OK=YES SIZE={1} ADDED={2} MISS={3}" -f $out,$size,$added,$miss); exit 0
}else{
  Write-Output ("ART_MIN={0} OK=NO SIZE={1} ADDED={2} MISS={3}" -f $out,($size?$size:0),$added,$miss); exit 1
}
