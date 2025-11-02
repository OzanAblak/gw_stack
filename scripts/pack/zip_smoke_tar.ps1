$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$src=Join-Path $root "scripts\ci_smoke_local.ps1"
$outDir=Join-Path $root "artifacts"
$out=Join-Path $outDir "zip_smoke.zip"
if(!(Test-Path $src)){ Write-Output "ZIP_SMOKE SRC_MISSING"; exit 1 }
if(!(Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }
if(Test-Path $out){ Remove-Item $out -Force 2>$null }
$tar=Join-Path $env:SystemRoot "System32\tar.exe"
& $tar -a -c -f $out -C $root "scripts\ci_smoke_local.ps1" 2>$null
if(Test-Path $out){ $s=(Get-Item $out).Length; Write-Output ("ZIP_SMOKE OK SIZE={0}" -f ($s?$s:0)); exit 0 } else { Write-Output "ZIP_SMOKE FAIL"; exit 1 }
