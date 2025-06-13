from fastapi.testclient import TestClient
from order_service.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert "status" in response.json()

def test_create_order():
    order_data = {
        "customer_name": "John Doe",
        "customer_address": "123 Main St",
        "item_name": "Pizza",
        "quantity": 1
    }
    response = client.post("/order", json=order_data)
    assert response.status_code == 200
    data = response.json()
    assert "order_id" in data 