import os
import uuid
import pytest
import requests

# Allow overriding the target URL for running inside the container vs host
BASE = os.getenv("SALES_API_URL", "http://127.0.0.1:8001") + "/api/v1"


def test_create_order_flow():
    # create customer with unique email
    unique = uuid.uuid4().hex[:8]
    cust = {"name": "pytest user", "email": f"pytest.user+{unique}@example.com", "phone": "123", "address": "py street"}
    r = requests.post(f"{BASE}/customers", json=cust)
    assert r.status_code in (200, 201, 400)
    if r.status_code == 400:
        # duplicate or bad request; try to find the created customer via listing
        customers = requests.get(f"{BASE}/customers").json()
        c = next((x for x in customers if x.get("email") == cust["email"]), None)
        assert c is not None, "customer not found after 400 response"
    else:
        c = r.json()
    customer_id = c["id"]

    # create product
    product = {"name": "pytest product", "description": "desc", "price": 5.5, "cost": 2.5, "stock": 10, "category": "t", "supplier": "s", "status": "active"}
    r = requests.post(f"{BASE}/products", json=product)
    assert r.status_code in (200, 201)
    p = r.json()
    product_id = p["id"]

    # create order with minimal payload (no prices)
    order = {"customer_id": customer_id, "items": [{"product_id": product_id, "quantity": 3}]}
    r = requests.post(f"{BASE}/orders", json=order)
    assert r.status_code in (200, 201)
    o = r.json()

    assert o["customer_id"] == customer_id
    assert o["subtotal"] == pytest.approx(5.5 * 3, rel=1e-3)
    assert len(o["items"]) == 1
    assert o["items"][0]["product_id"] == product_id
