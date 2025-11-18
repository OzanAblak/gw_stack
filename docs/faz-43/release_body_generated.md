# GW Stack — Release Notları — {TAG}

- Tür: {RELEASE_TYPE}           <!-- Pre-release / Release -->
- Branch: `{BRANCH}`
- Commit: `{COMMIT}`            <!-- kısa SHA veya tam SHA -->
- Yayın tarihi: {RELEASE_DATE}

---

## 1) Özet

{CHANGE_SUMMARY_SHORT}

- Öne çıkan değişiklikler:
  - {HIGHLIGHT_1}
  - {HIGHLIGHT_2}
  - {HIGHLIGHT_3}

> Not: Bu bölüm son kullanıcı ve iş tarafı için hızlı okunabilir, 3–5 maddelik kısa özet.  
> CI / DoD detayları aşağıdaki bölümlerde.

---

## 2) CI Zinciri Özeti

Kaynak: `{BRANCH}` üzerinde çalışan CI zinciri.

| Adım          | Run ID                | Sonuç          | Not |
| ------------- | --------------------- | -------------- | --- |
| smoke         | {SMOKE_RUN_ID}        | {SMOKE_STATUS} |     |
| post_smoke    | {POST_SMOKE_RUN_ID}   | {POST_SMOKE_STATUS} | |
| release_draft | {RELEASE_DRAFT_RUN_ID}| {RELEASE_DRAFT_STATUS} | |
| site_check    | {SITE_CHECK_RUN_ID}   | {SITE_CHECK_STATUS} | |

Ek meta:

- Pipeline durumu: {CI_PIPELINE_STATUS} <!-- örn. Tüm adımlar PASS -->
- Kaynak commit: `{COMMIT}` (`{BRANCH}`)

---

## 3) Definition of Done (DoD)

- Sabit DoD satırı:  
  `PASS 19090=200 38888=200 E2E=200`

- DoD sonucu: **UNKNOWN** <!-- PASS / FAIL / PARTIAL -->

DoD artefakt paketi:

- `DoD.txt`  
  - İçerik özeti: Bu release için DoD.txt artefaktı bulunamadı veya CI tarafından üretilmedi. <!-- örn. “DoD check sonuçlarının tam logu” -->
- `last_smoke.txt`  
  - İçerik özeti: Bu release için son smoke koşusuna ait detaylı özet bilgisi bulunamadı. <!-- örn. “En son smoke run çıktıları + tarih” -->
- `last_sha256.txt`  
  - İçerik özeti: Bu release için SHA256 özet bilgisi (last_sha256.txt) bulunamadı. <!-- örn. “Artefakt SHA256 hash değerleri” -->

> Not: Bu bölüm, CI’nin gerçekten DoD’yi geçtiğini tek bakışta göstermeli.  
> Otomasyon tarafında bu alanlar doğrudan DoD artefaktlarından doldurulabilir.

---

## 4) Değişiklik Detayları

### 4.1) Ürün / Kullanıcı Deneyimi (UX / UI)

{UX_CHANGES}

Örnek kullanım (FAZ-42 için stil):

- Landing hero metni güncellendi: {UX_ITEM_1}
- Early access formu eklendi: {UX_ITEM_2}
- Görsel düzenlemeler: {UX_ITEM_3}

### 4.2) Backend / API / Altyapı

{BACKEND_CHANGES}

Örnek alanlar:

- API / servis değişiklikleri: {BACKEND_ITEM_1}
- Konfigürasyon / infra güncellemeleri: {BACKEND_ITEM_2}
- Performans / güvenlik iyileştirmeleri: {BACKEND_ITEM_3}

### 4.3) CI / Geliştirici Deneyimi

{CI_CHANGES}

Örnek alanlar:

- Yeni iş akışları veya güncellemeler: {CI_ITEM_1}
- Test kapsamı / senaryo değişiklikleri: {CI_ITEM_2}
- Developer experience iyileştirmeleri: {CI_ITEM_3}

---

## 5) Bilinen Sorunlar ve Sınırlar

- Bilinen sorunlar:
  - {KNOWN_ISSUE_1}
  - {KNOWN_ISSUE_2}
  - {KNOWN_ISSUE_3}

- Geçici workaround’lar:
  - {WORKAROUND_1}
  - {WORKAROUND_2}

> Not: Bu bölüm boşsa, açıkça “Bu sürüm için bilinen kritik bir sorun yok.” yaz.

---

## 6) Sonraki Adımlar / Faz Planı

- Sonraki faz: **FAZ-{NEXT_PHASE_NO} — {NEXT_PHASE_NAME}**
- Planlanan başlıklar:
  - {NEXT_PHASE_ITEM_1}
  - {NEXT_PHASE_ITEM_2}
  - {NEXT_PHASE_ITEM_3}

Bu release ile zemin hazırlayan konular:

- {FOUNDATION_ITEM_1}
- {FOUNDATION_ITEM_2}

---

## 7) Teknik Meta

- Release URL: {RELEASE_URL}
- Tag: `{TAG}`
- Hedef commit: `{COMMIT}` (branch: `{BRANCH}`)
- CI zinciri kök run: {ROOT_RUN_ID} <!-- opsiyonel, istersen boş bırak -->
- Oluşturan: {AUTHOR}
- Kaynak faz: **FAZ-{FAZ_NO} — {FAZ_NAME}**

