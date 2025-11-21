from typing import Optional, Dict, Any

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="GW Stack Billing API")

# CORS (stub / lokal geliştirme için geniş açık)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # file:// ve localhost senaryolarını da kapsasın
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# ÖRNEK VERİLER (STUB)
# ---------------------------------------------------------------------------

EXAMPLE_SUBSCRIPTION_ACTIVE = {
    "id": "sub_example_active",
    "status": "active",
    "planCode": "starter",
}

EXAMPLE_SUBSCRIPTION_INCOMPLETE = {
    "id": "sub_example_incomplete",
    "status": "incomplete",
    "planCode": "starter",
}

EXAMPLE_CHECKOUT_RESPONSE_SUCCESS = {
    "paymentAttemptId": "pay_example_success",
    "subscriptionId": EXAMPLE_SUBSCRIPTION_ACTIVE["id"],
}

EXAMPLE_CHECKOUT_RESPONSE_FAILED = {
    "paymentAttemptId": "pay_example_failed",
    "subscriptionId": EXAMPLE_SUBSCRIPTION_INCOMPLETE["id"],
}


class CheckoutStartRequest(BaseModel):
    planCode: Optional[str] = None
    successUrl: Optional[str] = None
    cancelUrl: Optional[str] = None


def error_detail(code: str, message: str, details: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    return {
        "code": code,
        "message": message,
        "details": details or {},
    }


# ---------------------------------------------------------------------------
# HEALTH
# ---------------------------------------------------------------------------

@app.get("/health")
async def health() -> Dict[str, Any]:
    return {
        "service": "billing_api",
        "status": "ok",
        "version": "0.1.0-stub",
        "checks": {
            "subscription_stub": "ok",
            "checkout_stub": "ok",
        },
    }


# ---------------------------------------------------------------------------
# SUBSCRIPTION
# ---------------------------------------------------------------------------

@app.get("/api/billing/subscription")
async def get_subscription(
    testNoSubscription: bool = Query(False, alias="testNoSubscription"),
) -> Dict[str, Any]:
    """
    Varsayılan: aktif subscription döner.
    testNoSubscription=true ise 404 + SUBSCRIPTION_NOT_FOUND.
    """
    if testNoSubscription:
        raise HTTPException(
            status_code=404,
            detail=error_detail(
                "SUBSCRIPTION_NOT_FOUND",
                "Bu hesap için aktif bir abonelik bulunamadı.",
            ),
        )

    return {"subscription": EXAMPLE_SUBSCRIPTION_ACTIVE}


# ---------------------------------------------------------------------------
# CHECKOUT START
# ---------------------------------------------------------------------------

@app.post("/api/billing/checkout/start")
async def checkout_start(payload: CheckoutStartRequest) -> Dict[str, Any]:
    """
    planCode boş ise:
      400 + PLAN_CODE_REQUIRED
    planCode == "fail_card" ise:
      failed checkout stub
    Aksi durumda:
      successful checkout stub
    """
    if not payload.planCode:
        raise HTTPException(
            status_code=400,
            detail=error_detail(
                "PLAN_CODE_REQUIRED",
                "Bir plan seçmeniz gerekiyor.",
            ),
        )

    if payload.planCode == "fail_card":
        return EXAMPLE_CHECKOUT_RESPONSE_FAILED

    # Default: başarılı stub
    return EXAMPLE_CHECKOUT_RESPONSE_SUCCESS


# ---------------------------------------------------------------------------
# CHECKOUT STATUS
# ---------------------------------------------------------------------------

@app.get("/api/billing/checkout/status")
async def checkout_status(
    paymentAttemptId: str = Query(..., alias="paymentAttemptId"),
) -> Dict[str, Any]:
    """
    paymentAttemptId == pay_example_success:
      paymentAttempt.succeeded + subscription.active
    paymentAttemptId == pay_example_failed:
      paymentAttempt.failed + CARD_DECLINED
    Diğer tüm ID'ler:
      404 + PAYMENT_ATTEMPT_NOT_FOUND
    """
    if paymentAttemptId == "pay_example_success":
        return {
            "paymentAttempt": {
                "id": "pay_example_success",
                "status": "succeeded",
                "subscriptionId": EXAMPLE_SUBSCRIPTION_ACTIVE["id"],
            },
            "subscription": EXAMPLE_SUBSCRIPTION_ACTIVE,
        }

    if paymentAttemptId == "pay_example_failed":
        return {
            "paymentAttempt": {
                "id": "pay_example_failed",
                "status": "failed",
                "subscriptionId": EXAMPLE_SUBSCRIPTION_INCOMPLETE["id"],
                "errorCode": "CARD_DECLINED",
                "userFacingMessage": (
                    "Ödemeniz kart sağlayıcınız tarafından reddedildi. "
                    "Lütfen farklı bir kart deneyin."
                ),
            },
            "subscription": EXAMPLE_SUBSCRIPTION_INCOMPLETE,
        }

    raise HTTPException(
        status_code=404,
        detail=error_detail(
            "PAYMENT_ATTEMPT_NOT_FOUND",
            "Bu ödeme denemesi bulunamadı.",
        ),
    )
