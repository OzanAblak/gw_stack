# DEVİR PLANI + VERSİYON HİKAYESİ — GW Stack — FAZ-44

## 1) KAPSAM — FAZ-44 NEYİ GETİRDİ?

FAZ-44, FAZ-43’te kurulan release body şablonunu (template) ve script’ini,
`release_draft` CI workflow’una **gerçek üretim entegrasyonu** ile bağlayan fazdır.

Ana hedefler:

- `release_draft` workflow’unu, `post_smoke` sonrası otomatik çalışan,
  “release body üreten + pre-release oluşturan” bir zincire dönüştürmek.
- `generate_release_body.ps1` script’ini:
  - Lokal ortamda ve CI’da aynı şekilde çalışan,
  - Template + env + artefakt kombinasyonuyla body üreten bir core katmana dönüştürmek.
- DoD ve smoke bilgilerini:
  - Sadece asset olarak değil,
  - Release body içinde okunabilir, standart bir DoD bölümüne dönüştürmek.
- Placeholder’lı bir şablonu:
  - “Boş bırakılmış Markdown” olmaktan çıkarıp,
  - **her koşulda insan okunabilir** bir release notuna evirmek.

Bu faz, FAZ-41/42/43’te kurulan:

- CI zinciri (smoke → post_smoke → release_draft → site_check),
- DoD artefakt üretimi,
- release template tasarımı,

üzerine “**otomatik release body + pre-release otomasyonu**” katmanını ekler.

---

## 2) ÇEKİRDEK BİLEŞENLER

### 2.1) Script — `scripts/generate_release_body.ps1`

Görev:
- `docs/faz-43/release_body_template.md` dosyasındaki placeholder’ları,
  aşağıdaki kaynaklarla doldurur:
  - CI env değişkenleri,
  - `ci_artifacts` klasöründeki DoD dosyaları,
  - Gerektiğinde fallback metinler ve otomatik türetilmiş alanlar.

Ana özellikler:

- Repo köküne göre relative path kullanır:
  - Template: `docs/faz-43/release_body_template.md`
  - Output:   `docs/faz-43/release_body_generated.md`
- ENV → placeholder eşleşmeleri:
  - `{TAG}`              ← `REL_TAG`
  - `{RELEASE_TYPE}`     ← `REL_TYPE`
  - `{BRANCH}`           ← `REL_BRANCH`
  - `{COMMIT}`           ← `REL_COMMIT`
  - `{RELEASE_URL}`      ← `REL_URL`
  - `{RELEASE_DATE}`     ← `REL_DATE` (yoksa script UTC “şimdi” yazar)
  - `{SMOKE_RUN_ID}`     ← `SMOKE_RUN_ID`
  - `{SMOKE_STATUS}`     ← `SMOKE_STATUS`
  - `{POST_SMOKE_RUN_ID}`     ← `POST_SMOKE_RUN_ID`
  - `{POST_SMOKE_STATUS}`     ← `POST_SMOKE_STATUS`
  - `{RELEASE_DRAFT_RUN_ID}`  ← `RELEASE_DRAFT_RUN_ID`
  - `{RELEASE_DRAFT_STATUS}`  ← `RELEASE_DRAFT_STATUS`
  - `{SITE_CHECK_RUN_ID}`     ← `SITE_CHECK_RUN_ID`
  - `{SITE_CHECK_STATUS}`     ← `SITE_CHECK_STATUS`
  - `{CI_PIPELINE_STATUS}`    ← `CI_PIPELINE_STATUS`
  - `{DOD_STATUS}`            ← `DOD_STATUS`

DoD artefakt entegrasyonu:

- Klasör: `ci_artifacts`
  - `DoD.txt`:
    - İçerik → `{DOD_TXT_DESC}`
    - Eğer env’den `DOD_STATUS` gelmiyorsa:
      - Metindeki “PASS/FAIL” ifadesine göre `{DOD_STATUS}` türetilir.
  - `last_smoke.txt`:
    - İçerik → `{LAST_SMOKE_DESC}`
    - Ek olarak, içerikteki pattern’lerden:
      - `RUN=...` → `{SMOKE_RUN_ID}`
      - `CONCLUSION=...` veya “success/failure” → `{SMOKE_STATUS}`
  - `last_sha256.txt`:
    - İçerik → `{LAST_SHA256_DESC}`

Dostça fallback’ler (GATE-3):

- Eğer yukarıdaki kaynaklarla doldurulamazlarsa:
  - `{DOD_TXT_DESC}`:
    - “Bu release için DoD.txt artefaktı bulunamadı veya CI tarafından üretilmedi.”
  - `{LAST_SMOKE_DESC}`:
    - “Bu release için son smoke koşusuna ait detaylı özet bilgisi bulunamadı.”
  - `{LAST_SHA256_DESC}`:
    - “Bu release için SHA256 özet bilgisi (last_sha256.txt) bulunamadı.”
  - `{DOD_STATUS}`:
    - “UNKNOWN”

Sonuç:
- Script, **hiçbir koşulda ham placeholder bırakmayacak** şekilde tasarlanmıştır.
- Artefakt ve env doluysa zengin veri, yoksa temiz fallback metin verir.

---

### 2.2) Workflow — `.github/workflows/release_draft.yml`

Trigger:

- `on: workflow_run` (workflow: `post_smoke`, conclusion: `success`)

Akış:

1. **Checkout**
   - Repo’yu full fetch ile çeker (`fetch-depth: 0`).

2. **Download CI artifacts (DoD bundle)**
   - `actions/download-artifact@v4`
   - `run-id: github.event.workflow_run.id`
   - `name: ci_artifacts`
   - `path: ci_artifacts`
   - `continue-on-error: true` (artefakt yoksa pipeline düşmez)

3. **Show DoD bundle**
   - Dosya sistemi ve DoD dosyaları log’a basılır:
     - `DoD.txt`
     - `last_smoke.txt`
     - `last_sha256.txt`

4. **Export release env**
   - `REL_TAG = v0.1.1-draft-${{ github.run_id }}`
   - `REL_TYPE = Pre-release`
   - `REL_BRANCH = github.event.workflow_run.head_branch`
   - `REL_COMMIT = github.event.workflow_run.head_sha`
   - `REL_URL = https://github.com/<repo>/releases/tag/<TAG>`
   - `REL_DATE = date -u +%Y-%m-%dT%H:%M:%SZ`
   - CI meta:
     - `SMOKE_RUN_ID = github.event.workflow_run.id`
     - `SMOKE_STATUS = github.event.workflow_run.conclusion`
     - `POST_SMOKE_RUN_ID = github.event.workflow_run.id`
     - `POST_SMOKE_STATUS = github.event.workflow_run.conclusion`
     - `RELEASE_DRAFT_RUN_ID = github.run_id`
     - `RELEASE_DRAFT_STATUS = success`
     - `SITE_CHECK_RUN_ID/SITE_CHECK_STATUS` (şimdilik boş)
     - `CI_PIPELINE_STATUS = ALL PASS`
     - `DOD_STATUS = PASS` (script gerekirse DoD içeriğine göre override eder)

5. **Generate release body (FAZ-44)**
   - `shell: pwsh`
   - `run: ./scripts/generate_release_body.ps1`
   - Sonuç: `docs/faz-43/release_body_generated.md` üretilir.

6. **Create or update pre-release**
   - `GH_TOKEN = secrets.GITHUB_TOKEN`
   - Eğer TAG mevcutsa:
     - `gh release edit TAG --prerelease --notes-file docs/faz-43/release_body_generated.md`
   - Değilse:
     - `gh release create TAG --target REL_BRANCH --prerelease --title TAG --notes-file ...`
   - DoD asset upload:
     - Varsa:
       - `ci_artifacts/DoD.txt`
       - `ci_artifacts/last_smoke.txt`
       - `ci_artifacts/last_sha256.txt`
     - `gh release upload TAG <dosya> --clobber`

---

## 3) VERSİYON HİKAYESİ — FAZ-44 GATE’LERİ

Bu bölüm, FAZ-44’ün “zihinsel modelini” ve commit seviyesindeki evrimini saklar.

### GATE-1 — Entegrasyonun ilk adımı  
Commit: `be5af59` — `FAZ-44: wire release_draft to generate_release_body`

- `release_draft.yml`:
  - `post_smoke` sonrası tetiklenen temel akış kuruldu.
  - `generate_release_body.ps1` script’i workflow’a step olarak eklendi.
  - Pre-release oluşturma/güncelleme adımı eklendi.
- `generate_release_body.ps1`:
  - Template’i repo köküne göre relative path ile okuyan ilk sürüm.
  - ENV → placeholder mapping’in ilk iskeleti oluşturuldu.

### GATE-1.5 — DoD artefakt indirmenin yumuşatılması  
Commit: `f478172` — `FAZ-44: make ci_artifacts optional in release_draft`

- `Download CI artifacts` step’i:
  - `continue-on-error: true` ile işaretlendi.
- Amaç:
  - `ci_artifacts` eksik olduğunda, tüm release_draft job’ının düşmesini engellemek.
  - Release body üretimi ve pre-release adımları her koşulda çalışsın.

### GATE-2 — DoD içeriğinin body’ye taşınması  
Commit: `e0a997c` — `FAZ-44: GATE-2 fill DoD section from ci_artifacts`

- Script:
  - `DoD.txt`, `last_smoke.txt`, `last_sha256.txt` dosyaları okunmaya başlandı.
  - Bu dosyaların içerikleri:
    - `{DOD_TXT_DESC}`
    - `{LAST_SMOKE_DESC}`
    - `{LAST_SHA256_DESC}`
    alanlarına basıldı.
  - DoD_status:
    - Env eksikse, `DoD.txt` içeriğinden PASS/FAIL türetildi.

### GATE-3 — Placeholder’sız DoD bölümü (fallback katmanı)  
Commit: `8bfa6f0` — `FAZ-44: GATE-3 friendly fallbacks for DoD placeholders`

- Script:
  - Artefakt veya env hiç gelmese bile:
    - `{DOD_TXT_DESC}`, `{LAST_SMOKE_DESC}`, `{LAST_SHA256_DESC}`, `{DOD_STATUS}` için
      anlamlı Türkçe fallback mesajlar eklendi.
- Sonuç:
  - Release body, en kötü senaryoda bile “ham token” değil, okunabilir cümleler içeriyor.

### GATE-4 — RELEASE_DATE alanının otomatik doldurulması  
Commit: `8bfa6f0` sonrası aynı faz içinde (env + script güncellemeleri)

- `release_draft.yml`:
  - `REL_DATE = date -u +%Y-%m-%dT%H:%M:%SZ` env’i eklendi.
- Script:
  - `{RELEASE_DATE}`:
    - Env’den dolduruluyor,
    - Env yoksa script UTC “şimdi”yi yazıyor.
- Amaç:
  - Release body içinde, “bu not ne zaman üretildi?” sorusuna tek, standart yanıt.

### GATE-5 — Smoke meta’nın last_smoke.txt’ten türetilmesi  
Commit: `9c80807` — `FAZ-44: GATE-5 derive smoke meta from last_smoke`

- Script:
  - `last_smoke.txt` içeriğinden:
    - `RUN=...` pattern’i → `{SMOKE_RUN_ID}`
    - `CONCLUSION=...` veya “success/failure” kelimeleri → `{SMOKE_STATUS}`
  - Bu alanlar, env’den gelmeyen durumlarda da gerçek smoke koşusuna yakın bilgi ile doldurulmaya başlandı.
- Sonuç:
  - DoD bölümünde sadece metin değil, smoke run ID + status de anlamlı hale geldi.

---

## 4) ŞU ANKİ DAVRANIŞ FOTOĞRAFI (FAZ-44 SONU YAKLAŞIRKEN)

- `post_smoke` başarılı → `release_draft` tetiklenir.
- `release_draft`:
  - DoD artefaktlarını indirmeyi dener (başarısız olsa bile düşmez).
  - release env’lerini yazar:
    - TAG, BRANCH, COMMIT, URL, DATE, CI meta, DOD_STATUS.
  - `generate_release_body.ps1` ile template’ten release body üretir.
  - Pre-release’i oluşturur/günceller, body’yi (`release_body_generated.md`) release gövdesi yapar.
  - DoD asset’lerini (varsa) release’e yükler.

Release body:

- Header:
  - TAG, BRANCH, COMMIT, RELEASE_URL, RELEASE_DATE otomatik.
- CI bölümü:
  - SMOKE/POST_SMOKE/RELEASE_DRAFT run id/status alanları en azından CI context’inden dolu.
  - SMOKE meta, `last_smoke.txt` ile zenginleştirilmiş durumda.
- DoD bölümü:
  - DoD.txt / last_smoke / last_sha256 varsa, oradan gerçek içerik.
  - Yoksa Türkçe fallback mesajlar.
- Diğer alanlar:
  - UX/BACKEND/CI değişiklik listeleri, highlight’lar, bilinen sorunlar vb.
  - Şimdilik manuel doldurulmak üzere bırakılmış durumda.

---

## 5) FAZ-45 İÇİN NOT: OLASI İYİLEŞTİRMELER

Gelecek fazlarda (FAZ-45 ve sonrası) düşünülebilecek aksiyonlar:

- CI meta iyileştirme:
  - `SMOKE_RUN_ID`, `POST_SMOKE_RUN_ID`, `SITE_CHECK_RUN_ID` için
    gerçekten ilgili workflow’ların son run’larını bulan küçük yardımcı script’ler.
- Release body otomasyonu:
  - Commit mesajlarından veya label’lardan “CHANGE_SUMMARY_SHORT” / “HIGHLIGHT_*”
    üretmek için basit heuristikler.
- Template evrimi:
  - Prod/stable release’ler için ayrı bir template varyantı
    (örn. “Pre-release” vs “Stable” bölümleri).

Bu plan ve versiyon hikayesi, FAZ-44’ün ilerleyen devir özetine ve FAZ-45 başlangıç tasarımına referans olacak şekilde hazırlanmıştır.
