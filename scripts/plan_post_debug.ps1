$ErrorActionPreference='SilentlyContinue'
function OneLine($s){ $t=($s -replace '\s+',' '); if($t.Length -gt 200){$t=$t.Substring(0,200)}; $t }

# 1) compile → planId
$pid=$null
try{
  $r=Invoke-RestMethod -Method Post -Uri "http://localhost:19090/v1/plan/compile" -ContentType "application/json" -Body "{}" -TimeoutSec 10
  $pid=$r.planId
}catch{
  $pid = ($_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue).planId
}
if(-not $pid){ Write-Output "POSTDBG pid=NULL"; exit 1 }

# 2) POST /v1/plan(/) {"planId":pid, "format":"json"}
$payload = @{ planId = "$pid"; format="json" } | ConvertTo-Json -Compress
$code=0; $body=""; $url1="http://localhost:19090/v1/plan/"; $url2="http://localhost:19090/v1/plan"
try{
  $resp = Invoke-RestMethod -Method Post -Uri $url1 -ContentType "application/json" -Body $payload -TimeoutSec 10 -ErrorAction Stop
  Write-Output ("POSTDBG pid={0} url={1} code=200 body={2}" -f $pid,$url1,(OneLine(($resp | ConvertTo-Json -Compress))))
  exit 0
}catch{
  try{ $code = $_.Exception.Response.StatusCode.value__ }catch{}
  try{
    $sr = New-Object IO.StreamReader $_.Exception.Response.GetResponseStream()
    $body = $sr.ReadToEnd()
  }catch{}
  if($code -eq 0 -and $body -eq ""){ Write-Output ("POSTDBG pid={0} url={1} code=0 body=" -f $pid,$url1); exit 1 }
  $b=OneLine($body)
  Write-Output ("POSTDBG pid={0} url={1} code={2} body={3}" -f $pid,$url1,$code,$b)
}

# 3) Noktasız URL fallback
try{
  $resp = Invoke-RestMethod -Method Post -Uri $url2 -ContentType "application/json" -Body $payload -TimeoutSec 10 -ErrorAction Stop
  Write-Output ("POSTDBG pid={0} url={1} code=200 body={2}" -f $pid,$url2,(OneLine(($resp | ConvertTo-Json -Compress))))
  exit 0
}catch{
  try{ $code = $_.Exception.Response.StatusCode.value__ }catch{}
  try{
    $sr = New-Object IO.StreamReader $_.Exception.Response.GetResponseStream()
    $body = $sr.ReadToEnd()
  }catch{}
  $b=OneLine($body)
  Write-Output ("POSTDBG pid={0} url={1} code={2} body={3}" -f $pid,$url2,$code,$b)
  exit 1
}
