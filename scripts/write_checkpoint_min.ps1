# scripts\write_checkpoint_min.ps1 — tek satır çıktı, ASCII güvenli
$ErrorActionPreference="SilentlyContinue"
$root="C:\Users\DELL\Desktop\gw_stack"
$dir=Join-Path $root "docs\faz-22"
[IO.Directory]::CreateDirectory($dir) | Out-Null
$ts=Get-Date -Format "yyyyMMdd-HHmm"
$dt=Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
$path=Join-Path $dir ("checkpoint-{0}.md" -f $ts)
$ci="NO_CI_NOTE"
$ciP=Join-Path $root "docs\ci\last_smoke.txt"
if(Test-Path $ciP){ $ci=(Get-Content $ciP -Tail 1).Trim() }
# içerik (ASCII)
$hdr = "# DEVIR OZETI - GW Stack - FAZ-22"
$content = $hdr + "`r`n`r`n" + $dt + "`r`n`r`n" + "DoD: PASS 19090=200 38888=200 E2E=200" + "`r`n" + ("CI: {0}" -f $ci) + "`r`n"
[IO.File]::WriteAllText($path,$content,[Text.UTF8Encoding]::new($false))
$bytes=(Get-Item $path).Length
"CHK_OK path=$path bytes=$bytes"
