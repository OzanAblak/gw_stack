# C:\Users\DELL\Desktop\gw_stack\scripts\diag_planner.ps1
param()

$ErrorActionPreference='SilentlyContinue'
$ProgressPreference   ='SilentlyContinue'

$root = 'C:\Users\DELL\Desktop\gw_stack'
$log  = Join-Path $root 'artifacts\PLANNER.DIAG.log'
New-Item -ItemType Directory -Force -Path (Split-Path $log) | Out-Null

# 1) Planner container ID
$cid=''; try { $cid = (docker ps --filter 'label=com.docker.compose.service=planner' -q) } catch {}
if(-not $cid){
  [IO.File]::WriteAllText($log,'planner container not running',[Text.Encoding]::UTF8)
  [Console]::Out.WriteLine('PL DIAG status=down health=na exit=na hostport=na hcode=0 log='+$log)
  exit 0
}

# 2) Inspect
$status='?'; $health='none'; $exit='?'; $hp=''; $image=''
try {
  $j=(docker inspect $cid | ConvertFrom-Json)[0]
  $status = $j.State.Status
  if($j.State.Health){ $health = $j.State.Health.Status }
  $exit   = $j.State.ExitCode
  $image  = $j.Config.Image
  $ports  = $j.NetworkSettings.Ports
  if($ports.'9090/tcp'){ $hp = $ports.'9090/tcp'[0].HostPort }
  elseif($ports.'19090/tcp'){ $hp = $ports.'19090/tcp'[0].HostPort }
} catch {}

# 3) Son loglar
try { (docker logs --tail 200 $cid) | Out-File -Encoding UTF8 -FilePath $log } catch {}

# 4) Health denemesi
function H($u){ try{ (Invoke-WebRequest -UseBasicParsing -Method Head -Uri $u -TimeoutSec 4 -EA Stop).StatusCode }catch{ 0 } }
$hcode=0
if($hp){ $hcode = H ('http://127.0.0.1:'+ $hp +'/health') } else { $hcode = H 'http://127.0.0.1:19090/health' }

# 5) Tek satır özet
$line=('PL DIAG status={0} health={1} exit={2} hostport={3} hcode={4} log={5}' -f $status,$health,$exit,($(if($hp){$hp}else{'na'})),$hcode,$log)
[Console]::Out.WriteLine($line)
