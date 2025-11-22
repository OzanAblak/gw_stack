# Planner ↔ Billing Subscription Integration (FAZ-48)

Bu doküman, planner servisinin billing_api ile olan abonelik (subscription) entegrasyonunu tanımlar.

- Faz: **FAZ-48**
- Dosya: `docs/faz-48/planner_billing_integration.md`
- İlgili kod:
  - `planner/billing_client.py`
  - `planner/app.py`
  - `config/planner.example.env`
- İlgili stub/backend:
  - `services/billing_api/app.py`
  - endpoint: `GET /api/billing/subscription` (stub)

---

## 1. Amaç

Planner’ın, kullanıcının abonelik durumunu billing_api üzerinden öğrenebilmesi ve bunu:

1. **Tek bir client katmanı** (`BillingClient`) ile yapması,
2. Basit debug endpoint’leri ile dışarıya açması:
   - `GET /v1/billing/subscription_probe`
   - `GET /v1/billing/access_preview`
3. İleride **feature gating** için kullanılabilecek net bir “access preview” çıktısı üretmesi.

**Bu fazda:**  
Planner’ın core planlama davranışı (`/v1/plan/compile`) abonelik durumuna göre değişmiyor; sadece billing entegrasyonunun iskeleti kuruluyor.

---

## 2. Env / Config

### 2.1. Planner env örneği

Dosya: `config/planner.example.env`

```env
# GW Stack - Planner env example (FAZ-48)
# Bu dosya sadece ÖRNEKTİR. Gerçek ortamda kendi .env dosyanıza kopyalayıp değerleri düzenleyin.

# Billing API base URL
# Planner, abonelik durumunu öğrenmek için billing_api servisine bu base URL üzerinden gider.
# Lokal stub geliştirme için örnek:
#   http://127.0.0.1:19100
#
# Bu değer config/payment.example.env içindeki BILLING_API_BASE_URL ile uyumlu kalmalıdır.
BILLING_API_BASE_URL=http://127.0.0.1:19100

# İLERİDE KULLANILABİLECEK PLANNER AYARLARI (ÖRNEK, ŞU AN ZORUNLU DEĞİL):
# PLANNER_PORT=9090
# PLANNER_LOG_LEVEL=info
