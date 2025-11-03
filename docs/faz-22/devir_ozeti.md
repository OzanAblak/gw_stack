# DEVİR ÖZETİ — GW Stack — 2025-11-03 (TRT/UTC+3)

KURALLAR (kalıcı)
- SINGLE-CMD: Her adım tek komut; `; && |` yok; tek satır çıktı.
- Akış: STEP:<etiket> → tek komut → tek satır çıktı → “devam”.
- Kök: C:\Users\DELL\Desktop\gw_stack
- JSON anahtarı: planId (id GEÇERSİZ).
- Teşhis sırası: root → files → docker → health → E2E → smoke → CI.
- DoD satırı: PASS 19090=200 38888=200 E2E=200
- Yayın kapısı: CI/SMOKE tek satır PASS olmadan publish yok.
- Kabuk disiplini: SADECE
  1) `cmd /d /c curl.exe …` (health/E2E)
  2) `powershell -NoProfile -ExecutionPolicy Bypass -File <.ps1> …` (betikler)
- Gürültü bastırma: STDERR kapalı; tek satır STDOUT; PS5 uyumlu.

DURUM — FAZ-22 (Sprint-0)
- Branch=main   Son commit=smoke.yml kilit ve temizlik  [YEŞİL]
- Servisler=planner(19090→9090) + gwfwd(38888→planner:9090) + gateway(8088→planner:9090)
- Lokal sağlık=H19090=200 H38888=200  [YEŞİL]
- E2E=POST /v1/plan/compile → 200  [YEŞİL]
- CI (GitHub Actions):
  - `smoke.yml` = yalnız `workflow_dispatch`  [YEŞİL]
  - Concurrency: `smoke-${{ github.ref }}`  [YEŞİL]
  - Son koşu Summary: **PASS 19090=200 38888=200 E2E=200**  [YEŞİL]
  - Eski iş akışları silindi, yalnız `smoke.yml` kaldı  [YEŞİL]
- Artefakt/tag: v0.1.3-core mevcut (lokal)  [YEŞİL]
- Kayıt: `docs/ci/last_smoke.txt` UI ile PASS satırı eklendi  [YEŞİL]
- Checkpoint: `docs/faz-22/checkpoint-20251103-1602.md` uzak repo’da  [YEŞİL]

BİLEŞENLER
- planner=Flask/Waitress; /health, POST /v1/plan/compile, (opsiyonel) GET /v1/plan/{planId}
- gwfwd=alpine/socat; 38888→planner:9090; /health proxy=planner:9090/health
- gateway=nginx:1.25-alpine; /health=200, /v1/→planner:9090

BUGÜN (2025-11-03) — YAPILANLAR
- `smoke.yml` baştan yazıldı; tetikleyici `workflow_dispatch`, concurrency aktif.
- Eski workflow’lar silindi; yalnız smoke kaldı.
- UI’dan çalıştırıldı; Summary tek satır PASS doğrulandı.
- PASS kaydı `docs/ci/last_smoke.txt` içine yazıldı (UI).
- `docs/faz-22/` oluşturuldu; checkpoint dosyası yüklendi (UI).

AÇIK NOKTALAR / BACKLOG
- [CI] Retry penceresi 180s korunuyor; ağ dalgalanması için gerekirse 240s.
- [CI] PASS satırını Summary yanında `docs/ci/last_smoke.txt`’te tutmaya devam.
- [Repo] Lokal CLI push için PAT tanımlanacaksa `repo`+`workflow` scope.

RİSKLER
- Runner ağ gecikmesi → health/E2E timeout.
- PAT olmadan CLI push yapılamaz → UI akışı gerekebilir.

KAYITLAR
- CI workflow: `.github/workflows/smoke.yml`  [Güncel]
- PASS kaydı: `docs/ci/last_smoke.txt`  [Var]
- Checkpoint: `docs/faz-22/checkpoint-20251103-1602.md`  [Var]

KARARLAR
- E2E ölçütü: `compile(planId)=200` (GET gösterimi opsiyonel; 404 fail sayılmaz).
- “Tek komut / tek satır / kırmızısız” çıktı standardı zorunlu.
- CI’de yalnız `smoke.yml` kullanılacak; Summary PASS/FAIL tek satır.

DoD HATIRLATMA
- PASS 19090=200 38888=200 E2E=200

YAYIN KAPILARI
- Kapı-1: Lokal SMOKE PASS  ✅
- Kapı-2: CI SMOKE PASS  ✅
- Kapı-3: Artefakt ZIP + SHA256  ✅ (v0.1.3-core)
- Kapı-4: Tag + Push  ✅
- Kapı-5: Gateway prod sağlığı (8088=200, GW_PASS)  ✅

NOTLAR
- `smoke.yml` “Finalize summary” adımı, fail durumunda da tek satır üretir.
- UI akışları ASCII/UTF-8 sorunlarından bağımsızdır.
