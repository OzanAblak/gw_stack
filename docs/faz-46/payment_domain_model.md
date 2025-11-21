PAYMENT DOMAIN MODEL // FAZ-46

Tarih: 2025-11-19 (TRT/UTC+3)

Repo: gw\_stack



Amaç:

\- Payment-Ready hedefi için minimum domain modelini netleştirmek:

&nbsp; - Kullanıcı → Plan → Abonelik → Ödeme denemesi / işlem zinciri.

\- Bu doküman, gerçek kod/DB tasarımında referans alınacak şema taslağıdır.

\- Uygulama dili / teknoloji bağımsızdır; alan isimleri ve status setleri ana kaynaktır.



================================================

1\) TEMEL VARLIKLAR (ENTITIES)

================================================



Bu model 3 çekirdek entity üzerine kurulu:



1\. PLAN

2\. SUBSCRIPTION (Abonelik)

3\. PAYMENT\_ATTEMPT (Ödeme denemesi / işlem)



Kullanıcı (USER) kavramı sistemde zaten var kabul ediliyor; burada tekrar tanımlanmıyor.



------------------------------------------------

1.1 PLAN

------------------------------------------------



Amaç:

\- Fiyatlandırma / teklif tarafında MASTER CHECKLIST ile eşleşen ürün-plan bilgisini temsil eder.



Önerilen alanlar:



\- `id`

&nbsp; - Sistem içi benzersiz kimlik (int/uuid vs.).

\- `code`

&nbsp; - İnsan okunur, kısa kod (örn. `starter`, `pro`, `enterprise`).

\- `name`

&nbsp; - Ekranda görünen isim (örn. `Starter Plan`).

\- `description`

&nbsp; - Kısa açıklama (isteğe bağlı).

\- `billing\_period`

&nbsp; - Örn. `monthly`, `yearly`.

\- `price\_amount`

&nbsp; - Örn. `29.00`.

\- `price\_currency`

&nbsp; - Örn. `USD`, `EUR`, `TRY`.

\- `gateway\_price\_id`

&nbsp; - Ödeme sağlayıcısındaki karşılık (örn. Stripe `price\_XXX`, iyzico `planId` vb.).

\- `is\_active`

&nbsp; - Plan şuan satılabilir mi? (bool).



Not:

\- Geliştirme döneminde tek plan kullanıyorsak:

&nbsp; - En az bir `starter` planı bu şema ile tanımlamak yeterli.



------------------------------------------------

1.2 SUBSCRIPTION (ABONELİK)

------------------------------------------------



Amaç:

\- Bir kullanıcının (USER) belirli bir plan (PLAN) için ödeme ile ilişkilendirilmiş durumunu tutar.



Önerilen alanlar:



\- `id`

&nbsp; - Benzersiz abonelik kimliği.

\- `user\_id`

&nbsp; - Aboneliğin sahibi kullanıcı.

\- `plan\_id`

&nbsp; - Bağlı olduğu plan.

\- `status`

&nbsp; - Abonelik durumu (enum, aşağıda detaylı).

\- `start\_date`

&nbsp; - Abonelik başlangıç tarihi.

\- `current\_period\_start`

&nbsp; - İçinde bulunulan fatura döneminin başlangıcı.

\- `current\_period\_end`

&nbsp; - İçinde bulunulan fatura döneminin bitişi.

\- `trial\_end`

&nbsp; - Deneme süresi varsa, bitiş tarihi (opsiyonel).

\- `cancel\_at`

&nbsp; - Gelecekte iptal edilecek tarih (ör. dönem sonu iptal).

\- `canceled\_at`

&nbsp; - İptal gerçekten ne zaman gerçekleşti.

\- `last\_payment\_at`

&nbsp; - Son başarılı ödeme tarihi (opsiyonel).

\- `external\_subscription\_id`

&nbsp; - Ödeme sağlayıcısındaki abonelik ID’si (varsa).

\- `metadata`

&nbsp; - Ek alanlar için esnek yapı (json vb., opsiyonel).



Abonelik STATUS değerleri (önerilen set):



\- `trial`

&nbsp; - Deneme süresi aktif.

\- `active`

&nbsp; - Ödeme alınmış, abonelik sorunsuz devam ediyor.

\- `past\_due`

&nbsp; - Ödeme gecikmiş (ödeme denemesi başarısız olmuş, ama sistem tamamen kapalı değil).

\- `canceled`

&nbsp; - Abonelik sonlandırılmış.

\- `incomplete`

&nbsp; - İlk ödeme işlemi tamamlanmamış (ör. kullanıcı ödeme adımını yarıda bıraktı).

\- `incomplete\_expired`

&nbsp; - İlk ödeme uzun süre tamamlanmadığı için abonelik geçersiz sayıldı.

\- `paused` (opsiyonel)

&nbsp; - Abonelik geçici olarak duraklatılmış (ileride gerekirse).



Not:

\- Bu status seti:

&nbsp; - Stripe/benzeri sistemlerin mantığına yakın,

&nbsp; - Ama sistemin kendi ihtiyaçlarına göre sadeleştirilebilir.

\- Payment-Ready için kritik olan:

&nbsp; - `active`, `past\_due`, `canceled`, `incomplete` ayrımlarının net olması.



------------------------------------------------

1.3 PAYMENT\_ATTEMPT (ÖDEME DENEMESİ / İŞLEM)

------------------------------------------------



Amaç:

\- Her ödeme girişimini ve sonucunu kaydetmek:

&nbsp; - Tek seferlik ödemeler,

&nbsp; - Abonelik yenileme ödemeleri,

&nbsp; - Başarısız denemeler.



Önerilen alanlar:



\- `id`

&nbsp; - Benzersiz işlem/deneme kimliği.

\- `subscription\_id`

&nbsp; - Hangi aboneliğe bağlı olduğu (yoksa tek seferlik kullanımda opsiyonel).

\- `user\_id`

&nbsp; - Denemeyi tetikleyen kullanıcı (gerekirse).

\- `provider`

&nbsp; - Örn. `stripe`, `iyzico`, `mock`.

\- `provider\_payment\_id`

&nbsp; - Ödeme sağlayıcısındaki işlem ID’si.

\- `amount`

&nbsp; - Denenen tahsilat tutarı.

\- `currency`

&nbsp; - Para birimi (`USD`, `TRY` vb.).

\- `status`

&nbsp; - Ödeme denemesinin sonucu (enum, aşağıda).

\- `error\_code`

&nbsp; - Ödeme sağlayıcısının hata kodu (varsa).

\- `error\_message`

&nbsp; - Kullanıcıya gösterilmeyecek teknik mesaj (log için).

\- `user\_facing\_message`

&nbsp; - Kullanıcıya gösterilebilecek sade/hijyenik mesaj (opsiyonel).

\- `created\_at`

&nbsp; - Denemenin oluşturulma zamanı.

\- `updated\_at`

&nbsp; - Son güncelleme zamanı.

\- `raw\_provider\_payload`

&nbsp; - Provider’dan gelen ham veri (gerekirse maskeleme/encrypt ile).



PAYMENT\_ATTEMPT STATUS değerleri (önerilen set):



\- `pending`

&nbsp; - İşlem başlatıldı, henüz sonuç yok / kullanıcı aksiyon bekleniyor.

\- `succeeded`

&nbsp; - Ödeme başarıyla tamamlandı.

\- `failed`

&nbsp; - Ödeme reddedildi veya hata oluştu.

\- `refunded`

&nbsp; - Daha önce başarılı olan işlem iade edildi (tam veya kısmi).

\- `canceled`

&nbsp; - Kullanıcı veya sistem denemeyi iptal etti (örn. redirect sayfasından geri döndü).



Not:

\- Payment-Ready için:

&nbsp; - En kritik akış: `pending → succeeded` ve `pending → failed`.

&nbsp; - `refunded` ve `canceled` ileri fazlarda daha detaylı kullanılabilir.



================================================

2\) STATUS HARİTALARI (KISA ÖZET)

================================================



Bu bölüm, abonelik ve ödeme status’lerinin birbirleriyle ilişkisini özetler.



------------------------------------------------

2.1 Abonelik status ↔ Ödeme sonuçları

------------------------------------------------



Baz senaryolar:



1\) İlk kayıt + başarılı ilk ödeme:

&nbsp;  - PAYMENT\_ATTEMPT:

&nbsp;    - `status=succeeded`

&nbsp;  - SUBSCRIPTION:

&nbsp;    - `status=active`



2\) İlk kayıt + başarısız ilk ödeme:

&nbsp;  - PAYMENT\_ATTEMPT:

&nbsp;    - `status=failed`

&nbsp;  - SUBSCRIPTION:

&nbsp;    - `status=incomplete`

&nbsp;  - Kullanıcıya:

&nbsp;    - “Ödemenizi tamamlayamadık, lütfen tekrar deneyin” tipinde mesaj.



3\) Yenileme tarihinde kart reddedildi:

&nbsp;  - PAYMENT\_ATTEMPT:

&nbsp;    - `status=failed`

&nbsp;  - SUBSCRIPTION:

&nbsp;    - `status=past\_due`

&nbsp;  - Aksiyon:

&nbsp;    - Sistem belirli aralıklarla yeniden deneme yapabilir (policy’ye bağlı).



4\) Kullanıcı aboneliği iptal ediyor:

&nbsp;  - SUBSCRIPTION:

&nbsp;    - `status=canceled`

&nbsp;    - `canceled\_at` dolu

&nbsp;  - İade / kısmi iade gibi durumlar:

&nbsp;    - PAYMENT\_ATTEMPT kayıtları üzerinden yönetilir (`refunded` vs.).



------------------------------------------------

2.2 Provider status ↔ Sistem status

------------------------------------------------



Bu doküman, provider bağımsız bir model sunar.  

Gerçek hayatta:



\- Stripe, iyzico vb. sağlayıcıların kendi status setleri:

&nbsp; - Örneğin Stripe:

&nbsp;   - `requires\_payment\_method`, `requires\_action`, `processing`, `succeeded`, `canceled` vb.

&nbsp; - Sistem içinde:

&nbsp;   - Bunlar `PAYMENT\_ATTEMPT.status` ve `SUBSCRIPTION.status` alanlarına map edilir.



Örnek (soyut):



\- Provider status: `succeeded`

&nbsp; - Bizde:

&nbsp;   - `PAYMENT\_ATTEMPT.status = succeeded`

&nbsp;   - İlgili abonelik:

&nbsp;     - `SUBSCRIPTION.status = active`



\- Provider status: ödeme reddedildi (insufficient\_funds / card\_declined vb.)

&nbsp; - Bizde:

&nbsp;   - `PAYMENT\_ATTEMPT.status = failed`

&nbsp;   - `SUBSCRIPTION.status = past\_due` veya `incomplete` (akışa göre).



Bu mapping:

\- İleride oluşturulacak “payment provider adapter” katmanında netleştirilir;

\- Bu dokümandaki enum seti, adapter’in hedeflediği ortak dil olarak kullanılır.



================================================

3\) CHECKLIST İLE BAĞLANTI (KISA NOT)

================================================



MASTER CHECKLIST A bloğu (ÖDEME / GÜVENLİK / HATA YÖNETİMİ) ile bağlantı:



\- “Kartla ödeme akışı uçtan uca çalışıyor” maddesi:

&nbsp; - SUBSCRIPTION + PAYMENT\_ATTEMPT modelinin uygulanabilir olmasına dayanır.

\- “Başarılı / başarısız ödeme sonrası davranış” maddesi:

&nbsp; - Yukarıdaki status geçişlerine ve frontend’e göndereceğimiz `user\_facing\_message` gibi alanlara dayanır.

\- “Ödeme sırasında kritik verilerin saklanmaması”:

&nbsp; - Bu dokümanda kart bilgisi için alan yok; sadece provider ID ve meta alanları var.

&nbsp; - Kart bilgisi doğrudan ödeme sağlayıcısına gider; sistem içinde tutulmaz.



Bu doküman:

\- Ödeme/abonelik alanında yapacağımız gerçek kod + DB tasarımı için referans şema taslağıdır.

\- İleride:

&nbsp; - Seçilen ödeme sağlayıcısına göre:

&nbsp;   - `provider` alanı ve status mapping kısmı genişletilebilir,

&nbsp;   - Gerekirse ek alanlar (invoice, receipt URL vs.) eklenir.



