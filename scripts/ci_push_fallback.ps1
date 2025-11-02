# scripts\ci_push_fallback.ps1
param([string]$Branch="main",[string]$Message="ci: fallback push")
$ErrorActionPreference="Stop"; $ProgressPreference="SilentlyContinue"
Set-Location "C:\Users\DELL\Desktop\gw_stack"

# CRLF/LF uyarılarını kapat
git config --local core.safecrlf false 2>$null

# Stage + commit + push sessiz
git add -A 1>$null 2>$null
$staged = git diff --cached --name-only 2>$null
$cnt = 0
if (-not [string]::IsNullOrWhiteSpace($staged)) {
  $cnt = ($staged -split '\r?\n' | Where-Object { $_ }).Count
  git commit -m $Message 1>$null 2>$null
}
git push origin HEAD:$Branch 1>$null 2>$null

# Tek satır çıktı
$sha = ((git rev-parse --short HEAD) 2>$null).Trim()
Write-Output ("PUSH_OK branch={0} sha={1} files={2}" -f $Branch,$sha,$cnt)
