$ErrorActionPreference = "Stop"

function Fail([string]$m){ Write-Host "FAIL: $m"; exit 1 }
function Pass([string]$m){ Write-Host "PASS: $m" }

# T0 — Stack up ve sağlık
docker compose up -d | Out-Null
$base = "http://127.0.0.1:8088"
$plan = "http://127.0.0.1:9090"

try {
  $g = Invoke-WebRequest "$base/health" -Method GET -TimeoutSec 10
  if($g.StatusCode -ne 200){ Fail "gateway /health $($g.StatusCode)" }
  $p = Invoke-WebRequest "$plan/health" -Method GET -TimeoutSec 10
  if($p.StatusCode -ne 200){ Fail "planner /health $($p.StatusCode)" }
  Pass "T0: gateway+planner health 200"
} catch { Fail $_ }

# T1 — Uzun TTL: 70 sn sonra GET 200 ve CT=json
try {
  $compile = Invoke-RestMethod "$base/v1/plan/compile" -Method POST -ContentType "application/json" -Body (@{} | ConvertTo-Json)
  if(-not $compile.planId){ Fail "planId yok (T1)" }
  $planId = $compile.planId
  Write-Host "T1 planId: $planId"
  Start-Sleep -Seconds 70
  $r = Invoke-WebRequest "$base/v1/plan/$planId" -Method GET -TimeoutSec 10
  if($r.StatusCode -ne 200){ Fail "T1 GET status $($r.StatusCode)" }
  $ct = $r.Headers["Content-Type"]
  if(-not $ct -or -not ($ct -like "application/json*")){ Fail "T1 CT=$ct" }
  Pass "T1: 70 sn sonra 200, CT=application/json"
} catch { Fail $_ }

# T2 — Cleaner TTL=0: dosya 30 sn içinde silinmeli
try {
  docker compose -f docker-compose.yml -f cleaner0.yml up -d cleaner | Out-Null
  $compile2 = Invoke-RestMethod "$base/v1/plan/compile" -Method POST -ContentType "application/json" -Body (@{} | ConvertTo-Json)
  if(-not $compile2.planId){ Fail "planId yok (T2)" }
  $planId2 = $compile2.planId
  Write-Host "T2 planId: $planId2"

  $ps = docker compose ps --format json | ConvertFrom-Json
  $plannerName = ($ps | Where-Object { $_.Service -eq "planner" } | Select-Object -First 1).Name
  if(-not $plannerName){ Fail "planner container bulunamadı" }

  $deadline = (Get-Date).AddSeconds(30)
  $removed = $false
  while((Get-Date) -lt $deadline){
    docker exec $plannerName sh -c "test -f /plans/$planId2.json"
    if($LASTEXITCODE -ne 0){ $removed = $true; break }
    Start-Sleep -Seconds 2
  }
  if(-not $removed){ Fail "T2: dosya 30 sn içinde silinmedi" }
  Pass "T2: CLEAN_TTL_MIN=0 ile dosya silindi"
} catch { Fail $_ }

Pass "TÜM GATE'LER PASS"
exit 0

