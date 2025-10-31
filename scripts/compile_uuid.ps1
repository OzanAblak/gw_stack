$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
$r=& $curl -s -m 8 -H "Content-Type: application/json" -H "Accept: application/json" -d "{}" http://localhost:19090/v1/plan/compile
$pid=$null
try{ $pid=($r|ConvertFrom-Json).planId }catch{}
if(-not $pid -or -not ($pid -match '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')){
  $m=[regex]::Match($r,'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}')
  if($m.Success){$pid=$m.Value}else{$pid=$null}
}
if($pid){Write-Output "PID=$pid";exit 0}else{Write-Output "PID=NULL";exit 1}
