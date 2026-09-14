from tests.helpers import login, make_world, when


def _completed_booking(client, db, w):
    ch, wh = login(client, "9100000001"), login(client, "9100000002")
    b = client.post("/api/v1/bookings", headers=ch, json={"service_id": w["svc"].id, "lat": 19.1136, "lng": 72.8697,
                                                          "address": "X", "scheduled_at": when()}).json()
    client.post(f"/api/v1/bookings/{b['id']}/assign", headers=ch, json={"worker_id": w["worker"].id})
    for step in ("accept", "start", "complete"):
        client.post(f"/api/v1/bookings/{b['id']}/{step}", headers=wh)
    return b["id"], ch, wh


def test_demo_pay_rate_invoice(client, db):
    w = make_world(db)
    bid, ch, wh = _completed_booking(client, db, w)

    order = client.post("/api/v1/payments/create-order", headers=ch, json={"booking_id": bid}).json()
    assert order["order_id"] == "demo" and order["amount"] == 50000

    assert client.post("/api/v1/payments/demo-mark-paid", headers=ch, json={"booking_id": bid}).json()["status"] == "paid"

    r = client.post("/api/v1/ratings", headers=ch, json={"booking_id": bid, "stars": 5, "comment": "Great"})
    assert r.status_code == 201 and r.json()["status"] == "rated"
    assert r.json()["worker"]["rating_avg"] == 5.0 and r.json()["worker"]["rating_count"] == 1
    assert client.post("/api/v1/ratings", headers=ch, json={"booking_id": bid, "stars": 1}).status_code == 409

    inv = client.get(f"/api/v1/invoices/{bid}", headers=ch)
    assert inv.status_code == 200 and "INV-" in inv.text and "400.00" in inv.text
    assert client.get("/api/v1/workers/me/earnings", headers=wh).json()["month_total"] == "400.00"
