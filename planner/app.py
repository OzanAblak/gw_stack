# planner/app.py
# Flask/Waitress planner service
# Endpoints:
#   GET  /health                                -> 200
#   POST /v1/plan/compile                       -> 200 with {"ok":true,...} on valid payload
#                                                 -> 400 on invalid/missing/blank goal or non-JSON
#   GET  /v1/billing/subscription_probe         -> 200 with subscription / no-subscription
#                                                 -> 5xx on billing/config errors
#   GET  /v1/billing/access_preview             -> 200 with access preview derived from subscription
#   POST /v1/plan/compile_with_access_preview   -> 200 with plan + billing access preview

from flask import Flask, request, jsonify
import os
from typing import Any, Dict

from billing_client import (  # type: ignore
    BillingClient,
    BillingClientTemporaryError,
    BillingClientError,
    BillingSubscriptionStatus,
)
from access_gating import feature_access_from_preview  # FAZ-49: access gating helper

app = Flask(__name__)


@app.get("/health")
def health() -> Any:
    return jsonify({"ok": True})


def _validate_payload(data: Any) -> (bool, str):
    # Expect JSON object with non-empty string field "goal"
    if not isinstance(data, dict):
        return False, "json_expected"
    goal = data.get("goal")
    if not isinstance(goal, str):
        return False, "invalid_goal_type"
    if not goal.strip():
        return False, "invalid_goal"
    return True, ""


def _compile_goal(goal: str) -> Dict[str, Any]:
    # Minimal placeholder compiler. Keep deterministic and fast.
    return {
        "ok": True,
        "goal": goal,
        "plan": {
            "steps": [
                {"id": 1, "action": "analyze_goal", "status": "ready"},
                {"id": 2, "action": "propose_tasks", "status": "ready"},
                {"id": 3, "action": "schedule", "status": "ready"},
            ]
        },
    }


@app.post("/v1/plan/compile")
def compile_plan() -> Any:
    # Parse JSON silently to map non-JSON bodies to 400
    data = request.get_json(silent=True)
    ok, err = _validate_payload(data)
    if not ok:
        return jsonify({"error": err}), 400
    goal = data["goal"].strip()
    result = _compile_goal(goal)
    return jsonify(result), 200


def _get_billing_client() -> BillingClient:
    """
    BillingClient factory.
    Şimdilik sadece env'den BILLING_API_BASE_URL okuyup client oluşturur.
    """
    return BillingClient()


@app.get("/v1/billing/subscription_probe")
def subscription_probe() -> Any:
    """
    Billing API'den abonelik bilgisini çekmek için küçük bir probe endpoint.
    """
    try:
        client = _get_billing_client()
    except BillingClientError as e:
        # Konfigürasyon hatası (örn. BILLING_API_BASE_URL set edilmemiş)
        return (
            jsonify(
                {
                    "ok": False,
                    "source": "billing_api",
                    "kind": "config_error",
                    "message": str(e),
                }
            ),
            500,
        )

    try:
        # account_id şimdilik stub; ileride gerçek hesap kimliği ile beslenecek.
        sub = client.get_subscription(account_id="stub")
    except BillingClientTemporaryError as e:
        # Geçici HTTP / network / JSON hataları
        return (
            jsonify(
                {
                    "ok": False,
                    "source": "billing_api",
                    "kind": "temporary_error",
                    "message": str(e),
                }
            ),
            503,
        )
    except BillingClientError as e:
        # Diğer client hataları (beklenmeyen durum)
        return (
            jsonify(
                {
                    "ok": False,
                    "source": "billing_api",
                    "kind": "client_error",
                    "message": str(e),
                }
            ),
            500,
        )

    if sub is None:
        # SUBSCRIPTION_NOT_FOUND senaryosu
        return jsonify(
            {
                "ok": True,
                "status": "no_subscription",
                "subscription": None,
            }
        ), 200

    # Abonelik bulundu
    return jsonify(
        {
            "ok": True,
            "status": "subscription_found",
            "subscription": {
                "id": sub.subscription_id,
                "planCode": sub.plan_code,
                "status": sub.status.value,
                "renewPeriod": sub.renew_period,
                "renewsAt": sub.renews_at,
            },
        }
    ), 200


def _compute_access_preview_from_subscription(sub_status) -> Dict[str, Any]:
    """
    Subscription status'ine göre access preview üretir.
    """
    if sub_status is None:
        return {
            "hasSubscription": False,
            "accessLevel": "limited",
            "reason": "no_subscription",
            "subscriptionStatus": None,
        }

    if sub_status in (BillingSubscriptionStatus.ACTIVE, BillingSubscriptionStatus.TRIALING):
        return {
            "hasSubscription": True,
            "accessLevel": "full",
            "reason": "ok",
            "subscriptionStatus": sub_status.value,
        }

    if sub_status == BillingSubscriptionStatus.INCOMPLETE:
        return {
            "hasSubscription": True,
            "accessLevel": "limited",
            "reason": "incomplete",
            "subscriptionStatus": sub_status.value,
        }

    if sub_status == BillingSubscriptionStatus.CANCELED:
        return {
            "hasSubscription": True,
            "accessLevel": "limited",
            "reason": "canceled",
            "subscriptionStatus": sub_status.value,
        }

    # UNKNOWN veya beklenmeyen durumlar
    return {
        "hasSubscription": False,
        "accessLevel": "limited",
        "reason": "unknown_status",
        "subscriptionStatus": sub_status.value,
    }


@app.get("/v1/billing/access_preview")
def access_preview() -> Any:
    """
    Planner için abonelik bazlı erişim önizlemesi.
    """
    try:
        client = _get_billing_client()
    except BillingClientError as e:
        return (
            jsonify(
                {
                    "ok": False,
                    "source": "billing_api",
                    "kind": "config_error",
                    "message": str(e),
                }
            ),
            500,
        )

    try:
        sub = client.get_subscription(account_id="stub")
    except BillingClientTemporaryError as e:
        return (
            jsonify(
                {
                    "ok": False,
                    "source": "billing_api",
                    "kind": "temporary_error",
                    "message": str(e),
                }
            ),
            503,
        )
    except BillingClientError as e:
        return (
            jsonify(
                {
                    "ok": False,
                    "source": "billing_api",
                    "kind": "client_error",
                    "message": str(e),
                }
            ),
            500,
        )

    if sub is None:
        preview = _compute_access_preview_from_subscription(None)
        return jsonify(
            {
                "ok": True,
                "source": "billing_api",
                "status": "no_subscription",
                "preview": preview,
            }
        ), 200

    preview = _compute_access_preview_from_subscription(sub.status)

    return jsonify(
        {
            "ok": True,
            "source": "billing_api",
            "status": "subscription_found",
            "preview": preview,
        }
    ), 200


@app.post("/v1/plan/compile_with_access_preview")
def compile_with_access_preview() -> Any:
    """
    Plan derleyip, yanına billing access preview ekleyen endpoint.

    Davranış:
    - Payload VALID ise:
      - Plan her durumda derlenir.
      - Billing tarafında hata olsa bile HTTP 200 döner, fakat "billing" bloğu içinde hata bilgisi taşır.
    - Payload INVALID ise:
      - Eski /v1/plan/compile ile aynı şekilde 400 döner.
    """
    data = request.get_json(silent=True)
    ok, err = _validate_payload(data)
    if not ok:
        return jsonify({"error": err}), 400

    goal = data["goal"].strip()
    plan_result = _compile_goal(goal)

    # Varsayılan billing bloğu (hata durumunda override edilir)
    billing_block: Dict[str, Any]

    try:
        client = _get_billing_client()
        sub = client.get_subscription(account_id="stub")
    except BillingClientTemporaryError as e:
        billing_block = {
            "ok": False,
            "source": "billing_api",
            "kind": "temporary_error",
            "message": str(e),
        }
    except BillingClientError as e:
        billing_block = {
            "ok": False,
            "source": "billing_api",
            "kind": "config_or_client_error",
            "message": str(e),
        }
    else:
        if sub is None:
            preview = _compute_access_preview_from_subscription(None)
            billing_block = {
                "ok": True,
                "source": "billing_api",
                "status": "no_subscription",
                "preview": preview,
            }
        else:
            preview = _compute_access_preview_from_subscription(sub.status)
            billing_block = {
                "ok": True,
                "source": "billing_api",
                "status": "subscription_found",
                "preview": preview,
            }

    response_body: Dict[str, Any] = {
        **plan_result,
        "billing": billing_block,
    }

    # --- access gating integration (FAZ-49) ---
    preview_for_gating = None
    if isinstance(billing_block, dict) and billing_block.get("ok") and "preview" in billing_block:
        preview_for_gating = billing_block["preview"]

    feature_access = feature_access_from_preview(preview_for_gating)
    response_body["featureAccess"] = feature_access.to_dict()
    # --- end access gating integration ---

    return jsonify(response_body), 200


def create_app() -> Flask:
    # For tests that import the app factory
    return app


if __name__ == "__main__":
    # Run with Waitress in container. Inside Docker we map 9090 -> 19090 host.
    # If Waitress is not available, fall back to Flask dev server.
    host = "0.0.0.0"
    port = int(os.environ.get("PORT", "9090"))
    try:
        from waitress import serve  # type: ignore

        serve(app, host=host, port=port)
    except Exception:
        app.run(host=host, port=port)
