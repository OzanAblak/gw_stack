# RUNBOOK — gw_stack

## Başlat
cd C:\Users\DELL\Desktop\gw_stack
docker compose up -d

## Smoke
C:\Users\DELL\Desktop\gw_stack\smoke.cmd

## Geçitler
- gw_pass_gate.ps1  (T0–T2)
- gw_ops_gate.ps1   (T3–T4)
- gw_watch.ps1      (T5–T6)
- gw_rt_diag.ps1    (RT teşhis)
- CI: .github\workflows\ci.yml
- Soak: T16 (5 dk), uzun soak için Görev Zamanlayıcı kullanılabilir.

## Log Rotate
powershell -NoProfile -ExecutionPolicy Bypass -File .\gw_rotate.ps1
