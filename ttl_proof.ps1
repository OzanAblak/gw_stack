param([int]$p=18088,[int]$ttlMin=5)
$log = Join-Path $PSScriptRoot "docs\project-log\2025-10-25-ttl.txt"
$enc = New-Object System.Text.UTF8Encoding($false)
function stamp($m){ [IO.File]::AppendAllText($log, ("[{0}] {1}`r`n" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $m), $enc) }
Remove-Item $log -ErrorAction SilentlyContinue
stamp "START ttl_proof PORT=$p TTL_MIN=$ttlMin"

$compile = (curl.exe -s -H "Content-Type: application/json" -d "{}" -X POST "http://localhost:$p/v1/plan/compile")
if(-not $compile){ stamp "ERR compile_empty"; exit 2 }
try { $planId = ($compile | ConvertFrom-Json).planId } catch { stamp "ERR compile_parse"; exit 2 }
stamp "PLANID=$planId"

$g0 = (curl.exe -s -o NUL -w "%{http_code}" "http://localhost:$p/v1/plan/$planId")
stamp "GET0=$g0"; if($g0 -ne "200"){ stamp "FAIL initial_get_$g0"; exit 3 }

$secs = ($ttlMin*60)+10
stamp "SLEEP=${secs}s"; Start-Sleep -Seconds $secs

$g1 = (curl.exe -s -o NUL -w "%{http_code}" "http://localhost:$p/v1/plan/$planId")
stamp "GET1=$g1"
if($g1 -eq "410"){ stamp "TTL_PROOF=PASS"; exit 0 } else { stamp "TTL_PROOF=FAIL"; exit 4 }