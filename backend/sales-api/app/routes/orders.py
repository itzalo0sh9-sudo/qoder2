from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import schemas, models
from app.models.order import OrderItem
from app.database import get_db

from sqlalchemy import select

router = APIRouter()

@router.post("/", response_model=schemas.Order)
def create_order(order: schemas.OrderCreate, db: Session = Depends(get_db)):
    # Create the order
    # Compute subtotal from items; if item price not provided, load product price
    subtotal = 0.0
    db_items = []
    for item in order.items:
        item_data = item.dict()
        if not item_data.get('price'):
            # fetch product price
            prod = db.execute(select(models.Product).where(models.Product.id == item_data['product_id'])).scalars().first()
            if prod is None:
                raise HTTPException(status_code=400, detail=f"Product {item_data['product_id']} not found")
            item_data['price'] = prod.price
        item_data['total'] = item_data.get('total') or (item_data['price'] * item_data['quantity'])
        subtotal += item_data['total']
        db_items.append(item_data)

    tax = order.tax or 0.0
    shipping = order.shipping or 0.0
    total = subtotal + tax + shipping

    order_data = order.dict(exclude={'items'})
    # override monetary fields with computed values
    order_data['subtotal'] = subtotal
    order_data['tax'] = tax
    order_data['shipping'] = shipping
    order_data['total'] = total

    db_order = models.Order(**order_data)
    db.add(db_order)
    db.commit()
    db.refresh(db_order)

    # Create order items
    for item in db_items:
        db_item = OrderItem(order_id=db_order.id, **item)
        db.add(db_item)

    db.commit()
    db.refresh(db_order)
    return db_order

@router.get("/", response_model=list[schemas.Order])
def read_orders(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    orders = db.query(models.Order).offset(skip).limit(limit).all()
    return orders

@router.get("/{order_id}", response_model=schemas.Order)
def read_order(order_id: int, db: Session = Depends(get_db)):
    db_order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if db_order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    return db_order

@router.put("/{order_id}", response_model=schemas.Order)
def update_order(order_id: int, order: schemas.OrderUpdate, db: Session = Depends(get_db)):
    db_order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if db_order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    
    for key, value in order.dict(exclude_unset=True).items():
        setattr(db_order, key, value)
    
    db.commit()
    db.refresh(db_order)
    return db_order

@router.delete("/{order_id}")
def delete_order(order_id: int, db: Session = Depends(get_db)):
    db_order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if db_order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    
    db.delete(db_order)
    db.commit()
    return {"message": "Order deleted successfully"}