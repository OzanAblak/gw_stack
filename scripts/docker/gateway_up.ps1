$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$file=Join-Path $root 'docker-compose.gateway.yml'
if(!(Test-Path $file)){ Write-Output "GW_UP=NO_FILE"; exit 1 }
if(-not (Get-Command docker -ErrorAction SilentlyContinue)){ Write-Output "GW_UP=DOCKER_MISSING"; exit 1 }
$curl=Join-Path $env:SystemRoot 'System32\curl.exe'
if(!(Test-Path $curl)){ Write-Output "GW_UP=CURL_MISSING"; exit 1 }

# up -d gateway
& docker compose -f $file up -d gateway 2>$null | Out-Null

# health bekle
function Code($u){ & $curl -s -m 5 -o NUL -w "%{http_code}" $u }
$code=0
for($i=0;$i -lt 40;$i++){
  $code=Code "http://localhost:8088/health"
  if($code -eq 200){ break }
  Start-Sleep -Milliseconds 300
}

Write-Output ("GW_UP 8088={0}" -f $code)
exit ($(if($code -eq 200){0}else{1}))
