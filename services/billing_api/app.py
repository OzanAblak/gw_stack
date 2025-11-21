from fastapi import FastAPI, HTTPException

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


@app.get("/api/billing/subscription")
async def get_subscription():
    """
    Payment API contract dokümanındaki GET /api/billing/subscription
    endpoint’ine karşılık gelen ilk stub implementasyonu.

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
