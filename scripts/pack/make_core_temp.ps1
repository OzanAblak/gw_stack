$ErrorActionPreference='SilentlyContinue'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root="C:\Users\DELL\Desktop\gw_stack"
$tag="v0.1.2-core"
$outDir=Join-Path $root "artifacts"
$tmp=[IO.Path]::GetTempPath()
$stage=Join-Path $tmp "gw_core_stage"
$tmpZip=Join-Path $tmp ("gw_stack_{0}.zip" -f $tag)
$final=Join-Path $outDir ("gw_stack_{0}.zip" -f $tag)
$want=@("docker-compose.yml","docker-compose.gateway.yml","infra","scripts","docs","docs\publish_checklist.md")

if(Test-Path $stage){ Remove-Item -Recurse -Force $stage 2>$null }
New-Item -ItemType Directory -Path $stage | Out-Null
if(Test-Path $tmpZip){ Remove-Item $tmpZip -Force 2>$null }

$copied=0;$miss=0
foreach($p in $want){
  $src=Join-Path $root $p
  if(Test-Path $src -PathType Leaf){
    $dst=Join-Path $stage $p
    New-Item -ItemType Directory -Path (Split-Path $dst) -Force | Out-Null
    Copy-Item $src $dst -Force -ErrorAction SilentlyContinue
    $copied++
  } elseif(Test-Path $src -PathType Container){
    $dst=Join-Path $stage $p
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
    & cmd /d /c robocopy "$src" "$dst" * /E /R:0 /W:0 /NFL /NDL /NJH /NJS /NP >NUL 2>NUL
    $copied++
  } else { $miss++ }
}

try{ [IO.Compression.ZipFile]::CreateFromDirectory($stage,$tmpZip) }catch{}
$okTmp=(Test-Path $tmpZip)
$szTmp=(Get-Item $tmpZip -ErrorAction SilentlyContinue).Length
if($okTmp -and $szTmp -gt 0){
  if(!(Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }
  if(Test-Path $final){ Remove-Item $final -Force 2>$null }
  Copy-Item $tmpZip $final -Force
}
$szFin=(Get-Item $final -ErrorAction SilentlyContinue).Length
$files=(Get-ChildItem -Recurse -File $stage -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Output ("ART={0} OK={1} SIZE={2} TMP={3} TMP_SIZE={4} FILES={5} COPIED={6} MISS={7}" -f $final,($(if($szFin -gt 0){"YES"}else{"NO"})),$(if($szFin){$szFin}else{0}),$okTmp,$(if($szTmp){$szTmp}else{0}),$files,$copied,$miss)
exit ($(if($szFin -gt 0){0}else{1}))
