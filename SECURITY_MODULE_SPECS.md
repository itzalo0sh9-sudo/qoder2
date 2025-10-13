# Security Architecture & Module Specifications

## Security Architecture Implementation

### Authentication & Authorization Framework

```python
# JWT Token Service
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext

class SecurityService:
    def __init__(self):
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        self.secret_key = os.getenv("JWT_SECRET_KEY")
        self.algorithm = "HS256"
        self.access_token_expire = 30  # minutes
        self.refresh_token_expire = 7   # days

    def create_access_token(self, user_id: str, org_id: str, permissions: List[str]):
        expire = datetime.utcnow() + timedelta(minutes=self.access_token_expire)
        payload = {
            "user_id": user_id,
            "org_id": org_id,
            "permissions": permissions,
            "exp": expire,
            "type": "access"
        }
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)

    def verify_token(self, token: str) -> dict:
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            return payload
        except JWTError:
            raise HTTPException(401, "Invalid token")

# Permission Middleware
class PermissionMiddleware:
    def __init__(self, app):
        self.app = app
    
    async def __call__(self, scope, receive, send):
        if scope["type"] == "http":
            request = Request(scope, receive)
            
            # Extract token from Authorization header
            auth_header = request.headers.get("authorization")
            if auth_header and auth_header.startswith("Bearer "):
                token = auth_header.split(" ")[1]
                try:
                    payload = security_service.verify_token(token)
                    scope["user"] = payload
                except HTTPException:
                    scope["user"] = None
        
        await self.app(scope, receive, send)
```

### Role-Based Access Control (RBAC)

```python
# RBAC Implementation
class RBACService:
    PERMISSIONS = {
        # Sales permissions
        "sales.customers.read": "View customers",
        "sales.customers.write": "Create/edit customers", 
        "sales.customers.delete": "Delete customers",
        "sales.orders.read": "View orders",
        "sales.orders.write": "Create/edit orders",
        "sales.orders.approve": "Approve orders",
        
        # Finance permissions
        "finance.accounts.read": "View chart of accounts",
        "finance.accounts.write": "Manage accounts",
        "finance.journal.read": "View journal entries",
        "finance.journal.write": "Create journal entries",
        "finance.journal.post": "Post journal entries",
        
        # HR permissions
        "hr.employees.read": "View employees",
        "hr.employees.write": "Manage employees",
        "hr.payroll.read": "View payroll",
        "hr.payroll.process": "Process payroll",
    }
    
    ROLES = {
        "sales_manager": [
            "sales.customers.read", "sales.customers.write",
            "sales.orders.read", "sales.orders.write", "sales.orders.approve"
        ],
        "sales_rep": [
            "sales.customers.read", "sales.customers.write",
            "sales.orders.read", "sales.orders.write"
        ],
        "finance_manager": [
            "finance.accounts.read", "finance.accounts.write",
            "finance.journal.read", "finance.journal.write", "finance.journal.post"
        ],
        "accountant": [
            "finance.accounts.read", "finance.journal.read", "finance.journal.write"
        ]
    }

def require_permission(permission: str):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Get current user from request context
            user = get_current_user()
            if not user or permission not in user.get("permissions", []):
                raise HTTPException(403, f"Permission '{permission}' required")
            return await func(*args, **kwargs)
        return wrapper
    return decorator
```

### Data Encryption Strategy

```python
# Field-level encryption for sensitive data
from cryptography.fernet import Fernet

class EncryptionService:
    def __init__(self):
        self.key = os.getenv("ENCRYPTION_KEY").encode()
        self.cipher = Fernet(self.key)
    
    def encrypt_field(self, value: str) -> str:
        if not value:
            return value
        return self.cipher.encrypt(value.encode()).decode()
    
    def decrypt_field(self, encrypted_value: str) -> str:
        if not encrypted_value:
            return encrypted_value
        return self.cipher.decrypt(encrypted_value.encode()).decode()

# SQLAlchemy encrypted field type
class EncryptedType(TypeDecorator):
    impl = Text
    
    def process_bind_param(self, value, dialect):
        if value is not None:
            return encryption_service.encrypt_field(value)
        return value
    
    def process_result_value(self, value, dialect):
        if value is not None:
            return encryption_service.decrypt_field(value)
        return value
```

---

## Module Design Specifications

### Sales Module API

```python
# Sales FastAPI Application
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

app = FastAPI(title="Sales API", version="1.0.0")

# Customer endpoints
@app.get("/customers", response_model=List[CustomerResponse])
@require_permission("sales.customers.read")
async def get_customers(
    skip: int = 0,
    limit: int = 100,
    search: str = None,
    db: Session = Depends(get_db)
):
    query = db.query(Customer).filter(Customer.deleted_at.is_(None))
    
    if search:
        query = query.filter(
            Customer.company_name.ilike(f"%{search}%") |
            Customer.contact_person.ilike(f"%{search}%")
        )
    
    customers = query.offset(skip).limit(limit).all()
    return customers

@app.post("/customers", response_model=CustomerResponse)
@require_permission("sales.customers.write")
async def create_customer(
    customer: CustomerCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    db_customer = Customer(
        **customer.dict(),
        organization_id=current_user["org_id"],
        created_by=current_user["user_id"]
    )
    db.add(db_customer)
    db.commit()
    db.refresh(db_customer)
    return db_customer

# Order management
@app.post("/orders", response_model=OrderResponse)
@require_permission("sales.orders.write")
async def create_order(
    order: OrderCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    # Calculate totals
    subtotal = sum(item.quantity * item.unit_price for item in order.items)
    tax_amount = subtotal * order.tax_rate
    total_amount = subtotal + tax_amount - order.discount_amount
    
    db_order = Order(
        **order.dict(exclude={"items"}),
        organization_id=current_user["org_id"],
        subtotal=subtotal,
        tax_amount=tax_amount,
        total_amount=total_amount,
        created_by=current_user["user_id"]
    )
    
    db.add(db_order)
    db.flush()  # Get order ID
    
    # Add order items
    for item_data in order.items:
        db_item = OrderItem(
            **item_data.dict(),
            order_id=db_order.id,
            line_total=item_data.quantity * item_data.unit_price
        )
        db.add(db_item)
    
    db.commit()
    return db_order
```

### Finance Module (Django)

```python
# Django models for Finance
from django.db import models
from django.core.validators import MinValueValidator
from decimal import Decimal

class Account(models.Model):
    ACCOUNT_TYPES = [
        ('asset', 'Asset'),
        ('liability', 'Liability'),
        ('equity', 'Equity'),
        ('revenue', 'Revenue'),
        ('expense', 'Expense'),
    ]
    
    organization = models.ForeignKey('shared.Organization', on_delete=models.CASCADE)
    account_code = models.CharField(max_length=20)
    account_name = models.CharField(max_length=255)
    account_type = models.CharField(max_length=50, choices=ACCOUNT_TYPES)
    parent_account = models.ForeignKey('self', null=True, blank=True, on_delete=models.CASCADE)
    normal_balance = models.CharField(max_length=10, choices=[('debit', 'Debit'), ('credit', 'Credit')])
    is_active = models.BooleanField(default=True)
    
    class Meta:
        db_table = 'finance_accounts'
        unique_together = ['organization', 'account_code']

class JournalEntry(models.Model):
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('posted', 'Posted'),
        ('reversed', 'Reversed'),
    ]
    
    organization = models.ForeignKey('shared.Organization', on_delete=models.CASCADE)
    entry_number = models.CharField(max_length=50)
    entry_date = models.DateField()
    description = models.TextField()
    reference = models.CharField(max_length=100, blank=True)
    total_debit = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    total_credit = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
    created_by = models.ForeignKey('shared.User', on_delete=models.PROTECT)
    
    def clean(self):
        if self.total_debit != self.total_credit:
            raise ValidationError("Journal entry must be balanced")
    
    class Meta:
        db_table = 'finance_journal_entries'
        unique_together = ['organization', 'entry_number']

# Django REST API views
from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response

class AccountViewSet(viewsets.ModelViewSet):
    serializer_class = AccountSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Account.objects.filter(
            organization=self.request.user.organization,
            is_active=True
        )
    
    @action(detail=False, methods=['get'])
    def chart_of_accounts(self, request):
        """Return hierarchical chart of accounts"""
        accounts = self.get_queryset().select_related('parent_account')
        tree = build_account_tree(accounts)
        return Response(tree)

class JournalEntryViewSet(viewsets.ModelViewSet):
    serializer_class = JournalEntrySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return JournalEntry.objects.filter(
            organization=self.request.user.organization
        ).prefetch_related('lines__account')
    
    @action(detail=True, methods=['post'])
    def post_entry(self, request, pk=None):
        """Post a journal entry"""
        entry = self.get_object()
        if entry.status != 'draft':
            return Response({'error': 'Only draft entries can be posted'}, status=400)
        
        entry.status = 'posted'
        entry.posted_by = request.user
        entry.posted_at = timezone.now()
        entry.save()
        
        return Response({'status': 'posted'})
```

### HR Module (Django)

```python
# HR Models
class Employee(models.Model):
    organization = models.ForeignKey('shared.Organization', on_delete=models.CASCADE)
    employee_id = models.CharField(max_length=50)
    user = models.OneToOneField('shared.User', on_delete=models.CASCADE, null=True, blank=True)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    email = models.EmailField()
    phone = models.CharField(max_length=20, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    hire_date = models.DateField()
    termination_date = models.DateField(null=True, blank=True)
    department = models.ForeignKey('Department', on_delete=models.PROTECT)
    position = models.ForeignKey('Position', on_delete=models.PROTECT)
    manager = models.ForeignKey('self', null=True, blank=True, on_delete=models.SET_NULL)
    salary = models.DecimalField(max_digits=15, decimal_places=2, null=True, blank=True)
    employment_type = models.CharField(max_length=20, choices=[
        ('full_time', 'Full Time'),
        ('part_time', 'Part Time'),
        ('contract', 'Contract'),
        ('intern', 'Intern'),
    ])
    status = models.CharField(max_length=20, choices=[
        ('active', 'Active'),
        ('on_leave', 'On Leave'),
        ('terminated', 'Terminated'),
    ], default='active')
    
    class Meta:
        db_table = 'hr_employees'
        unique_together = ['organization', 'employee_id']

class PayrollCycle(models.Model):
    organization = models.ForeignKey('shared.Organization', on_delete=models.CASCADE)
    cycle_name = models.CharField(max_length=100)
    start_date = models.DateField()
    end_date = models.DateField()
    pay_date = models.DateField()
    status = models.CharField(max_length=20, choices=[
        ('draft', 'Draft'),
        ('calculated', 'Calculated'),
        ('approved', 'Approved'),
        ('paid', 'Paid'),
    ], default='draft')
    
    class Meta:
        db_table = 'hr_payroll_cycles'

# HR API Views with enhanced security
class EmployeeViewSet(viewsets.ModelViewSet):
    serializer_class = EmployeeSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        queryset = Employee.objects.filter(organization=user.organization)
        
        # Managers can see their direct reports and themselves
        if user.has_perm('hr.view_all_employees'):
            return queryset
        elif user.has_perm('hr.view_team_employees'):
            return queryset.filter(
                Q(manager__user=user) | Q(user=user)
            )
        else:
            return queryset.filter(user=user)
    
    @action(detail=True, methods=['post'])
    def terminate_employee(self, request, pk=None):
        employee = self.get_object()
        termination_date = request.data.get('termination_date')
        reason = request.data.get('reason')
        
        # Create termination record
        EmployeeTermination.objects.create(
            employee=employee,
            termination_date=termination_date,
            reason=reason,
            terminated_by=request.user
        )
        
        employee.status = 'terminated'
        employee.termination_date = termination_date
        employee.save()
        
        return Response({'status': 'terminated'})
```

This comprehensive design provides detailed security architecture with RBAC implementation and specific module designs for Sales (FastAPI), Finance (Django), and HR (Django) with proper authentication, authorization, and data protection measures.