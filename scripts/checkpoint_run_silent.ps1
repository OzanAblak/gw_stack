# RUN CHECKPOINT — tam sessiz, tek satır (STDERR içerde gömülür)
$ErrorActionPreference='SilentlyContinue'
$script="C:\Users\DELL\Desktop\gw_stack\scripts\checkpoint_faz21_final.ps1"

$psi=New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName="$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$psi.Arguments='-NoProfile -ExecutionPolicy Bypass -File "'+$script+'"'
$psi.RedirectStandardOutput=$true
$psi.RedirectStandardError=$true
$psi.UseShellExecute=$false
$psi.CreateNoWindow=$true

$p=[System.Diagnostics.Process]::Start($psi)
$stdout=$p.StandardOutput.ReadToEnd()
$null=$p.StandardError.ReadToEnd()   # kırmızıları içeride yut
$p.WaitForExit()

$line=(($stdout -replace '\s+',' ').Trim())
if([string]::IsNullOrEmpty($line)){ $line="CHK_ERR=NO_OUTPUT" }
Write-Output $line
exit 0
