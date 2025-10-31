$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
$out = & (Join-Path $PSScriptRoot 'compile_uuid.ps1')
if(-not ($out -match '^PID=([0-9a-fA-F-]{36})$')){ Write-Output "E2E PID=NULL"; exit 1 }
$pid=$Matches[1]
function Code($u){ & $curl -s -m 8 -o NUL -w "%{http_code}" $u }
$urls=@(
  "http://localhost:19090/v1/plan/$pid",
  "http://localhost:19090/v1/plan/$pid?format=json",
  "http://localhost:38888/v1/plan/$pid",
  "http://localhost:38888/v1/plan/$pid?format=json"
)
$hit=""; $last=0
foreach($u in $urls){
  for($i=0;$i -lt 40;$i++){
    $c=Code $u
    if($c -eq 200){ $hit=$u; $last=200; break }
    $last=$c; Start-Sleep -Milliseconds 300
  }
  if($hit){ break }
}
if($hit){ Write-Output ("E2E url={0} code=200" -f $hit); exit 0 } else { Write-Output ("E2E NO200 last={0}" -f $last); exit 1 }

