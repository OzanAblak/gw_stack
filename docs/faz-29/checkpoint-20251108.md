# CHECKPOINT — GW Stack — FAZ-29 — 2025-11-08 (TRT/UTC+3)

## ÖZET
- Negatif E2E: PASS.
  - N1=404, N2=400, N3=400, N4=400, N5=404, N6=404, N7=404, N8=404, N9=404, N10=400, N11=400, N12=405
- Gateway: `/health` POST=405; konfig ve yeniden kurulum tamam.
- Smoke: RUN başarılı.
- last_smoke.txt: PASS 19090=200 38888=200 E2E=200 2025-11-08
- last_sha256.txt: 10349fbe2db9cf47be00200cfd00b5cb8bc83ffcac267c1d7d71112ae732bd7d
- Release: v0.1.1-smoke-20251108-2 (pre-release) yayınlandı.
- Dokümantasyon: plan ve devir özetleri güncellendi.

## KURALLAR (HATIRLATMA)
- SINGLE-CMD: Tek komut, tek satır çıktı; `; && |` yok.
- Akış: STEP:<etiket> → komut → tek satır çıktı → “devam”.
- Kabuk: Windows CMD (`cmd.exe`); PowerShell yok.

## AÇIK NOKTALAR
- Gateway `/v1/` route kapsamını genişletme.
- README’ye smoke/CI akış şeması.
- Release draft akışının sade doğrulaması.

## SONRAKİ ADIM (FAZ-29)
- [ ] Release draft → publish kapısı için basit kontrol listesi.
- [ ] Gateway konfig lint ve uyarı temizliği.
- [ ] Planner iş mantığına minimum validasyon şeması.
