$ErrorActionPreference='SilentlyContinue'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root="C:\Users\DELL\Desktop\gw_stack"
$src = Join-Path $root "scripts\ci_smoke_local.ps1"
$outDir = Join-Path $root "artifacts"
$out = Join-Path $outDir "zip_smoke.zip"
if(!(Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }
if(!(Test-Path $src)){ Write-Output "ZIP_SMOKE SRC_MISSING"; exit 1 }
try{
  if(Test-Path $out){ Remove-Item $out -Force 2>$null }
  $fs  = [IO.File]::Open($out,[IO.FileMode]::Create,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
  $zip = New-Object IO.Compression.ZipArchive($fs,[IO.Compression.ZipArchiveMode]::Create,$true)
  $entryStream = ($zip.CreateEntry("scripts/ci_smoke_local.ps1",[IO.Compression.CompressionLevel]::Optimal)).Open()
  $in = [IO.File]::OpenRead($src)
  $in.CopyTo($entryStream)
  $entryStream.Dispose(); $in.Dispose(); $zip.Dispose(); $fs.Dispose()
  $size=(Get-Item $out -ErrorAction SilentlyContinue).Length
  Write-Output ("ZIP_SMOKE OK SIZE={0}" -f ($size?$size:0))
  exit 0
}catch{
  $msg = ($_.Exception.Message -replace '\s+',' ')
  Write-Output ("ZIP_SMOKE ERR={0}" -f $msg.Substring(0,[Math]::Min(140,$msg.Length)))
  exit 1
}
