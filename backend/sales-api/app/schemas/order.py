from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class OrderItemBase(BaseModel):
    product_id: int
    quantity: int
    # Allow clients to omit price/total; server will fill them in.
    price: Optional[float] = None
    total: Optional[float] = None

class OrderItemCreate(OrderItemBase):
    pass

class OrderItem(OrderItemBase):
    id: int
    order_id: int

    class Config:
        orm_mode = True

class OrderBase(BaseModel):
    customer_id: int
    status: Optional[str] = "pending"
    payment_status: Optional[str] = "pending"
    # Allow monetary fields to be optional on input; server will compute if missing.
    subtotal: Optional[float] = 0.0
    tax: Optional[float] = 0.0
    shipping: Optional[float] = 0.0
    total: Optional[float] = 0.0

class OrderCreate(OrderBase):
    items: List[OrderItemCreate]

class OrderUpdate(OrderBase):
    status: Optional[str] = None
    payment_status: Optional[str] = None

class Order(OrderBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    items: List[OrderItem] = []

    class Config:
        orm_mode = True