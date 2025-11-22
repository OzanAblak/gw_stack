\# GW Stack · Planner ↔ Billing Entegrasyonu (FAZ-48 · GATE-1)



Bu doküman, \*\*planner\*\* servisi ile \*\*billing\_api\*\* arasındaki entegrasyonun \*abonelik (subscription)\* tarafını tanımlar.



Amaç:



\- Planner’ın, bir kullanıcı / hesap için \*\*aktif abonelik var mı?\*\* sorusunu hangi API ve hangi veri modeli üzerinden cevaplayacağını netleştirmek.

\- FAZ-46’daki payment domain + API contract dokümanları ile uyumlu, tekrar etmeyen ama onları \*tüketen\* bir kontrat ortaya koymak.

\- İleride gerçek provider adapter’ına geçerken değişmeyecek \*ara yüzü\* tarif etmek.



---



\## 1. Bağlam (Context)



\- \*\*billing\_api\*\* şu anda \*STUB\* seviyesinde:

&nbsp; - Gerçek ödeme sağlayıcısına (Stripe, Iyzico vb.) bağlı değil.

&nbsp; - Kalıcı veri tutmuyor.

\- Ancak:

&nbsp; - FAZ-46’da payment domain modeli, API contract ve error code standardı tanımlandı.

&nbsp; - FAZ-47’de landing → billing\_api entegrasyonu ve CORS + CI health omurgası kuruldu.

\- FAZ-48’le birlikte:

&nbsp; - \*\*planner\*\* servisi de bu billing\_api kontratını kullanarak “abonelik bilincine sahip” hale gelecek.



Bu doküman:



\- billing\_api’nin \*subscription\* endpoint’ini,

\- planner’ın bu endpoint’i nasıl tüketeceğini,

\- hata senaryolarında planner’ın nasıl davranacağını

tanımlar.



---



\## 2. Abonelik Kullanım Senaryoları (Planner Perspektifi)



Planner’ın abonelik bilgisini kullanacağı temel senaryolar:



1\. \*\*Feature gating (özellik bazlı kilitleme)\*\*

&nbsp;  - Örnek:

&nbsp;    - Aktif aboneliği olan kullanıcı:

&nbsp;      - Tam özellik seti (ör. sınırsız proje, ileri raporlama vb.)

&nbsp;    - Aboneliği olmayan kullanıcı (`SUBSCRIPTION\_NOT\_FOUND`):

&nbsp;      - Sadece temel görünüm / read-only / trial mod.



2\. \*\*UI içi durum gösterimi\*\*

&nbsp;  - Kullanıcı kendi “plan” durumunu görebilmeli:

&nbsp;    - Örnek metin: `Plan: starter · status: active`

&nbsp;    - Abonelik yoksa: `Bu hesap için aktif bir abonelik bulunamadı.`



3\. \*\*Gelecekte: limitler ve kota yönetimi\*\*

&nbsp;  - İlerleyen fazlarda:

&nbsp;    - Plan’a göre proje sayısı, workspace sayısı, log retention süresi vb. limitler bu abonelik bilgisinden türetilebilir.



Bu doküman, özellikle (1) ve (2)’yi kapsar; (3) ileriki fazlar için referans olarak not edilmiştir.



---



\## 3. Billing API · Subscription Endpoint (Consumer View)



\### 3.1. Endpoint



\- HTTP method: `GET`

\- Path: `/api/billing/subscription`

\- Auth: 

&nbsp; - Şimdilik STUB:

&nbsp;   - Kullanıcı/hesap kimliği sabit veya internal stub mantığı ile belirlenir.

&nbsp; - Gelecekte:

&nbsp;   - Auth header / token üzerinden hesap belirlenmesi (FAZ-49+).



\### 3.2. Query Parametreleri



\- `testNoSubscription` (opsiyonel, bool/flag)

&nbsp; - Amaç (stub):

&nbsp;   - `true` gönderilirse “abonelik yok” senaryosunu zorla tetiklemek.

&nbsp; - Prod:

&nbsp;   - Sadece dev/stub ortamlarda anlamlı; prod’da kullanılması beklenmez.



Örnek çağrılar:



\- Normal kullanım:

&nbsp; - `GET /api/billing/subscription`

\- Stub testi:

&nbsp; - `GET /api/billing/subscription?testNoSubscription=true`



---



\## 4. Response Model (Subscription)



Bu bölüm, planner’ın \*kullanacağı\* alanları listeler. Domain modelin tamamı FAZ-46 dokümanlarındadır; burada sadece planner için \*gerekli\* subset tanımlanır.



\### 4.1. Başarılı Durum (HTTP 200)



```jsonc

{

&nbsp; "subscriptionId": "sub\_example\_active",

&nbsp; "accountId": "acc\_12345",           // ileride planner ile hizalanacak

&nbsp; "planCode": "starter",              // örnek: starter, team, enterprise

&nbsp; "status": "active",                 // örnek: active, trialing, incomplete, canceled

&nbsp; "renewPeriod": "month",             // örnek: month, year

&nbsp; "renewsAt": "2025-12-01T00:00:00Z", // opsiyonel, yenilenme tarihi

&nbsp; "createdAt": "2025-11-20T10:00:00Z",

&nbsp; "cancelAt": null                    // varsa: gelecekte iptal tarihi

}



