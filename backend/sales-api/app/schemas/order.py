from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class OrderItemBase(BaseModel):
    product_id: int
    quantity: int
    price: float
    total: float

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
    subtotal: float
    tax: float
    shipping: float
    total: float

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