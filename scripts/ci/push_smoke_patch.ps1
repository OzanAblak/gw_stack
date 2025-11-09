# scripts\ci\push_smoke_patch.ps1
$ErrorActionPreference='SilentlyContinue'
$ProgressPreference='SilentlyContinue'
$root='C:\Users\DELL\Desktop\gw_stack'
Set-Location $root

# Git kontrol
if(-not (Get-Command git -ErrorAction SilentlyContinue)){
  Write-Output 'PUSH=ERR_GIT_NOT_FOUND'; exit 0
}

# Sessiz add/commit/push, tek satır çıktı
git add .github/workflows/smoke.yml *> $null
$chg = (git status --porcelain .github/workflows/smoke.yml)
if(-not $chg){ Write-Output 'PUSH=SKIP_NO_CHANGE'; exit 0 }

git commit -m "ci(smoke): add artifact packaging" *> $null
git push origin main *> $null
if($LASTEXITCODE -eq 0){ 'PUSH=OK' } else { 'PUSH=ERR' }
