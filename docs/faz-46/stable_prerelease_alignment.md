STABLE ↔ PRE-RELEASE ALIGNMENT // FAZ-46

Tarih: 2025-11-19 (TRT/UTC+3)

Repo: gw\_stack



Amaç:

\- Stable release’lerin, pre-release (draft) zinciriyle ilişkisini tanımlamak.

\- Release body’de, "Bu stable hangi pre-release serisinin sonucu?" sorusuna net cevap verebilecek alanlar için kural seti hazırlamak.

\- Payment-Ready / Launch-Ready hedefleriyle uyumlu, sade bir alignment modeli oluşturmak.



================================================

1\) KAVRAMLAR

================================================



1.1 Pre-release (draft) hatları

-------------------------------

\- Örnek tag’ler:

&nbsp; - `v0.1.1-draft-19306522483`

&nbsp; - `v0.1.1-draft-19327818973`

\- Özellikleri:

&nbsp; - Genellikle `release\_draft` workflow zinciriyle üretilen, CI meta ve artefakt zenginliği yüksek, fakat “son” olmayan release’ler.

&nbsp; - Daha çok iç test, erken doğrulama, CI/DoD takibi için kullanılır.



1.2 Stable release’ler

----------------------

\- Örnek tag:

&nbsp; - `v0.1.4-core`

\- Özellikleri:

&nbsp; - Kullanıcı / müşteri tarafına gösterilmeye hazır, "resmi" release’ler.

&nbsp; - Genellikle manuel `workflow\_dispatch` ile çalışan `release\_stable.yml` üzerinden üretilir.

&nbsp; - Payment-Ready / Launch-Ready yol haritasında esas dikkate alınan release tipi.



================================================

2\) HEDEF: BASİT ALIGNMENT MODELİ

================================================



Hedef:

\- Her stable tag için:

&nbsp; - "Hangi pre-release serisinin üzerine inşa edildi?" sorusuna yanıt verebilmek.

\- Bunu:

&nbsp; - Tag isimlendirmesi,

&nbsp; - Release body içindeki meta alanlar,

&nbsp; - Basit dokümantasyon kuralları ile çözmek.



İlk aşamada:

\- Alignment, dokümantasyon ve naming seviyesinde tutulacak.

\- İlerleyen fazlarda:

&nbsp; - Script’ler stable release body’sine bu bilgiyi otomatik ekleyecek.



================================================

3\) TAG NAMING STRATEJİSİ

================================================



3.1 Prefix / çekirdek versiyon

------------------------------



Varsayım:

\- Hem pre-release hem stable tarafında çekirdek bir "base versiyon" kullanıyoruz:

&nbsp; - Örn.:

&nbsp;   - Pre-release: `v0.1.4-draft-19327818973`

&nbsp;   - Stable:      `v0.1.4-core`



Kural:

\- Base versiyon (örn. `v0.1.4`) sabit kalır, suffix’ler farklı rolleri temsil eder:

&nbsp; - `-draft-XXXX` → CI/testing odaklı pre-release serisi

&nbsp; - `-core`       → üretime hazır stable (temel çekirdek işlev)



3.2 Önerilen alignment kuralı (basit)

-------------------------------------



\- Bir stable tag:

&nbsp; - `vX.Y.Z-core`

\- Buna karşılık gelen pre-release serisi:

&nbsp; - `vX.Y.Z-draft-<anything>`



Yani:

\- `v0.1.4-core` stable’ı:

&nbsp; - `v0.1.4-draft-\*` serisinin "üstüne inşa edildi" kabul edilir.

\- Gerçek hayatta:

&nbsp; - Kullanılan son draft tag, alignment için referans alınır:

&nbsp;   - Örn. `v0.1.4-draft-19327818973`.



Not:

\- Şu an için bu ilişki dokümantatif; ileride script’ler bu mapping’i otomatik bulabilir.



================================================

4\) RELEASE BODY İÇİN ÖNERİLEN ALANLAR (TASLAK)

================================================



Gelecekte (FAZ-47+), stable release body’sine eklenebilecek örnek placeholder alanlar:



4.1 `{SOURCE\_BASE\_VERSION}`

\- Örnek:

&nbsp; - `v0.1.4`

\- Üretim:

&nbsp; - Stable tag’den (`v0.1.4-core`) base kısmın ayrılması.

\- Anlam:

&nbsp; - Hem pre-release hem stable için ortak çekirdek versiyon.



4.2 `{SOURCE\_DRAFT\_TAG}`

\- Örnek:

&nbsp; - `v0.1.4-draft-19327818973`

\- Üretim:

&nbsp; - `v0.1.4-draft-\*` tag’leri arasından:

&nbsp;   - Zaman olarak en son olan,

&nbsp;   - Veya belirli bir kuralı sağlayan (örneğin ALL PASS pipeline) draft tag’i seçilir.

\- Anlam:

&nbsp; - “Bu stable, şu pre-release sonucunu referans alır.”



4.3 `{SOURCE\_PIPELINE\_INFO}`

\- Örnek:

&nbsp; - `Pre-release pipeline: ALL PASS (SMOKE+POST\_SMOKE+SITE\_CHECK)`

\- Üretim:

&nbsp; - Pre-release release body’sindeki `CI\_PIPELINE\_STATUS` ve `DOD\_STATUS` bilgileri üzerinden türetilir.

\- Anlam:

&nbsp; - Stable’in dayandığı pre-release’in kalite sinyallerini özetler.



Not:

\- Bu alanlar FAZ-46’da HENÜZ kodlanmayacak; sadece taslak olarak bu dokümanda tanımlanır.



================================================

5\) ALIGNMENT KULLANIM SENARYOSU

================================================



Örnek senaryo:



1\) Pre-release süreci:

&nbsp;  - Tag: `v0.1.4-draft-19327818973`

&nbsp;  - CI sonucu:

&nbsp;    - `CI\_PIPELINE\_STATUS=ALL PASS`

&nbsp;    - `DOD\_STATUS=PASS`

&nbsp;  - Release body:

&nbsp;    - Tüm teknik detaylar, DoD, CI meta vs. dolu.



2\) Stable süreci:

&nbsp;  - Tag: `v0.1.4-core`

&nbsp;  - `release\_stable.yml` ile:

&nbsp;    - Aynı commit’ten veya ilgili branch’ten checkout.

&nbsp;  - Stable release body’sinde:

&nbsp;    - `{SOURCE\_BASE\_VERSION}=v0.1.4`

&nbsp;    - `{SOURCE\_DRAFT\_TAG}=v0.1.4-draft-19327818973`

&nbsp;    - `{SOURCE\_PIPELINE\_INFO}="ALL PASS / DOD=PASS"` gibi bir özet gösterilebilir.



Fayda:

\- Stable body’si:

&nbsp; - Hem “müşteriye bakan temiz yüz”,

&nbsp; - Hem de “arkasında hangi pre-release / CI geçmişi olduğu” bilgisini taşıyan bir köprü olur.



================================================

6\) PAYMENT-READY / LAUNCH-READY İLE İLİŞKİ

================================================



Payment-Ready (2026-01-01) açısından:

\- Alignment modeli zorunlu değil, ancak:

&nbsp; - Stable bir versiyon ile ödeme entegrasyonu yapılırken:

&nbsp;   - Hangi pre-release/doğrulama serisine dayandığını bilmek, risk yönetimi için önemli.

\- Bu dönemde:

&nbsp; - Alignment kuralı daha çok internal kullanım / dokümantasyon seviyesinde olabilir.



Launch-Ready (2026-01-15) açısından:

\- İlk gerçek müşterilerin sisteme girdiği dönemde:

&nbsp; - Kullanılan stable release’lerin:

&nbsp;   - Hangi pre-release geçmişine dayandığı,

&nbsp;   - Hangi CI ve DoD sinyalleriyle desteklendiği

&nbsp; net olmalı.

\- Alignment bilgisi:

&nbsp; - Release body içinde sade ve anlaşılır bir şekilde gösterildiğinde:

&nbsp;   - Hem teknik ekip,

&nbsp;   - Hem de “iç kalite güveni” tarafı güçlenir.



================================================

7\) UYGULAMA PLANI (FAZ-46 VE SONRASI)

================================================



FAZ-46:

\- Bu doküman ile alignment kuralları sadece TANIMLANIR.

\- Henüz:

&nbsp; - `{SOURCE\_BASE\_VERSION}`, `{SOURCE\_DRAFT\_TAG}`, `{SOURCE\_PIPELINE\_INFO}` gibi alanlar:

&nbsp;   - Template veya script seviyesinde zorunlu hale getirilmez.



FAZ-47+:

\- Alignment bilgisini otomatikleştirmek için olası adımlar:

&nbsp; 1) Tag arama:

&nbsp;    - `git tag` veya GitHub API / `gh` ile:

&nbsp;      - `vX.Y.Z-draft-\*` tag’leri listelenir.

&nbsp;      - En güncel / en uygun (ALL PASS etc.) draft tag seçilir.

&nbsp; 2) Pre-release body okuma:

&nbsp;    - İlgili pre-release body’sinden:

&nbsp;      - `DOD\_STATUS`, `CI\_PIPELINE\_STATUS` gibi alanlar çekilebilir (ileride).

&nbsp; 3) Stable body üretimi:

&nbsp;    - Stable release body’sine:

&nbsp;      - `SOURCE\_BASE\_VERSION`

&nbsp;      - `SOURCE\_DRAFT\_TAG`

&nbsp;      - `SOURCE\_PIPELINE\_INFO`

&nbsp;      alanları otomatik eklenir.



Bu doküman:

\- Stable ↔ pre-release alignment konusunda TEK referans noktası olarak kabul edilir.

\- İlerleyen fazlarda script ve template’ler güncellendikçe, buradaki kurallar da revize edilecektir.



