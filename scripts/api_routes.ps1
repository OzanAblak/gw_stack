$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
$urls=@(
  "http://localhost:19090/openapi.json",
  "http://localhost:19090/openapi",
  "http://localhost:19090/v1/openapi.json"
)
$json=""
foreach($u in $urls){
  $r=& $curl -s -m 5 $u
  if($r -and $r.Length -gt 0 -and $r -match "^\s*\{"){ $json=$r; break }
}
if(-not $json){ Write-Output "ROUTES=UNKNOWN"; exit 1 }
$paths = [regex]::Matches($json,'"\s*(/[^"]+)"\s*:\s*\{') | ForEach-Object {$_.Groups[1].Value}
$sel = $paths | Where-Object {$_ -like "*/v1/*plan*"}
if(-not $sel){ $sel = $paths | Where-Object {$_ -like "*/plan*"} }
$flat = ($sel | Select-Object -Unique) -join ","
if(-not $flat){ $flat="NONE" }
Write-Output ("ROUTES=" + $flat)
