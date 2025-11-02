$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$tag="v0.1.2-core"
$outDir=Join-Path $root "artifacts"
$out=Join-Path $outDir ("gw_stack_{0}.zip" -f $tag)
if(!(Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }
if(Test-Path $out){ Remove-Item $out -Force 2>$null }

$want=@(
  "docker-compose.yml",
  "docker-compose.gateway.yml",
  "infra",
  "scripts",
  "docs\publish_checklist.md",
  "docs"
)

$have=@(); $skip=0
foreach($p in $want){
  $f=Join-Path $root $p
  if(Test-Path $f){ $have += $p } else { $skip++ }
}

if($have.Count -eq 0){ Write-Output ("ART={0} OK=NO ITEMS=0 SKIP={1}" -f $out,$skip); exit 1 }

# tar ile ziple: -C root + göreli yollar; stderr susturulur
& tar.exe -a -c -f $out -C $root @have 2>$null
$ok = (Test-Path $out)
$size = ($ok)? (Get-Item $out).Length : 0
Write-Output ("ART={0} OK={1} SIZE={2} ITEMS={3} SKIP={4}" -f $out,($(if($ok){"YES"}else{"NO"})),$size,$have.Count,$skip)
exit ($(if($ok){0}else{1}))
