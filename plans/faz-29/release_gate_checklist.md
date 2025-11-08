# RELEASE GATE CHECKLIST — GW Stack — FAZ-29 — 2025-11-08 (TRT/UTC+3)

## KURALLAR
- Tek adım tek karar: her madde net ✅/❌
- Kabuk referansı: Windows CMD (cmd.exe)
- Yayın akışı: pre-release → gate → stable

## ÖN KOŞULLAR (HIZLI DOĞRULAMA — CMD)
- last_smoke: `curl -s https://raw.githubusercontent.com/OzanAblak/gw_stack/main/docs/ci/last_smoke.txt`
- last_sha256: `curl -s https://raw.githubusercontent.com/OzanAblak/gw_stack/main/docs/ci/last_sha256.txt`
- gateway /health POST: `curl -s -o NUL -w "HTTP=%{http_code}" -X POST http://localhost:8088/health`  → 405
- pre-release var mı: Releases sayfasında son tag

## GATE LİSTESİ
- [ ] CI sinyalleri güncel:
  - [ ] `docs/ci/last_smoke.txt` bugün PASS (19090=200 38888=200 E2E=200)
  - [ ] `docs/ci/last_sha256.txt` 64 haneli hex
- [ ] Negatif E2E PASS kaydı dokümante (plans/faz-29/e2e_negatif.md)
- [ ] Gateway /health POST=405 doğrulandı
- [ ] Artefakt mevcut ve indirilebilir (smoke_artifact)
- [ ] Devir özeti güncel (docs/faz-29/devir_ozeti.md)
- [ ] Değişiklik listesi (changelog kısa not) hazır
- [ ] Sürüm adı/etiketi kararlaştırıldı:
  - Pre-release: `v0.1.1-smoke-20251108-2`
  - Stable hedef tag: `v0.1.1` (örnek; gerekirse güncelle)

## YAYIN ADIMLARI (STABLE TERFİ)
1) GitHub → Releases → **New release**
2) **Choose a tag**: `v0.1.1` (Create new tag… → Target: `main`)
3) Title: `GW Stack v0.1.1`
4) Body:
   - `last_smoke` satırı
   - `last_sha256` = (dosyadaki 64 hane)
   - Özet değişiklikler
5) Assets:
   - Gerekirse smoke_artifact.zip’i yükle
6) “Pre-release” kapalı olsun → **Publish release**

## YAYIN SONRASI KONTROLLER
- [ ] API: `curl -s -o NUL -w "HTTP=%{http_code}" http://localhost:8088/health` → 200
- [ ] POST engeli: `curl -s -o NUL -w "HTTP=%{http_code}" -X POST http://localhost:8088/health` → 405
- [ ] Release API: `curl -s -o NUL -w "HTTP=%{http_code}" https://api.github.com/repos/OzanAblak/gw_stack/releases/tags/v0.1.1` → 200

## GERİ DÖNÜŞ PLANI
- Stable hatalıysa:
  - Release’i **Edit → Delete** (tag’i kaldırırsan yeniden oluştur)
  - En son working pre-release’e geri dön
  - Hatayı düzelt, smoke → post-smoke → gate yeniden uygula
