$root="C:\Users\DELL\Desktop\gw_stack"
if (Test-Path (Join-Path $root ".git")) { Write-Output "GIT_REPO=OK" } else { Write-Output "GIT_REPO=MISSING"; exit 1 }
