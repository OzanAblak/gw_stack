$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
function Code([string[]]$a){ & $curl @a }

# 1) compile → planId
$resp = & $curl -s -m 8 -H "Content-Type: application/json" -d "{}" http://localhost:19090/v1/plan/compile
try { $pid = ($resp | ConvertFrom-Json).planId } catch { $pid=$null }
if(-not $pid){ $m=[regex]::Match($resp,'\"planId\"\s*:\s*\"([^\"]+)\"'); if($m.Success){$pid=$m.Groups[1].Value} }
if(-not $pid){ Write-Output "MATRIX pid=NULL"; exit 1 }

$payload = "{`"planId`":`"$pid`"}"

# 2) denemeler
$tests=@(
  @{name="GET_PATH";    args=@("-s","-m","8","-o","NUL","-w","%{http_code}","http://localhost:19090/v1/plan/$pid") },
  @{name="GET_QID";     args=@("-s","-m","8","-o","NUL","-w","%{http_code}","http://localhost:19090/v1/plan?id=$pid") },
  @{name="GET_QPLANID"; args=@("-s","-m","8","-o","NUL","-w","%{http_code}","http://localhost:19090/v1/plan?planId=$pid") },
  @{name="POST_SLASH";  args=@("-s","-m","8","-o","NUL","-w","%{http_code}","-H","Content-Type: application/json","-d",$payload,"-X","POST","http://localhost:19090/v1/plan/") },
  @{name="POST_NOSL";   args=@("-s","-m","8","-o","NUL","-w","%{http_code}","-H","Content-Type: application/json","-d",$payload,"-X","POST","http://localhost:19090/v1/plan") }
)

$results=@()
foreach($t in $tests){
  $code = Code $t.args
  $results += ("{0}={1}" -f $t.name,$code)
}
Write-Output ("MATRIX pid={0} {1}" -f $pid, ($results -join " "))
