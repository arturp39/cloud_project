from fastapi.testclient import TestClient
from restaurant_service.main import app
from fastapi_cache import FastAPICache
from fastapi_cache.backends.inmemory import InMemoryBackend  # Use a simple backend for tests

client = TestClient(app)

def setup_module(module):
    FastAPICache.init(InMemoryBackend())

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert "status" in response.json()
    assert "components" in response.json()

def test_get_menu():
    response = client.get("/menu")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
