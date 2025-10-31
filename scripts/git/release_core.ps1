$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$det = & (Join-Path $root 'scripts\git\detect_git.ps1')
if(-not ($det -match '^GIT=(.+)$')){ Write-Output "GIT_COMMIT ERROR=GIT_NOT_FOUND"; exit 1 }
$git=$Matches[1]

$outDir=Join-Path $root 'out'
if(-not (Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }

$sm = & (Join-Path $root 'scripts\ci_smoke_local.ps1')
$sm = ($sm -replace '\s+',' ').Trim()
Set-Content -Path (Join-Path $outDir 'ci_smoke.txt') -Value $sm -NoNewline

$un=& $git -C $root config user.name 2>$null
$ue=& $git -C $root config user.email 2>$null
if(-not $un){ & $git -C $root config user.name "gw-bot" | Out-Null }
if(-not $ue){ & $git -C $root config user.email "gw-bot@example.local" | Out-Null }

& $git -C $root add -A | Out-Null
$diff=& $git -C $root status --porcelain
$committed="SKIP"
if($diff){
  $msg="chore(ci): local smoke -> $sm"
  & $git -C $root commit -m $msg 2>$null | Out-Null
  $committed="OK"
}

$sha=& $git -C $root rev-parse --short=7 HEAD 2>$null
$tag="v0.1.2-core"
$hasTag=& $git -C $root rev-parse -q --verify "refs/tags/$tag" 2>$null
if(-not $hasTag){ & $git -C $root tag -a $tag -m "core line release" 2>$null }

$push="FAIL"
try{
  & $git -C $root push origin HEAD 2>$null | Out-Null
  & $git -C $root push origin $tag 2>$null | Out-Null
  $push="OK"
}catch{}

Write-Output ("GIT_COMMIT COMMIT={0} SHA={1} TAG={2} PUSH={3} SMOKE={4}" -f $committed,$sha,$tag,$push,$sm)
exit 0
