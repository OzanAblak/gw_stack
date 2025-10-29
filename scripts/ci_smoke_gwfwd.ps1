Param([string]$HostBase="http://localhost")
function Resolve-Curl {
  $p1=Join-Path $env:WINDIR 'Sysnative\curl.exe'
  $p2=Join-Path $env:WINDIR 'System32\curl.exe'
  if (Test-Path $p1) { return $p1 }
  elseif (Test-Path $p2) { return $p2 }
  else { return $null }
}
$CURL = Resolve-Curl

function HttpCode([string]$u){
  if($CURL){
    try { [int](& $CURL -s -o NUL -w "%{http_code}" $u) } catch { 0 }
  } else {
    try {
      $req=[System.Net.WebRequest]::Create($u); $req.Method="GET"; $req.Timeout=5000
      $resp=[System.Net.HttpWebResponse]$req.GetResponse()
      [int]$resp.StatusCode
    } catch [System.Net.WebException] {
      if ($_.Exception.Response){ [int]([System.Net.HttpWebResponse]$_.Exception.Response).StatusCode } else { 0 }
    }
  }
}

$h1=HttpCode("$HostBase:19090/health")
$h2=HttpCode("$HostBase:38888/health")

$id=$null
if($CURL){
  try{
    $resp=& $CURL -s -H "Content-Type: application/json" -d "{}" "$HostBase:38888/v1/plan/compile"
    $m=[regex]::Match($resp,'"(?:id|planId)"\s*:\s*"([^"]+)"')
    if($m.Success){ $id=$m.Groups[1].Value }
  }catch{ $id=$null }
}else{
  try{
    $req=[System.Net.WebRequest]::Create("$HostBase:38888/v1/plan/compile"); $req.Method="POST"; $req.ContentType="application/json"
    $bytes=[Text.Encoding]::UTF8.GetBytes("{}"); $req.ContentLength=$bytes.Length
    $s=$req.GetRequestStream(); $s.Write($bytes,0,$bytes.Length); $s.Close()
    $resp=[System.Net.HttpWebResponse]$req.GetResponse()
    $txt=(New-Object IO.StreamReader($resp.GetResponseStream())).ReadToEnd()
    $m=[regex]::Match($txt,'"(?:id|planId)"\s*:\s*"([^"]+)"')
    if($m.Success){ $id=$m.Groups[1].Value }
  }catch{ $id=$null }
}

$g=0
if($id){ for($i=0;$i -lt 30 -and $g -ne 200;$i++){ Start-Sleep -Milliseconds 200; $g=HttpCode("$HostBase:38888/v1/plan/$id") } }

"SMOKE=$h1,$h2,$g"
if($h1 -eq 200 -and $h2 -eq 200 -and $g -eq 200){ exit 0 } else { exit 2 }
