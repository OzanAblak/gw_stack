# Planner ↔ Billing Entegrasyonu (FAZ-48)

Bu doküman, planner servisinin billing_api ile entegrasyonunu ve ilgili endpoint’leri açıklar.  
Amaç, tek bir entegrasyon katmanı üzerinden abonelik bilgisini okuyup, planner tarafında erişim önizlemesi (access preview) üretmek ve bunu plan çıktısıyla birleştirmektir.

---

## 1. Amaç ve Genel Mimari

FAZ-48 ile hedeflenenler:

- Planner’ın billing_api’den abonelik (subscription) durumunu okuyabilmesi.
- Bu bilgiyi tek bir client katmanı (`planner/billing_client.py`) üzerinden almak.
- İki adet debug endpoint sağlamak:
  - `GET /v1/billing/subscription_probe`
  - `GET /v1/billing/access_preview`
- Plan derleme sonucu ile billing erişim önizlemesini birleştiren endpoint eklemek:
  - `POST /v1/plan/compile_with_access_preview`

Genel akış:

1. Planner, env’den `BILLING_API_BASE_URL` okur.
2. `BillingClient`, billing_api’ye HTTP üzerinden bağlanır.
3. Billing cevabı normalize edilerek `BillingSubscription` modeline map edilir.
4. Planner endpoint’leri bu modeli kullanarak:
   - Ham subscription view (`subscription_probe`),
   - Access preview (`access_preview`),
   - Plan + access preview birleşimi (`compile_with_access_preview`)
   üretir.

---

## 2. Env Konfigürasyonu

Planner’ın billing_api ile konuşabilmesi için env’de:

- Değişken adı: `BILLING_API_BASE_URL`

Örnek (development/stub):

```env
BILLING_API_BASE_URL=http://127.0.0.1:19100
