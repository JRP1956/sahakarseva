from decimal import Decimal

from app.models import Service
from app.services.pricing import price_booking

svc = Service(name="Plumbing", category="Home", base_price=Decimal("500"), worker_share_pct=80, coop_share_pct=20)


def test_normal_split():
    p = price_booking(svc, False)
    assert (p.customer_price, p.worker_wage, p.coop_contribution) == (Decimal("500.00"), Decimal("400.00"), Decimal("100.00"))


def test_emergency_split():
    p = price_booking(svc, True)
    assert (p.customer_price, p.worker_wage, p.coop_contribution) == (Decimal("750.00"), Decimal("600.00"), Decimal("150.00"))


def test_sum_invariant_with_rounding():
    odd = Service(name="x", category="x", base_price=Decimal("333.33"), worker_share_pct=77, coop_share_pct=23)
    p = price_booking(odd, True)
    assert p.worker_wage + p.coop_contribution == p.customer_price
    assert p.customer_price == Decimal("500.00")
