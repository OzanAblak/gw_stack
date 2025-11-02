$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$tag="v0.1.2-core"
$outDir=Join-Path $root "artifacts"
$stage=Join-Path $outDir "stage_core"
$out=Join-Path $outDir ("gw_stack_{0}.zip" -f $tag)
$want=@("docker-compose.yml","docker-compose.gateway.yml","infra","scripts","docs","docs\publish_checklist.md")

if(Test-Path $stage){ Remove-Item -Recurse -Force $stage 2>$null }
New-Item -ItemType Directory -Path $stage | Out-Null
if(!(Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }
if(Test-Path $out){ Remove-Item $out -Force 2>$null }

$copied=0; $miss=0
foreach($p in $want){
  $src = Join-Path $root $p
  if(Test-Path $src -PathType Leaf){
    $dst = Join-Path $stage $p
    New-Item -ItemType Directory -Path (Split-Path $dst) -Force | Out-Null
    Copy-Item $src $dst -Force -ErrorAction SilentlyContinue
    $copied++
  } elseif(Test-Path $src -PathType Container){
    $dst = Join-Path $stage $p
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
    & cmd /d /c robocopy "$src" "$dst" * /E /R:0 /W:0 /NFL /NDL /NJH /NJS /NP >NUL 2>NUL
    $copied++
  } else {
    $miss++
  }
}

$ok=$false
try{
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::CreateFromDirectory($stage,$out)
  $ok=$true
}catch{
  try{
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $out -Force -ErrorAction Stop
    $ok=$true
  }catch{}
}

$size=(Get-Item $out -ErrorAction SilentlyContinue).Length
$files=(Get-ChildItem -Recurse -File $stage -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Output ("ART={0} OK={1} SIZE={2} FILES={3} COPIED={4} MISS={5}" -f $out,($(if($ok){"YES"}else{"NO"})),($size?$size:0),($files?$files:0),$copied,$miss)
exit ($(if($ok){0}else{1}))
