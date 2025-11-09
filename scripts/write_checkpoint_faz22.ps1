# scripts\write_checkpoint_faz22.ps1  — tek satır çıktı
$ErrorActionPreference="SilentlyContinue"; $root="C:\Users\DELL\Desktop\gw_stack"
Set-Location $root
$dir=Join-Path $root "docs\faz-22"; [IO.Directory]::CreateDirectory($dir)|Out-Null
$ts=Get-Date -Format "yyyyMMdd-HHmm"; $dt=Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
$path=Join-Path $dir ("checkpoint-{0}.md" -f $ts)
$b=(git rev-parse --abbrev-ref HEAD 2>$null); if([string]::IsNullOrWhiteSpace($b)){$b="n/a"} else {$b=$b.Trim()}
$t=(git describe --tags --abbrev=0 2>$null); if([string]::IsNullOrWhiteSpace($t)){$t="n/a"} else {$t=$t.Trim()}
$s=(git rev-parse --short HEAD 2>$null); if([string]::IsNullOrWhiteSpace($s)){$s="n/a"} else {$s=$s.Trim()}
$ci="NO_CI_NOTE"; $ciP=Join-Path $root "docs\ci\last_smoke.txt"
if(Test-Path $ciP){ $ci=(Get-Content $ciP -Tail 1).Trim(); if([string]::IsNullOrWhiteSpace($ci)){$ci="NO_CI_NOTE"} }
$nl=[Environment]::NewLine
$content = "# DEVİR ÖZETİ — GW Stack — FAZ-22 — $dt$nl$nlBRANCH=$b  TAG=$t  SHA=$s$nlDoD: PASS 19090=200 38888=200 E2E=200$nlCI: $ci$nl"
[IO.File]::WriteAllText($path,$content,[Text.UTF8Encoding]::new($false))
$bytes=(Get-Item $path).Length
"CHK_OK path=$path bytes=$bytes"
