# C:\Users\DELL\Desktop\gw_stack\scripts\repair_planner.ps1
param()

$ErrorActionPreference='SilentlyContinue'
$ProgressPreference   ='SilentlyContinue'

$root = 'C:\Users\DELL\Desktop\gw_stack'

# 1) Docker motoru hazır mı?
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

# 2) planner'ı ayağa kaldır
try{ & docker compose -f (Join-Path $root 'docker-compose.yml') up -d planner *> $null }catch{}

# 3) planner container ve host port'unu bul
$pl=''; try { $pl = (& docker ps --filter 'label=com.docker.compose.service=planner' -q) } catch {}
if(-not $pl){ [Console]::Out.WriteLine('PL FAIL 19090=0 NOTE=container_not_found'); exit 0 }

$hp = 19090
try{
  $j = (docker inspect $pl | ConvertFrom-Json)[0]
  $ports = $j.NetworkSettings.Ports
  if($ports.'9090/tcp'){ $hp = [int]$ports.'9090/tcp'[0].HostPort }
}catch{}

# 4) Health bekle
function H($url){ try{ (Invoke-WebRequest -UseBasicParsing -Method Head -Uri $url -TimeoutSec 5 -EA Stop).StatusCode }catch{ 0 } }
$deadline=(Get-Date).AddSeconds(60)
do{
  $h = H ("http://127.0.0.1:$hp/health")
  Start-Sleep -Milliseconds 500
} while(($h -ne 200) -and (Get-Date) -lt $deadline)

# 5) Tek satır sonuç (+ dosyaya yaz)
$line = if($h -eq 200){ "PL PASS 19090=$h" } else { "PL FAIL 19090=$h" }
$mark = Join-Path $root 'artifacts\REPAIR_PLANNER.LAST.txt'
New-Item -ItemType Directory -Force -Path (Split-Path $mark) | Out-Null
[IO.File]::WriteAllText($mark,$line,[Text.Encoding]::ASCII)
[Console]::Out.WriteLine($line)
