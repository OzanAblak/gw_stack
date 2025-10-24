param([int]$p=18088)

function Get-StatusCode($url){
  try { (Invoke-WebRequest -Uri $url -UseBasicParsing).StatusCode } catch {
    try { $_.Exception.Response.StatusCode.Value__ } catch { -1 }
  }
}

$H = Get-StatusCode ("http://127.0.0.1:{0}/health" -f $p)

$PLANID = $null
try {
  $PLANID = (Invoke-RestMethod -Uri ("http://127.0.0.1:{0}/v1/plan/compile" -f $p) -Method POST -ContentType 'application/json' -Body '{}').planId
} catch { $PLANID = $null }

if ($PLANID) { $G = Get-StatusCode ("http://127.0.0.1:{0}/v1/plan/{1}" -f $p,$PLANID) } else { $G = -1 }

$planOut = if ($PLANID) { $PLANID } else { 'n/a' }
$gOut    = if ($null -ne $G) { $G } else { 'n/a' }
$S = if (($H -eq 200) -and ($G -eq 200) -and $PLANID) { 'PASS' } else { 'FAIL' }

"{0} / {1} / {2} / {3} / {4}" -f $p,$H,$planOut,$gOut,$S