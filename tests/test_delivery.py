from fastapi.testclient import TestClient
from delivery_service.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_create_delivery():
    delivery_data = {
        "order_id": 1,
        "courier_name": "John Doe"
    }
    response = client.post("/deliveries/", json=delivery_data)
    assert response.status_code == 200
    data = response.json()
    assert data["order_id"] == delivery_data["order_id"]
    assert isinstance(data["courier_name"], str)
