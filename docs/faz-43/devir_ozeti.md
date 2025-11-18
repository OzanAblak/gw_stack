DEVİR ÖZETİ // GW Stack // FAZ-43 // 2025-11-18 (TRT/UTC+3)



============================================================

1\) KAPSAM ÖZETİ (FAZ-43 NEYİ ÇÖZDÜ?)

============================================================



Bu fazın ana amacı, FAZ-41 ve FAZ-42 ile kurulan “CI + DoD + release + landing” omurgası üzerinde

RELEASE BODY tarafını standartlaştırmak ve otomasyona hazır hale getirmekti.



Çıktı seviyesi:



\- Tek seferlik yazılmış release notu yerine:

&nbsp; - Tekrarlanabilir, markdown tabanlı bir release body şablonu kuruldu.

\- Bu şablon için:

&nbsp; - Alan sözlüğü (hangi placeholder ne demek, nereden besleniyor?) hazırlandı.

&nbsp; - Otomasyon taslak dokümanı (CI pipeline içinde nasıl kullanılacağı) yazıldı.

\- İlk otomasyon adımı olarak:

&nbsp; - `generate\_release\_body.ps1` script’i yazıldı.

&nbsp; - Header ve CI/DoD meta alanlarını environment değişkenlerinden doldurur hale getirildi.

\- FAZ-42 release’i için (`v0.1.1-draft-19436033993`):

&nbsp; - `release\_body\_generated.md` dosyası üzerinden gövde üretildi.

&nbsp; - Aynı içerik GitHub’daki pre-release body’sine taşındı ve yedeklendi.



Sonuç olarak FAZ-43 sonunda:

\- Release body artık “standart bir formatta” üretilebilir durumda.

\- Bir sonraki fazda doğrudan CI pipeline’a entegre edilebilecek tasarım ve script hazır.



============================================================

2\) HAZIRLANAN DOSYALAR (FAZ-43 ARTEFAKTLARI)

============================================================



Proje kök: `C:\\Users\\DELL\\Desktop\\gw\_stack`



1\) Release body şablonu:

&nbsp;  - Yol: `docs\\faz-43\\release\_body\_template.md`

&nbsp;  - Amaç:

&nbsp;    - Tüm release’ler için ortak gövde yapısını tanımlar.

&nbsp;  - Öne çıkan placeholder alanlar:

&nbsp;    - Header/meta:

&nbsp;      - `{TAG}`, `{RELEASE\_TYPE}`, `{BRANCH}`, `{COMMIT}`, `{RELEASE\_DATE}`, `{RELEASE\_URL}`

&nbsp;    - Özet:

&nbsp;      - `{CHANGE\_SUMMARY\_SHORT}`, `{HIGHLIGHT\_1..3}`

&nbsp;    - CI zinciri:

&nbsp;      - `{SMOKE\_RUN\_ID}`, `{SMOKE\_STATUS}`, `{POST\_SMOKE\_RUN\_ID}`, `{POST\_SMOKE\_STATUS}`,

&nbsp;        `{RELEASE\_DRAFT\_RUN\_ID}`, `{RELEASE\_DRAFT\_STATUS}`, `{SITE\_CHECK\_RUN\_ID}`,

&nbsp;        `{SITE\_CHECK\_STATUS}`, `{CI\_PIPELINE\_STATUS}`

&nbsp;    - DoD:

&nbsp;      - `{DOD\_STATUS}`, `{DOD\_TXT\_DESC}`, `{LAST\_SMOKE\_DESC}`, `{LAST\_SHA256\_DESC}`

&nbsp;    - Detay alanlar:

&nbsp;      - `{UX\_CHANGES}`, `{BACKEND\_CHANGES}`, `{CI\_CHANGES}` ve ilgili madde listeleri

&nbsp;    - Diğer:

&nbsp;      - Bilinen sorunlar, sonraki faz planı, teknik meta alanları.



2\) Alan sözlüğü:

&nbsp;  - Yol: `docs\\faz-43\\release\_body\_template\_fields.md`

&nbsp;  - Amaç:

&nbsp;    - Template içindeki her placeholder için:

&nbsp;      - Ne anlama geliyor?

&nbsp;      - İlk etapta nereden doldurulacak? (manuel / CI context / DoD artefaktları)

&nbsp;      - Gelecekte otomasyona uygun mu?

&nbsp;    - Otomasyon sırasında “hangi env hangi placeholder’a gider?” sorusuna net cevap verir.



3\) Otomasyon taslak dokümanı:

&nbsp;  - Yol: `docs\\faz-43\\release\_body\_automation\_plan.md`

&nbsp;  - Amaç:

&nbsp;    - `release\_body\_template.md` dosyasının CI pipeline içinde nasıl kullanılacağını tarif eder.

&nbsp;  - Önerilen akış:

&nbsp;    1. CI’de `generate\_release\_body` adımı:

&nbsp;       - Template’i okur.

&nbsp;       - Placeholder’ları env değişkenleriyle doldurur.

&nbsp;       - `release\_body\_generated.md` üretir.

&nbsp;    2. Sonraki adım:

&nbsp;       - `gh release edit {TAG} --notes-file release\_body\_generated.md`

&nbsp;    3. Uzun vadede:

&nbsp;       - DoD artefaktları ve CI context’ten veri çekme,

&nbsp;       - Bazı alanları otomatik özetleme (change summary) opsiyonu.



4\) PowerShell script (otomasyon iskeleti):

&nbsp;  - Yol: `scripts\\generate\_release\_body.ps1`

&nbsp;  - Amaç:

&nbsp;    - Template’ten release body üretmek için ilk otomasyon adımı.

&nbsp;  - Temel özellikler:

&nbsp;    - Template ve output path’leri absolute:

&nbsp;      - Template: `docs\\faz-43\\release\_body\_template.md`

&nbsp;      - Output:   `docs\\faz-43\\release\_body\_generated.md`

&nbsp;    - Placeholder → env haritası (v1):

&nbsp;      - Header/meta:

&nbsp;        - `{TAG}`          ← `REL\_TAG`

&nbsp;        - `{RELEASE\_TYPE}` ← `REL\_TYPE`

&nbsp;        - `{BRANCH}`       ← `REL\_BRANCH`

&nbsp;        - `{COMMIT}`       ← `REL\_COMMIT`

&nbsp;        - `{RELEASE\_URL}`  ← `REL\_URL`

&nbsp;      - CI zinciri:

&nbsp;        - `{SMOKE\_RUN\_ID}`          ← `SMOKE\_RUN\_ID`

&nbsp;        - `{SMOKE\_STATUS}`          ← `SMOKE\_STATUS`

&nbsp;        - `{POST\_SMOKE\_RUN\_ID}`     ← `POST\_SMOKE\_RUN\_ID`

&nbsp;        - `{POST\_SMOKE\_STATUS}`     ← `POST\_SMOKE\_STATUS`

&nbsp;        - `{RELEASE\_DRAFT\_RUN\_ID}`  ← `RELEASE\_DRAFT\_RUN\_ID`

&nbsp;        - `{RELEASE\_DRAFT\_STATUS}`  ← `RELEASE\_DRAFT\_STATUS`

&nbsp;        - `{SITE\_CHECK\_RUN\_ID}`     ← `SITE\_CHECK\_RUN\_ID`

&nbsp;        - `{SITE\_CHECK\_STATUS}`     ← `SITE\_CHECK\_STATUS`

&nbsp;        - `{CI\_PIPELINE\_STATUS}`    ← `CI\_PIPELINE\_STATUS`

&nbsp;      - DoD:

&nbsp;        - `{DOD\_STATUS}`            ← `DOD\_STATUS`

&nbsp;    - Env değişkeni boşsa:

&nbsp;      - Placeholder olduğu gibi bırakılır (boş string yazılmaz).

&nbsp;    - Çıktı dosyası:

&nbsp;      - `docs\\faz-43\\release\_body\_generated.md` (UTF-8).



5\) Örnek üretilmiş release body:

&nbsp;  - Yol: `docs\\faz-43\\release\_body\_generated.md`

&nbsp;  - Durum:

&nbsp;    - FAZ-42 için gerçek verilerle doldurulmuş, kullanılabilir örnek release notu.

&nbsp;    - Aynı içerik GitHub’da `v0.1.1-draft-19436033993` pre-release body’sine kopyalanmış durumda.



============================================================

3\) YAPILAN TESTLER

============================================================



TEST-1 — Dry-run (env’siz temel doğrulama):



\- Komut:

&nbsp; - `powershell -ExecutionPolicy Bypass -File "scripts\\generate\_release\_body.ps1"`

\- Beklenti:

&nbsp; - Template dosyası bulunur.

&nbsp; - `release\_body\_generated.md` üretilir.

&nbsp; - Hata (kırmızı satır) yok.

\- Sonuç:

&nbsp; - Script template’i okuyup output dosyasını oluşturdu.

&nbsp; - Placeholder’lar doğal olarak template’teki gibi kaldı.



TEST-2 — FAZ-42 verileriyle header + CI meta doldurma:



\- Kullanılan değerler:

&nbsp; - TAG: `v0.1.1-draft-19436033993`

&nbsp; - RELEASE\_TYPE: `Pre-release`

&nbsp; - BRANCH: `main`

&nbsp; - COMMIT: `09393aa`

&nbsp; - RELEASE\_URL:

&nbsp;   - `https://github.com/OzanAblak/gw\_stack/releases/tag/v0.1.1-draft-19436033993`

&nbsp; - CI run ID’leri:

&nbsp;   - SMOKE\_RUN\_ID:        `19436018818`

&nbsp;   - POST\_SMOKE\_RUN\_ID:   `19436027603`

&nbsp;   - RELEASE\_DRAFT\_RUN\_ID:`19436033993`

&nbsp;   - SITE\_CHECK\_RUN\_ID:   `19436018944`

&nbsp; - CI status:

&nbsp;   - `CI\_PIPELINE\_STATUS = "ALL PASS"`

&nbsp;   - Tüm job status’leri `PASS`

&nbsp; - DoD:

&nbsp;   - `DOD\_STATUS = "PASS"`



\- Çalıştırma:

&nbsp; - Env değişkenleri set edildi, ardından `generate\_release\_body.ps1` çalıştı.



\- Sonuç:

&nbsp; - Header:

&nbsp;   - `{TAG}`          → `v0.1.1-draft-19436033993`

&nbsp;   - `{RELEASE\_TYPE}` → `Pre-release`

&nbsp;   - `{BRANCH}`       → `main`

&nbsp;   - `{COMMIT}`       → `09393aa`

&nbsp; - CI tablosu:

&nbsp;   - `{SMOKE\_RUN\_ID}`          → `19436018818`

&nbsp;   - `{POST\_SMOKE\_RUN\_ID}`     → `19436027603`

&nbsp;   - `{RELEASE\_DRAFT\_RUN\_ID}`  → `19436033993`

&nbsp;   - `{SITE\_CHECK\_RUN\_ID}`     → `19436018944`

&nbsp;   - `{CI\_PIPELINE\_STATUS}`    → `ALL PASS`

&nbsp; - DoD:

&nbsp;   - `{DOD\_STATUS}` → `PASS`

&nbsp; - Script hata vermeden tamamlandı, `release\_body\_generated.md` güncellendi.



Not:

\- Encoding kaynaklı Türkçe karakter bozulmaları (â, Ä vb.) fonksiyonel olmayan, sadece kozmetik bir durum.

\- Template başlıkları ASCII’ye sadeleştirilerek bu etki azaltılabilir.



============================================================

4\) KURALLAR VE KARARLAR (FAZ-43 SONU)

============================================================



KURAL-1 — Release body standardı:

\- Tüm release notları, `release\_body\_template.md` yapısına göre yazılmalı.

\- Şablon, hem manuel hem otomatik üretime uygun olarak korunmalı.



KURAL-2 — Otomatik / manuel ayrımı:

\- Otomasyon için hedeflenen alanlar:

&nbsp; - Header/meta: TAG, RELEASE\_TYPE, BRANCH, COMMIT, RELEASE\_URL, RELEASE\_DATE (kısmen).

&nbsp; - CI meta: SMOKE/POST\_SMOKE/RELEASE\_DRAFT/SITE\_CHECK run id + status, CI\_PIPELINE\_STATUS.

&nbsp; - DOD\_STATUS.

\- Manuel kalmaya devam edecek alanlar:

&nbsp; - CHANGE\_SUMMARY\_SHORT, HIGHLIGHT maddeleri.

&nbsp; - UX/BACKEND/CI değişiklik detayları.

&nbsp; - Bilinen sorunlar, workaround’lar.

&nbsp; - Sonraki faz plan maddeleri, FAZ\_NO / FAZ\_NAME.



KARAR-1 — Script kullanım modeli (FAZ-43 seviyesi):

\- Kısa vadede:

&nbsp; - Yeni release hazırlanırken:

&nbsp;   1. Env değişkenleri set edilir (TAG, BRANCH, CI run id’leri vb.).

&nbsp;   2. `generate\_release\_body.ps1` ile `release\_body\_generated.md` üretilir.

&nbsp;   3. Dosya açılıp manuel alanlar doldurulur.

&nbsp;   4. GitHub release body’sine kopyalanır.

\- Orta vadede:

&nbsp; - Script bir GitHub Actions adımı olarak `release\_draft` workflow’una taşınır.

&nbsp; - Env değişkenleri GitHub context + DoD artefaktları üzerinden otomatik set edilir.



KARAR-2 — Pre-release stratejisi:

\- `v0.1.1-draft-...` serisi pre-release olarak devam edecek.

\- “Latest stable” flag’i sadece gerçekten prod’a giden sürümlere atanacak.

\- FAZ-43 çıktıları, ilerideki stable release’ler için de kullanılacak bir standardı hazırlamış durumda.



============================================================

5\) SONRAKİ ADIM ÖNERİSİ (FAZ-44 İÇİN)

============================================================



FAZ-44 için önerilen odak:



1\) CI entegrasyonu:

&nbsp;  - `release\_draft` workflow’unda:

&nbsp;    - `generate\_release\_body.ps1` adımını gerçek bir job olarak eklemek.

&nbsp;    - Gerekli env değişkenlerini GitHub Actions context’ten beslemek:

&nbsp;      - `GITHUB\_REF\_NAME` → BRANCH

&nbsp;      - `GITHUB\_SHA`      → COMMIT

&nbsp;      - Job run id’leri → workflow context

&nbsp;  - `gh release edit` ile body’yi otomatik güncellemek.



2\) DoD artefaktlarının kullanımı:

&nbsp;  - `DoD.txt`, `last\_smoke.txt`, `last\_sha256.txt` formatını sabitleyip,

&nbsp;  - Script’in bu dosyalardan:

&nbsp;    - DOD\_STATUS,

&nbsp;    - LAST\_SMOKE\_DESC,

&nbsp;    - LAST\_SHA256\_DESC gibi özet alanları üretmesini sağlamak.



3\) Kullanıcı odaklı özet:

&nbsp;  - `CHANGE\_SUMMARY\_SHORT` ve `HIGHLIGHT\_1..3` için:

&nbsp;    - Commit mesaj pattern’leri,

&nbsp;    - Label veya milestone bilgileri üzerinden yarı otomatik özetleme araştırması.



Bu devir özeti ile FAZ-43:



\- Release notu gövdesini tasarlayan,

\- Bunu tekrar kullanılabilir bir şablona çeviren,

\- İlk otomasyon script’iyle CI entegrasyonuna hazır hale getiren faz olarak kapanmıştır.



