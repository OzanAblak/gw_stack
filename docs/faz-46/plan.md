PLAN // GW Stack // FAZ-46 // Payment-Ready \& Release Pipeline Alignment

Tarih: 2025-11-19 (TRT/UTC+3)

Repo: gw\_stack

Branch: main



============================================================

1\) KAPSAM (FAZ-46 NEYİ ÇÖZECEK?)

============================================================



FAZ-46, FAZ-45 ile tanımlanan iki ana hattı birbirine bağlayan bir “köprü faz”:



1\) Release pipeline tarafı:

&nbsp;  - Pre-release (`release\_draft`) ve stable (`release\_stable`) workflow’ları için:

&nbsp;    - Placeholder alanlarının resmi dokümantasyonu,

&nbsp;    - DoD / CI status sinyallerinin standardı,

&nbsp;    - Stable ↔ pre-release ilişkisinin kural seti.



2\) Payment-Ready / Launch-Ready tarafı:

&nbsp;  - FAZ-45’te tanımlanan MASTER CHECKLIST’in repo içinde kalıcı, tek kaynak haline getirilmesi.

&nbsp;  - Payment-Ready (2026-01-01) ve Launch-Ready (2026-01-15) hedeflerinin bu checklist üzerinden takip edilmesi.



Bu fazda ağırlık:

\- Dokümantasyon, kurallar ve checklist inşası (altyapı hazırlığı).

\- Küçük, hedefli teknik dokunuşlar için zemin hazırlama.

\- Sonraki fazlarda yapılacak ödeme entegrasyonu ve UX işlerinin “nehre döküleceği” yatağı netleştirmek.



============================================================

2\) HEDEF TARİHLER (FAZ-45’İN DEVAMI)

============================================================



\- Payment-Ready hedefi:

&nbsp; - Tarih: 2026-01-01

&nbsp; - Tanım:

&nbsp;   - Ödeme entegrasyonu uçtan uca çalışır,

&nbsp;   - Güvenlik / hata yönetimi / loglama minimum standardı sağlar,

&nbsp;   - Kullanıcı ürün içinde ödeme yapıp bir planı aktif hale getirebilir.



\- Launch-Ready hedefi:

&nbsp; - Tarih: 2026-01-15 (baz senaryo)

&nbsp; - Tanım:

&nbsp;   - Payment-Ready’nin üzerine:

&nbsp;     - Landing / pricing / onboarding / ilk izlenim tarafı “vasat değil, küçük ama profesyonel ürün” seviyesine gelir.

&nbsp;     - Müşteri “Ben bunu alıyorum” dediğinde teknik + algı tarafında utandırmayacak deneyim sağlanır.



FAZ-46 bu tarihleri doğrudan gerçekleştirmez; bu tarihleri taşıyan MASTER CHECKLIST’in ilk resmi sürümünü ve pipeline kurallarını oluşturur.



============================================================

3\) FAZ-46 GATE’LERİ (YAPILACAKLAR)

============================================================



GATE-1 — MASTER CHECKLIST’i repo içine taşımak

------------------------------------------------

Amaç:

\- FAZ-45 devir özetinde Bölüm 8 olarak tanımlanan

&nbsp; “MASTER CHECKLIST // PAYMENT-READY / LAUNCH-READY” içeriğini

&nbsp; repo içinde tek, kanonik bir dosyaya taşımak.



Adımlar:

\- `docs/faz-45/devir\_ozeti.md` içine not düş:

&nbsp; - “Checklist’in kanonik sürümü: `docs/faz-46/payment\_launch\_checklist\_v1.md`”

\- Yeni dosya:

&nbsp; - Yol: `docs/faz-46/payment\_launch\_checklist\_v1.md`

&nbsp; - İçerik:

&nbsp;   - FAZ-45 devir özetindeki MASTER CHECKLIST bölümünün aynen taşınmış, küçük başlık düzeltmeleri yapılmış hali.

&nbsp;   - Check maddeleri `\[ ]` / `\[x]` formatında.



Çıktı:

\- Payment-Ready / Launch-Ready için TEK referans dosya.



GATE-2 — release\_body\_template\_fields.md dokümanını oluşturmak/güncellemek

------------------------------------------------

Amaç:

\- Release body template’inde kullanılan tüm placeholder alanlarını:

&nbsp; - Listelemek,

&nbsp; - Sınıflandırmak,

&nbsp; - Payment-Ready / Launch-Ready hedefleriyle ilişkilendirmek.



Adımlar:

\- Dosya oluştur:

&nbsp; - `docs/faz-46/release\_body\_template\_fields.md` (veya mevcutsa güncelle).

\- İçerik:

&nbsp; - Her placeholder için:

&nbsp;   - İsim: `{TAG}`, `{RELEASE\_TYPE}`, `{BRANCH}`, `{COMMIT}`, `{RELEASE\_URL}`, `{RELEASE\_DATE}`, `{SMOKE\_RUN\_ID}`, `{SMOKE\_STATUS}`, `{POST\_SMOKE\_RUN\_ID}`, `{POST\_SMOKE\_STATUS}`, `{SITE\_CHECK\_RUN\_ID}`, `{SITE\_CHECK\_STATUS}`, `{RELEASE\_DRAFT\_RUN\_ID}`, `{RELEASE\_DRAFT\_STATUS}`, `{CI\_PIPELINE\_STATUS}`, `{DOD\_STATUS}`, `{DOD\_TXT\_DESC}`, `{LAST\_SMOKE\_DESC}`, `{LAST\_SHA256\_DESC}`, `{CHANGE\_SUMMARY\_SHORT}` vs.

&nbsp;   - Kategori:

&nbsp;     - `required | optional | auto | artefact-based`

&nbsp;   - Kaynak:

&nbsp;     - `env`, `ci\_artifacts`, `git log`, `helper script` vs.

&nbsp;   - Not:

&nbsp;     - “Payment-Ready için kritik mi?” (E/H)

&nbsp;     - “Sadece release kalitesini mi etkiler?” gibi basit notlar.



Çıktı:

\- Release body alanlarının tek dokümanda resmi listesi ve kullanım standardı.



GATE-3 — DoD ve CI status sinyal standardı (doküman)

------------------------------------------------

Amaç:

\- `{DOD\_STATUS}` ve `{CI\_PIPELINE\_STATUS}` alanlarının anlamını ve üretim mantığını netleştirmek.



Adımlar:

\- Dosya:

&nbsp; - `docs/faz-46/dod\_ci\_status\_policy.md`

\- İçerik:

&nbsp; - `DOD\_STATUS` için olası değerler:

&nbsp;   - `PASS`, `PARTIAL`, `FAIL`, `UNKNOWN` (veya benzeri).

&nbsp; - Öncelik sıralaması:

&nbsp;   - Örn. `FAIL > PARTIAL > PASS > UNKNOWN`.

&nbsp; - `CI\_PIPELINE\_STATUS` için örnek string’ler:

&nbsp;   - `ALL PASS`

&nbsp;   - `SMOKE+POST\_SMOKE+SITE\_CHECK PASS`

&nbsp;   - `SITE\_CHECK SKIPPED`, vs.

&nbsp; - Bu alanların Payment-Ready / Launch-Ready ile ilişkisi:

&nbsp;   - Payment-Ready’de minimum hangi statü kabul edilebilir,

&nbsp;   - Launch-Ready’de beklenen seviye nedir?



Çıktı:

\- CI ve DoD sinyallerinin nasıl okunacağına dair tek referans.



GATE-4 — Stable ↔ pre-release ilişki taslağı

------------------------------------------------

Amaç:

\- Stable release’in, hangi pre-release / draft serisine dayandığının nasıl belirtileceğine dair kural seti hazırlamak.



Adımlar:

\- Dosya:

&nbsp; - `docs/faz-46/stable\_prerelease\_alignment.md`

\- İçerik:

&nbsp; - Naming / tagging stratejisi:

&nbsp;   - Örn. `v0.1.4-core` stable’ı hangi `v0.1.4-draft-...` serisine karşılık gelir?

&nbsp; - Release body’de gösterilecek alan önerileri:

&nbsp;   - `{SOURCE\_DRAFT\_TAG}`, `{SOURCE\_PIPELINE\_INFO}` gibi potansiyel placeholder’lar.

&nbsp; - Uygulama zamanı:

&nbsp;   - Kural seti FAZ-47+’da koda dökülecek, FAZ-46’da sadece taslak netleştirilecek.



Çıktı:

\- Stable ve pre-release ilişkisinin nasıl gösterileceğine dair guideline.



============================================================

4\) FAZ-46’NIN PAYMENT-READY / LAUNCH-READY İLE İLİŞKİSİ

============================================================



FAZ-46 direkt ödeme entegrasyonu yapmayacak; ama:



\- Payment-Ready (2026-01-01) ve Launch-Ready (2026-01-15) hedeflerini taşıyacak:

&nbsp; - MASTER CHECKLIST’in ilk resmi sürümünü repo’ya koyacak,

&nbsp; - Release dokümantasyonunu bu hedeflerle uyumlu hale getirecek,

&nbsp; - CI / DoD sinyallerini standardize ederek, ileride “kalite barı” tanımlamak için altyapı kuracak.



Bu sayede:

\- FAZ-47+ fazlarında yapılacak:

&nbsp; - Ödeme entegrasyonu,

&nbsp; - Landing / onboarding geliştirmeleri,

&nbsp; - Pazarlama hamleleri,

&nbsp; tek bir checklist ve net kalite sinyalleri üzerinden yönetilebilecek.



============================================================

5\) RİSKLER / DİKKAT NOKTALARI

============================================================



\- Risk-1:

&nbsp; - Dokümantasyon fazında kaybolmak, gerçek teknik işlerden kopmak.

&nbsp; - Önlem:

&nbsp;   - GATE bazlı ilerleme:

&nbsp;     - GATE-1 bitti → kısa commit → checklist güncelle.

&nbsp;     - GATE-2 bitti → kısa commit → checklist güncelle. vb.



\- Risk-2:

&nbsp; - MASTER CHECKLIST’in bir kısmını faz içinde, bir kısmını dışında güncellemek ve tek kaynak ilkesini bozmak.

&nbsp; - Önlem:

&nbsp;   - Checklist’in kanonik sürümü `docs/faz-46/payment\_launch\_checklist\_v1.md` olarak kabul edilecek.

&nbsp;   - Devir özetleri checklist’i KOPYA değil, REFERANS olarak gösterecek.



\- Risk-3:

&nbsp; - Stable ↔ pre-release alignment’ı çok karmaşık tasarlamak.

&nbsp; - Önlem:

&nbsp;   - Basit kural: Tek stable, belirli bir pre-release serisinin “finali”dir.

&nbsp;   - Detay, FAZ-47+’da koda dökülür; FAZ-46 sadece sade guideline üretir.



============================================================

6\) ÇIKIŞ KRİTERİ (FAZ-46 TAMAMLANDI DEMEK İÇİN)

============================================================



FAZ-46, aşağıdaki durumlar sağlandığında tamamlanmış sayılır:



1\) `docs/faz-46/payment\_launch\_checklist\_v1.md`:

&nbsp;  - Mevcut MASTER CHECKLIST’in eksiksiz ve güncel ilk sürümü bu dosyada yer alıyor.

&nbsp;  - FAZ-45 devir özetinden referans verildi.



2\) `docs/faz-46/release\_body\_template\_fields.md`:

&nbsp;  - Tüm placeholder alanları listelenmiş,

&nbsp;  - Her biri için kategori (required/optional/auto/artefact-based) belirlenmiş.



3\) `docs/faz-46/dod\_ci\_status\_policy.md`:

&nbsp;  - `DOD\_STATUS` ve `CI\_PIPELINE\_STATUS` değerleri ve öncelik kuralları tanımlanmış.



4\) `docs/faz-46/stable\_prerelease\_alignment.md`:

&nbsp;  - Stable ↔ pre-release ilişkisinin temel kural seti yazılmış.



5\) MASTER CHECKLIST entegrasyonu:

&nbsp;  - Devir özetinde (FAZ-45 ve FAZ-46) checklist dosyasına net referans var.

&nbsp;  - Checklist, sonraki fazlar için tek referans olarak kabul edilmiş.



Bu koşullar sağlandığında:

\- Release pipeline dokümantasyonun ve Payment-Ready / Launch-Ready hedeflerin,

&nbsp; tek bir checklist ve net kurallar üzerinden yönetilebilir hale gelmiş olacak.



