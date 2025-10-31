$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$curl="$env:SystemRoot\System32\curl.exe"
# planId
$r=& $curl -s -m 8 -H "Content-Type: application/json" -d "{}" http://localhost:19090/v1/plan/compile
$pid=try{ ($r|ConvertFrom-Json).planId }catch{ $null }
if(-not $pid){ $m=[regex]::Match($r,'[0-9a-fA-F\-]{6,}'); if($m.Success){$pid=$m.Value} }
$payload="{`"planId`":`"$pid`"}"
# POST ve log çek
$code=& $curl -s -m 8 -o NUL -w "%{http_code}" -H "Content-Type: application/json" -d $payload -X POST http://localhost:19090/v1/plan/
Start-Sleep -Milliseconds 300
$logs=& docker compose -f (Join-Path $root 'docker-compose.yml') logs planner --since 3s 2>&1
$hit=$logs | Select-String -Pattern 'Traceback|ERROR|Exception|KeyError|TypeError|ValueError' | Select-Object -Last 1
$err=if($hit){$hit.Line}else{""}
$one=($err -replace '\s+',' ').Substring(0,[Math]::Min(220, [Math]::Max(0,($err -replace '\s+',' ').Length)))
Write-Output ("POSTLOG code={0} pid={1} err={2}" -f $code,($pid?$pid:"NULL"),$one)
