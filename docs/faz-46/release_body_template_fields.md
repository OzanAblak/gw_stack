RELEASE BODY TEMPLATE FIELDS // FAZ-46

Tarih: 2025-11-19 (TRT/UTC+3)

Repo: gw\_stack

İlgili scriptler:

\- scripts/generate\_release\_body.ps1

\- scripts/resolve\_ci\_meta.ps1

\- ci\_artifacts/\*



Not:

\- Bu doküman, release body template’inde kullanılabilen TÜM placeholder alanlarını listeler.

\- Her alan için:

&nbsp; - Kategori: required | optional | auto | artefact-based

&nbsp; - Kaynak: env | ci\_artifacts | git log | helper script

&nbsp; - Payment-Ready / Launch-Ready ile ilişkisi: kritik mi, kaliteyi mi etkiliyor?



KATEGORİ TANIMLARI

------------------

\- required:

&nbsp; - Release body’nin minimum anlamlı olması için doldurulması gereken alanlar.

\- optional:

&nbsp; - Boş kalırsa release body yine kullanılabilir, sadece bilgi eksik olur.

\- auto:

&nbsp; - Değeri kullanıcı tarafından değil, script/pipeline tarafından otomatik üretilen alanlar.

\- artefact-based:

&nbsp; - Değeri, CI artefaktlarından (DoD.txt, last\_smoke.txt, last\_sha256.txt vb.) gelen alanlar.



================================================

1\) GENEL RELEASE BİLGİLERİ

================================================



1.1 `{TAG}`

\- Kategori: required

\- Kaynak: env (`REL\_TAG`)

\- Açıklama:

&nbsp; - Release’in tag adını temsil eder (örn. `v0.1.4-core`, `v0.1.1-draft-19327818973`).

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için kritik (hangi yapı deploy edildiğini gösterir).



1.2 `{RELEASE\_TYPE}`

\- Kategori: required

\- Kaynak: env (`REL\_TYPE`)

\- Açıklama:

&nbsp; - `Pre-release`, `Stable` gibi release türünü gösterir.

\- Payment-Ready / Launch-Ready:

&nbsp; - Kritik; kullanıcı ve internal ekip için release’in doğasını anlatır.



1.3 `{BRANCH}`

\- Kategori: required

\- Kaynak: env (`REL\_BRANCH`)

\- Açıklama:

&nbsp; - Release’in üretildiği branch (örn. `main`).

&nbsp; - Stable tarafında detached HEAD durumu göz önünde bulundurulmalıdır.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready’de `main` gibi net ve güvenilir bir branch’tan geliyor olması beklenir (kural dokümanlarda netleştirilecek).



1.4 `{COMMIT}`

\- Kategori: required

\- Kaynak: env (`REL\_COMMIT`)

\- Açıklama:

&nbsp; - Release’in bağlı olduğu commit SHA değeri (örn. `fe87f7e...`).

\- Payment-Ready / Launch-Ready:

&nbsp; - Kritik; hata durumunda hangi commit’in canlıda olduğunu bilmek için gereklidir.



1.5 `{RELEASE\_URL}`

\- Kategori: required

\- Kaynak: env (`REL\_URL`) — deterministik olarak `releases/tag/{TAG}` formatında üretilebilir.

\- Açıklama:

&nbsp; - GitHub üzerindeki release sayfasına doğrudan link.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için önemli; debug ve audit süreçlerinde referans noktası.



1.6 `{RELEASE\_DATE}`

\- Kategori: required

\- Kaynak: env (`REL\_DATE`)

\- Açıklama:

&nbsp; - Release’in üretildiği tarih/zaman (genelde UTC).

\- Payment-Ready / Launch-Ready:

&nbsp; - Kritik; özellikle stable/pazarlama tarafında zaman çizelgesi takibi için.



================================================

2\) PIPELINE / CI METRİKLERİ

================================================



2.1 `{SMOKE\_RUN\_ID}`

\- Kategori: auto

\- Kaynak: helper script (`resolve\_ci\_meta.ps1`) + env override

\- Açıklama:

&nbsp; - Son başarılı smoke run’ının ID’si (`gh run` `databaseId`).

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için önemli; en az bir başarılı smoke koşusu referansı beklenir.



2.2 `{SMOKE\_STATUS}`

\- Kategori: auto

\- Kaynak: helper script + env

\- Açıklama:

&nbsp; - Smoke pipeline’ının durumu (`success`, `failure`, `UNKNOWN` vb.).

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready’de ideal değer: `success`.



2.3 `{POST\_SMOKE\_RUN\_ID}`

\- Kategori: auto

\- Kaynak: helper script + env

\- Açıklama:

&nbsp; - Son başarılı post\_smoke run’ının ID’si.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için önemli; release\_draft’ı tetikleyen zincirin sağlığı için.



2.4 `{POST\_SMOKE\_STATUS}`

\- Kategori: auto

\- Kaynak: helper script + env

\- Açıklama:

&nbsp; - post\_smoke pipeline’ının durumu.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready’de ideal değer: `success`.



2.5 `{SITE\_CHECK\_RUN\_ID}`

\- Kategori: auto | optional

\- Kaynak: helper script + env

\- Açıklama:

&nbsp; - Son başarılı site\_check run’ının ID’si.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için güçlü sinyal (site sağlığı).

&nbsp; - Mevcutta opsiyonel; ileride “mandatory” hale gelebilir.



2.6 `{SITE\_CHECK\_STATUS}`

\- Kategori: auto | optional

\- Kaynak: helper script + env

\- Açıklama:

&nbsp; - site\_check pipeline’ının durumu.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready’de ideal değer: `success` veya en azından `SKIPPED` değil.



2.7 `{RELEASE\_DRAFT\_RUN\_ID}`

\- Kategori: auto

\- Kaynak: env (`GITHUB\_RUN\_ID`)

\- Açıklama:

&nbsp; - release\_draft workflow run ID’si (pre-release tarafı için).

\- Payment-Ready / Launch-Ready:

&nbsp; - İzlenebilirlik için önemli; kritik sorun yaşandığında “hangi run ile release üretildi?” sorusunu cevaplar.



2.8 `{RELEASE\_DRAFT\_STATUS}`

\- Kategori: auto

\- Kaynak: env / helper

\- Açıklama:

&nbsp; - release\_draft workflow’unun durumu.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için `success` olması beklenir.



2.9 `{CI\_PIPELINE\_STATUS}`

\- Kategori: auto

\- Kaynak: script içi mantık (`generate\_release\_body.ps1` + `resolve\_ci\_meta.ps1`)

\- Açıklama:

&nbsp; - Pipeline genel özet string’i:

&nbsp;   - Örn. `ALL PASS`, `SMOKE+POST\_SMOKE+SITE\_CHECK PASS`, `SITE\_CHECK SKIPPED`, vb.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için “en azından smoke + post\_smoke PASS” beklenir.

&nbsp; - Detaylı politika `dod\_ci\_status\_policy.md` dokümanında tanımlanacaktır.



================================================

3\) DoD / ARTEFAKT TEMELLİ ALANLAR

================================================



3.1 `{DOD\_STATUS}`

\- Kategori: auto

\- Kaynak: `ci\_artifacts/DoD.txt` + env + script mantığı

\- Açıklama:

&nbsp; - Definition of Done durumunu özetleyen alan: `PASS`, `PARTIAL`, `FAIL`, `UNKNOWN` gibi değerler alır.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready’de asgari seviye: `PASS` veya belirli bir min seviye (politika ile netleştirilecek).

&nbsp; - Politika için: `docs/faz-46/dod\_ci\_status\_policy.md`.



3.2 `{DOD\_TXT\_DESC}`

\- Kategori: artefact-based | optional

\- Kaynak: `ci\_artifacts/DoD.txt`

\- Açıklama:

&nbsp; - DoD.txt içeriğinin insan okunur özeti / tamamı.

&nbsp; - Dosya yoksa veya okunamazsa, fallback metin kullanılır.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için zorunlu değil,

&nbsp; - Launch-Ready / kalite dokümantasyonu için önemli.



3.3 `{LAST\_SMOKE\_DESC}`

\- Kategori: artefact-based | optional

\- Kaynak: `ci\_artifacts/last\_smoke.txt`

\- Açıklama:

&nbsp; - Son smoke koşusuna ait detaylı özet (ör. endpoint sonuçları, süreler vb.).

&nbsp; - Dosya yoksa, fallback açıklama kullanılır.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için “nice-to-have”,

&nbsp; - Problemler olduğunda debug kolaylığı sağlar.



3.4 `{LAST\_SHA256\_DESC}`

\- Kategori: artefact-based | optional

\- Kaynak: `ci\_artifacts/last\_sha256.txt`

\- Açıklama:

&nbsp; - Release ile ilişkili artefaktların SHA256 özet bilgisi.

&nbsp; - Dosya yoksa fallback mesaj gösterilir.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için zorunlu değil,

&nbsp; - Artefakt doğrulama / güvenlik için değerli.



================================================

4\) CHANGE SUMMARY / GİT LOG TABANLI ALANLAR

================================================



4.1 `{CHANGE\_SUMMARY\_SHORT}`

\- Kategori: auto

\- Kaynak: `git log --pretty="- %h %s" -n 10`

\- Açıklama:

&nbsp; - Son 10 commit’in kısa formatta markdown bullet listesi.

&nbsp; - Git bilgisi alınamazsa, fallback açıklama yazılır.

\- Payment-Ready / Launch-Ready:

&nbsp; - Payment-Ready için zorunlu değil,

&nbsp; - Launch-Ready’de release’i anlamlandırmak için önemli (hem teknik hem ürün tarafı).



================================================

5\) İLERİDE EKLENEBİLECEK ALANLAR (TASLAK)

================================================



Not:

\- Bu bölüm, FAZ-46’dan sonra eklenebilecek yeni placeholder’lar için taslak alanıdır.

\- Örnekler:

&nbsp; - `{SOURCE\_DRAFT\_TAG}`:

&nbsp;   - Stable release’in dayandığı pre-release tag.

&nbsp; - `{SOURCE\_PIPELINE\_INFO}`:

&nbsp;   - Bu stable’ın beslendiği pre-release pipeline özet bilgisi.

\- Bu alanlar kullanılmaya başlandığında:

&nbsp; - Kategori, kaynak ve Payment-Ready / Launch-Ready ilişkisi burada güncellenecektir.



================================================

6\) PAYMENT-READY / LAUNCH-READY İLE İLİŞKİ ÖZETİ

================================================



ÖZET:

\- Payment-Ready (2026-01-01) için:

&nbsp; - REQUIRED alanlar:

&nbsp;   - `{TAG}`, `{RELEASE\_TYPE}`, `{BRANCH}`, `{COMMIT}`, `{RELEASE\_URL}`, `{RELEASE\_DATE}`

&nbsp; - CI / pipeline tarafında:

&nbsp;   - `{SMOKE\_STATUS}`, `{POST\_SMOKE\_STATUS}`, `{RELEASE\_DRAFT\_STATUS}`, `{CI\_PIPELINE\_STATUS}`

&nbsp;   - DoD tarafında:

&nbsp;     - `{DOD\_STATUS}`’ün en azından kabul edilebilir bir seviyede olması (politika dokümanına göre).

\- Launch-Ready (2026-01-15) için:

&nbsp; - Payment-Ready alanlarına ek olarak:

&nbsp;   - `{CHANGE\_SUMMARY\_SHORT}` gibi alanların dolu olması,

&nbsp;   - `{DOD\_TXT\_DESC}`, `{LAST\_SMOKE\_DESC}`, `{LAST\_SHA256\_DESC}` gibi artefact tabanlı alanların mümkün olduğunca doldurulması,

&nbsp;   - Release body’nin sadece teknik değil, ürün/pazarlama açısından da anlamlı bir hikâye taşıması beklenir.



Bu doküman, ilerleyen fazlarda placeholder eklenip çıkarıldıkça güncellenecek; release body template’iyle ilgili TEK referans kaynağı olarak kabul edilir.



