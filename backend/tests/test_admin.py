from tests.helpers import login, make_world, when


def test_admin_endpoints(client, db):
    w = make_world(db)
    ah, ch = login(client, "9999999999"), login(client, "9100000001")
    assert client.get("/api/v1/admin/stats", headers=ch).status_code == 403

    client.post("/api/v1/bookings", headers=ch, json={"service_id": w["svc"].id, "lat": 19.11, "lng": 72.87, "address": "X", "scheduled_at": when()})
    s = client.get("/api/v1/admin/stats", headers=ah).json()
    assert s["workers"] == 1 and s["bookings_by_status"]["requested"] == 1

    assert client.get("/api/v1/admin/workers", headers=ah).json()[0]["name"] == "Ramesh"
    assert client.get("/api/v1/admin/cooperatives", headers=ah).json()[0]["workers"] == 1
    assert client.get("/api/v1/admin/welfare", headers=ah).json()["total"] == 1
    assert len(client.get("/api/v1/admin/demand-map", headers=ah).json()) == 1
    assert client.get("/api/v1/admin/bookings?status=requested", headers=ah).json()[0]["status"] == "requested"
    assert client.get("/api/v1/admin/payments", headers=ah).json()["settlements"] == []
    assert client.get("/api/v1/admin/forecast", headers=ah).json()["rows"] == []
