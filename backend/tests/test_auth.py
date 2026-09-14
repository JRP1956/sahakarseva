from app.models import Cooperative


def test_register_login_me_refresh(client, db):
    r = client.post("/api/v1/auth/register", json={"phone": "9000000001", "password": "pass123", "name": "Asha"})
    assert r.status_code == 201, r.text
    tok = r.json()
    assert tok["role"] == "customer"
    h = {"Authorization": f"Bearer {tok['access_token']}"}
    assert client.get("/api/v1/auth/me", headers=h).json()["name"] == "Asha"

    r = client.post("/api/v1/auth/login", json={"phone": "9000000001", "password": "pass123"})
    assert r.status_code == 200
    r = client.post("/api/v1/auth/refresh", json={"refresh_token": tok["refresh_token"]})
    assert r.status_code == 200 and r.json()["access_token"]

    assert client.post("/api/v1/auth/login", json={"phone": "9000000001", "password": "nope"}).status_code == 401


def test_worker_register_needs_coop(client, db):
    coop = Cooperative(name="Andheri LCS", area="Andheri")
    db.add(coop); db.flush()
    r = client.post("/api/v1/auth/register", json={"phone": "9000000002", "password": "pass123", "name": "Ramesh", "role": "worker"})
    assert r.status_code == 400
    r = client.post("/api/v1/auth/register", json={"phone": "9000000002", "password": "pass123", "name": "Ramesh", "role": "worker", "coop_id": coop.id})
    assert r.status_code == 201 and r.json()["role"] == "worker"


def test_no_token_401(client):
    assert client.get("/api/v1/auth/me").status_code == 401
