# planner/billing_client.py
# Billing API client for planner service (FAZ-48 · GATE-3/5)
#
# Bu modül, planner tarafında billing_api ile konuşan TEK sorumlu katmandır.
# Şu anda sadece abonelik (subscription) bilgisi için minimal bir iskelet sağlar.
#
# Notlar:
# - Sadece Python standard library kullanır (requests vb. ek bağımlılık yok).
# - account_id parametresi şimdilik stub aşamasında kullanılmaz, ancak
#   ileride gerçek multi-account senaryoları için arayüzde tutulur.

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Optional, Any, Dict
import os
import json
import urllib.request
import urllib.error


class BillingSubscriptionStatus(str, Enum):
    ACTIVE = "active"
    TRIALING = "trialing"
    INCOMPLETE = "incomplete"
    CANCELED = "canceled"
    UNKNOWN = "unknown"  # Beklenmeyen status değerleri için


@dataclass
class BillingSubscription:
    subscription_id: str
    plan_code: str
    status: BillingSubscriptionStatus
    renew_period: Optional[str] = None
    renews_at: Optional[str] = None  # ISO8601 string; ileride datetime'a çevrilebilir
    created_at: Optional[str] = None
    cancel_at: Optional[str] = None


class BillingClientError(Exception):
    """Billing client için temel hata tipi."""


class BillingClientTemporaryError(BillingClientError):
    """Geçici network / HTTP hataları için kullanılır."""


class BillingClient:
    """
    Planner -> Billing API client.

    Şu anda sadece GET /api/billing/subscription endpoint'ini tüketir.
    account_id parametresi arayüzde tutulur ancak stub API tarafından henüz kullanılmaz.
    """

    def __init__(self, base_url: Optional[str] = None) -> None:
        # base_url parametresi verilmezse env'den okunur.
        env_base = os.environ.get("BILLING_API_BASE_URL", "")
        self.base_url = (base_url or env_base).rstrip("/")
        if not self.base_url:
            raise BillingClientError("BILLING_API_BASE_URL is not configured")

    def get_subscription(self, account_id: str) -> Optional[BillingSubscription]:
        """
        Aktif aboneliği getirir.

        account_id:
            Şimdilik stub aşamasında kullanılmaz, ileride gerçek hesap kimliği için tutulur.

        Döner:
            - BillingSubscription örneği (abonelik varsa)
            - None (billing_api 'SUBSCRIPTION_NOT_FOUND' dönerse)
        Hata:
            - BillingClientTemporaryError (geçici HTTP / network / JSON hataları)
        """
        # Stub API şu an account_id almadığı için URL'e eklemiyoruz.
        url = f"{self.base_url}/api/billing/subscription"

        try:
            with urllib.request.urlopen(url, timeout=5) as resp:
                status_code = resp.getcode()
                body_bytes = resp.read()
        except urllib.error.HTTPError as e:
            # Abonelik yok senaryosu: 404 + SUBSCRIPTION_NOT_FOUND
            if e.code == 404:
                try:
                    payload = json.loads(e.read().decode("utf-8") or "{}")
                except Exception:
                    payload = {}
                if payload.get("errorCode") == "SUBSCRIPTION_NOT_FOUND":
                    return None
            # Diğer HTTP hataları geçici hata olarak sınıflanır.
            raise BillingClientTemporaryError(f"Billing HTTP error: {e.code}") from e
        except Exception as e:
            # Network, timeout vb. hatalar
            raise BillingClientTemporaryError("Error calling billing_api") from e

        if status_code != 200:
            # 200 dışındaki status'ler şu an için beklenmiyor.
            raise BillingClientTemporaryError(
                f"Unexpected status code from billing_api: {status_code}"
            )

        try:
            payload = json.loads(body_bytes.decode("utf-8"))
        except Exception as e:
            raise BillingClientTemporaryError("Invalid JSON from billing_api") from e

        return self._parse_subscription(payload)

    def _parse_subscription(self, raw: Dict[str, Any]) -> BillingSubscription:
        """
        billing_api JSON çıktısını BillingSubscription modeline map eder.

        Desteklenen şekiller:
        1) Top-level subscription:
           {
             "subscriptionId": "...",
             "planCode": "...",
             "status": "active"
           }

        2) İç içe subscription nesnesi:
           {
             "subscription": {
               "id": "...",
               "planCode": "...",
               "status": "active"
             }
           }
        """
        # Eğer "subscription" alanı varsa önce onu kullan, yoksa raw'ı kullan
        container = raw.get("subscription") or raw

        status_str = str(container.get("status") or "").lower()
        try:
            status = BillingSubscriptionStatus(status_str)
        except ValueError:
            status = BillingSubscriptionStatus.UNKNOWN

        # ID için hem "subscriptionId" hem "id" alanlarını destekle
        subscription_id = container.get("subscriptionId") or container.get("id") or ""
        plan_code = container.get("planCode") or ""

        return BillingSubscription(
            subscription_id=str(subscription_id),
            plan_code=str(plan_code),
            status=status,
            renew_period=container.get("renewPeriod"),
            renews_at=container.get("renewsAt"),
            created_at=container.get("createdAt"),
            cancel_at=container.get("cancelAt"),
        )
