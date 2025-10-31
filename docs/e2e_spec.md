# E2E Standard — GW Stack

Tanım
- Tek ölçüt: `POST /v1/plan/compile` → HTTP 200 ve JSON’da `planId`.
- `GET /v1/plan/{planId}` opsiyonel; 404 kabul edilir (başarısızlık sayılmaz).

DoD Satırı
PASS 19090=200 38888=200 E2E=200

Kabuk Disiplini
- Sadece: `cmd /d /c curl.exe …` (health/E2E) ve
- `powershell -NoProfile -ExecutionPolicy Bypass -File <.ps1>` (betikler).
- Tek adım = tek komut = tek satır; STDERR kapalı.
