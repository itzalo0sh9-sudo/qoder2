#!/bin/bash

# Enterprise System Deployment Verification Script
echo "========================================"
echo "Enterprise System - Deployment Check"
echo "========================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"

# Check if required files exist
REQUIRED_FILES=(
    "docker-compose.yml"
    "backend/sales-api/requirements.txt"
    "backend/finance-api/requirements.txt"
    "backend/hr-api/requirements.txt"
    "frontend/package.json"
    "infrastructure/docker/nginx/nginx.conf"
    "infrastructure/docker/postgres-init/01-init.sql"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file exists"
    else
        echo "❌ $file is missing"
        exit 1
    fi
done

# Check network connectivity
echo ""
echo "Checking service configurations..."

# Check Docker Compose syntax
if docker-compose config > /dev/null 2>&1; then
    echo "✅ Docker Compose configuration is valid"
else
    echo "❌ Docker Compose configuration has errors"
    exit 1
fi

# Build and start services
echo ""
echo "Building and starting services..."
docker-compose up -d --build

# Wait for services to start
echo "Waiting for services to initialize..."
sleep 30

# Check service health
SERVICES=("postgres" "redis" "sales-api" "finance-api" "hr-api" "frontend" "nginx")

echo ""
echo "Checking service health..."
for service in "${SERVICES[@]}"; do
    if docker-compose ps | grep -q "$service.*Up"; then
        echo "✅ $service is running"
    else
        echo "❌ $service is not running"
        docker-compose logs "$service" | tail -10
    fi
done

# Check API endpoints
echo ""
echo "Checking API endpoints..."

# Sales API
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/health | grep -q "200"; then
    echo "✅ Sales API health check passed"
else
    echo "❌ Sales API health check failed"
fi

# Finance API
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8002/health/ | grep -q "200"; then
    echo "✅ Finance API health check passed"
else
    echo "❌ Finance API health check failed"
fi

# HR API
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8003/health/ | grep -q "200"; then
    echo "✅ HR API health check passed"
else
    echo "❌ HR API health check failed"
fi

# Frontend
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
    echo "✅ Frontend is accessible"
else
    echo "❌ Frontend is not accessible"
fi

# Nginx
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
    echo "✅ Nginx proxy is working"
else
    echo "❌ Nginx proxy is not working"
fi

echo ""
echo "========================================"
echo "System URLs:"
echo "🌐 Frontend: http://localhost"
echo "🔧 Sales API: http://localhost:8001"
echo "💰 Finance API: http://localhost:8002"
echo "👥 HR API: http://localhost:8003"
echo ""
echo "📚 API Documentation:"
echo "Sales API Docs: http://localhost:8001/docs"
echo "Finance API Docs: http://localhost:8002/api/docs/"
echo "HR API Docs: http://localhost:8003/api/docs/"
echo ""
echo "Demo Login:"
echo "Username: admin"
echo "Password: admin123"
echo "========================================"