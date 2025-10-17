# Enterprise Software System

A comprehensive enterprise software system with microservices architecture, built with FastAPI, Django, and React.

## 🏗️ Architecture

### Backend Services
- **Sales API** (FastAPI) - Core sales management, orders, customers, products
- **Finance API** (Django) - Financial operations, accounting, billing
- **HR API** (Django) - Human resources, employee management, payroll

### Frontend
- **React Application** - Modern TypeScript-based web interface
- **Material-UI** - Professional UI components
- **Redux Toolkit** - State management

### Infrastructure
- **PostgreSQL** - Primary database with multi-schema design
- **Redis** - Caching and session storage
- **Nginx** - Reverse proxy and load balancer
- **Docker** - Containerized deployment

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Git

### 1. Clone the Repository
```bash
git clone <repository-url>
cd qoder2
```

### 2. Environment Setup
```bash
# Copy example environment file
cp .env.example .env

# Edit .env file with your configuration
nano .env
```

## تشغيل محلي (بالعربية)

فيما يلي تعليمات سريعة لتشغيل المشروع بالكامل محليًا، تشغيل الاختبارات، وملاحظة مهمة حول إعادة كتابة السجل (history rewrite).

### المتطلبات
- Docker و Docker Compose
- Git

### تشغيل الخدمات
في مجلد المشروع:
```powershell
docker-compose up -d
docker-compose logs -f
```

### الوصول إلى الخدمات
- الواجهة الأمامية: http://localhost
- Sales API: http://localhost:8001
- Finance API: http://localhost:8002
- HR API: http://localhost:8003

### تشغيل الاختبارات (Sales API)
ادخل إلى مجلد الخدمة وشغّل pytest داخل الحاوية أو محليًا بعد تثبيت المتطلبات:
```powershell
cd backend/sales-api
# داخل الحاوية: pytest
# أو تشغيل محليًا بعد تثبيت المتطلبات:
pytest
```

### فحص الأنواع واللِنتر
- Python: ruff، mypy
- Frontend: npm run type-check

### ملاحظة مهمة — إعادة كتابة السجل (تمّت الآن)
تمت إزالة ملفات كبيرة/حساسة من تاريخ Git (على سبيل المثال: `.chrome-dev-profile`, `.venv`, `frontend/node_modules`, `frontend/build`, `dev.db`) عن طريق إعادة كتابة التاريخ وإجبار الدفع (force-push). هذا يغيّر التاريخ المشترك. خطوات مريحة للمساهمة بعد هذا التغيير:
```powershell
# أسهل حل: استنساخ جديد
git clone https://github.com/itzalo0sh9-sudo/qoder2.git

# أو تحديث نسخة محلية حالية (احذر من التغييرات غير المدمجة)
git fetch origin
git checkout main
git reset --hard origin/main
```
نسخة احتياطية من التاريخ القديم متاحة على الفرع `backup-before-filter` في الريموت.


### 3. Start All Services
```bash
# Start the entire system
docker-compose up -d

# View logs
docker-compose logs -f
```

### 4. Access the Application
- **Frontend**: http://localhost (port 80)
- **Sales API**: http://localhost:8001
- **Finance API**: http://localhost:8002  
- **HR API**: http://localhost:8003

## 📊 Key Features

### 🔐 Security & Compliance
- **Role-Based Access Control (RBAC)** with fine-grained permissions
- **Comprehensive Audit Logging** for SOX, GDPR compliance
- **JWT Authentication** across all services
- **Data encryption** and sensitive data handling

### 📈 Business Operations
- **Customer Management** - CRM functionality
- **Product Catalog** - Inventory and product management
- **Order Processing** - Sales workflow automation
- **Financial Operations** - Accounting and billing
- **HR Management** - Employee lifecycle, payroll

### 🔧 Technical Features
- **Data Import/Export** - CSV, Excel, JSON support
- **Advanced Search** - Elasticsearch integration
- **Real-time Notifications** - WebSocket-based alerts
- **Reporting & Analytics** - Comprehensive dashboards
- **Multi-tenant Architecture** - Organization isolation

## 🏭 Development Setup

### Local Development (without Docker)

#### Backend Services
Each service can be run independently:

```bash
# Sales API
cd backend/sales-api
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001

# Finance API
cd backend/finance-api
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 8002

# HR API
cd backend/hr-api
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 8003
```

#### Frontend
```bash
cd frontend
npm install
npm start
```

## 📁 Project Structure

```
qoder2/
├── backend/
│   ├── sales-api/          # FastAPI service
│   ├── finance-api/        # Django service
│   ├── hr-api/            # Django service
│   └── shared/            # Shared utilities
├── frontend/              # React application
├── infrastructure/
│   └── docker/           # Docker configurations
├── docker-compose.yml    # Main deployment file
└── .env.example         # Environment template
```

## 🔧 Configuration

### Environment Variables
Key configuration options (see `.env.example`):

```bash
# Database
DATABASE_URL=postgresql://postgres:postgres123@localhost:5432/enterprise

# Redis
REDIS_URL=redis://localhost:6379/0

# Security
JWT_SECRET_KEY=your-secret-key-change-in-production
DJANGO_SECRET_KEY=your-django-secret-key-change-in-production

# API Endpoints
REACT_APP_SALES_API_URL=http://localhost:8001
REACT_APP_FINANCE_API_URL=http://localhost:8002
REACT_APP_HR_API_URL=http://localhost:8003
```

### Database Schema
The system uses a multi-schema PostgreSQL setup:
- `shared` - Common entities (users, organizations, roles)
- `sales` - Sales-specific data
- `finance` - Financial data
- `hr` - HR-specific data  
- `audit` - Audit logs and compliance data

## 🧪 Testing

### Backend Testing
```bash
# Sales API
cd backend/sales-api
pytest

# Django services
cd backend/finance-api
python manage.py test

cd backend/hr-api
python manage.py test
```

### Frontend Testing
```bash
cd frontend
npm test
```

## 📦 Deployment

### Production Deployment
1. Update environment variables for production
2. Set strong passwords and secret keys
3. Configure SSL certificates
4. Set up monitoring and logging
5. Deploy with Docker Compose:

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Health Checks
All services include health check endpoints:
- Sales API: `GET /health`
- Finance API: `GET /health/`
- HR API: `GET /health/`

## 🔍 API Documentation

### Sales API (FastAPI)
- **Interactive Docs**: http://localhost:8001/docs
- **OpenAPI Spec**: http://localhost:8001/openapi.json

### Django Services
- **Finance API**: http://localhost:8002/api/schema/
- **HR API**: http://localhost:8003/api/schema/

## 🛠️ Troubleshooting

### Common Issues

1. **Database Connection Issues**
   - Ensure PostgreSQL is running
   - Check connection string in environment variables

2. **Authentication Failures**
   - Verify JWT secret keys match across services
   - Check user permissions and roles

3. **Import Errors**
   - All Python dependencies are listed in requirements.txt
   - Use Docker for consistent environment

### Logs
```bash
# View all service logs
docker-compose logs

# View specific service logs
docker-compose logs sales-api
docker-compose logs frontend
```

## 📝 License

This project is proprietary enterprise software.

## 🤝 Contributing

Please follow the established coding standards and ensure all tests pass before submitting changes.