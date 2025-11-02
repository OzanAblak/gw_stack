$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
function Http($u){ & $curl -s -m 5 -o NUL -w "%{http_code}" $u }

$h = Http "http://localhost:8088/health"

$raw = & $curl -s -m 8 -H "Content-Type: application/json" -d "{}" -w "`n%{http_code}" "http://localhost:8088/v1/plan/compile"
$parts = $raw -split "`r?`n"
$e2e = 0; $pid=$null
if ($parts.Length -ge 1) {
  $codeLine = $parts[-1].Trim()
  if ($codeLine -match '^\d+$') { $e2e = [int]$codeLine }
  if ($parts.Length -gt 1) {
    $body = ($parts[0..($parts.Length-2)] -join "`n")
    try { $pid = ($body | ConvertFrom-Json).planId } catch {}
    if(-not $pid){
      $m=[regex]::Match($body,'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}|^\d{2,}$')
      if($m.Success){ $pid=$m.Value }
    }
    if (-not $pid) { $e2e = 0 }
  } else { $e2e = 0 }
}

if ($h -eq 200 -and $e2e -eq 200) {
  Write-Output "GW_PASS 8088=200 E2E=200"
  exit 0
} else {
  Write-Output ("GW_FAIL 8088={0} E2E={1}" -f $h,$e2e)
  exit 1
}
