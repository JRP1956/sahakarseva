import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.core.db import Base, get_db
from app.main import app

engine = create_engine(settings.test_database_url)
TestSession = sessionmaker(bind=engine, autoflush=False)


@pytest.fixture(scope="session", autouse=True)
def _schema():
    import app.models  # noqa: F401  register tables
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    yield


@pytest.fixture
def db():
    conn = engine.connect()
    tx = conn.begin()
    session = TestSession(bind=conn)
    yield session
    session.close()
    tx.rollback()
    conn.close()


@pytest.fixture
def client(db):
    app.dependency_overrides[get_db] = lambda: db
    yield TestClient(app)
    app.dependency_overrides.clear()
