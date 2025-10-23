$ErrorActionPreference="Stop"
function Fail([string]$m){ Write-Host "FAIL: $m"; exit 1 }
function Pass([string]$m){ Write-Host "PASS: $m" }

$base="http://127.0.0.1:8088"

# -------- T3: Health watcher + /plans disk --------
try{
  $lat=@()
  for($i=1;$i -le 6;$i++){
    $sw=[Diagnostics.Stopwatch]::StartNew()
    $r=Invoke-WebRequest -Uri "$base/health" -TimeoutSec 5 -Method GET
    $sw.Stop()
    if($r.StatusCode -ne 200){ Fail(("T3 health {0}: {1}" -f $i,$r.StatusCode)) }
    $lat+= [int]$sw.ElapsedMilliseconds
    Start-Sleep -Seconds 10
  }

  $ps=docker compose ps --format json | ConvertFrom-Json
  $plannerName=($ps | Where-Object { $_.Service -eq "planner" } | Select-Object -First 1).Name
  if(-not $plannerName){ Fail "T3: planner container bulunamadı" }

  $pctTxt=(docker exec $plannerName sh -lc "df -P /plans | awk 'NR==2{print \$5}'").Trim()
  if(-not $pctTxt){ Fail "T3: df çıktısı boş" }
  $pct=[int]($pctTxt.TrimEnd('%'))
  if($pct -ge 90){ Fail "T3: /plans disk dolu ($pct%)" }

  $max=($lat | Measure-Object -Maximum).Maximum
  Write-Host ("T3 latency(ms): {0}" -f ($lat -join ', '))
  Pass ("T3: health 200 (6/6), max={0}ms, /plans={1}%%" -f $max,$pct)
} catch { Fail $_ }

# -------- T4: Port 8088 ve compose --------
try{
  $ln=$null
  try { $ln=Get-NetTCPConnection -LocalPort 8088 -State Listen -ErrorAction Stop } catch { $ln=$null }
  if(-not $ln){
    $ns=netstat -ano | Select-String -Pattern "0\.0\.0\.0:8088|127\.0\.0\.1:8088"
    if(-not $ns){ Fail "T4: 8088 dinleyen yok" } else { Write-Host "T4: 8088 listener bulundu (netstat)" }
  } else {
    $pid=$ln.OwningProcess
    $p=Get-Process -Id $pid -ErrorAction SilentlyContinue
    $name=$p.ProcessName
    Write-Host "T4: 8088 owner PID=$pid Name=$name"
    if($name -notmatch 'docker|com\.docker|docker-desktop|docker-proxy'){ Fail "T4: 8088 docker dışında ($name)" }
  }

  docker compose config | Out-Null
  $ps=docker compose ps --format json | ConvertFrom-Json
  $running=($ps | Where-Object { $_.State -match 'running' }).Count
  if($running -lt 3){ Fail "T4: running service < 3 ($running)" }

  Pass "T4: 8088 owner OK, compose OK, running=$running"
} catch { Fail $_ }

Pass "OPS GATE'LER PASS"
exit 0
