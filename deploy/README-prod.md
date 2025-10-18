# Production deployment (minimal)

This document explains how to build and run the project in a minimal production mode using Docker Compose.

1. Ensure you have environment variables set (use a `.env.prod` or CI secrets):

```
POSTGRES_DB=enterprise
POSTGRES_USER=postgres
POSTGRES_PASSWORD=strong-production-password
DATABASE_URL=postgresql://postgres:strong-production-password@postgres:5432/enterprise
JWT_SECRET_KEY=super-secret-jwt
REACT_APP_SALES_API_URL=https://your-host:8001
```

2. Build images and bring up services:

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

3. Confirm health endpoints and configure reverse proxy / load balancer for TLS.
