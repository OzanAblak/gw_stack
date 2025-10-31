$root="C:\Users\DELL\Desktop\gw_stack"
$out = & (Join-Path $PSScriptRoot "detect_git.ps1")
if ($LASTEXITCODE -ne 0 -or -not ($out -match '^GIT=(.+)$')) { Write-Output "ERROR=GIT_NOT_FOUND"; exit 1 }
$git=$Matches[1]
try {
  $branch = & $git -C $root rev-parse --abbrev-ref HEAD 2>$null
  $sha    = & $git -C $root rev-parse --short=7 HEAD 2>$null
  $tag    = & $git -C $root describe --tags --abbrev=0 2>$null
  if (-not $tag) { $tag="NONE" }
  Write-Output ("BRANCH={0} COMMIT={1} TAG={2}" -f $branch,$sha,$tag)
  exit 0
} catch {
  Write-Output "ERROR=GIT_STATUS_FAIL"
  exit 1
}
