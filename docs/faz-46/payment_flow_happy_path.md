PAYMENT FLOW — HAPPY PATH TEST PLANI // FAZ-46

Tarih: 2025-11-19 (TRT/UTC+3)

Repo: gw\_stack



Amaç:

\- Payment-Ready için “ilk ödeme akışı”nın gerçekten çalıştığını kanıtlayacak minimum senaryoyu tanımlamak.

\- Bu plan, manuel test + ileride otomasyona dönüştürülebilecek adımlar için referansdır.



================================================

1\) SENARYO 1 — İLK ÖDEME (YENİ KULLANICI)

================================================



Özet:

\- Yeni bir kullanıcı sisteme kayıt olur,

\- Bir plan seçer,

\- Ödeme akışını tamamlar,

\- Aboneliği “active” olur.



Adımlar:



1\) Kullanıcı kayıt olur / giriş yapar.

&nbsp;  - Giriş yöntemi: mevcut auth akışın (e-posta + şifre vs.).

&nbsp;  - Beklenen:

&nbsp;    - Kullanıcı paneline/ana ekrana düşer.



2\) Kullanıcı plan seçimi ekranına gider.

&nbsp;  - Plan: `starter` (veya varsayılan plan).

&nbsp;  - Beklenen:

&nbsp;    - Plan adı, fiyat, periyot (monthly/yearly) net görünür.



3\) Kullanıcı “satın al / devam et” butonuna tıklar.

&nbsp;  - Frontend:

&nbsp;    - `POST /api/billing/checkout/start` çağrılır.

&nbsp;  - Beklenen backend davranışı:

&nbsp;    - PAYMENT\_ATTEMPT kaydı oluşturulur (`status=pending`).

&nbsp;    - Gerekirse SUBSCRIPTION kaydı oluşturulur (`status=incomplete`).

&nbsp;    - Provider tarafında checkout/session oluşturulur.

&nbsp;    - Response:

&nbsp;      - `checkoutUrl` dolu,

&nbsp;      - `paymentAttemptId` dolu.



4\) Kullanıcı ödeme sağlayıcısı ekranında kart bilgilerini girer (test kartı).

&nbsp;  - Beklenen:

&nbsp;    - Ödeme sağlayıcısı testi başarıyla kabul eder.

&nbsp;    - Kullanıcı `successUrl` adresine geri yönlendirilir.



5\) Frontend success sayfasında `paymentAttemptId` ile durum sorgular.

&nbsp;  - `GET /api/billing/checkout/status?paymentAttemptId=...`

&nbsp;  - Beklenen response:

&nbsp;    - `paymentAttempt.status = "succeeded"`

&nbsp;    - `subscription.status = "active"` (veya çok kısa gecikmeyle active’e geçer).



6\) Kullanıcı abonelik özetini görür.

&nbsp;  - `GET /api/billing/subscription`

&nbsp;  - Beklenen:

&nbsp;    - Plan bilgileri doğru,

&nbsp;    - `status="active"`,

&nbsp;    - `currentPeriodStart` ve `currentPeriodEnd` mantıklı (örn. bugün → +1 ay).



Başarılı kabul kriteri:

\- Tüm adımlar hata almadan tamamlanır.

\- Son durumda:

&nbsp; - SUBSCRIPTION `active`,

&nbsp; - En az 1 PAYMENT\_ATTEMPT `succeeded`,

&nbsp; - Kullanıcı arayüzünde “ödeme başarılı / abonelik aktif” net şekilde görünür.



================================================

2\) SENARYO 2 — BAŞARISIZ İLK ÖDEME

================================================



Özet:

\- Kullanıcı kayıt olur,

\- Plan seçer,

\- Ödeme denemesi başarısız olur (örneğin “card declined”),

\- Abonelik “incomplete” kalır,

\- Kullanıcıya net ve insan gibi hata mesajı gösterilir.



Adımlar:



1\) Kullanıcı kayıt olur / giriş yapar.

2\) Plan seçer ve “satın al” butonuna basar.

3\) `POST /api/billing/checkout/start` başarılı döner, `checkoutUrl` alınır.

4\) Ödeme sağlayıcı ekranında “reddedilecek” bir test kartı kullanılır.

&nbsp;  - Örn. sağlayıcının dokümanlarında verilen “declined” test kartı.



5\) Sağlayıcı kullanıcıyı `cancelUrl` veya hata sonrası kendi sayfasından geri döndürür.

6\) Frontend:

&nbsp;  - `GET /api/billing/checkout/status?paymentAttemptId=...`

7\) Beklenen response:

&nbsp;  - `paymentAttempt.status = "failed"`

&nbsp;  - `paymentAttempt.errorCode` dolu (örn. `CARD\_DECLINED`)

&nbsp;  - `paymentAttempt.userFacingMessage`:

&nbsp;    - “Ödemeniz kart sağlayıcınız tarafından reddedildi. Lütfen farklı bir kart deneyin.” benzeri, net bir mesaj.

&nbsp;  - `subscription.status = "incomplete"` veya uygun bir “tamamlanmadı” durumu.



8\) Kullanıcı arayüzü:

&nbsp;  - Kullanıcıya yukarıdaki userFacingMessage gösterilir.

&nbsp;  - Sistem “patlamaz”; kullanıcı tekrar denemeye yönlendirilebilir.



Başarılı kabul kriteri:

\- Hata durumunda:

&nbsp; - Backend ve log tarafında kayıt var,

&nbsp; - Kullanıcı tarafında “ne olduğu anlaşılır” net mesaj var,

&nbsp; - Abonelik uygun bir “tamamlanmamış / incomplete” statüsünde.



================================================

3\) SENARYO 3 — SUBSCRIPTION GÖRÜNÜRLÜĞÜ

================================================



Özet:

\- Yeni (ödeme yapmamış) kullanıcı için `/api/billing/subscription` davranışını test eder.



Adımlar:



1\) Ödeme yapmamış bir kullanıcı ile giriş yap.

2\) `GET /api/billing/subscription` çağrısı yapılır.

3\) Beklenen:

&nbsp;  - Ya 404:

&nbsp;    - `code = "SUBSCRIPTION\_NOT\_FOUND"`

&nbsp;    - `message = "Bu hesap için aktif bir abonelik bulunamadı."`

&nbsp;  - Veya:

&nbsp;    - `subscription` alanı `null` ve API bunu açıkça belirtir.



Kabul kriteri:

\- “Aboneliği olmayan” durumda API’nin net bir davranış standardı var ve frontend bunu bekliyor.



================================================

4\) NOTLAR

================================================



\- Bu happy path planı,

&nbsp; - Payment-Ready’in minimum kabul testidir.

\- İleride:

&nbsp; - Yenileme ödemeleri,

&nbsp; - İptal / iade,

&nbsp; - Farklı planlara upgrade/downgrade

&nbsp; gibi senaryolar için ek test planları hazırlanabilir.

\- Şu an öncelik:

&nbsp; - “İlk ödeme → aktif abonelik” akışının gerçekten uçtan uca ve güvenle çalışması.

================================================
5) IMPLEMENTASYON DURUMU (FAZ-46 — BACKEND STUB)
================================================

Durum özeti:
- billing_api (FastAPI) servisi altında aşağıdaki endpoint’ler stub olarak çalışıyor:
  - GET /api/billing/subscription
  - POST /api/billing/checkout/start
  - GET /api/billing/checkout/status

Senaryo eşleşmeleri:
- Senaryo 1 — İlk ödeme (yeni kullanıcı, başarılı):
  - POST /api/billing/checkout/start body:
    - planCode="starter"
  - Dönen paymentAttemptId: pay_example_success
  - GET /api/billing/checkout/status?paymentAttemptId=pay_example_success
    - paymentAttempt.status = "succeeded"
    - subscription.status = "active"

- Senaryo 2 — Başarısız ilk ödeme (kart reddedildi):
  - POST /api/billing/checkout/start body:
    - planCode="fail_card"
  - Dönen paymentAttemptId: pay_example_failed
  - GET /api/billing/checkout/status?paymentAttemptId=pay_example_failed
    - paymentAttempt.status = "failed"
    - paymentAttempt.errorCode = "CARD_DECLINED"
    - subscription.status = "incomplete"

Not:
- Bu davranışlar FAZ-46 kapsamında stub’dur:
  - Gerçek ödeme sağlayıcısı entegrasyonu ve kalıcı veri katmanı
    ileriki fazlarda uygulanacaktır.
- Bu doküman, hem manuel testte hem de ileride yazılacak otomatik
  testlerde referans alınacaktır.




