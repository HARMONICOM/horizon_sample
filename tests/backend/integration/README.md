# Integration Tests

This directory contains integration tests that require actual database connections.

## Purpose

Integration tests verify that the application components work correctly when integrated with external systems like databases. Unlike unit tests, these tests:

- Connect to real databases (PostgreSQL/MySQL)
- Perform actual CRUD operations
- Test error handling with real database constraints
- Verify transaction behavior

## Running Integration Tests

Integration tests require:

1. Database server running (use `make up`)
2. Database migrations applied (`make run zig-out/bin/migrate up`)
3. Optionally, seed data (`make run zig-out/bin/seeder development`)

```bash
# Start services
make up

# Run migrations
make run zig-out/bin/migrate up

# Run integration tests
make zig test tests/backend/integration/users_integration_test.zig
```

## Test Organization

- `users_integration_test.zig` - User model database operations
- `password_reset_integration_test.zig` - Password reset flow with database
- (Add more as needed)

## Best Practices

1. **Cleanup**: Always clean up test data after tests
2. **Isolation**: Each test should be independent
3. **Idempotency**: Tests should be able to run multiple times
4. **Transactions**: Consider using transactions for test isolation when possible
5. **Unique Data**: Use unique identifiers to avoid conflicts

## Notes

- Integration tests are slower than unit tests
- They may fail if database is not accessible
- Consider using separate test database
- Some tests may need to handle timing-dependent behavior

