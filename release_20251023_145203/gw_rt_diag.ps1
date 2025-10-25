$ErrorActionPreference="Stop"
function Fail([string]$m){ Write-Host "FAIL: $m"; exit 1 }
function Pass([string]$m){ Write-Host "PASS: $m" }
function Stat($arr){ $m=($arr|Measure-Object -Average -Maximum); return @{avg=[int]$m.Average; max=[int]$m.Maximum} }

# ENV
$base="http://127.0.0.1:8088"
Write-Host ("ENV: PSVersion={0}" -f $PSVersionTable.PSVersion)
Write-Host ("ENV: Now={0:o}" -f (Get-Date))

# Port owner
$owner="unknown"
try{
  $ln=Get-NetTCPConnection -LocalPort 8088 -State Listen -ErrorAction Stop
  $p=Get-Process -Id $ln.OwningProcess -ErrorAction Stop
  $owner=$p.ProcessName
  Write-Host ("OWNER: 8088 PID={0} Name={1}" -f $p.Id,$p.ProcessName)
}catch{
  $ns=netstat -ano | Select-String -Pattern "0\.0\.0\.0:8088|127\.0\.0\.1:8088"
  if($ns){ Write-Host "OWNER: 8088 listener (netstat)"; $owner="netstat" } else { Write-Host "OWNER: 8088 yok" }
}

# planner container
$ps=docker compose ps --format json | ConvertFrom-Json
$planner=($ps | Where-Object { $_.Service -eq "planner" } | Select-Object -First 1).Name
if(-not $planner){ Fail "planner container yok" }

# RT1: /health latency x10
$h=@()
for($i=1;$i -le 10;$i++){
  $sw=[Diagnostics.Stopwatch]::StartNew()
  try{ $r=Invoke-WebRequest -Uri "$base/health" -TimeoutSec 5 -Method GET }catch{ $sw.Stop(); Fail ("RT1 health hata: "+$_.Exception.Message) }
  $sw.Stop(); if($r.StatusCode -ne 200){ Fail ("RT1 health status "+$r.StatusCode) }
  $h+= [int]$sw.ElapsedMilliseconds
  Start-Sleep -Milliseconds 200
}
$s=Stat $h
Write-Host ("RT: health avg={0}ms max={1}ms ({2})" -f $s.avg,$s.max,($h -join ','))

# RT2: docker exec no-op x10
$d=@()
for($i=1;$i -le 10;$i++){
  $sw=[Diagnostics.Stopwatch]::StartNew()
  docker exec $planner sh -c "true" | Out-Null
  $sw.Stop(); $d+=[int]$sw.ElapsedMilliseconds
  Start-Sleep -Milliseconds 200
}
$s2=Stat $d
Write-Host ("RT: docker-exec avg={0}ms max={1}ms ({2})" -f $s2.avg,$s2.max,($d -join ','))

# RT3: host disk write/read 1 MiB
$buf = New-Object byte[] 1048576; (New-Object System.Random).NextBytes($buf)
$tmp=Join-Path $PWD "_iobench.bin"
$sw=[Diagnostics.Stopwatch]::StartNew(); [IO.File]::WriteAllBytes($tmp,$buf); $sw.Stop(); $w=[int]$sw.ElapsedMilliseconds
$sw=[Diagnostics.Stopwatch]::StartNew(); [void][IO.File]::ReadAllBytes($tmp); $sw.Stop(); $r=[int]$sw.ElapsedMilliseconds
Remove-Item $tmp -Force -ErrorAction SilentlyContinue
Write-Host ("RT: disk write={0}ms read={1}ms" -f $w,$r)

# RT4: docker compose ps overhead
$o=@()
for($i=1;$i -le 5;$i++){
  $sw=[Diagnostics.Stopwatch]::StartNew(); docker compose ps | Out-Null; $sw.Stop(); $o+=[int]$sw.ElapsedMilliseconds
}
$s4=Stat $o
Write-Host ("RT: compose-ps avg={0}ms max={1}ms ({2})" -f $s4.avg,$s4.max,($o -join ','))

# Basit eşiklerle PASS/FAIL
$bad=0
if($s.avg -gt 200 -or $s.max -gt 500){ Write-Host "FAIL: RT1 health yüksek"; $bad++ }
if($s2.avg -gt 800 -or $s2.max -gt 1500){ Write-Host "FAIL: RT2 docker-exec yüksek"; $bad++ }
if($w -gt 50 -or $r -gt 30){ Write-Host "FAIL: RT3 disk yavaş"; $bad++ }
if($s4.avg -gt 700 -or $s4.max -gt 1500){ Write-Host "FAIL: RT4 compose yavaş"; $bad++ }

if($bad -gt 0){ Fail "RT: eşik aşıldı ($bad)" } else { Pass "RT: tüm metrikler normal" }
