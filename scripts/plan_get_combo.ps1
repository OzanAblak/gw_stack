$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
function Code([string[]]$a){ & $curl @a }

# compile → planId
$resp = & $curl -s -m 8 -H "Content-Type: application/json" -d "{}" http://localhost:19090/v1/plan/compile
try { $pid = ($resp | ConvertFrom-Json).planId } catch { $pid=$null }
if(-not $pid){ $m=[regex]::Match($resp,'\"planId\"\s*:\s*\"([^\"]+)\"'); if($m.Success){$pid=$m.Groups[1].Value} }
if(-not $pid){ Write-Output "COMBO pid=NULL"; exit 1 }

$urls=@(
  "http://localhost:19090/v1/plan/$pid",
  "http://localhost:19090/v1/plan/$pid/",
  "http://localhost:19090/v1/plan/$pid?format=html",
  "http://localhost:19090/v1/plan/$pid?format=json"
)

$results=@()
foreach($u in $urls){
  $g1 = Code @("-s","-m","8","-o","NUL","-w","%{http_code}", $u)
  $g2 = Code @("-s","-m","8","-o","NUL","-w","%{http_code}","-H","Accept: text/html", $u)
  $p1 = Code @("-s","-m","8","-o","NUL","-w","%{http_code}","-H","Content-Type: application/json","-d","{`"planId`":`"$pid`"}","-X","POST", $u)
  $results += ("{0}=GET:{1}|GEThtml:{2}|POSTjson:{3}" -f ($u -replace '^http://localhost:',''),$g1,$g2,$p1)
}
Write-Output ("COMBO pid={0} {1}" -f $pid, ($results -join " ; "))
