import os
import uuid
import pytest
import requests

BASE = os.getenv("SALES_API_URL", "http://127.0.0.1:8001") + "/api/v1"


def make_unique_email(prefix="edge"):
    return f"{prefix}.{uuid.uuid4().hex[:8]}@example.com"


def test_create_order_product_not_found():
    # create a fake customer to reference
    cust = {"name": "edge user", "email": make_unique_email("edge1")}
    r = requests.post(f"{BASE}/customers", json=cust)
    assert r.status_code in (200, 201, 400)
    if r.status_code == 400:
        customers = requests.get(f"{BASE}/customers").json()
        c = next((x for x in customers if x.get("email") == cust["email"]), None)
        assert c is not None
    else:
        c = r.json()
    customer_id = c["id"]

    # Try to create an order with a non-existent product id
    order = {"customer_id": customer_id, "items": [{"product_id": 999999, "quantity": 1}]}
    r = requests.post(f"{BASE}/orders", json=order)
    assert r.status_code >= 400


def test_create_order_zero_quantity():
    # create customer and product
    cust = {"name": "edge user 2", "email": make_unique_email("edge2")}
    r = requests.post(f"{BASE}/customers", json=cust)
    assert r.status_code in (200, 201, 400)
    if r.status_code == 400:
        customers = requests.get(f"{BASE}/customers").json()
        c = next((x for x in customers if x.get("email") == cust["email"]), None)
        assert c is not None
    else:
        c = r.json()
    customer_id = c["id"]

    product = {"name": "edge product", "description": "d", "price": 1.0, "cost": 0.2, "stock": 10, "category": "t", "supplier": "s", "status": "active"}
    r = requests.post(f"{BASE}/products", json=product)
    assert r.status_code in (200, 201)
    product_id = r.json()["id"]

    # zero quantity should be rejected
    order = {"customer_id": customer_id, "items": [{"product_id": product_id, "quantity": 0}]}
    r = requests.post(f"{BASE}/orders", json=order)
    assert r.status_code >= 400


def test_delete_order():
    # create customer/product/order then delete
    cust = {"name": "edge user 3", "email": make_unique_email("edge3")}
    r = requests.post(f"{BASE}/customers", json=cust)
    assert r.status_code in (200, 201, 400)
    if r.status_code == 400:
        customers = requests.get(f"{BASE}/customers").json()
        c = next((x for x in customers if x.get("email") == cust["email"]), None)
        assert c is not None
    else:
        c = r.json()
    customer_id = c["id"]

    product = {"name": "edge product 2", "description": "d", "price": 2.0, "cost": 0.5, "stock": 10, "category": "t", "supplier": "s", "status": "active"}
    r = requests.post(f"{BASE}/products", json=product)
    assert r.status_code in (200, 201)
    product_id = r.json()["id"]

    order = {"customer_id": customer_id, "items": [{"product_id": product_id, "quantity": 1}]}
    r = requests.post(f"{BASE}/orders", json=order)
    assert r.status_code in (200, 201)
    order_id = r.json()["id"]

    # delete
    r = requests.delete(f"{BASE}/orders/{order_id}")
    assert r.status_code in (200, 204)
