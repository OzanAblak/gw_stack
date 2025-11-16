$ErrorActionPreference='SilentlyContinue'
$ProgressPreference='SilentlyContinue'
$root='C:\Users\DELL\Desktop\gw_stack'
Set-Location $root

if(-not (Get-Command git -ErrorAction SilentlyContinue)){
  Write-Output 'GDIAG=ERR_NO_GIT'; exit
}

if(-not (Test-Path (Join-Path $root '.git'))){
  Write-Output 'GDIAG=ERR_NOT_REPO'; exit
}

$br = (& git rev-parse --abbrev-ref HEAD 2>$null).Trim()
$auth='OK'
$null = & git ls-remote --heads origin main *> $null
if($LASTEXITCODE -ne 0){ $auth='FAIL' }

Write-Output ('GDIAG=BR:{0} AUTH:{1}' -f $br,$auth)
