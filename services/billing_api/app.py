from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="GW Stack Billing API")


# Şimdilik kontrata uygun tek bir örnek abonelik dönen stub.
# İleride bunu gerçek SUBSCRIPTION verisine bağlayacağız.
EXAMPLE_SUBSCRIPTION = {
    "subscription": {
        "id": "sub_example",
        "status": "active",  # trial | active | past_due | canceled | incomplete | incomplete_expired | paused
        "plan": {
            "id": "plan_1",
            "code": "starter",
            "name": "Starter Plan",
            "billingPeriod": "monthly",      # monthly | yearly
            "priceAmount": 29.0,
            "priceCurrency": "USD",
        },
        "currentPeriodStart": "2025-12-01T00:00:00Z",
        "currentPeriodEnd": "2026-01-01T00:00:00Z",
        "trialEnd": None,
        "cancelAt": None,
        "canceledAt": None,
        "lastPaymentAt": "2025-12-01T00:00:00Z",
    }
}


# Checkout başlangıcı için örnek stub response.
EXAMPLE_CHECKOUT_RESPONSE = {
    "checkoutUrl": "https://payment-provider.example/checkout/session_example",
    "paymentAttemptId": "pay_example_123",
    "subscriptionId": "sub_example",
}


# Payment attempt için örnek stub.
EXAMPLE_PAYMENT_ATTEMPT = {
    "id": "pay_example_123",
    "status": "succeeded",           # pending | succeeded | failed | refunded | canceled
    "errorCode": None,
    "userFacingMessage": "Ödemeniz başarıyla alındı.",
}


class CheckoutStartRequest(BaseModel):
    planCode: str
    successUrl: str | None = None
    cancelUrl: str | None = None


@app.get("/api/billing/subscription")
async def get_subscription():
    """
    Payment API contract dokümanındaki
    GET /api/billing/subscription endpoint’ine karşılık gelen ilk stub implementasyonu.

    Şimdilik her zaman örnek bir 'active' abonelik döner.
    İleride:
    - Kullanıcının kimliğini auth katmanından okuyacağız,
    - Gerçek SUBSCRIPTION tablosundan/servisinden veriyi çekeceğiz,
    - Aboneliği olmayan kullanıcıya 404 döneceğiz.
    """
    # Eğer ileride “abonelik yok” senaryosunu simüle etmek istersen:
    # raise HTTPException(
    #     status_code=404,
    #     detail={
    #         "code": "SUBSCRIPTION_NOT_FOUND",
    #         "message": "Bu hesap için aktif bir abonelik bulunamadı.",
    #         "details": None,
    #     },
    # )

    return EXAMPLE_SUBSCRIPTION


@app.post("/api/billing/checkout/start")
async def checkout_start(payload: CheckoutStartRequest):
    """
    Payment API contract dokümanındaki
    POST /api/billing/checkout/start endpoint'inin ilk stub implementasyonu.

    Şimdilik:
    - Request içinden sadece planCode alınıyor (starter/pro vs.)
    - Her zaman sabit bir checkoutUrl + paymentAttemptId döndürüyoruz.

    İleride:
    - planCode üzerinden gerçek PLAN lookup yapılacak,
    - Gerçek ödeme sağlayıcısında checkout oturumu oluşturulacak,
    - paymentAttempt + subscription kayıtları domain modeline göre saklanacak.
    """

    # Basit bir kontrol: şimdilik planCode boşsa 400 dönelim.
    if not payload.planCode:
        raise HTTPException(
            status_code=400,
            detail={
                "code": "PLAN_CODE_REQUIRED",
                "message": "Bir plan seçmeniz gerekiyor.",
                "details": None,
            },
        )

    return EXAMPLE_CHECKOUT_RESPONSE


@app.get("/api/billing/checkout/status")
async def checkout_status(paymentAttemptId: str):
    """
    Payment API contract dokümanındaki
    GET /api/billing/checkout/status endpoint'inin ilk stub implementasyonu.

    Şimdilik:
    - Query param olarak paymentAttemptId alıyoruz,
    - Eğer bizim örnek ID ile eşleşiyorsa:
        paymentAttempt + subscription bilgisi döndürüyoruz,
    - Eşleşmiyorsa, 404 + PAYMENT_ATTEMPT_NOT_FOUND hatası döndürüyoruz.

    İleride:
    - paymentAttemptId üzerinden PAYMENT_ATTEMPT tablosu/servisi sorgulanacak,
    - İlgili SUBSCRIPTION kaydı ile ilişkilendirilecek.
    """

    if paymentAttemptId != EXAMPLE_PAYMENT_ATTEMPT["id"]:
        raise HTTPException(
            status_code=404,
            detail={
                "code": "PAYMENT_ATTEMPT_NOT_FOUND",
                "message": "Bu ödeme denemesi bulunamadı.",
                "details": None,
            },
        )

    return {
        "paymentAttempt": EXAMPLE_PAYMENT_ATTEMPT,
        "subscription": EXAMPLE_SUBSCRIPTION["subscription"],
    }
