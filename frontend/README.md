# Frontend React Application

Modern React TypeScript application for the Enterprise Management System.

## 🚀 Quick Start

### Development with Docker
```bash
# From the root directory
docker-compose up frontend

# Or start all services
docker-compose up
```

### Local Development
```bash
cd frontend
npm install
npm start
```

## 📦 Dependencies

### Core Dependencies
- **React 18.2.0** - Core framework
- **TypeScript 5.2.2** - Type safety
- **Material-UI 5.14.12** - UI components
- **React Router 6.16.0** - Client-side routing
- **Redux Toolkit 1.9.7** - State management
- **Axios 1.5.0** - HTTP client

### Development Dependencies
- **Testing Library** - Component testing
- **Jest** - Testing framework
- **React Scripts 5.0.1** - Build toolchain

## 🏗️ Architecture

### State Management
- **Redux Toolkit** for global state
- **RTK Query** for API data fetching
- **Local state** for component-specific data

### Authentication
- JWT token-based authentication
- Automatic token refresh
- Route protection with authentication guards

### API Integration
- Centralized API client with Axios
- Request/response interceptors
- Error handling and retry logic

## 📁 Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── Layout.tsx      # Main application layout
│   ├── LoadingSpinner.tsx
│   └── ...
├── pages/              # Route-based page components
│   ├── LoginPage.tsx   # Authentication
│   ├── DashboardPage.tsx
│   ├── CustomersPage.tsx
│   └── ...
├── services/           # API service layer
│   ├── apiClient.ts    # Axios configuration
│   ├── authService.ts  # Authentication API
│   └── ...
├── store/              # Redux state management
│   ├── store.ts        # Store configuration
│   ├── authSlice.ts    # Authentication state
│   └── hooks.ts        # Typed Redux hooks
├── App.tsx             # Main application component
└── index.tsx           # Application entry point
```

## 🎨 UI Components

### Material-UI Theme
- Custom color palette
- Typography configurations
- Component style overrides
- Responsive breakpoints

### Layout System
- Responsive navigation drawer
- App bar with user menu
- Main content area with proper spacing
- Mobile-first responsive design

## 🔐 Authentication

### Login Flow
1. User enters credentials
2. API authentication request
3. JWT tokens stored in localStorage
4. Automatic redirect to dashboard
5. Token validation on app reload

### Route Protection
- Private routes require authentication
- Automatic redirect to login
- Role-based access control (RBAC)

## 🌐 API Integration

### Backend Services
- **Sales API** (Port 8001) - Core business logic
- **Finance API** (Port 8002) - Financial operations
- **HR API** (Port 8003) - Human resources

### API Client Configuration
```typescript
// Base URL configuration
const API_BASE_URL = process.env.REACT_APP_SALES_API_URL || 'http://localhost:8001';

// Automatic token injection
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

## 🧪 Testing

### Component Testing
```bash
npm test
```

### Type Checking
```bash
npm run type-check
```

### Build Validation
```bash
npm run build
```

## 🐳 Docker Configuration

### Development
- Hot reload enabled
- Volume mounting for source code
- Environment variable injection

### Production
- Multi-stage build process
- Nginx static file serving
- Optimized bundle size

## 📱 Responsive Design

### Breakpoints
- **xs**: 0px and up
- **sm**: 600px and up
- **md**: 900px and up
- **lg**: 1200px and up
- **xl**: 1536px and up

### Mobile Features
- Collapsible navigation drawer
- Touch-friendly interface
- Optimized loading states

## 🔧 Environment Variables

### Development
```env
REACT_APP_SALES_API_URL=http://localhost:8001
REACT_APP_FINANCE_API_URL=http://localhost:8002
REACT_APP_HR_API_URL=http://localhost:8003
REACT_APP_ENVIRONMENT=development
```

### Production
```env
REACT_APP_SALES_API_URL=https://api.yourdomain.com
REACT_APP_FINANCE_API_URL=https://finance-api.yourdomain.com
REACT_APP_HR_API_URL=https://hr-api.yourdomain.com
REACT_APP_ENVIRONMENT=production
```

## 🚀 Deployment

### Development
```bash
docker-compose up frontend
```

### Production
```bash
# Build production image
docker build -f Dockerfile -t enterprise-frontend:latest .

# Run with environment variables
docker run -p 80:80 \
  -e REACT_APP_SALES_API_URL=https://api.yourdomain.com \
  enterprise-frontend:latest
```

## 📈 Performance

### Optimization Features
- Code splitting with React.lazy()
- Bundle size optimization
- Image optimization
- Caching strategies

### Monitoring
- Web Vitals tracking
- Error boundary implementation
- Performance metrics collection

## 🔍 Troubleshooting

### Common Issues

1. **Module Not Found Errors**
   ```bash
   # Install dependencies
   npm install
   ```

2. **TypeScript Errors**
   ```bash
   # Check type errors
   npm run type-check
   ```

3. **API Connection Issues**
   - Verify backend services are running
   - Check environment variables
   - Verify CORS configuration

### Development Tips
- Use React Developer Tools browser extension
- Enable Redux DevTools for state debugging
- Check browser console for runtime errors
- Verify network requests in browser DevTools

## 🤝 Contributing

### Code Style
- Use TypeScript for all new components
- Follow Material-UI design patterns
- Implement proper error handling
- Write tests for critical components

### Git Workflow
- Create feature branches
- Write descriptive commit messages
- Test before submitting pull requests