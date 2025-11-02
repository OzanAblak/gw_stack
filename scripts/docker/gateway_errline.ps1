$ErrorActionPreference='SilentlyContinue'
$gw = (& docker ps --format "{{.Names}}" 2>$null | Where-Object {$_ -match "gateway"} | Select-Object -First 1)
if(-not $gw){ Write-Output "GATEWAY_ERR=NO_CONTAINER"; exit 1 }
$logs = & docker logs --tail 400 $gw 2>&1
if(-not $logs){ Write-Output "GATEWAY_ERR=NO_LOGS"; exit 1 }
$hit = $logs | Select-String -Pattern 'emerg|alert|crit|error|warn|Traceback|Exception|Segmentation|bind\(|permission|refused' | Select-Object -First 1
$line = if($hit){ $hit.Line } else { ($logs | Select-Object -First 1) }
$one  = ($line -replace '\s+',' ')
if($one.Length -gt 220){ $one=$one.Substring(0,220) }
Write-Output ("GATEWAY_ERR " + $one)
