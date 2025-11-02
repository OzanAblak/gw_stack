$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$tag="v0.1.2-core"
$art=Join-Path $root "artifacts"
$stage=Join-Path $art "core_stage"
$out=Join-Path $art ("gw_stack_{0}.zip" -f $tag)

if(!(Test-Path $art)){ New-Item -ItemType Directory -Path $art | Out-Null }
if(Test-Path $stage){ Remove-Item -Recurse -Force $stage 2>$null }
New-Item -ItemType Directory -Path $stage | Out-Null

$paths=@(
  "docker-compose.yml",
  "docker-compose.gateway.yml",
  "infra",
  "scripts\ci_smoke_local.ps1",
  "scripts\git",
  "docs\publish_checklist.md",
  "docs"
)

$copied=0; $missing=@()
foreach($p in $paths){
  $src=Join-Path $root $p
  if(Test-Path $src){
    Copy-Item $src -Destination $stage -Recurse -Force -ErrorAction SilentlyContinue
    $copied++
  } else {
    $missing += $p
  }
}

if(Test-Path $out){ Remove-Item $out -Force 2>$null }

$ok=$false
try{
  if(Get-Command Compress-Archive -ErrorAction SilentlyContinue){
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $out -Force -ErrorAction Stop
    $ok=$true
  }
}catch{}

if(-not $ok){
  try{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($stage,$out)
    $ok=$true
  }catch{}
}

if(-not $ok){
  $seven="$env:ProgramFiles\7-Zip\7z.exe"
  if(Test-Path $seven){
    Push-Location $stage; & $seven a -tzip $out * | Out-Null; Pop-Location
    if(Test-Path $out){ $ok=$true }
  }
}

$size=(Get-Item $out -ErrorAction SilentlyContinue).Length
$files=(Get-ChildItem -Recurse -File $stage -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Output ("ART={0} OK={1} SIZE={2} FILES={3} COPIED={4} MISSING={5}" -f $out, ($(if($ok){"YES"}else{"NO"})), ($size?$size:0), ($files?$files:0), $copied, ($missing.Count))
