param()
$ErrorActionPreference="Stop"
$ps=docker compose ps --format json | ConvertFrom-Json
$gw=($ps | Where-Object { $_.Service -eq "gateway" } | Select-Object -First 1).Name
if(-not $gw){ throw "gateway container yok" }
$exists=(docker exec $gw sh -lc "test -f /var/log/nginx/access.log && echo yes || echo no").Trim()
if($exists -ne "yes"){ Write-Host "SKIP: access.log yok (stdout logging)"; exit 0 }
$ts=(Get-Date -Format yyyyMMddHHmmss)
docker exec $gw sh -lc "mv /var/log/nginx/access.log /var/log/nginx/access.log.$ts && nginx -s reopen" | Out-Null
$ok=(docker exec $gw sh -lc "test -f /var/log/nginx/access.log && echo ok || echo miss").Trim()
if($ok -ne "ok"){ throw "reopen başarısız" } else { Write-Host ("ROTATE OK "+$ts) }
