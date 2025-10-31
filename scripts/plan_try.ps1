$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
function Code([string[]]$a){ & $curl @a }
function Snip($s){ $t=($s -replace '\s+',' '); if($t.Length -gt 140){$t=$t.Substring(0,140)}; $t }

# 1) compile → planId
$resp = & $curl -s -m 8 -H "Content-Type: application/json" -d "{}" http://localhost:19090/v1/plan/compile
try { $pid = ($resp | ConvertFrom-Json).planId } catch { $pid=$null }
if(-not $pid){ $m=[regex]::Match($resp,'\"planId\"\s*:\s*\"([^\"]+)\"'); if($m.Success){$pid=$m.Groups[1].Value} }
if(-not $pid){ Write-Output "TRY pid=NULL"; exit 1 }

$payload_json_planId = "{`"planId`":`"$pid`"}"
$payload_json_id     = "{`"id`":`"$pid`"}"
$payload_form_planId = "planId=$pid"
$payload_form_id     = "id=$pid"

$hosts=@("http://localhost:19090","http://localhost:38888")
$paths=@("/v1/plan","/v1/plan/")

$results=@()
foreach($h in $hosts){
  foreach($p in $paths){
    $url="$h$p"
    # GET queries
    $c1 = Code @("-s","-m","8","-o","NUL","-w","%{http_code}","$url`?planId=$pid")
    $c2 = Code @("-s","-m","8","-o","NUL","-w","%{http_code}","$url`?id=$pid")
    # POST json
    $c3 = Code @("-s","-m","8","-o","NUL","-w","%{http_code}","-H","Content-Type: application/json","-d",$payload_json_planId,"-X","POST",$url)
    $c4 = Code @("-s","-m","8","-o","NUL","-w","%{http_code}","-H","Content-Type: application/json","-d",$payload_json_id,"-X","POST",$url)
    # POST form
    $c5 = Code @("-s","-m","8","-o","NUL","-w","%{http_code}","-H","Content-Type: application/x-www-form-urlencoded","-d",$payload_form_planId,"-X","POST",$url)
    $c6 = Code @("-s","-m","8","-o","NUL","-w","%{http_code}","-H","Content-Type: application/x-www-form-urlencoded","-d",$payload_form_id,"-X","POST",$url)
    $results += ("{0}:{1} GET_planId={2} GET_id={3} POSTjson_planId={4} POSTjson_id={5} POSTform_planId={6} POSTform_id={7}" -f ($h -replace '^http://localhost:',''),$p,$c1,$c2,$c3,$c4,$c5,$c6)
  }
}

Write-Output ("TRY pid={0} {1}" -f $pid, ($results -join " | "))
