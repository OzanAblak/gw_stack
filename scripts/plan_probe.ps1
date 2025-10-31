$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
function HttpCode($u){ & $curl -s -m 5 -o NUL -w "%{http_code}" $u }

$h1 = HttpCode "http://localhost:19090/health"
$h2 = HttpCode "http://localhost:38888/health"

$resp = & $curl -s -m 8 -H "Content-Type: application/json" -d "{}" http://localhost:19090/v1/plan/compile
try { $pid = ($resp | ConvertFrom-Json).planId } catch { $pid=$null }
if (-not $pid) { $m=[regex]::Match($resp,'\"planId\"\s*:\s*\"([^\"]+)\"'); if($m.Success){$pid=$m.Groups[1].Value} }

$path   = if ($pid){ HttpCode ("http://localhost:19090/v1/plan/{0}" -f $pid) } else { 0 }
$pathf  = if ($pid){ HttpCode ("http://localhost:19090/v1/plan/{0}?format=json" -f $pid) } else { 0 }
$qid    = if ($pid){ HttpCode ("http://localhost:19090/v1/plan?id={0}" -f $pid) } else { 0 }
$qplan  = if ($pid){ HttpCode ("http://localhost:19090/v1/plan?planId={0}" -f $pid) } else { 0 }

if (-not $pid) { $pid="NULL" }
Write-Output ("PROBE H19090={0} H38888={1} PID={2} PATH={3} PATHFMT={4} QID={5} QPLANID={6}" -f $h1,$h2,$pid,$path,$pathf,$qid,$qplan)
