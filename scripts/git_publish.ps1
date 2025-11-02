param([string]$Tag="v0.1.3-core",[string]$Zip="artifacts\gw_stack_v0.1.3-core.zip")

$ErrorActionPreference='SilentlyContinue'
$ProgressPreference   ='SilentlyContinue'

$root="C:\Users\DELL\Desktop\gw_stack"
Set-Location $root

# ZIP bilgileri
$sha=""; $size=0
if (Test-Path $Zip) {
  try {
    $sha  = (Get-FileHash -Algorithm SHA256 $Zip).Hash.ToLower()
    $size = (Get-Item $Zip).Length
  } catch {}
}

# Git var mı?
$git_ok=$false
try { & git --version *> $null; if ($LASTEXITCODE -eq 0) { $git_ok=$true } } catch { $git_ok=$false }
if (-not $git_ok) {
  [Console]::Out.WriteLine("GIT FAIL TAG=$Tag ZIP_SIZE=$size SHA256=$sha NOTE=git_not_found")
  exit 0
}

# Tag yerelde var mı?
$exists_local=0
try { & git rev-parse -q --verify ("refs/tags/"+$Tag) *> $null; if ($LASTEXITCODE -eq 0) { $exists_local=1 } } catch {}

# Yoksa oluştur
if ($exists_local -eq 0) {
  try { & git tag -a $Tag -m ("release "+$Tag+" size="+$size+" sha256="+$sha) *> $null } catch {}
}

# Push
$push=0
try { & git push origin $Tag *> $null; if ($LASTEXITCODE -eq 0) { $push=1 } } catch {}

# Tek satır çıktı
$out = if ($push -eq 1) {
  "GIT PASS TAG=$Tag ZIP_SIZE=$size SHA256=$sha"
} else {
  "GIT FAIL TAG=$Tag ZIP_SIZE=$size SHA256=$sha"
}
[Console]::Out.WriteLine($out)
