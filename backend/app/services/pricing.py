from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal

from app.models import Service

EMERGENCY_MULTIPLIER = Decimal("1.5")
CENT = Decimal("0.01")


@dataclass(frozen=True)
class Price:
    customer_price: Decimal
    worker_wage: Decimal
    coop_contribution: Decimal


def price_booking(service: Service, is_emergency: bool) -> Price:
    total = (Decimal(service.base_price) * (EMERGENCY_MULTIPLIER if is_emergency else 1)).quantize(CENT, ROUND_HALF_UP)
    wage = (total * service.worker_share_pct / 100).quantize(CENT, ROUND_HALF_UP)
    return Price(customer_price=total, worker_wage=wage, coop_contribution=total - wage)
