#!/bin/bash

# Enterprise System Startup Script

echo "🚀 Starting Enterprise System Development Environment"
echo "=================================================="

# Check if running on macOS, Linux, or Windows
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "📋 Detected OS: ${MACHINE}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

MISSING_DEPS=()

if ! command_exists python3; then
    MISSING_DEPS+=("python3")
fi

if ! command_exists node; then
    MISSING_DEPS+=("node")
fi

if ! command_exists npm; then
    MISSING_DEPS+=("npm")
fi

if ! command_exists psql; then
    MISSING_DEPS+=("postgresql")
fi

if ! command_exists redis-cli; then
    MISSING_DEPS+=("redis")
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "❌ Missing dependencies: ${MISSING_DEPS[*]}"
    echo ""
    echo "📖 Please install the missing dependencies and run this script again."
    echo "   Refer to DEVELOPMENT_SETUP.md for installation instructions."
    exit 1
fi

echo "✅ All prerequisites are installed"

# Setup backend
echo ""
echo "🐍 Setting up Python backend..."
cd backend/sales-api

if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

echo "🔧 Activating virtual environment and installing dependencies..."
source venv/bin/activate
pip install -r requirements.txt

# Copy environment file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📄 Creating .env file from example..."
    cp .env.example .env
fi

cd ../..

# Setup frontend
echo ""
echo "⚛️  Setting up React frontend..."
cd frontend

if [ ! -d "node_modules" ]; then
    echo "📦 Installing Node.js dependencies..."
    npm install
fi

cd ..

# Check database connection
echo ""
echo "🗄️  Checking database connection..."
if psql -d enterprise -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed"
    echo "🔧 Creating database and running initialization..."
    
    # Try to create database
    createdb enterprise 2>/dev/null || echo "Database might already exist"
    
    # Run initialization script
    psql -d enterprise -f infrastructure/docker/postgres-init/01-init.sql
    
    if [ $? -eq 0 ]; then
        echo "✅ Database initialized successfully"
    else
        echo "❌ Database initialization failed"
        echo "📖 Please check DEVELOPMENT_SETUP.md for manual setup instructions"
        exit 1
    fi
fi

# Check Redis connection
echo ""
echo "🔗 Checking Redis connection..."
if redis-cli ping >/dev/null 2>&1; then
    echo "✅ Redis connection successful"
else
    echo "❌ Redis connection failed"
    echo "📖 Please ensure Redis is running. Check DEVELOPMENT_SETUP.md for instructions."
fi

echo ""
echo "🎉 Setup complete! You can now start the development servers:"
echo ""
echo "📋 To start the services:"
echo "   1. Backend API:  cd backend/sales-api && source venv/bin/activate && uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload"
echo "   2. Frontend:     cd frontend && npm start"
echo ""
echo "🌐 Application URLs:"
echo "   • Frontend:      http://localhost:3000"
echo "   • Sales API:     http://localhost:8001"
echo "   • API Docs:      http://localhost:8001/docs"
echo ""
echo "🔐 Default login credentials:"
echo "   • Username: admin"
echo "   • Password: admin123"
echo ""
echo "📖 For more information, see README.md and DEVELOPMENT_SETUP.md"