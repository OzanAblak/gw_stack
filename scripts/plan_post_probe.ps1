$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
function CodeBody($args){ $r=& $curl @args; $r2=$r -replace '\s+',' '; if($r2.Length -gt 200){$r2=$r2.Substring(0,200)}; return $r2 }
# planId al
$resp = & $curl -s -m 8 -H "Content-Type: application/json" -d "{}" http://localhost:19090/v1/plan/compile
try { $pid = ($resp | ConvertFrom-Json).planId } catch { $pid=$null }
if(-not $pid){ $m=[regex]::Match($resp,'\"planId\"\s*:\s*\"([^\"]+)\"'); if($m.Success){$pid=$m.Groups[1].Value} }
if(-not $pid){ Write-Output "POSTPROBE pid=NULL"; exit 1 }
$payload = "{`"planId`":`"$pid`",`"format`":`"json`"}"
# 19090
$c1 = & $curl -s -m 10 -o NUL -w "%{http_code}" -H "Content-Type: application/json" -H "Accept: application/json" -d $payload -X POST "http://localhost:19090/v1/plan/"
$b1 = CodeBody @("-s","-m","10","-H","Content-Type: application/json","-H","Accept: application/json","-d",$payload,"-X","POST","http://localhost:19090/v1/plan/")
# 38888
$c2 = & $curl -s -m 10 -o NUL -w "%{http_code}" -H "Content-Type: application/json" -H "Accept: application/json" -d $payload -X POST "http://localhost:38888/v1/plan/"
$b2 = CodeBody @("-s","-m","10","-H","Content-Type: application/json","-H","Accept: application/json","-d",$payload,"-X","POST","http://localhost:38888/v1/plan/")
Write-Output ("POSTPROBE pid={0} 19090={1} body={2} 38888={3} body={4}" -f $pid,$c1,$b1,$c2,$b2)
