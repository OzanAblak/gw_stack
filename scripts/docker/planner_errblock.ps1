$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$logs = & docker compose -f (Join-Path $root 'docker-compose.yml') logs planner --since 30s 2>&1
if(-not $logs){ Write-Output "ERRBLOCK=NO_LOGS"; exit 1 }
$hit = $logs | Select-String -Pattern '"unhandled_exception"' | Select-Object -Last 1
if(-not $hit){ Write-Output "ERRBLOCK=NO_HIT"; exit 1 }
$line=$hit.Line
$err=[regex]::Match($line,'\"error\"\s*:\s*\"([^\"]+)\"').Groups[1].Value
$path=[regex]::Match($line,'\"path\"\s*:\s*\"([^\"]+)\"').Groups[1].Value
if(-not $err){ $err=$line }
$flat=(("{0} {1}" -f $path,$err) -replace '\s+',' ').Trim()
if($flat.Length -gt 240){ $flat=$flat.Substring(0,240) }
Write-Output ("ERRBLOCK " + $flat)
