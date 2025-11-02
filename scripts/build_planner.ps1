# C:\Users\DELL\Desktop\gw_stack\scripts\build_planner.ps1
param()

$ErrorActionPreference='SilentlyContinue'
$ProgressPreference   ='SilentlyContinue'

$root = 'C:\Users\DELL\Desktop\gw_stack'
$log  = Join-Path $root 'artifacts\PLANNER.BUILD.log'
New-Item -ItemType Directory -Force -Path (Split-Path $log) | Out-Null

# 0) Docker Engine hazır mı?
$dok=$false
try { & docker info *> $null; $dok = ($LASTEXITCODE -eq 0) } catch {}
if(-not $dok){
  $dd='C:\Program Files\Docker\Docker\Docker Desktop.exe'
  if(Test-Path $dd){ try{ Start-Process $dd | Out-Null }catch{} }
  $deadline=(Get-Date).AddMinutes(2)
  do{
    Start-Sleep -Milliseconds 500
    try{ & docker info *> $null; $dok = ($LASTEXITCODE -eq 0) }catch{ $dok=$false }
  } while(-not $dok -and (Get-Date) -lt $deadline)
}

# 1) Build
$build_ok=$false
try{
  & docker compose -f (Join-Path $root 'docker-compose.yml') build planner *> $null
  $build_ok = ($LASTEXITCODE -eq 0)
}catch{ $build_ok=$false }

# 2) Up
try{ & docker compose -f (Join-Path $root 'docker-compose.yml') up -d planner *> $null }catch{}

# 3) Container/port tespiti
$cid=''; try { $cid = (& docker ps --filter 'label=com.docker.compose.service=planner' -q) } catch {}
$hp=''; $status='down'; $health='none'; $exit='na'
if($cid){
  try{
    $j=(docker inspect $cid | ConvertFrom-Json)[0]
    $status = $j.State.Status
    if($j.State.Health){ $health = $j.State.Health.Status }
    $exit   = $j.State.ExitCode
    $ports  = $j.NetworkSettings.Ports
    if($ports.'9090/tcp'){ $hp = $ports.'9090/tcp'[0].HostPort }
    elseif($ports.'19090/tcp'){ $hp = $ports.'19090/tcp'[0].HostPort }
  }catch{}
}

# 4) Health bekleme
function H($u){ try{ (Invoke-WebRequest -UseBasicParsing -Method Head -Uri $u -TimeoutSec 6 -EA Stop).StatusCode }catch{ 0 } }
$h=0
if($hp){
  $deadline=(Get-Date).AddSeconds(60)
  do{
    $h = H ("http://127.0.0.1:$hp/health")
    Start-Sleep -Milliseconds 500
  } while(($h -ne 200) -and (Get-Date) -lt $deadline)
}else{
  # hostport bilinmiyorsa varsayılanı dene
  $deadline=(Get-Date).AddSeconds(30)
  do{
    $h = H 'http://127.0.0.1:19090/health'
    Start-Sleep -Milliseconds 500
  } while(($h -ne 200) -and (Get-Date) -lt $deadline)
}

# 5) Son 200 log satırı
try{
  if($cid){ (docker logs --tail 200 $cid) | Out-File -Encoding UTF8 -FilePath $log }
  else     { 'planner container not running' | Out-File -Encoding UTF8 -FilePath $log }
}catch{}

# 6) Tek satır çıktı
$hp_out = $(if($hp){$hp}else{'na'})
$line = if($h -eq 200){
  "BUILD PASS 19090=200 hostport=$hp_out build=$build_ok log=$log"
}else{
  "BUILD FAIL 19090=$h hostport=$hp_out status=$status health=$health exit=$exit build=$build_ok log=$log"
}
[Console]::Out.WriteLine($line)
