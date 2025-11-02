$ErrorActionPreference='SilentlyContinue'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root="C:\Users\DELL\Desktop\gw_stack"
$art = Join-Path $root "artifacts"
if(!(Test-Path $art)){ New-Item -ItemType Directory -Path $art | Out-Null }
$tmp = Join-Path $art "_zip_smoke"
if(Test-Path $tmp){ Remove-Item -Recurse -Force $tmp 2>$null }
New-Item -ItemType Directory -Path $tmp | Out-Null
Set-Content -Path (Join-Path $tmp "a.txt") -Value "ok" -NoNewline

# 1) Compress-Archive
$z1 = Join-Path $art "z1.zip"; if(Test-Path $z1){ Remove-Item $z1 -Force 2>$null }
$Z1=$false; try{ Compress-Archive -LiteralPath (Join-Path $tmp "a.txt") -DestinationPath $z1 -Force -ErrorAction Stop; $Z1=Test-Path $z1 }catch{}
$sz1 = (Get-Item $z1 -ErrorAction SilentlyContinue).Length; if(-not $sz1){$sz1=0}

# 2) .NET ZipFile.CreateFromDirectory
$z2 = Join-Path $art "z2.zip"; if(Test-Path $z2){ Remove-Item $z2 -Force 2>$null }
$Z2=$false; try{ [IO.Compression.ZipFile]::CreateFromDirectory($tmp,$z2); $Z2=Test-Path $z2 }catch{}
$sz2 = (Get-Item $z2 -ErrorAction SilentlyContinue).Length; if(-not $sz2){$sz2=0}

# 3) tar.exe
$z3 = Join-Path $art "z3.zip"; if(Test-Path $z3){ Remove-Item $z3 -Force 2>$null }
$Z3=$false; $tar = Join-Path $env:SystemRoot "System32\tar.exe"
if(Test-Path $tar){ & $tar -a -c -f "$z3" -C "$tmp" "a.txt" 2>$null; $Z3=Test-Path $z3 }
$sz3 = (Get-Item $z3 -ErrorAction SilentlyContinue).Length; if(-not $sz3){$sz3=0}

Write-Output ("ZIPENV Z1_CA={0}:{1} Z2_ZIPFILE={2}:{3} Z3_TAR={4}:{5}" -f ($(if($Z1){"OK"}else{"ERR"}),$sz1,$(if($Z2){"OK"}else{"ERR"}),$sz2,$(if($Z3){"OK"}else{"ERR"}),$sz3))
