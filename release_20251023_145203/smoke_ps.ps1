$ErrorActionPreference="Stop"
trap { Write-Output ("FAIL "+$_.Exception.Message); exit 9 }
$uG="http://127.0.0.1:8088/health"; $uP="http://127.0.0.1:9090/health"; $u="http://127.0.0.1:8088"
$r1=Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri $uG; if($r1.StatusCode -ne 200){exit 1}
$r2=Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri $uP; if($r2.StatusCode -ne 200){exit 2}
$id=(Invoke-RestMethod -Method Post -Uri "$u/v1/plan/compile" -TimeoutSec 8).planId
$r=Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri "$u/v1/plan/$id"; if($r.StatusCode -ne 200){exit 3}
$ct=$r.Headers["Content-Type"]; if($ct -notmatch "application/json"){exit 4}
Write-Output ("PASS smoke id="+$id+" CT="+$ct)
