$ErrorActionPreference = 'SilentlyContinue'
$root = "C:\Users\DELL\Desktop\gw_stack"

# 1) Git yolunu detect_git.ps1 ile al
$det = & "$root\scripts\git\detect_git.ps1"
if ($LASTEXITCODE -ne 0 -or ($det -notlike 'GIT=*')) {
  Write-Output 'ERROR=GIT_NOT_FOUND'
  exit 1
}
$git = $det.Substring(4)

# 2) .git var mı
if (-not (Test-Path (Join-Path $root '.git'))) {
  Write-Output 'ERROR=NOT_A_REPO'
  exit 1
}

# 3) rev-parse ile teyit
$out = & "$git" -C $root rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -eq 0 -and ($out.Trim() -eq 'true')) {
  Write-Output 'GIT_REPO=OK'
  exit 0
} else {
  Write-Output 'ERROR=NOT_A_REPO'
  exit 1
}
