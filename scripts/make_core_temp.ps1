param([string]$OutZip = "artifacts\gw_stack_v0.1.3-core.zip")

$ErrorActionPreference='SilentlyContinue'
$ProgressPreference   ='SilentlyContinue'

$root = "C:\Users\DELL\Desktop\gw_stack"

# Staging
$stg = Join-Path $env:TEMP ("gw_stack_pkg_" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $stg | Out-Null

# Dahil edilecekler (varsa kopyalanır)
$include = @("planner","scripts","infra","docker-compose.yml","docker-compose.gateway.yml","README.md","LICENSE")
foreach($p in $include){
  $src = Join-Path $root $p
  if(Test-Path $src){
    Copy-Item -Recurse -Force $src -Destination (Join-Path $stg $p) | Out-Null
  }
}

# ZIP üret
$outPath = Join-Path $root $OutZip
New-Item -ItemType Directory -Force -Path (Split-Path $outPath -Parent) | Out-Null
try{ if(Test-Path $outPath){ Remove-Item -Force $outPath } } catch {}

Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
  [System.IO.Compression.ZipFile]::CreateFromDirectory($stg,$outPath,[IO.Compression.CompressionLevel]::Optimal,$false)
} catch {}

# Boyut + SHA256
$size = 0
$sha  = ""
if(Test-Path $outPath){
  try {
    $size = (Get-Item $outPath).Length
    $sha  = (Get-FileHash -Algorithm SHA256 $outPath).Hash.ToLower()
  } catch {}
}

# Tek satır çıktı
$out = if($size -gt 0 -and $sha){ "ART PASS SIZE=$size SHA256=$sha" } else { "ART FAIL SIZE=$size SHA256=$sha" }
[Console]::Out.WriteLine($out)
