$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$logs = & docker compose -f (Join-Path $root 'docker-compose.yml') logs planner --tail 400 2>&1
if(-not $logs){ Write-Output "PLANNER_ERR=NO_LOGS"; exit 1 }
$hit = $logs | Select-String -Pattern 'Traceback|ERROR|Exception|KeyError|ValueError|TypeError|werkzeug|waitress' | Select-Object -Last 1
$line = if($hit){ $hit.Line } else { ($logs | Select-Object -Last 1) }
$one = ($line -replace '\s+',' ')
if($one.Length -gt 220){ $one=$one.Substring(0,220) }
Write-Output ("PLANNER_ERR " + $one)
