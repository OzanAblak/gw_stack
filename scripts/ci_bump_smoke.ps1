# scripts\ci_bump_smoke.ps1
param([string]$Branch="main")
$ErrorActionPreference="Stop"; $ProgressPreference="SilentlyContinue"
Set-Location "C:\Users\DELL\Desktop\gw_stack"
$p=".github\workflows\smoke.yml"
if(-not (Test-Path $p)){ Write-Output "ERR_NO_SMOKE_YML"; exit 1 }
$ts=[DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$c=[IO.File]::ReadAllText($p,[Text.UTF8Encoding]::new($false))
$marker="# ci-bump:"
$nl=[Environment]::NewLine
if($c -match '(?m)^# ci-bump:.*$'){
  $c=[Text.RegularExpressions.Regex]::Replace($c,'(?m)^# ci-bump:.*$',"$marker $ts")
}else{
  $c=$c.TrimEnd() + $nl + "$marker $ts" + $nl
}
[IO.File]::WriteAllText($p,$c,[Text.UTF8Encoding]::new($false))
git config --local core.safecrlf false 2>$null
git add $p 1>$null 2>$null
git commit -m "ci: smoke trigger bump $ts" 1>$null 2>$null
git push origin HEAD:$Branch 1>$null 2>$null
$sha=((git rev-parse --short HEAD) 2>$null).Trim()
Write-Output ("PUSH_OK branch={0} sha={1} files=1" -f $Branch,$sha)
