$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
function Http($u){ & $curl -s -m 5 -o NUL -w "%{http_code}" $u }

$h1 = Http "http://localhost:19090/health"
$h2 = Http "http://localhost:38888/health"

# compile: body + http_code ayrı satırlar
$raw = & $curl -s -m 8 -H "Content-Type: application/json" -d "{}" -w "`n%{http_code}" "http://localhost:19090/v1/plan/compile"
$parts = $raw -split "`r?`n"
$e2e = 0
$pid = $null
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
  } else {
    $e2e = 0
  }
}

if ($h1 -eq 200 -and $h2 -eq 200 -and $e2e -eq 200) {
  Write-Output "PASS 19090=200 38888=200 E2E=200"
  exit 0
} else {
  Write-Output ("FAIL H19090={0} H38888={1} E2E={2}" -f $h1,$h2,$e2e)
  exit 1
}
