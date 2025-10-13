# Development Environment Setup

## Prerequisites

Since Docker is not available on this system, we'll set up the development environment manually.

### Required Software

1. **Python 3.11+**
2. **Node.js 18+**  
3. **PostgreSQL 15+**
4. **Redis 7+**

## Quick Setup Instructions

### Option 1: Manual Installation

#### 1. Install Python Dependencies (Backend)

```bash
# Create virtual environment
cd backend/sales-api
python3 -m venv venv
source venv/bin/activate  # On macOS/Linux
# or
venv\Scripts\activate     # On Windows

# Install dependencies
pip install -r requirements.txt
```

#### 2. Install Node.js Dependencies (Frontend)

```bash
cd frontend
npm install
```

#### 3. Database Setup

If you have PostgreSQL installed locally:

```bash
# Create database
createdb enterprise

# Run the init script
psql -d enterprise -f infrastructure/docker/postgres-init/01-init.sql
```

### Option 2: Using Package Managers

#### macOS (using Homebrew)

```bash
# Install required services
brew install postgresql@15 redis node python@3.11

# Start services
brew services start postgresql@15
brew services start redis

# Create database
createdb enterprise
psql -d enterprise -f infrastructure/docker/postgres-init/01-init.sql
```

#### Ubuntu/Debian

```bash
# Install required packages
sudo apt update
sudo apt install postgresql-15 postgresql-client-15 redis-server nodejs npm python3.11 python3.11-venv

# Start services
sudo systemctl start postgresql
sudo systemctl start redis

# Create database
sudo -u postgres createdb enterprise
sudo -u postgres psql -d enterprise -f infrastructure/docker/postgres-init/01-init.sql
```

## Running the Application

### 1. Start Backend Services

```bash
# Terminal 1: Sales API
cd backend/sales-api
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload

# Terminal 2: Finance API (when ready)
cd backend/finance-api
source venv/bin/activate
python manage.py runserver 0.0.0.0:8002
```

### 2. Start Frontend

```bash
# Terminal 3: React Frontend
cd frontend
npm start
```

### 3. Access the Application

- **Frontend**: http://localhost:3000
- **Sales API**: http://localhost:8001
- **Sales API Docs**: http://localhost:8001/docs
- **Finance API**: http://localhost:8002

## Environment Variables

Create a `.env` file in the backend/sales-api directory:

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/enterprise
REDIS_URL=redis://localhost:6379/0
JWT_SECRET_KEY=your-secret-key-change-in-production
ENVIRONMENT=development
DEBUG=True
```

## Default Login Credentials

- **Username**: admin
- **Password**: admin123

## API Testing

You can test the APIs using:

1. **Swagger UI**: http://localhost:8001/docs
2. **cURL**:
   ```bash
   # Login
   curl -X POST "http://localhost:8001/api/v1/auth/login" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=admin&password=admin123"
   ```

## Next Steps

1. Install the required software for your operating system
2. Set up the database and services
3. Install Python and Node.js dependencies
4. Start the services
5. Access the application at http://localhost:3000

## Troubleshooting

### Common Issues

1. **Port conflicts**: If ports 3000, 8001, 8002, 5432, or 6379 are in use, modify the configuration
2. **Database connection**: Ensure PostgreSQL is running and accessible
3. **Redis connection**: Ensure Redis is running on default port 6379
4. **Python version**: Ensure you're using Python 3.11+
5. **Node.js version**: Ensure you're using Node.js 18+

### Database Reset

If you need to reset the database:

```bash
dropdb enterprise
createdb enterprise
psql -d enterprise -f infrastructure/docker/postgres-init/01-init.sql
```