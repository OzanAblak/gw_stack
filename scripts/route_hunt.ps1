$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
function Code($u){ & $curl -s -L -m 5 -o NUL -w "%{http_code}" $u }
function Wait200($u,$n=40){ $last=0; for($i=0;$i -lt $n;$i++){ $c=Code $u; if($c -eq 200){return 200}; $last=$c; Start-Sleep -Milliseconds 300 }; return [int]$last }

# planId al
$resp = & $curl -s -m 8 -H "Content-Type: application/json" -d "{}" http://localhost:19090/v1/plan/compile
try { $pid = ($resp | ConvertFrom-Json).planId } catch { $pid=$null }
if(-not $pid){ $m=[regex]::Match($resp,'\"planId\"\s*:\s*\"([^\"]+)\"'); if($m.Success){$pid=$m.Groups[1].Value} }
if(-not $pid){ Write-Output "HUNT pid=NULL url=NONE code=0"; exit 1 }

$hosts=@("http://localhost:19090","http://localhost:38888")
$paths=@("/v1/plan/{0}","/v1/plans/{0}","/plan/{0}","/plans/{0}","/v1/plan?id={0}","/v1/plan?planId={0}")

foreach($h in $hosts){
  foreach($p in $paths){
    $u = $h + ($p -f $pid)
    $c = Wait200 $u 60
    if($c -eq 200){ Write-Output ("HUNT pid={0} url={1} code=200" -f $pid,$u); exit 0 }
  }
}

Write-Output ("HUNT pid={0} url=NONE code=404" -f $pid); exit 1
