-- Create schemas
CREATE SCHEMA IF NOT EXISTS shared;
CREATE SCHEMA IF NOT EXISTS sales;
CREATE SCHEMA IF NOT EXISTS finance;
CREATE SCHEMA IF NOT EXISTS hr;
CREATE SCHEMA IF NOT EXISTS audit;

-- Create shared tables
SET search_path TO shared;

CREATE TABLE IF NOT EXISTS organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    is_superuser BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(organization_id, name)
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

-- Create sales tables
SET search_path TO sales;

CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(15, 2),
    cost DECIMAL(15, 2),
    stock INTEGER DEFAULT 0,
    category VARCHAR(100),
    supplier VARCHAR(255),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    status VARCHAR(20) DEFAULT 'pending',
    payment_status VARCHAR(20) DEFAULT 'pending',
    subtotal DECIMAL(15, 2),
    tax DECIMAL(15, 2),
    shipping DECIMAL(15, 2),
    total DECIMAL(15, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    price DECIMAL(15, 2),
    total DECIMAL(15, 2)
);

-- Create finance tables
SET search_path TO finance;

CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    account_type VARCHAR(20),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES accounts(id),
    transaction_type VARCHAR(10),
    amount DECIMAL(15, 2),
    description TEXT,
    transaction_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(100),
    customer_email VARCHAR(255),
    amount DECIMAL(15, 2),
    due_date DATE,
    status VARCHAR(20) DEFAULT 'draft',
    issued_date DATE DEFAULT NOW()::DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(id),
    amount DECIMAL(15, 2),
    payment_method VARCHAR(20),
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    transaction_id VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create HR tables
SET search_path TO hr;

CREATE TABLE IF NOT EXISTS departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ensure department names are unique so ON CONFLICT (name) works in seed inserts
CREATE UNIQUE INDEX IF NOT EXISTS idx_departments_name ON departments(name);

CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    department_id INTEGER REFERENCES departments(id),
    position VARCHAR(100),
    hire_date DATE,
    employment_status VARCHAR(20) DEFAULT 'active',
    salary DECIMAL(15, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS documents (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id) ON DELETE CASCADE,
    document_type VARCHAR(30),
    title VARCHAR(200),
    file_path VARCHAR(500),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payroll_periods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    period_type VARCHAR(20),
    start_date DATE,
    end_date DATE,
    processed BOOLEAN DEFAULT FALSE,
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payroll_items (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id),
    payroll_period_id INTEGER REFERENCES payroll_periods(id),
    gross_salary DECIMAL(15, 2),
    tax_deductions DECIMAL(15, 2) DEFAULT 0,
    other_deductions DECIMAL(15, 2) DEFAULT 0,
    net_salary DECIMAL(15, 2),
    paid BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS benefits (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id) ON DELETE CASCADE,
    benefit_type VARCHAR(30),
    name VARCHAR(100),
    description TEXT,
    start_date DATE,
    end_date DATE,
    cost DECIMAL(15, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create audit tables
SET search_path TO audit;

CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    organization_id INTEGER,
    action VARCHAR(50),
    table_name VARCHAR(100),
    record_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
SET search_path TO shared;
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

SET search_path TO sales;
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);

SET search_path TO finance;
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_payments_invoice_id ON payments(invoice_id);

SET search_path TO hr;
CREATE INDEX IF NOT EXISTS idx_employees_email ON employees(email);
CREATE INDEX IF NOT EXISTS idx_employees_department_id ON employees(department_id);
CREATE INDEX IF NOT EXISTS idx_payroll_items_employee_id ON payroll_items(employee_id);

SET search_path TO audit;
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at);

-- Insert sample data
SET search_path TO shared;

INSERT INTO organizations (name, domain) VALUES 
    ('Acme Corporation', 'acme.com'),
    ('Globex Corporation', 'globex.com')
ON CONFLICT (domain) DO NOTHING;

INSERT INTO users (organization_id, username, email, password_hash, first_name, last_name, is_active, is_superuser) VALUES 
    (1, 'admin', 'admin@acme.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.PZvO.S', 'Admin', 'User', TRUE, TRUE),
    (1, 'john_doe', 'john.doe@acme.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.PZvO.S', 'John', 'Doe', TRUE, FALSE),
    (2, 'jane_smith', 'jane.smith@globex.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.PZvO.S', 'Jane', 'Smith', TRUE, TRUE)
ON CONFLICT (username) DO NOTHING;

INSERT INTO roles (organization_id, name, description) VALUES 
    (1, 'admin', 'Administrator role with full access'),
    (1, 'sales_manager', 'Sales manager role'),
    (1, 'finance_manager', 'Finance manager role'),
    (1, 'hr_manager', 'HR manager role'),
    (2, 'admin', 'Administrator role with full access')
ON CONFLICT (organization_id, name) DO NOTHING;

INSERT INTO user_roles (user_id, role_id) VALUES 
    (1, 1),
    (2, 2),
    (3, 5)
ON CONFLICT DO NOTHING;

-- Insert sample sales data
SET search_path TO sales;

INSERT INTO customers (name, email, phone, address) VALUES 
    ('John Doe', 'john.doe@example.com', '+1234567890', '123 Main St, City, State 12345'),
    ('Jane Smith', 'jane.smith@example.com', '+0987654321', '456 Oak Ave, Town, State 67890'),
    ('Acme Corp', 'contact@acme.com', '+1122334455', '789 Business Blvd, Metropolis, State 55555')
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (name, description, price, cost, stock, category, supplier, status) VALUES 
    ('Laptop Pro', 'High-performance laptop for professionals', 1299.99, 800.00, 50, 'Electronics', 'TechSupplier Inc.', 'active'),
    ('Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 12.00, 200, 'Electronics', 'TechSupplier Inc.', 'active'),
    ('Office Chair', 'Comfortable ergonomic office chair', 199.99, 120.00, 25, 'Furniture', 'Furniture Co.', 'active')
ON CONFLICT DO NOTHING;

-- Insert sample finance data
SET search_path TO finance;

INSERT INTO accounts (code, name, account_type, description) VALUES 
    ('1000', 'Cash', 'asset', 'Cash on hand'),
    ('1100', 'Accounts Receivable', 'asset', 'Money owed to the company'),
    ('4000', 'Sales Revenue', 'revenue', 'Revenue from sales'),
    ('5000', 'Cost of Goods Sold', 'expense', 'Direct costs of producing goods'),
    ('6000', 'Salaries Expense', 'expense', 'Employee salaries')
ON CONFLICT (code) DO NOTHING;

-- Insert sample HR data
SET search_path TO hr;

INSERT INTO departments (name, description) VALUES 
    ('Engineering', 'Software development and engineering'),
    ('Marketing', 'Marketing and promotions'),
    ('Human Resources', 'HR and personnel management'),
    ('Finance', 'Financial operations and accounting')
ON CONFLICT (name) DO NOTHING;

INSERT INTO employees (first_name, last_name, email, phone, department_id, position, hire_date, employment_status, salary) VALUES 
    ('John', 'Doe', 'john.doe@company.com', '+1234567890', 1, 'Senior Developer', '2025-01-15', 'active', 75000.00),
    ('Jane', 'Smith', 'jane.smith@company.com', '+0987654321', 2, 'Marketing Manager', '2025-02-20', 'active', 65000.00),
    ('Bob', 'Johnson', 'bob.johnson@company.com', '+1122334455', 3, 'HR Specialist', '2025-03-10', 'active', 55000.00)
ON CONFLICT (email) DO NOTHING;

-- Grant permissions
GRANT ALL PRIVILEGES ON SCHEMA shared TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA sales TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA finance TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA hr TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA audit TO postgres;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA shared TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sales TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA finance TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA hr TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA audit TO postgres;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA shared TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sales TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA finance TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA hr TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA audit TO postgres;