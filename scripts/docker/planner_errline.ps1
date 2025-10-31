$ErrorActionPreference='SilentlyContinue'
$pl = (& docker ps --format "{{.Names}}" 2>$null | Where-Object {$_ -match "planner"} | Select-Object -First 1)
if(-not $pl){ Write-Output "PLANNER_ERR=NO_CONTAINER"; exit 1 }
$logs = & docker logs --tail 400 $pl 2>&1
if(-not $logs){ Write-Output "PLANNER_ERR=NO_LOGS"; exit 1 }
$match = $logs | Select-String -Pattern 'Traceback|ERROR|Exception|KeyError|ValueError|TypeError|werkzeug|waitress' | Select-Object -Last 1
$line  = if($match){ $match.Line } else { ($logs | Select-Object -Last 1) }
$flat  = ($line -replace '\s+',' ')
if($flat.Length -gt 200){ $flat = $flat.Substring(0,200) }
Write-Output ("PLANNER_ERR " + $flat)
