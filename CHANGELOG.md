# CHANGELOG — GW Stack

Biçim: Tarih = TRT/UTC+3. Kısa, doğrulanabilir maddeler.

## [v0.1.1] — 2025-11-08 — Stable
### Eklendi
- CI akışı dokümantasyonu: `docs/ci/flow.md` (mermaid diyagramı).
- Release gate kontrol listesi: `plans/faz-29/release_gate_checklist.md`.

### Düzeltildi
- Gateway `/health` uç noktası: POST artık `405` (GET/HEAD `200`).
- Planner JSON doğrulama: boş/bozuk gövde `400`.

### CI
- Smoke → post_smoke → release_draft → release hattı yeşil.
- `docs/ci/last_smoke.txt` ⇒ `PASS 19090=200 38888=200 E2E=200 2025-11-08`
- `docs/ci/last_sha256.txt` ⇒ `e4ec51f7c4d45d1b684553cda123767905a6e7069623dfe685e67f555bbb3a0f`

---

## [v0.1.1-smoke-20251108-2] — 2025-11-08 — Pre-release
### Değişiklikler
- Negatif E2E plan ve sonuçları eklendi (`plans/faz-29/e2e_negatif.md`).
- Gateway konfig yeniden inşa ve doğrulama adımları.
- CI artefakt hattı doğrulandı.
- SHA256: `10349fbe2db9cf47be00200cfd00b5cb8bc83ffcac267c1d7d71112ae732bd7d`.

---

## [v0.1.1-smoke-20251108] — 2025-11-08 — Pre-release
### Değişiklikler
- `smoke.yml` artefakt yükleme adımı eklendi.
- `post_smoke.yml` `last_smoke.txt` ve `last_sha256.txt` üretip commit ediyor.
- İlk SHA256: `abd6531a41348dfc9d3af6551065724dd4c94ec82f9282578a922f50bb473ff4`.

---

## Notlar
- “Pre-release” sürümler prod değil; gate sonrası “Stable” yayımlandı.
- SHA256 değerleri CI tarafından üretilen paketler içindir; GitHub UI’a manuel yüklenen zip’ler farklı hash üretebilir.

