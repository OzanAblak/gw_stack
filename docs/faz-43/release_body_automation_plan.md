============================================================
FAZ-43 // release_body_template Otomasyon Taslağı (v1)
============================================================

AMAÇ:
- `release_body_template.md` dosyasını kullanarak,
- Release gövdesini (body) otomatik üretmeye uygun bir yol haritası çıkarmak.

------------------------------------------------------------
A) GENEL FİKİR
------------------------------------------------------------

1) CI pipeline (özellikle `release_draft` workflow) içinde bir adım eklenir:
   - Adı örn: `generate_release_body`.

2) Bu adımda çalışan bir script (ör. PowerShell):
   - `docs/faz-43/release_body_template.md` dosyasını okur.
   - Placeholder alanları ({TAG}, {COMMIT}, {SMOKE_RUN_ID} vb.) environment değişkenleriyle doldurur.
   - Ortaya çıkan metni geçici bir dosyaya yazar: `docs/faz-43/release_body_generated.md`.

3) Sonraki adım:
   - `gh release edit {TAG} --notes-file docs/faz-43/release_body_generated.md`
   - Böylece GitHub release body’si bu dosyadan beslenir.

FAZ-43’te:
- Bu tasarım sadece “kağıt üzerinde” netleştirilir.
- İlk script iskeleti yazılır, ama pipeline’a bağlamak bir sonraki faza sarkabilir.

------------------------------------------------------------
B) GEREKLİ GİRDİLER (CI TARAFINDA)
------------------------------------------------------------

Script’in ihtiyacı olan minimum environment değişkenleri:

- `REL_TAG`        → {TAG}
- `REL_TYPE`       → {RELEASE_TYPE}
- `REL_BRANCH`     → {BRANCH}
- `REL_COMMIT`     → {COMMIT}
- `REL_URL`        → {RELEASE_URL}
- `SMOKE_RUN_ID`   → {SMOKE_RUN_ID}
- `POST_SMOKE_RUN_ID`
- `REL_DRAFT_RUN_ID`
- `SITE_CHECK_RUN_ID`
- `CI_PIPELINE_STATUS`
- `DOD_STATUS`

İlk versiyonda:
- Bunların bir kısmı CI context’ten gelir (GITHUB_SHA, GITHUB_REF_NAME vb.).
- Bir kısmı DoD artefaktlarından okunur (DoD.txt, last_smoke.txt, last_sha256.txt).

------------------------------------------------------------
C) ÖRNEK SCRIPT AKIŞI (KONSEPT)
------------------------------------------------------------

1) `templatePath = docs/faz-43/release_body_template.md`
2) `outputPath   = docs/faz-43/release_body_generated.md`
3) `content = templatePath` içeriğini string olarak oku.
4) `content` üzerinde sırasıyla şu replace işlemlerini yap:
   - `{TAG}`             → env.REL_TAG
   - `{RELEASE_TYPE}`    → env.REL_TYPE
   - `{BRANCH}`          → env.REL_BRANCH
   - `{COMMIT}`          → env.REL_COMMIT
   - `{RELEASE_URL}`     → env.REL_URL
   - `{SMOKE_RUN_ID}`    → env.SMOKE_RUN_ID
   - ... (CI alanlarının tamamı)
5) İnsan tarafından yazılacak alanlar (örn. {CHANGE_SUMMARY_SHORT}, {UX_CHANGES}):
   - İlk otomasyon versiyonunda ya boş bırakılır ya da “TODO” kalıbıyla doldurulur.
6) Sonuç string’i `outputPath` içine yaz.
7) CI adımı:
   - `gh release edit $REL_TAG --notes-file $outputPath` komutunu çalıştırır.

------------------------------------------------------------
D) BUGÜN İÇİN PRAKTİK KULLANIM
------------------------------------------------------------

FAZ-43 sonuna kadar minimum seviye:

1) Yeni bir release hazırlarken:
   - `release_body_template.md` dosyasını aç.
   - İlgili placeholder alanları elle doldur (özellikle:
     - {TAG}, {BRANCH}, {COMMIT}, {CHANGE_SUMMARY_SHORT}, CI run id’leri, DoD durumu).

2) Doldurulmuş metni:
   - GitHub release ekranına “body” olarak yapıştır.
   - Veya ayrı bir `release_body_<TAG>.md` dosyası oluşturup arşivle.

3) CI tarafında:
   - DoD artefaktları (DoD.txt, last_smoke.txt, last_sha256.txt) aynı standartta tutulur.
   - İleride script bu dosyalardan beslenebilsin diye formatı korumaya devam et.

Bu seviye, FAZ-43 hedefiyle uyumlu:
- Güçlü, tekrar kullanılabilir bir şablon.
- Alan sözlüğü + otomasyon planı hazır.
- Gerçek otomasyon adımları için net yol haritası var.
