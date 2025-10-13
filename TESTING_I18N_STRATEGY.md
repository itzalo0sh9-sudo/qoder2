# Testing Strategy, I18n, Deployment & Implementation Roadmap

## Testing and Quality Assurance Strategy

### Testing Pyramid Implementation

```mermaid
graph TB
    subgraph "Testing Pyramid"
        E2E[End-to-End Tests<br/>~5-10%]
        INTEGRATION[Integration Tests<br/>~20-30%]
        UNIT[Unit Tests<br/>~60-70%]
    end
    
    E2E --> INTEGRATION
    INTEGRATION --> UNIT
```

### Unit Testing Framework

```python
# pytest configuration for unit tests
# pytest.ini
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    --cov=app
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
    -v
    --tb=short

# FastAPI unit test example
import pytest
from httpx import AsyncClient
from fastapi.testclient import TestClient
from unittest.mock import Mock, patch
from app.main import app
from app.services.customer_service import CustomerService

@pytest.fixture
def test_client():
    return TestClient(app)

@pytest.fixture
def mock_db():
    return Mock()

@pytest.fixture
def sample_customer():
    return {
        "company_name": "Test Company",
        "contact_person": "John Doe",
        "email": "john@test.com",
        "phone": "+1234567890"
    }

class TestCustomerAPI:
    def test_create_customer_success(self, test_client, sample_customer):
        with patch('app.dependencies.get_current_user') as mock_user:
            mock_user.return_value = {"user_id": "test-user", "org_id": "test-org"}
            
            response = test_client.post("/api/v1/customers", json=sample_customer)
            
            assert response.status_code == 201
            assert response.json()["success"] is True
            assert response.json()["data"]["company_name"] == sample_customer["company_name"]
    
    def test_create_customer_validation_error(self, test_client):
        invalid_customer = {"company_name": ""}  # Missing required fields
        
        response = test_client.post("/api/v1/customers", json=invalid_customer)
        
        assert response.status_code == 422
        assert "validation" in response.json()["message"].lower()
    
    def test_get_customers_with_search(self, test_client):
        with patch('app.dependencies.get_current_user') as mock_user:
            mock_user.return_value = {"user_id": "test-user", "org_id": "test-org"}
            
            response = test_client.get("/api/v1/customers?search=test&limit=10")
            
            assert response.status_code == 200
            assert "data" in response.json()
            assert "meta" in response.json()

# Django unit test example
from django.test import TestCase, TransactionTestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase, APIClient
from finance.models import Account, JournalEntry

User = get_user_model()

class AccountModelTest(TestCase):
    def setUp(self):
        self.organization = Organization.objects.create(
            name="Test Org",
            code="TEST"
        )
        
    def test_account_creation(self):
        account = Account.objects.create(
            organization=self.organization,
            account_code="1000",
            account_name="Cash",
            account_type="asset",
            normal_balance="debit"
        )
        
        self.assertEqual(account.account_code, "1000")
        self.assertEqual(account.account_type, "asset")
        self.assertTrue(account.is_active)
    
    def test_account_unique_constraint(self):
        Account.objects.create(
            organization=self.organization,
            account_code="1000",
            account_name="Cash",
            account_type="asset",
            normal_balance="debit"
        )
        
        with self.assertRaises(IntegrityError):
            Account.objects.create(
                organization=self.organization,
                account_code="1000",  # Duplicate code
                account_name="Cash 2",
                account_type="asset",
                normal_balance="debit"
            )

class JournalEntryAPITest(APITestCase):
    def setUp(self):
        self.organization = Organization.objects.create(name="Test Org", code="TEST")
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            organization=self.organization
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        
        # Create test accounts
        self.cash_account = Account.objects.create(
            organization=self.organization,
            account_code="1000",
            account_name="Cash",
            account_type="asset",
            normal_balance="debit"
        )
        
        self.revenue_account = Account.objects.create(
            organization=self.organization,
            account_code="4000",
            account_name="Revenue",
            account_type="revenue",
            normal_balance="credit"
        )
    
    def test_create_journal_entry(self):
        entry_data = {
            "entry_date": "2024-01-01",
            "description": "Test entry",
            "lines": [
                {
                    "account_id": str(self.cash_account.id),
                    "debit_amount": "1000.00",
                    "credit_amount": "0.00",
                    "description": "Cash received"
                },
                {
                    "account_id": str(self.revenue_account.id),
                    "debit_amount": "0.00",
                    "credit_amount": "1000.00",
                    "description": "Revenue earned"
                }
            ]
        }
        
        response = self.client.post("/api/finance/journal-entries/", entry_data, format="json")
        
        self.assertEqual(response.status_code, 201)
        self.assertEqual(JournalEntry.objects.count(), 1)
```

### Integration Testing

```python
# Integration test example using test containers
import pytest
from testcontainers.postgres import PostgresContainer
from testcontainers.redis import RedisContainer
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

@pytest.fixture(scope="session")
def postgres_container():
    with PostgresContainer("postgres:15") as postgres:
        yield postgres

@pytest.fixture(scope="session") 
def redis_container():
    with RedisContainer() as redis:
        yield redis

@pytest.fixture(scope="session")
def test_database(postgres_container):
    engine = create_engine(postgres_container.get_connection_url())
    
    # Run migrations
    from alembic.config import Config
    from alembic import command
    
    alembic_cfg = Config("alembic.ini")
    alembic_cfg.set_main_option("sqlalchemy.url", postgres_container.get_connection_url())
    command.upgrade(alembic_cfg, "head")
    
    return engine

class TestSalesFinanceIntegration:
    def test_order_creates_journal_entry(self, test_database, redis_container):
        # Create order through Sales API
        order_data = {
            "customer_id": "test-customer-id",
            "items": [
                {"product_id": "test-product", "quantity": 2, "unit_price": 100.00}
            ]
        }
        
        # This should trigger automatic journal entry creation
        with patch('app.services.webhook_service.trigger_event') as mock_webhook:
            order = create_order(order_data)
            
            # Verify order was created
            assert order.total_amount == 200.00
            
            # Verify journal entry was created via webhook
            mock_webhook.assert_called_once()
            
            # Verify actual journal entry exists
            journal_entries = get_journal_entries_by_reference(f"ORDER-{order.order_number}")
            assert len(journal_entries) == 1
            assert journal_entries[0].total_debit == 200.00
```

### End-to-End Testing

```python
# E2E tests using Playwright
import pytest
from playwright.async_api import async_playwright

@pytest.fixture(scope="session")
async def browser():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        yield browser
        await browser.close()

@pytest.fixture
async def page(browser):
    context = await browser.new_context()
    page = await context.new_page()
    yield page
    await context.close()

class TestCompleteOrderFlow:
    async def test_complete_order_workflow(self, page):
        # Login
        await page.goto("http://localhost:3000/login")
        await page.fill("[data-testid=email]", "test@example.com")
        await page.fill("[data-testid=password]", "password123")
        await page.click("[data-testid=login-button]")
        
        # Navigate to customers
        await page.click("[data-testid=customers-menu]")
        await page.wait_for_selector("[data-testid=customer-list]")
        
        # Create new customer
        await page.click("[data-testid=add-customer-button]")
        await page.fill("[data-testid=company-name]", "Test Company E2E")
        await page.fill("[data-testid=contact-person]", "John Doe")
        await page.fill("[data-testid=email]", "john@testcompany.com")
        await page.click("[data-testid=save-customer]")
        
        # Verify customer was created
        await page.wait_for_selector("text=Customer created successfully")
        
        # Create order for customer
        await page.click("[data-testid=orders-menu]")
        await page.click("[data-testid=add-order-button]")
        await page.select_option("[data-testid=customer-select]", "Test Company E2E")
        
        # Add order items
        await page.click("[data-testid=add-item-button]")
        await page.select_option("[data-testid=product-select]", "Test Product")
        await page.fill("[data-testid=quantity]", "2")
        await page.click("[data-testid=save-order]")
        
        # Verify order total
        total_amount = await page.text_content("[data-testid=order-total]")
        assert "200.00" in total_amount
        
        # Submit order
        await page.click("[data-testid=submit-order]")
        await page.wait_for_selector("text=Order created successfully")
```

---

## CI/CD Pipeline Configuration

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PYTHON_VERSION: "3.11"
  NODE_VERSION: "18"
  POSTGRES_VERSION: "15"

jobs:
  test-backend:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Cache pip dependencies
        uses: actions/cache@v3
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      
      - name: Run linting
        run: |
          flake8 app/ tests/
          black --check app/ tests/
          isort --check-only app/ tests/
      
      - name: Run type checking
        run: mypy app/
      
      - name: Run security scan
        run: bandit -r app/
      
      - name: Run tests
        run: |
          pytest tests/ --cov=app --cov-report=xml --cov-report=html
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/test_db
          REDIS_URL: redis://localhost:6379/0
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml

  test-frontend:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        run: |
          cd frontend
          npm ci
      
      - name: Run linting
        run: |
          cd frontend
          npm run lint
          npm run type-check
      
      - name: Run unit tests
        run: |
          cd frontend
          npm run test:unit
      
      - name: Build application
        run: |
          cd frontend
          npm run build

  e2e-tests:
    runs-on: ubuntu-latest
    needs: [test-backend, test-frontend]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Compose
        run: |
          docker-compose -f docker-compose.test.yml up -d
          docker-compose -f docker-compose.test.yml exec -T backend alembic upgrade head
      
      - name: Wait for services
        run: |
          sleep 30
          curl --retry 10 --retry-delay 5 http://localhost:8000/health
          curl --retry 10 --retry-delay 5 http://localhost:3000
      
      - name: Run E2E tests
        run: |
          npx playwright test
      
      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

  deploy-staging:
    runs-on: ubuntu-latest
    needs: [test-backend, test-frontend, e2e-tests, security-scan]
    if: github.ref == 'refs/heads/develop'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to staging
        run: |
          # Deploy to staging environment
          echo "Deploying to staging..."
          # kubectl apply -f k8s/staging/
      
  deploy-production:
    runs-on: ubuntu-latest
    needs: [test-backend, test-frontend, e2e-tests, security-scan]
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to production
        run: |
          # Deploy to production environment
          echo "Deploying to production..."
          # kubectl apply -f k8s/production/
```

---

## Internationalization Strategy

```python
# I18n implementation using Flask-Babel pattern
from babel import Locale
from typing import Dict, Any
import json
import os

class InternationalizationService:
    def __init__(self):
        self.translations = {}
        self.supported_languages = ['en', 'es', 'fr', 'de', 'zh', 'ja']
        self.default_language = 'en'
        self.load_translations()
    
    def load_translations(self):
        """Load translation files for all supported languages"""
        translations_dir = os.path.join(os.path.dirname(__file__), 'translations')
        
        for lang in self.supported_languages:
            file_path = os.path.join(translations_dir, f'{lang}.json')
            if os.path.exists(file_path):
                with open(file_path, 'r', encoding='utf-8') as f:
                    self.translations[lang] = json.load(f)
    
    def get_text(self, key: str, language: str = None, **kwargs) -> str:
        """Get translated text for given key"""
        language = language or self.default_language
        
        if language not in self.translations:
            language = self.default_language
        
        translation = self.translations.get(language, {}).get(key, key)
        
        # Handle string formatting
        if kwargs:
            try:
                translation = translation.format(**kwargs)
            except (KeyError, ValueError):
                pass  # Return unformatted string if formatting fails
        
        return translation
    
    def get_locale_data(self, language: str) -> Dict[str, Any]:
        """Get locale-specific formatting data"""
        locale = Locale.parse(language)
        
        return {
            'language': language,
            'display_name': locale.display_name,
            'date_format': self._get_date_format(locale),
            'time_format': self._get_time_format(locale),
            'currency_format': self._get_currency_format(locale),
            'number_format': self._get_number_format(locale),
            'decimal_separator': locale.number_symbols.get('decimal', '.'),
            'thousands_separator': locale.number_symbols.get('group', ','),
        }

# Translation files structure
# translations/en.json
{
    "common": {
        "save": "Save",
        "cancel": "Cancel",
        "delete": "Delete",
        "edit": "Edit",
        "add": "Add",
        "search": "Search",
        "loading": "Loading...",
        "error": "An error occurred",
        "success": "Operation completed successfully"
    },
    "sales": {
        "customer": "Customer",
        "customers": "Customers",
        "order": "Order",
        "orders": "Orders",
        "product": "Product",
        "products": "Products",
        "add_customer": "Add Customer",
        "customer_created": "Customer created successfully",
        "order_total": "Order Total: {amount}"
    },
    "finance": {
        "account": "Account",
        "accounts": "Accounts",
        "journal_entry": "Journal Entry",
        "journal_entries": "Journal Entries",
        "debit": "Debit",
        "credit": "Credit",
        "balance": "Balance"
    }
}

# React i18n integration
import { createContext, useContext, useState, useEffect } from 'react';

const I18nContext = createContext();

export const I18nProvider = ({ children }) => {
    const [language, setLanguage] = useState(
        localStorage.getItem('language') || navigator.language.split('-')[0] || 'en'
    );
    const [translations, setTranslations] = useState({});
    const [localeData, setLocaleData] = useState({});

    useEffect(() => {
        loadTranslations(language);
    }, [language]);

    const loadTranslations = async (lang) => {
        try {
            const response = await fetch(`/api/i18n/translations/${lang}`);
            const data = await response.json();
            setTranslations(data.translations);
            setLocaleData(data.locale_data);
            localStorage.setItem('language', lang);
        } catch (error) {
            console.error('Failed to load translations:', error);
        }
    };

    const t = (key, params = {}) => {
        const keys = key.split('.');
        let value = translations;
        
        for (const k of keys) {
            value = value?.[k];
        }
        
        if (!value) return key;
        
        // Replace parameters
        return Object.keys(params).reduce((str, param) => {
            return str.replace(`{${param}}`, params[param]);
        }, value);
    };

    const formatCurrency = (amount, currency = 'USD') => {
        return new Intl.NumberFormat(language, {
            style: 'currency',
            currency: currency
        }).format(amount);
    };

    const formatDate = (date) => {
        return new Intl.DateTimeFormat(language).format(new Date(date));
    };

    return (
        <I18nContext.Provider value={{
            language,
            setLanguage,
            t,
            formatCurrency,
            formatDate,
            localeData
        }}>
            {children}
        </I18nContext.Provider>
    );
};

export const useI18n = () => {
    const context = useContext(I18nContext);
    if (!context) {
        throw new Error('useI18n must be used within an I18nProvider');
    }
    return context;
};

// Usage in React components
const CustomerForm = () => {
    const { t, formatCurrency } = useI18n();
    
    return (
        <form>
            <h2>{t('sales.add_customer')}</h2>
            <input placeholder={t('sales.customer_name')} />
            <button type="submit">{t('common.save')}</button>
        </form>
    );
};
```

This comprehensive testing strategy includes unit tests, integration tests, E2E tests with a complete CI/CD pipeline, and a robust internationalization framework supporting multiple languages with proper locale formatting.