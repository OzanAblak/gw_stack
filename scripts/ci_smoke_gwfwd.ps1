$ErrorActionPreference = 'Stop'
function HttpCode([string]$u){ & (Get-Command curl.exe) -s -o NUL -w '%{http_code}' $u }

$h1 = HttpCode 'http://localhost:19090/health'
$h2 = HttpCode 'http://localhost:38888/health'

$resp   = & (Get-Command curl.exe) -s -H 'Content-Type: application/json' -d '{}' 'http://localhost:38888/v1/plan/compile'
try { $planId = (ConvertFrom-Json $resp).planId } catch { $planId = $null }
if(-not $planId){ $planId = [regex]::Match($resp, '"planId"\s*:\s*"([^"]+)"').Groups[1].Value }

$code = ''
for($i=0; $i -lt 30; $i++){
  $code = HttpCode ("http://localhost:38888/v1/plan/" + $planId)
  if($code -eq '200'){ break }
  Start-Sleep -Milliseconds 300
}

if($h1 -eq '200' -and $h2 -eq '200' -and $code -eq '200'){
  Write-Output 'PASS 19090=200 38888=200 E2E=200'
} else {
  Write-Output ('FAIL H19090='+$h1+' H38888='+$h2+' E2E='+$code)
}
