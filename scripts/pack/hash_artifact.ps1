$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$art=Join-Path $root "artifacts\gw_stack_v0.1.2-core.zip"
if(!(Test-Path $art)){ Write-Output "ART_HASH=MISSING"; exit 1 }
$h=(Get-FileHash -Algorithm SHA256 -Path $art).Hash.ToLower()
$s=(Get-Item $art).Length
Write-Output ("ART_HASH={0} SIZE={1}" -f $h,$s)
