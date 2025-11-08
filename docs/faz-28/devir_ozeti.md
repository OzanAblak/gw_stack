# DEVİR ÖZETİ — GW Stack — FAZ-28 — 2025-11-08 (TRT/UTC+3)

## DURUM ÖZETİ
- DoD karşılandı: PASS 19090=200 38888=200 E2E=200.
- Pre-release yayınlandı: `v0.1.1-smoke-20251108` (Set as pre-release = true).
- Artefakt hattı aktif: smoke → upload, post_smoke → SHA256 üret + commit.

## KANITLAR
- `docs/ci/last_smoke.txt` ⇒ `PASS 19090=200 38888=200 E2E=200 2025-11-08`
- `docs/ci/last_sha256.txt` ⇒ `abd6531a41348dfc9d3af6551065724dd4c94ec82f9282578a922f50bb473ff4`
- Release assets = 3 (2×source + 1×smoke_artifact.zip)

## KURALLAR (FAZ-28’DE UYGULANAN)
- SINGLE-CMD: Her adım tek komut, tek satır çıktı.
- Kabuk: **CMD**; PowerShell devre dışı.
- Teşhis sırası: root → files → docker → health → E2E → smoke → CI.
- Yayın kapısı: Lokal+CI SMOKE PASS olmadan publish yok.
- Gürültü: Kırmızısız, tek satır.

## CI/MİMARİ NOTLARI
- `smoke.yml`: artefakt `smoke_artifact` yükleniyor.
- `post_smoke.yml`: smoke success → `last_smoke.txt` ve `last_sha256.txt` güncellenip push ediliyor.
- `permissions`: contents=write, actions=read; checkout `persist-credentials: true`.

## ÇÖZÜLEN KONULAR
- GH API 401: Token akışı yerine UI tetikleme ile smoke çalıştırıldı.
- post-smoke isim ve tetik: doğrulandı, güncel.

## AÇIK NOKTALAR / RİSKLER
- Release’teki zip’in SHA256’ı `last_sha256.txt` ile bire bir aynı olmayabilir (CI tarafında tar alınır). Gerekirse release açıklamasına zip SHA256 eklenebilir.
- PowerShell kullanımında parsing gürültüsü; CMD standardı korunmalı.

## SONRAKİ FAZ (FAZ-29) HEDEFLERİ
- [ ] Otomatik “release draft” oluşturma ve manuel gate ile stable’a terfi.
- [ ] E2E kapsamının genişletilmesi (gateway → planner hata yolları).
- [ ] Gateway nginx konfig uyarılarının temizlenmesi.
- [ ] CI artefakt imzası ve doğrulama adımı (opsiyonel).
- [ ] Dokümantasyon: `README`ye smoke akış şeması.

## KAPANIŞ
- FAZ-28 tamamlandı, pre-release doğrulandı.
