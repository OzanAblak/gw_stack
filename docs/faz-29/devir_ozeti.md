# DEVİR ÖZETİ — GW Stack — FAZ-29 — 2025-11-08 (TRT/UTC+3)

## BAŞLANGIÇ DURUMU
- Önceki faz tamam: pre-release `v0.1.1-smoke-20251108` yayımlandı.
- CI hattı aktif: `smoke` artefakt yüklüyor; `post_smoke` → `last_smoke.txt` ve `last_sha256.txt` üretiyor.
- En son değerler:
  - `docs/ci/last_smoke.txt` ⇒ `PASS 19090=200 38888=200 E2E=200 2025-11-08`
  - `docs/ci/last_sha256.txt` ⇒ `abd6531a41348dfc9d3af6551065724dd4c94ec82f9282578a922f50bb473ff4`
  - Release assets ⇒ 3

## KURALLAR
- SINGLE-CMD: Her adım tek komut; `; && |` yok; tek satır çıktı.
- Akış: STEP:<etiket> → tek komut → tek satır çıktı → “devam”.
- Kabuk: CMD (PowerShell kapalı).
- Teşhis sırası: root → files → docker → health → E2E → smoke → CI.
- Yayın kapısı: Lokal+CI SMOKE PASS olmadan publish yok.
- Gürültü: Kırmızısız, tek satır.

## MİMARİ ÖZET
- planner: Flask/Waitress → `/health`, `POST /v1/plan/compile`
- gwfwd: 38888→planner:9090, `/health`
- gateway: nginx `/health=200`, `/v1/→planner:9090`
- CI: `smoke.yml` (manual+push), `post_smoke.yml` (workflow_run: smoke)

## HEDEFLER (FAZ-29)
- [ ] Release otomasyonu: draft oluştur, manuel gate ile stable’a terfi.
- [ ] E2E kapsamı: gateway→planner hata yolları ve negatif testler.
- [ ] Nginx uyarılarının temizlenmesi.
- [ ] Artefakt imzası ve doğrulama (opsiyonel).
- [ ] README’ye smoke/CI akış şeması.

## HIZLI TEST KOMUTLARI (CMD — referans)
- last-smoke-check: `curl -s https://raw.githubusercontent.com/OzanAblak/gw_stack/main/docs/ci/last_smoke.txt`
- last-sha256-check: `curl -s https://raw.githubusercontent.com/OzanAblak/gw_stack/main/docs/ci/last_sha256.txt`
- post-smoke-exists: `curl -s -o NUL -w "HTTP=%{http_code}" https://raw.githubusercontent.com/OzanAblak/gw_stack/main/.github/workflows/post_smoke.yml`

## RİSKLER / NOTLAR
- Release’teki zip’in SHA256’ı CI’nin ürettiği tar SHA’sıyla bire bir aynı olmayabilir.
- CMD standardı korunmalı; PowerShell gürültüsü devre dışı.

## KAPANIŞ
- FAZ-29 başlangıcı kaydedildi; FAZ-28 artefakt ve yayın doğrulandı.
### 2025-11-08 Guncelleme 
- N1 duzeltildi: GET -> 405 
- Negatif E2E: 12/12 PASS 
- Quickstart: docs/quickstart_cmd.md
