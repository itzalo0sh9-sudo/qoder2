from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    cost: float
    stock: int
    category: str
    supplier: str
    status: Optional[str] = "active"

class ProductCreate(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    cost: float
    stock: int
    category: str
    supplier: str
    status: Optional[str] = "active"

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    cost: Optional[float] = None
    stock: Optional[int] = None
    category: Optional[str] = None
    supplier: Optional[str] = None
    status: Optional[str] = None

class Product(ProductBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True