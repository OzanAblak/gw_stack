$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
function Code($u){ & $curl -s -m 5 -o NUL -w "%{http_code}" $u }
function Body($u){ (& $curl -s -m 5 $u) -replace '\s+',' ' }

# planId al
$resp = & $curl -s -m 8 -H "Content-Type: application/json" -d "{}" http://localhost:19090/v1/plan/compile
try { $pid = ($resp | ConvertFrom-Json).planId } catch { $pid=$null }
if(-not $pid){ $m=[regex]::Match($resp,'\"planId\"\s*:\s*\"([^\"]+)\"'); if($m.Success){$pid=$m.Groups[1].Value} }
if(-not $pid){ Write-Output "SCAN pid=NULL"; exit 1 }

$hosts=@("http://localhost:19090","http://localhost:38888")
$paths=@("/v1/plan/{0}","/v1/plan/{0}?format=json","/v1/plan?id={0}","/v1/plan?planId={0}","/v1/plans/{0}","/plan/{0}","/plans/{0}")

$items=@()
$hit=$false
foreach($h in $hosts){
  foreach($p in $paths){
    $u = $h + ($p -f $pid)
    $c = Code $u
    $items += ("{0}:{1}={2}" -f ($h -replace '^http://localhost:',''),$p,$c)
    if($c -ne 404){ $hit=$true; break }
  }
  if($hit){ break }
}

Write-Output ("SCAN pid={0} {1}" -f $pid, ($items -join " "))
