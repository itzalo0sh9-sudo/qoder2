from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db

router = APIRouter()

@router.get("/")
def get_notifications(db: Session = Depends(get_db)):
    # In a real application, you would fetch notifications from the database
    return [
        {"id": 1, "title": "Welcome", "message": "Welcome to our system", "type": "info", "read": False},
        {"id": 2, "title": "New Order", "message": "You have a new order", "type": "success", "read": False}
    ]

@router.put("/{notification_id}/read")
def mark_as_read(notification_id: int, db: Session = Depends(get_db)):
    # In a real application, you would update the notification in the database
    return {"message": f"Notification {notification_id} marked as read"}

@router.put("/read-all")
def mark_all_as_read(db: Session = Depends(get_db)):
    # In a real application, you would update all notifications in the database
    return {"message": "All notifications marked as read"}