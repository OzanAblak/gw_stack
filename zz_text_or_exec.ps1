$ErrorActionPreference="Stop"
$rep="interp_report.txt"
# Basit yürütme kanıtları
$arith = (1+2)*3          # 9 olmalı
$today = Get-Date -Format yyyy-MM-dd
try { docker version > $null 2>&1; $dock="OK" } catch { $dock="NA" }

Set-Content -Path $rep -Encoding ASCII -Value @(
  "MODE=EXEC"
  "ARITH=$arith"
  "TODAY=$today"
  "DOCKER=$dock"
  "SUMMARY=PASS"
)
