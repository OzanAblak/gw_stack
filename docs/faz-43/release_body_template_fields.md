============================================================
FAZ-43 // release_body_template Alan Sözlüğü (v1)
============================================================

Bu doküman, `docs/faz-43/release_body_template.md` içindeki placeholder alanların
ne anlama geldiğini ve hangi kaynaktan doldurulacağını tarif eder.

------------------------------------------------------------
1) ÇEKİRDEK ALANLAR (HEADER)
------------------------------------------------------------

| Alan              | Açıklama                                             | Kaynak (ilk etap)                 | Otomasyon Adayı |
|-------------------|------------------------------------------------------|-----------------------------------|------------------|
| {TAG}             | Release tag’ı (`v0.1.1-draft-...`)                   | gh release / GitHub UI            | Evet            |
| {RELEASE_TYPE}    | Release türü (Pre-release / Release)                 | Manuel (şimdilik)                 | Evet            |
| {BRANCH}          | Hedef branch (genelde `main`)                        | Manuel veya `git branch` çıktısı  | Evet            |
| {COMMIT}          | Hedef commit SHA (kısa veya tam)                     | Manuel (şimdilik)                 | Evet            |
| {RELEASE_DATE}    | Yayın tarihi                                         | Manuel (FAZ-43’te)                | Evet            |

Not: CI içinden bakıldığında `{TAG}`, `{BRANCH}`, `{COMMIT}`, `{RELEASE_DATE}`
GitHub Actions context + `gh release view` ile otomatik alınabilir.

------------------------------------------------------------
2) ÖZET BÖLÜMÜ
------------------------------------------------------------

| Alan                   | Açıklama                                        | Kaynak            | Otomasyon Adayı |
|------------------------|-------------------------------------------------|-------------------|------------------|
| {CHANGE_SUMMARY_SHORT} | 2–4 cümlelik insan-okur odaklı genel özet       | Manuel            | Kısmen*         |
| {HIGHLIGHT_1}          | Öne çıkan değişiklik maddesi 1                  | Manuel            | Kısmen*         |
| {HIGHLIGHT_2}          | Öne çıkan değişiklik maddesi 2                  | Manuel            | Kısmen*         |
| {HIGHLIGHT_3}          | Öne çıkan değişiklik maddesi 3                  | Manuel            | Kısmen*         |

\* Not: Gelecekte commit mesajlarından / conventional commit’lerden otomatik özet üretme ihtimali var,
ama FAZ-43’te bu kısım bilinçli olarak manuel kalıyor.

------------------------------------------------------------
3) CI ZİNCİRİ ÖZETİ
------------------------------------------------------------

| Alan                     | Açıklama                              | Kaynak (ilk etap)                     | Otomasyon Adayı |
|--------------------------|---------------------------------------|---------------------------------------|------------------|
| {SMOKE_RUN_ID}           | Son smoke run ID                      | Manuel (FAZ-43) / CI context          | Evet            |
| {SMOKE_STATUS}           | smoke sonucu (PASS/FAIL)              | Manuel / DoD.txt / CI context         | Evet            |
| {POST_SMOKE_RUN_ID}      | post_smoke run ID                     | Manuel / CI context                   | Evet            |
| {POST_SMOKE_STATUS}      | post_smoke sonucu                     | Manuel / CI context                   | Evet            |
| {RELEASE_DRAFT_RUN_ID}   | release_draft run ID                  | Manuel / CI context                   | Evet            |
| {RELEASE_DRAFT_STATUS}   | release_draft sonucu                  | Manuel / CI context                   | Evet            |
| {SITE_CHECK_RUN_ID}      | site_check run ID                     | Manuel / CI context                   | Evet            |
| {SITE_CHECK_STATUS}      | site_check sonucu                     | Manuel / CI context                   | Evet            |
| {CI_PIPELINE_STATUS}     | Zincirin genel durumu (örn. ALL PASS)| Manuel (FAZ-43)                       | Evet            |

Gelecekte:
- GitHub Actions içinden zaten her job için run id ve conclusion alınabilir.
- Ayrıca `last_smoke.txt` dosyası da bu bilgiler için fallback kaynağı olabilir.

------------------------------------------------------------
4) DoD ve ARTEFAKT ALANLARI
------------------------------------------------------------

| Alan              | Açıklama                                        | Kaynak (ilk etap)             | Otomasyon Adayı |
|-------------------|-------------------------------------------------|-------------------------------|------------------|
| {DOD_STATUS}      | DoD sonucu (PASS / FAIL / PARTIAL)              | Manuel (FAZ-43’te PASS)       | Evet            |
| {DOD_TXT_DESC}    | DoD.txt içeriğine dair kısa açıklama            | Manuel                        | Evet (özetleme) |
| {LAST_SMOKE_DESC} | last_smoke.txt içeriğinin kısa özeti           | Manuel                        | Evet (özetleme) |
| {LAST_SHA256_DESC}| last_sha256.txt içeriğinin kısa özeti          | Manuel                        | Evet (özetleme) |

Temel fikir:
- Şu an sadece “Bu dosya neyi temsil ediyor?” diye kısa açıklama.
- İleride script, bu dosyaları okuyup otomatik özet çıkarabilir.

------------------------------------------------------------
5) DEĞİŞİKLİK DETAYLARI (Ürün / Backend / CI)
------------------------------------------------------------

Bu alanlar tamamen “release’e özel içerik” ve FAZ-43’te manuel kalacak.

| Alan              | Açıklama                           | Kaynak | Otomasyon Adayı |
|-------------------|------------------------------------|--------|------------------|
| {UX_CHANGES}      | UX değişikliklerinin serbest özeti | Manuel | Hayır           |
| {UX_ITEM_1..3}    | UX değişiklik madde listesi        | Manuel | Hayır           |
| {BACKEND_CHANGES} | Backend değişikliklerinin özeti    | Manuel | Hayır           |
| {BACKEND_ITEM_1..3}| Backend madde listesi             | Manuel | Hayır           |
| {CI_CHANGES}      | CI / DX değişikliklerinin özeti    | Manuel | Hayır           |
| {CI_ITEM_1..3}    | CI / DX madde listesi              | Manuel | Hayır           |

Bu alanlar, ileride story/issue etiketlerinden kısmen beslenebilir ama FAZ-43 kapsamına dahil değil.

------------------------------------------------------------
6) BİLİNEN SORUNLAR ve SONRAKİ ADIMLAR
------------------------------------------------------------

| Alan                 | Açıklama                               | Kaynak | Otomasyon Adayı |
|----------------------|----------------------------------------|--------|------------------|
| {KNOWN_ISSUE_1..3}   | Bu release için bilinen sorunlar       | Manuel | Hayır           |
| {WORKAROUND_1..2}    | Geçici çözümler                        | Manuel | Hayır           |
| {NEXT_PHASE_NO}      | Sonraki faz numarası                   | Manuel | Hayır           |
| {NEXT_PHASE_NAME}    | Sonraki fazın kısa adı                 | Manuel | Hayır           |
| {NEXT_PHASE_ITEM_1..3}| Sonraki faz için planlanan başlıklar  | Manuel | Hayır           |
| {FOUNDATION_ITEM_1..2}| Bu release’in hazırladığı zeminler    | Manuel | Hayır           |

------------------------------------------------------------
7) TEKNİK META ALANLARI
------------------------------------------------------------

| Alan           | Açıklama                                      | Kaynak (ilk etap)         | Otomasyon Adayı |
|----------------|-----------------------------------------------|----------------------------|------------------|
| {RELEASE_URL}  | GitHub release URL’i                          | gh release list/view       | Evet            |
| {ROOT_RUN_ID}  | CI zincirinin kök run ID’si (opsiyonel)       | CI context                 | Evet            |
| {AUTHOR}       | Release’i oluşturan kişi                      | GitHub kullanıcı adı       | Evet            |
| {FAZ_NO}       | Bu release’in beslendiği faz numarası         | Manuel (örn. 43)          | Hayır           |
| {FAZ_NAME}     | Faz kısa adı (örn. “release body tasarımı”)   | Manuel                     | Hayır           |

Bu tablo, FAZ-43 için:
- Hangi alanların “şu an manuel”,
- Hangi alanların “sonraki fazda otomatik doldurulabilir” olduğunu netleştirir.
