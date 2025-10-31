$ErrorActionPreference='SilentlyContinue'
$pl = (& docker ps --format "{{.Names}}" 2>$null | Where-Object {$_ -match "planner"} | Select-Object -First 1)
if(-not $pl){ Write-Output "OPENAPI=NO_CONTAINER"; exit 1 }
$py = "import json,urllib.request;print(','.join(sorted(json.loads(urllib.request.urlopen('http://localhost:9090/openapi.json',timeout=3).read().decode()).get('paths',{}).keys())))"
$out = & docker exec $pl python -c "$py" 2>$null
if(-not $out){ $out = & docker exec $pl python3 -c "$py" 2>$null }
if(-not $out){ Write-Output "OPENAPI=NONE"; exit 1 }
$flat = ($out -replace '\s+',' ')
Write-Output ("OPENAPI=" + $flat)
