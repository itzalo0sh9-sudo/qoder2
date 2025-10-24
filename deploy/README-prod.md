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

```markdown
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
GRAFANA_ADMIN_PASSWORD=change_me
```

2. Build images and bring up services:

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

3. Confirm health endpoints and configure reverse proxy / load balancer for TLS.

## TLS certificates

Place your TLS certificates in `infrastructure/docker/nginx/certs/` on the host. The production nginx configuration expects the following filenames:

- `fullchain.pem`  (certificate chain)
- `privkey.pem`    (private key)

Example (on a Linux host):

```bash
mkdir -p infrastructure/docker/nginx/certs
cp /etc/letsencrypt/live/your-domain/fullchain.pem infrastructure/docker/nginx/certs/
cp /etc/letsencrypt/live/your-domain/privkey.pem infrastructure/docker/nginx/certs/
``` 

Ensure the files are readable by the user running Docker (avoid committing them to git).

## Observability

Prometheus will be available on port 9090 and Grafana on port 3000 after startup. Grafana initial admin password is read from the `GRAFANA_ADMIN_PASSWORD` environment variable.

Accessing Prometheus:

	- http://<host>:9090

Accessing Grafana:

	- http://<host>:3000 (default admin user: `admin`)

## Example prod run (with .env.prod)

```bash
# Using a .env.prod file with production secrets
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
```

``` 
