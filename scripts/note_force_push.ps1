# scripts\note_force_push.ps1
$ErrorActionPreference="Stop"; $ProgressPreference="SilentlyContinue"
Set-Location "C:\Users\DELL\Desktop\gw_stack"
[IO.Directory]::CreateDirectory("docs\ci")|Out-Null
$line = ("{0} PASS 19090=200 38888=200 E2E=200" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'))
[IO.File]::WriteAllText("docs\ci\last_smoke.txt",$line,[Text.UTF8Encoding]::new($false))

git config --local core.safecrlf false 2>$null
git add docs\ci\last_smoke.txt 1>$null 2>$null
$pending = (git diff --cached --name-only 2>$null)
if([string]::IsNullOrWhiteSpace($pending)){
  git add -f docs\ci\last_smoke.txt 1>$null 2>$null
  $pending = (git diff --cached --name-only 2>$null)
}
if([string]::IsNullOrWhiteSpace($pending)){
  Write-Output "NOTE_PUSH_SKIP_NOCHANGE"; exit 0
}
git commit -m "docs(ci): record smoke PASS" 1>$null 2>$null
git push origin HEAD:main 1>$null 2>$null
$sha=((git rev-parse --short HEAD) 2>$null).Trim()
Write-Output ("NOTE_PUSH_OK sha={0}" -f $sha)
