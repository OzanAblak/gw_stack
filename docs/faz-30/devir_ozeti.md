DEVIR OZETI // GW Stack // FAZ-30 // 2025-11-11 (TRT/UTC+3)



KAPSAM

\- Kapsar: 2025-11-11 EOD’a kadar olan lokal ve CI akışı.

\- Dayanak: FAZ-29 kapanış + 2025-11-10/11 oturumları + PR#4, PR#5.



KURALLAR (hatırlatma)

\- SINGLE-CMD: Her adım tek komut, tek satır çıktı.

\- SHELL: CMD (cmd.exe). PowerShell yok.

\- ROOT: C:\\Users\\DELL\\Desktop\\gw\_stack

\- TEHSIS: root -> files -> docker -> health -> E2E -> smoke -> CI.

\- DoD: PASS 19090=200 38888=200 E2E=200.

\- PUBLISH GATE: Lokal + CI SMOKE PASS olmadan release yok.

\- GIT: origin=SSH (git@github.com:OzanAblak/gw\_stack.git), PR=squash.



MIMARI (PORTLAR)

\- planner: 19090 (/health, POST /v1/plan/compile)

\- gwfwd: 38888 (proxy -> planner:9090)

\- gateway: 8088 (nginx) -> planner:9090



DURUM (KAPANIŞ 2025-11-11)

\- Lokal health: 8088=200, 38888=200, 19090=200.

\- E2E Negatif N13: {"goal":123} artık 19090 ve 38888 üzerinden \*\*HTTP=400\*\*.

&nbsp; - Uygulanan koruma: `planner/app.py` içerik güncellendi + `hotpatch\_n13.py` (before\_request guard) eklendi.

\- Git/PR:

&nbsp; - PR#4: ci\_update\_smoke … MERGED (squash).

&nbsp; - PR#5: docs N13 PASS bayrağı … MERGED (squash).

\- CI Zinciri:

&nbsp; - smoke.yml → SUCCESS

&nbsp; - post\_smoke.yml → SUCCESS

&nbsp; - release\_draft.yml → SUCCESS

\- Release:

&nbsp; - v0.1.1-draft-19265082131 → PRE=false, DRAFT=false, ASSETS=0 (draft terfi edildi).

\- Artefakt:

&nbsp; - `last\_smoke.txt` ve `last\_sha256.txt` repoda değil, post\_smoke artefaktında.



NEGATIF E2E KATALOGU (SON)

\- N1..N12: PASS

\- N13: gwfwd /v1/plan/compile body {"goal":123} → \*\*PASS=400\*\* (2025-11-11)



DOSYA / DOKUMAN GÜNCEL

\- plans/faz-29/e2e\_negatif.md → N13 PASS kaydı eklendi (2025-11-11).

\- docs/quickstart\_cmd.md → CMD tek-blok quickstart.

\- .github/workflows/post\_smoke.yml → ad/etiket düzeltmeleri canlı.

\- CHANGELOG.md → v0.1.1 prerelease notları mevcut.



RISK / ONLEM

\- Geçici guard (hotpatch\_n13.py) üretimde kaldı.

&nbsp; ONLEM: Guard’ı kaldırmadan önce `compile\_plan` içinde yerleşik şema kontrolünün CI’de doğrulandığını ispatla (unit+E2E).

\- DoD metni tek kaynak değil.

&nbsp; ONLEM: `docs/ci/DoD.txt` oluştur, workflow’lar buradan okusun.

\- Release assets=0.

&nbsp; ONLEM: smoke/post\_smoke artefaktlarını release asset’lerine bağlayan adım ekle.



YAPILACAKLAR (FAZ-31)

\[ ] planner: \_validate\_payload yerleşik, guard olmadan da N13=400 kalıyor mu? Unit+E2E ile ispatla.

\[ ] hotpatch\_n13.py kaldır, `import hotpatch\_n13` satırını sil, rebuild/restart → N13=400 doğrula.

\[ ] CI DoD tek kaynak: docs/ci/DoD.txt + workflow echo.

\[ ] Compose: log rotasyonu (json-file max-size=10m max-file=3) → `docker inspect ...LogConfig` ile doğrula.

\[ ] README: port tablosu + DoD referansı + “tek-komut” notu.

\[ ] Release assets: post\_smoke artefaktları release’e ekle.



KANIT (CI / RELEASE)

\- smoke.yml: STATUS=completed CONCLUSION=success

\- post\_smoke.yml: STATUS=completed CONCLUSION=success

\- release\_draft.yml: STATUS=completed CONCLUSION=success

\- Releases/latest: v0.1.1-draft-19265082131 PRE=false DRAFT=false ASSETS=0



SON

\- N13 düzeltmesi canlı, zincir çalışır durumda.

\- PR#5 merge sonrası main güncel.

\- FAZ-31 ilk iş: hotpatch kaldır + unit/E2E ile kalıcılık doğrulama; DoD tek kaynak; log rotasyonu.



