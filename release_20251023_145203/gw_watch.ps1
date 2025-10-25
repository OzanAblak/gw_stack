$ErrorActionPreference="SilentlyContinue"
$log = Join-Path $PSScriptRoot "watch.log"
if(!(Test-Path $log)){ New-Item -Path $log -ItemType File -Force | Out-Null }

function Write-Log([string]$m){ $ts=Get-Date -Format o; "$ts $m" | Out-File -FilePath $log -Append -Encoding UTF8 }
function Ok([string]$m){ Write-Log ("PASS "+$m) }
function FailL([string]$m){ Write-Log ("FAIL "+$m); $script:hadFail=$true }

$hadFail=$false
$base="http://127.0.0.1:8088"

# Health
try{ $sw=[Diagnostics.Stopwatch]::StartNew(); $r=Invoke-WebRequest "$base/health" -TimeoutSec 5 -Method GET; $sw.Stop();
     if($r.StatusCode -ne 200){ FailL ("health="+$r.StatusCode) } else { Ok ("health=200 lat="+([int]$sw.ElapsedMilliseconds)+"ms") } }
catch{ FailL ("health err: "+$_.Exception.Message) }

# docker ps
try{ $ps=docker compose ps --format json | ConvertFrom-Json } catch{ $ps=$null; FailL "compose ps err" }
if($ps){
  $planner=($ps | Where-Object { $_.Service -eq "planner" } | Select-Object -First 1).Name
  if(!$planner){ FailL "planner yok" } else {
    try{
      # AWK YOK → tr+cut ile yüzde kolonu
      $pctTxt=(docker exec $planner sh -lc "df -P /plans | tail -n 1 | tr -s ' ' | cut -d' ' -f5").Trim()
      if(!$pctTxt){ FailL "df bos" } else { $pct=[int]($pctTxt.TrimEnd('%')); if($pct -ge 90){ FailL ("plans="+$pct+"%") } else { Ok ("plans="+$pct+"%") } }
    } catch{ FailL "df err" }
  }
  $running=($ps | Where-Object { $_.State -match 'running' }).Count
  if($running -lt 3){ FailL ("running<3 ("+$running+")") } else { Ok ("running="+$running) }
}

# 8088 owner (Docker Desktop WSL relay kabul)
try{
  $ln=Get-NetTCPConnection -LocalPort 8088 -State Listen -ErrorAction Stop
  $p=Get-Process -Id $ln.OwningProcess -ErrorAction SilentlyContinue
  $name=$p.ProcessName
  if($name -match 'docker|com\.docker|docker-desktop|docker-proxy|wslrelay|wslhost|vpnkit'){
    Ok ("8088 owner="+$name)
  } else {
    FailL ("8088 owner="+$name)
  }
} catch {
  $ns=netstat -ano | Select-String -Pattern "0\.0\.0\.0:8088|127\.0\.0\.1:8088"
  if(!$ns){ FailL "8088 yok" } else { Ok "8088 listener netstat" }
}

if($hadFail){ exit 1 } else { exit 0 }
