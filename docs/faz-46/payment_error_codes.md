PAYMENT ERROR CODES \& USER-FACING MESAJ POLİTİKASI // FAZ-46

Tarih: 2025-11-19 (TRT/UTC+3)

Repo: gw\_stack



Amaç:

\- Payment-Ready için kullanılan hata kodlarını ve mesaj formatını standartlaştırmak.

\- Frontend ve dokümantasyon tarafının bu tabloyu referans almasını sağlamak.



============================================

1\) GENEL KURALLAR

============================================



FORMAT:

\- HTTP status: 4xx/5xx

\- Body:

&nbsp; - HATA DURUMUNDA:

&nbsp;   ```json

&nbsp;   {

&nbsp;     "detail": {

&nbsp;       "code": "SOME\_ERROR\_CODE",

&nbsp;       "message": "Kullanıcıya gösterilebilecek açıklama.",

&nbsp;       "details": { ... } | null

&nbsp;     }

&nbsp;   }

&nbsp;   ```



KURALLAR:

\- `code`:

&nbsp; - Makine okunur, sabit string.

&nbsp; - İngilizce UPPER\_SNAKE\_CASE, örn. `SUBSCRIPTION\_NOT\_FOUND`.

\- `message`:

&nbsp; - Kullanıcı tarafından okunacak metin.

&nbsp; - Türkçe, net ve suçlayıcı olmayan bir üslup.

\- `details`:

&nbsp; - Opsiyonel.

&nbsp; - Teknik ek bilgi (örn. debug için), frontend genellikle göstermez.



============================================

2\) TANIMLI HATA KODLARI (FAZ-46)

============================================



Aşağıdaki kodlar FAZ-46 kapsamında billing\_api içinde uygulanmıştır.



--------------------------------------------

2.1) PLAN\_CODE\_REQUIRED

--------------------------------------------



\- HTTP status: 400

\- Nerede:

&nbsp; - POST /api/billing/checkout/start

\- Ne zaman:

&nbsp; - Request body’de `planCode` boş veya gelmemişse.



\- Body örneği:

&nbsp; ```json

&nbsp; {

&nbsp;   "detail": {

&nbsp;     "code": "PLAN\_CODE\_REQUIRED",

&nbsp;     "message": "Bir plan seçmeniz gerekiyor.",

&nbsp;     "details": null

&nbsp;   }

&nbsp; }



