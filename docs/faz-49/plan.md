# FAZ-49 // Planner Billing Access Gating Planı // 2025-11-22

## 1) Amaç (FAZ-49 neyi çözüyor?)

FAZ-48 ile:

- Planner, billing_api’den abonelik bilgisi okuyabiliyor.
- `access_preview` çıktısı ile:
  - `hasSubscription`
  - `accessLevel` (`full` / `limited`)
  - `reason`
  - `subscriptionStatus`
  üretebiliyor.
- `compile_with_access_preview` ile plan + billing JSON’ını tek endpoint’te dönebiliyoruz.

FAZ-49’un amacı:

- Bu “access preview” bilgisini sadece debug için değil,
- Gerçek “kapı” (gating) kararlarında kullanmaya başlamak:
  - Hangi özelliklerin “full”,
  - Hangilerinin “limited” erişimde kullanılabileceğini backend seviyesinde netleştirmek.

Kısaca: FAZ-49, access preview’i “sadece veri” olmaktan çıkarıp “davranış”a bağlayan fazdır.

---

## 2) Başlangıç durumu (FAZ-48’ten devralınan)

Planner tarafında şu an durum:

- Billing entegrasyon katmanı:
  - `planner/billing_client.py`
- Endpoint’ler:
  - `GET /v1/billing/subscription_probe`
  - `GET /v1/billing/access_preview`
  - `POST /v1/plan/compile_with_access_preview`
- Temel kural:
  - Plan derleme başarılıysa:
    - HTTP 200 + `ok=true` + `plan` her zaman dönüyor.
    - Billing hatası olursa sadece `billing.ok=false` + `kind` ile raporlanıyor.

Access mapping (özet):

- `ACTIVE` / `TRIALING` → `hasSubscription=true`, `accessLevel=full`, `reason=ok`
- `INCOMPLETE` → `hasSubscription=true`, `accessLevel=limited`, `reason=incomplete`
- `CANCELED` → `hasSubscription=true`, `accessLevel=limited`, `reason=canceled`
- Yok (`null`) → `hasSubscription=false`, `accessLevel=limited`, `reason=no_subscription`
- `UNKNOWN` → `hasSubscription=false`, `accessLevel=limited`, `reason=unknown_status`

Bu faz, bu yapı üzerine oturacak; FAZ-48’e geri dönüp temel kontratı bozmayacağız.

---

## 3) FAZ-49 hedefleri (yüksek seviye)

H1 — Minimum backend gating modelini tanımla:
- Access preview → “feature erişim” modeli (ör. `featureAccess` alanı) üret.
- Bu model:
  - JSON kontratı net,
  - `accessLevel` ve `reason` değerlerinden türetilmiş olacak.

H2 — Bu modeli planner API’ye ekle:
- `compile_with_access_preview` cevabında:
  - `billing.preview`’e ek olarak,
  - Ayrı bir blokla “hangi özellik açık / kapalı” bilgisini döndür.

H3 — Gating mantığını sade ve izole tut:
- Gating kararları:
  - Tek bir fonksiyon / modül üzerinden verilecek.
  - İleride değiştirmek istediğimizde tek yerden güncellenebilir olacak.

H4 — Gelecek için hazırlık:
- Gerçek `account_id` kullanımına ve provider adapter tasarımına zemin hazırla (bu fazda tamamen bitirmek zorunlu değil; planını çıkarıp min. değişiklikle ilerlemek yeterli).

---

## 4) GATE-8 (FAZ-49) — Minimum backend gating

Bu fazın ilk gate’i, FAZ-48 devir özetinde adı geçen GATE-8’in “gerçekleşmiş” hali olarak düşünülecek.

### 4.1 GATE-8 kapsamı

1) Gating kontratını tanımla:
   - Planner tarafında (muhtemelen `planner/app.py` içinde veya küçük bir yardımcı modülde) şöyle bir fikir netleşecek:
     - `access_preview` → `feature_access` dönüşümü.
   - Örnek JSON (hedef fikir, detay kod aşamasında netleşecek):

   ```json
   {
     "featureAccess": {
       "canSavePlans": true,
       "canExport": false,
       "maxConcurrentPlans": 1,
       "tier": "free"  // veya "paid"
     }
   }
