from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
import uvicorn
from app.routes import customers, products, orders, auth, notifications, reports
from app.database import engine, Base
from sqlalchemy.exc import OperationalError
import time
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST


def create_tables_with_retry(retries: int = 10, delay: float = 2.0):
    """Try to create DB tables with simple retry/backoff when Postgres isn't ready yet."""
    attempt = 0
    while attempt < retries:
        try:
            Base.metadata.create_all(bind=engine)
            return
        except OperationalError:
            attempt += 1
            time.sleep(delay)
    # last attempt (let exception bubble)
    Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Sales API",
    description="Enterprise Sales Management API",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(customers.router, prefix="/api/v1/customers", tags=["customers"])
app.include_router(products.router, prefix="/api/v1/products", tags=["products"])
app.include_router(orders.router, prefix="/api/v1/orders", tags=["orders"])
app.include_router(notifications.router, prefix="/api/v1/notifications", tags=["notifications"])
app.include_router(reports.router, prefix="/api/v1/reports", tags=["reports"])

@app.get("/")
async def root():
    return {"message": "Sales API is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}


@app.get("/metrics")
async def metrics():
    data = generate_latest()
    return Response(content=data, media_type=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)