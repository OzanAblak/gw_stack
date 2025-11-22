from dataclasses import dataclass
from typing import Any, Dict, Optional


@dataclass
class FeatureAccess:
    """
    Planner tarafında "hangi özellik açık / kapalı" bilgisini tutan basit model.

    Bu katman, billing tarafındaki access preview verisini (hasSubscription, accessLevel, reason, subscriptionStatus)
    alıp, planner davranışına daha yakın, sade bir modele dönüştürür.
    """

    tier: str  # "free" veya "paid"
    can_save_plans: bool
    can_export: bool
    max_concurrent_plans: int

    def to_dict(self) -> Dict[str, Any]:
        """
        JSON friendly sözlük çıktısı.
        """
        return {
            "tier": self.tier,
            "canSavePlans": self.can_save_plans,
            "canExport": self.can_export,
            "maxConcurrentPlans": self.max_concurrent_plans,
        }


def feature_access_from_preview(preview: Optional[Dict[str, Any]]) -> FeatureAccess:
    """
    Billing `preview` bloğundan feature-level access kararı üretir.

    Beklenen preview şekli (access_preview endpoint çıktısına göre):

        {
            "hasSubscription": bool,
            "accessLevel": "full" | "limited",
            "reason": "ok" | "no_subscription" | "incomplete" | "canceled" | "unknown_status",
            "subscriptionStatus": "active" | "trialing" | "incomplete" | "canceled" | "unknown" | None
        }

    Tasarım kararı (konservatif davranış):
    - Sadece ACTIVE / TRIALING + reason == "ok" için "paid/full" özellik seti açılır.
    - Diğer tüm durumlar "free/limited" kabul edilir.
    """

    if not preview:
        # Hiç preview yoksa: en güvenli, en kısıtlı deneyim.
        return FeatureAccess(
            tier="free",
            can_save_plans=False,
            can_export=False,
            max_concurrent_plans=1,
        )

    access_level = str(preview.get("accessLevel") or "").lower()
    reason = str(preview.get("reason") or "").lower()
    subscription_status = str(preview.get("subscriptionStatus") or "").lower()

    # "Full" erişim: sadece active / trialing + reason="ok" için.
    if access_level == "full" and subscription_status in ("active", "trialing") and reason == "ok":
        return FeatureAccess(
            tier="paid",
            can_save_plans=True,
            can_export=True,
            max_concurrent_plans=5,
        )

    # Diğer her şey: limited/free
    # - no_subscription
    # - incomplete
    # - canceled
    # - unknown_status
    # - preview alanları eksik/bozuk
    return FeatureAccess(
        tier="free",
        can_save_plans=False,
        can_export=False,
        max_concurrent_plans=1,
    )
