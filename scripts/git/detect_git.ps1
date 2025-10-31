$ErrorActionPreference = 'SilentlyContinue'
$found = @()

try {
  $cmd = (Get-Command git.exe -ErrorAction Stop).Source
  if ($cmd -and (Test-Path $cmd)) { $found += (Resolve-Path $cmd).Path }
} catch {}

$locations = @(
  "$env:ProgramFiles\Git\cmd\git.exe",
  "$env:ProgramFiles\Git\bin\git.exe",
  "$env:ProgramFiles(x86)\Git\cmd\git.exe",
  "$env:ProgramFiles(x86)\Git\bin\git.exe",
  "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe",
  "$env:LOCALAPPDATA\Programs\Git\bin\git.exe",
  "$env:ChocolateyInstall\bin\git.exe"
)

foreach ($p in $locations) {
  if ($p -and (Test-Path $p)) {
    $found += (Resolve-Path $p).Path
  }
}

$found = $found | Select-Object -Unique

if ($found.Count -gt 0) {
  Write-Output ("GIT=" + $found[0])
  exit 0
} else {
  Write-Output "ERROR=GIT_NOT_FOUND"
  exit 1
}
