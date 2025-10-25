$ErrorActionPreference="Stop"
function Out([string]$k,[string]$v){ Write-Output ("{0}={1}" -f $k,$v) }

# Port tespiti (fallback 8088)
$port=8088
try{
  $ps = docker compose ps --format json | ConvertFrom-Json
  $gw = $ps | Where-Object { $_.Service -eq "gateway" } | Select-Object -First 1
  if($gw -and $gw.Publishers){
    $pub = $gw.Publishers | Where-Object { $_.TargetPort -eq 80 } | Select-Object -First 1
    if($pub){ $port = [int]$pub.PublishedPort }
  }
} catch {}
Out "PORT" "$port"
$base = "http://127.0.0.1:$port"

# Health (retry)
$h= -1
for($i=1;$i -le 15;$i++){
  try{ $r=Invoke-WebRequest "$base/health" -TimeoutSec 3 -Method GET; $h=[int]$r.StatusCode } catch { $resp=$_.Exception.Response; $h=($resp ? [int]$resp.StatusCode : -1) }
  if($h -eq 200){ break }
  Start-Sleep -Milliseconds 300
}
Out "HEALTH" "$h"
if($h -ne 200){ Out "SUMMARY" "FAIL health=$h"; exit 1 }

# Compile
$PlanId=""
try{
  $c = Invoke-RestMethod "$base/v1/plan/compile" -Method POST -ContentType "application/json" -Body "{}"
  if($c.planId){ $PlanId = [string]$c.planId }
} catch {}
Out "PLANID" "$PlanId"
if(-not $PlanId){ Out "SUMMARY" "FAIL compile"; exit 1 }

# GET (retry)
$g= -1
$deadline=(Get-Date).AddSeconds(10)
while((Get-Date) -lt $deadline){
  try{ $resp=Invoke-WebRequest "$base/v1/plan/$PlanId" -Method GET -TimeoutSec 5; $g=[int]$resp.StatusCode } catch { $e=$_.Exception.Response; $g=($e ? [int]$e.StatusCode : -1) }
  if($g -eq 200){ break }
  Start-Sleep -Milliseconds 300
}
Out "GET" "$g"
if($g -ne 200){ Out "SUMMARY" "FAIL get=$g"; exit 1 }

Out "SUMMARY" "PASS"
