from tests.helpers import login, make_world, when


def test_customer_books_matches_assigns_worker_completes(client, db):
    w = make_world(db)
    ch, wh = login(client, "9100000001"), login(client, "9100000002")

    assert client.get("/api/v1/services").json()[0]["name"] == "Plumbing"

    r = client.post("/api/v1/bookings", headers=ch, json={"service_id": w["svc"].id, "lat": 19.1136, "lng": 72.8697,
                                                          "address": "Andheri W", "scheduled_at": when()})
    assert r.status_code == 201, r.text
    b = r.json()
    assert b["status"] == "requested" and b["customer_price"] == "500.00" and b["worker_wage"] == "400.00"

    cands = client.post(f"/api/v1/bookings/{b['id']}/match", headers=ch).json()
    assert cands[0]["worker"]["name"] == "Ramesh" and cands[0]["score"] > 50

    assert client.post(f"/api/v1/bookings/{b['id']}/assign", headers=ch, json={"worker_id": cands[0]["worker"]["id"]}).json()["status"] == "assigned"
    assert client.get("/api/v1/workers/me/jobs", headers=wh).json()[0]["id"] == b["id"]
    assert client.post(f"/api/v1/bookings/{b['id']}/accept", headers=wh).json()["status"] == "accepted"
    assert client.post(f"/api/v1/bookings/{b['id']}/start", headers=wh).json()["status"] == "in_progress"
    assert client.post(f"/api/v1/bookings/{b['id']}/complete", headers=wh).json()["status"] == "completed"
    assert client.post(f"/api/v1/bookings/{b['id']}/cancel", headers=ch).status_code == 409
    assert len(client.get("/api/v1/bookings", headers=wh).json()) == 1


def test_emergency_autoassigns(client, db):
    w = make_world(db)
    ch = login(client, "9100000001")
    r = client.post("/api/v1/bookings", headers=ch, json={"service_id": w["svc"].id, "lat": 19.1136, "lng": 72.8697,
                                                          "address": "X", "scheduled_at": when(), "is_emergency": True})
    assert r.json()["status"] == "assigned" and r.json()["customer_price"] == "750.00" and r.json()["worker"]["name"] == "Ramesh"


def test_worker_profile_endpoints(client, db):
    w = make_world(db)
    wh = login(client, "9100000002")
    me = client.get("/api/v1/workers/me", headers=wh).json()
    assert me["coop_name"] == "Andheri LCS" and me["lat"] == 19.12
    assert client.post("/api/v1/workers/me/availability", headers=wh, json={"is_available": False}).json()["is_available"] is False
    assert client.put("/api/v1/workers/me/skills", headers=wh, json=[w["skill"].id]).json()["skills"][0]["name"] == "Pipe fitting"
    r = client.post("/api/v1/workers/me/certifications", headers=wh, data={"name": "ITI Electrical"})
    assert r.status_code == 201 and r.json()["certifications"][0]["verified"] is False
    assert client.get("/api/v1/workers/me/earnings", headers=wh).json()["month_jobs"] == 0
