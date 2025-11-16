# scripts\push_checkpoint.ps1 — tek satır çıktı
param([string]$Branch="main",[string]$Message="docs: add checkpoint faz-22")
$ErrorActionPreference="Stop"; $ProgressPreference="SilentlyContinue"
$root="C:\Users\DELL\Desktop\gw_stack"; Set-Location $root
$dir=Join-Path $root "docs\faz-22"
if(-not (Test-Path $dir)){ Write-Output "PUSH_ERR_NOCHK_DIR"; exit 1 }
$latest = Get-ChildItem -Path $dir -Filter "checkpoint-*.md" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if(-not $latest){ Write-Output "PUSH_ERR_NOCHK_FILE"; exit 1 }
$rel = $latest.FullName.Replace($root+"\","")
git config --local core.safecrlf false 2>$null
git add -- $rel 1>$null 2>$null
$staged = (git diff --cached --name-only 2>$null)
if([string]::IsNullOrWhiteSpace($staged)){ Write-Output "PUSH_SKIP_NOCHANGE"; exit 0 }
git -c color.ui=false commit -m $Message 1>$null 2>$null
git push origin HEAD:$Branch 1>$null 2>$null
$sha = ((git rev-parse --short HEAD) 2>$null).Trim()
Write-Output ("PUSH_OK branch={0} sha={1} file={2}" -f $Branch,$sha,$rel)
