$ErrorActionPreference='SilentlyContinue'
try{
  $r=Invoke-RestMethod -Method Post -Uri "http://localhost:19090/v1/plan/compile" -ContentType "application/json" -Body "{}" -TimeoutSec 8
  $pid=$r.planId
}catch{ $pid=$null }
if(-not $pid -or ($pid -notmatch '^[0-9a-fA-F-]{8,}$')){ Write-Output "E2E PID=NULL"; exit 1 }
$curl="$env:SystemRoot\System32\curl.exe"
$u="http://localhost:19090/v1/plan/$pid"
$code=0
for($i=0;$i -lt 60;$i++){
  $code=& $curl -s -m 5 -o NUL -w "%{http_code}" $u
  if($code -eq 200){ break }
  Start-Sleep -Milliseconds 300
}
Write-Output ("E2E PID={0} CODE={1}" -f $pid,$code)
exit ($(if($code -eq 200){0}else{1}))
