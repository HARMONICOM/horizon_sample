# Horizon Sample Tests

This directory contains the test suite for the Horizon Sample application.

## Test Structure

### Backend Tests (Zig)

Backend tests are located in `tests/backend/` and are written in Zig using the standard testing framework.

**Test Files:**

- `users_test.zig` - User model tests (password hashing, user CRUD operations)
- `passwordResetTokens_test.zig` - Password reset token generation tests
- `password_reset_full_test.zig` - Complete password reset flow tests
- `db_test.zig` - Database connection and error conversion tests
- `routes_test.zig` - Basic route handler tests
- `admin_routes_test.zig` - Admin route handler tests (authentication, authorization)
- `email_test.zig` - Email configuration and sending tests

**Running Backend Tests:**

```bash
# Run all tests
make zig build test

# Run specific test file (example)
make zig test tests/backend/users_test.zig
```

### Frontend Tests (TypeScript/React)

Frontend tests are located in `tests/frontend/` and are written using Bun test runner with jsdom for DOM emulation.

**Test Files:**

- `index.test.tsx` - Index page component tests
- `login.test.tsx` - Login page component tests
- `admin.test.tsx` - Admin dashboard component tests
- `adminCrud.test.tsx` - Admin CRUD operation component tests
- `passwordReset.test.tsx` - Password reset components tests
- `logoutComplete.test.tsx` - Logout complete page component tests
- `testUtils.tsx` - Test utility functions and setup

**Running Frontend Tests:**

```bash
# Run all frontend tests
make front-test
```

### E2E Tests (Playwright)

E2E tests are located in `tests/e2e/` and are written using Playwright for browser automation.

**Test Files:**

- `index.spec.ts` - Top page E2E tests
- `api.spec.ts` - API routes E2E tests
- `admin.spec.ts` - Admin login and dashboard E2E tests
- `passwordReset.spec.ts` - Password reset flow E2E tests
- `crud.spec.ts` - User CRUD operations E2E tests
- `fullWorkflow.spec.ts` - Complete workflow E2E tests (login → dashboard → CRUD → logout)
- `fixtures.ts` - Test fixtures and utilities

**Running E2E Tests:**

```bash
# Run E2E tests (Chromium only)
make e2e

# Run E2E tests (all browsers)
make e2e-all
```

## Test Coverage

### Backend Coverage

- ✅ Database connection and error handling
- ✅ User model (CRUD operations, password hashing, authentication)
- ✅ Password reset token generation and validation
- ✅ Email configuration loading
- ✅ Route handlers (basic and admin routes)
- ✅ Authentication and authorization

### Frontend Coverage

- ✅ Component rendering (all major components)
- ✅ Form validation and submission
- ✅ Error and success message display
- ✅ User interaction (buttons, links, forms)
- ✅ CRUD operation UI (create, edit, delete dialogs)

### E2E Coverage

- ✅ Complete login flow
- ✅ Complete logout flow
- ✅ Dashboard access and display
- ✅ User CRUD operations (create, edit, delete)
- ✅ Password reset request and reset flows
- ✅ Authentication and authorization checks
- ✅ API endpoint responses
- ✅ Static file serving

## Test Environment Setup

### Backend Tests

Backend tests require:
- PostgreSQL or MySQL database (configured in environment variables)
- Database connection details set in environment

### Frontend Tests

Frontend tests use jsdom for DOM emulation and don't require a browser.

### E2E Tests

E2E tests require:
- Running backend server
- Database with test data (seeders)
- Playwright browsers installed
- Basic Auth credentials (set in environment variables)

## Best Practices

### Backend Tests

1. Use `testing.allocator` for memory management in tests
2. Clean up resources (defer statements) after tests
3. Create isolated test data for each test
4. Clean up test data after tests complete
5. Test both success and failure cases

### Frontend Tests

1. Use `cleanup()` in `afterEach` to reset DOM state
2. Use `renderWithRouter` for components that use React Router
3. Test user interactions, not implementation details
4. Verify visible elements and user-facing behavior

### E2E Tests

1. Set up authentication before each test
2. Use proper waits for async operations
3. Test complete user workflows
4. Use descriptive test names in Japanese
5. Clean up test data when possible
6. Handle timing issues with appropriate timeouts

## Notes

- Backend tests may require database connection. Ensure database is running and accessible.
- E2E tests require the application to be running (use `make up` to start services).
- Some tests create and delete test data. Ensure proper cleanup to avoid test interference.
- Error code 3 in Zig tests indicates normal termination.

## Troubleshooting

### Backend Tests Fail

- Check database connection settings
- Ensure database is running
- Verify database migrations are up to date
- Check for conflicting test data

### Frontend Tests Fail

- Ensure all dependencies are installed (`bun install`)
- Check for missing imports or components
- Verify component props and structure

### E2E Tests Fail

- Ensure application is running (`make up`)
- Check database has seed data
- Verify Basic Auth credentials
- Check for timing issues (increase timeouts if needed)
- Ensure Playwright browsers are installed (`npx playwright install`)

