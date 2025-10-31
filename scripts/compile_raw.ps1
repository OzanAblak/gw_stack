$ErrorActionPreference='SilentlyContinue'
$u='http://localhost:19090/v1/plan/compile'
$r = & $env:SystemRoot\System32\curl.exe -s -m 8 -H 'Content-Type: application/json' -H 'Accept: application/json' -d '{}' $u
$s = ($r -replace '\s+',' ')
if ($s.Length -gt 400) { $s = $s.Substring(0,400) }
Write-Output ("RAW " + $s)
