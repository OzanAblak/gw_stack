from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="GW Stack Billing API")


# ---------------------------------------------------------------------------
# ÖRNEK SUBSCRIPTION NESNELERİ
# ---------------------------------------------------------------------------

# Başarılı ödeme sonrası beklediğimiz aktif abonelik.
EXAMPLE_SUBSCRIPTION_ACTIVE = {
    "id": "sub_example_active",
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

# Başarısız ilk ödeme sonrası, abonelik tamamlanmamış durumda.
EXAMPLE_SUBSCRIPTION_INCOMPLETE = {
    "id": "sub_example_incomplete",
    "status": "incomplete",  # ilk ödeme tamamlanmamış
    "plan": {
        "id": "plan_1",
        "code": "starter",
        "name": "Starter Plan",
        "billingPeriod": "monthly",
        "priceAmount": 29.0,
        "priceCurrency": "USD",
    },
    "currentPeriodStart": None,
    "currentPeriodEnd": None,
    "trialEnd": None,
    "cancelAt": None,
    "canceledAt": None,
    "lastPaymentAt": None,
}


# ---------------------------------------------------------------------------
# ÖRNEK CHECKOUT RESPONSE NESNELERİ
# ---------------------------------------------------------------------------

# Başarılı senaryo için checkout başlangıcı.
EXAMPLE_CHECKOUT_RESPONSE_SUCCESS = {
    "checkoutUrl": "https://payment-provider.example/checkout/session_success",
    "paymentAttemptId": "pay_example_success",
    "subscriptionId": EXAMPLE_SUBSCRIPTION_ACTIVE["id"],
}

# Başarısız senaryo için checkout başlangıcı (örneğin kart reddedilecek).
EXAMPLE_CHECKOUT_RESPONSE_FAILED = {
    "checkoutUrl": "https://payment-provider.example/checkout/session_fail",
    "paymentAttemptId": "pay_example_failed",
    "subscriptionId": EXAMPLE_SUBSCRIPTION_INCOMPLETE["id"],
}


# ---------------------------------------------------------------------------
# ÖRNEK PAYMENT_ATTEMPT NESNELERİ
# ---------------------------------------------------------------------------

EXAMPLE_PAYMENT_ATTEMPT_SUCCESS = {
    "id": "pay_example_success",
    "status": "succeeded",           # pending | succeeded | failed | refunded | canceled
    "errorCode": None,
    "userFacingMessage": "Ödemeniz başarıyla alındı.",
}

EXAMPLE_PAYMENT_ATTEMPT_FAILED = {
    "id": "pay_example_failed",
    "status": "failed",
    "errorCode": "CARD_DECLINED",
    "userFacingMessage": "Ödemeniz kart sağlayıcınız tarafından reddedildi. Lütfen farklı bir kart deneyin.",
}


# ---------------------------------------------------------------------------
# REQUEST MODELLERİ
# ---------------------------------------------------------------------------

class CheckoutStartRequest(BaseModel):
    planCode: str
    successUrl: str | None = None
    cancelUrl: str | None = None


# ---------------------------------------------------------------------------
# ENDPOINTLER
# ---------------------------------------------------------------------------


@app.get("/api/billing/subscription")
async def get_subscription(testNoSubscription: bool = False):
    """
    GET /api/billing/subscription

    Şu anda iki durumu stub'luyoruz:

    1) Varsayılan (abonelik var):
       - testNoSubscription=false (veya parametre verilmemiş)
       - 200 OK + EXAMPLE_SUBSCRIPTION_ACTIVE

    2) Aboneliği olmayan kullanıcı (Senaryo 3 testi için):
       - testNoSubscription=true
       - 404 + SUBSCRIPTION_NOT_FOUND hatası
    """

    if testNoSubscription:
        # Senaryo 3: aboneliği olmayan kullanıcı için test amacıyla 404 döner.
        raise HTTPException(
            status_code=404,
            detail={
                "code": "SUBSCRIPTION_NOT_FOUND",
                "message": "Bu hesap için aktif bir abonelik bulunamadı.",
                "details": None,
            },
        )

    # Senaryo 1 / normal durumda aktif abonelik örneği.
    return {"subscription": EXAMPLE_SUBSCRIPTION_ACTIVE}


@app.post("/api/billing/checkout/start")
async def checkout_start(payload: CheckoutStartRequest):
    """
    POST /api/billing/checkout/start

    Şimdilik iki senaryoyu stub olarak destekliyoruz:

    1) Başarılı senaryo (happy path):
       - planCode = "starter" (veya herhangi başka bir normal plan kodu)
       - Response: EXAMPLE_CHECKOUT_RESPONSE_SUCCESS

    2) Başarısız ilk ödeme senaryosu (Senaryo 2 test için):
       - planCode = "fail_card"
       - Response: EXAMPLE_CHECKOUT_RESPONSE_FAILED
       Bu ID, checkout/status endpoint'inde 'failed' paymentAttempt ile eşleşir.
    """

    if not payload.planCode:
        raise HTTPException(
            status_code=400,
            detail={
                "code": "PLAN_CODE_REQUIRED",
                "message": "Bir plan seçmeniz gerekiyor.",
                "details": None,
            },
        )

    # Test amaçlı: özel plan kodu "fail_card" ise, bilinçli olarak
    # başarısız bir ödeme denemesine giden ID'yi döndürüyoruz.
    if payload.planCode == "fail_card":
        return EXAMPLE_CHECKOUT_RESPONSE_FAILED

    # Tüm diğer plan kodlarında (starter vs.), başarılı senaryoyu döndür.
    return EXAMPLE_CHECKOUT_RESPONSE_SUCCESS


@app.get("/api/billing/checkout/status")
async def checkout_status(paymentAttemptId: str):
    """
    GET /api/billing/checkout/status

    Şimdilik üç durum stub'lıyoruz:

    1) paymentAttemptId = pay_example_success
       - paymentAttempt: succeeded
       - subscription: active

    2) paymentAttemptId = pay_example_failed
       - paymentAttempt: failed (CARD_DECLINED)
       - subscription: incomplete

    3) Diğer tüm IDs:
       - 404 + PAYMENT_ATTEMPT_NOT_FOUND
    """

    if paymentAttemptId == EXAMPLE_PAYMENT_ATTEMPT_SUCCESS["id"]:
        return {
            "paymentAttempt": EXAMPLE_PAYMENT_ATTEMPT_SUCCESS,
            "subscription": EXAMPLE_SUBSCRIPTION_ACTIVE,
        }

    if paymentAttemptId == EXAMPLE_PAYMENT_ATTEMPT_FAILED["id"]:
        return {
            "paymentAttempt": EXAMPLE_PAYMENT_ATTEMPT_FAILED,
            "subscription": EXAMPLE_SUBSCRIPTION_INCOMPLETE,
        }

    # Diğer ID'ler için 404.
    raise HTTPException(
        status_code=404,
        detail={
            "code": "PAYMENT_ATTEMPT_NOT_FOUND",
            "message": "Bu ödeme denemesi bulunamadı.",
            "details": None,
        },
    )
