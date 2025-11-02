# C:\Users\DELL\Desktop\gw_stack\scripts\state_dump.ps1
param()

$ErrorActionPreference='SilentlyContinue'
$ProgressPreference   ='SilentlyContinue'

$root = 'C:\Users\DELL\Desktop\gw_stack'
$outd = Join-Path $root 'artifacts\STATE_DUMP'
New-Item -ItemType Directory -Force -Path $outd | Out-Null

function Save($p,$c){ [IO.File]::WriteAllText($p,$c,[Text.Encoding]::UTF8) }

# Docker engine var mı?
$dok=0; try{ & docker info *> $null; if($LASTEXITCODE -eq 0){$dok=1} }catch{}
Save (Join-Path $outd 'docker_available.txt') ("docker_engine="+$dok)

# docker info / ps
try{ (& docker info) | Out-File -Encoding UTF8 -FilePath (Join-Path $outd 'docker_info.txt') }catch{}
try{ (& docker ps -a) | Out-File -Encoding UTF8 -FilePath (Join-Path $outd 'docker_ps-a.txt') }catch{}

# compose config (varsa)
try{ (& docker compose -f (Join-Path $root 'docker-compose.yml') config) | Out-File -Encoding UTF8 -FilePath (Join-Path $outd 'compose_config.yml') }catch{}

# planner inspect/logs
$pl=''; try{ $pl = (& docker ps -a --filter 'label=com.docker.compose.service=planner' -q | Select-Object -First 1) }catch{}
if($pl){
  try{ (& docker inspect $pl) | Out-File -Encoding UTF8 -FilePath (Join-Path $outd 'planner_inspect.json') }catch{}
  try{ (& docker logs --tail 200 $pl) | Out-File -Encoding UTF8 -FilePath (Join-Path $outd 'planner_logs.txt') }catch{}
}

# gateway inspect/logs
$gw=''; try{ $gw = (& docker ps -a --filter 'label=com.docker.compose.service=gateway' -q | Select-Object -First 1) }catch{}
if($gw){
  try{ (& docker inspect $gw) | Out-File -Encoding UTF8 -FilePath (Join-Path $outd 'gateway_inspect.json') }catch{}
  try{ (& docker logs --tail 200 $gw) | Out-File -Encoding UTF8 -FilePath (Join-Path $outd 'gateway_logs.txt') }catch{}
}

# portlar
try{
  $ports=@()
  $ports += '---- netstat -ano ----'
  $ports += (netstat -ano)
  $ports += ''
  $ports += '---- Get-NetTCPConnection (best effort) ----'
  $g=@(); try{ $g = Get-NetTCPConnection | ? { $_.LocalPort -in 19090,38888,8088 } | Select-Object LocalAddress,LocalPort,State,OwningProcess }catch{}
  $ports += ($g | Out-String)
  Save (Join-Path $outd 'ports.txt') ($ports -join \"`r`n\")
}catch{}

# dosya varlık kontrolü
$items=@('planner\Dockerfile','planner\app.py','docker-compose.yml','docker-compose.gateway.yml','infra\gateway\default.conf','scripts\ci_smoke_local.ps1','scripts\docker\ci_smoke_gateway.ps1','scripts\build_planner.ps1','scripts\repair_planner.ps1')
$lines=@()
foreach($rel in $items){
  $abs=Join-Path $root $rel
  $lines += ('{0} | {1} | {2}' -f $rel, (Test-Path $abs), $abs)
}
Save (Join-Path $outd 'files.txt') ($lines -join \"`r`n\")

# planner durumu/port çıkarımı
$hp=''; $pl_status='down'; $pl_health='na'; $pl_exit='na'
if($pl){
  try{
    $j=(docker inspect $pl | ConvertFrom-Json)[0]
    $pl_status=$j.State.Status
    if($j.State.Health){ $pl_health=$j.State.Health.Status }
    $pl_exit=$j.State.ExitCode
    $p=$j.NetworkSettings.Ports
    if($p.'9090/tcp'){ $hp=$p.'9090/tcp'[0].HostPort }
    elseif($p.'19090/tcp'){ $hp=$p.'19090/tcp'[0].HostPort }
  }catch{}
}

# health denemeleri
function H($u){ try{ (Invoke-WebRequest -UseBasicParsing -Method Head -Uri $u -TimeoutSec 5 -EA Stop).StatusCode }catch{ 0 } }
$h19090 = if($hp){ H (\"http://127.0.0.1:$hp/health\") } else { H 'http://127.0.0.1:19090/health' }
$h38888 = H 'http://127.0.0.1:38888/health'
$h8088  = H 'http://127.0.0.1:8088/health'

# özet
$summary = \"STATE docker=$dok pl_status=$pl_status pl_health=$pl_health pl_exit=$pl_exit h19090=$h19090 h38888=$h38888 h8088=$h8088 out=$outd\"
Save (Join-Path $outd 'SUMMARY.txt') $summary
[Console]::Out.WriteLine($summary)
