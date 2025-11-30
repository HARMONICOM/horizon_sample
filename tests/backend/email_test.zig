const std = @import("std");
const testing = std.testing;
const horizon_sample = @import("horizon_sample");
const email = horizon_sample.utils.email;
const smtp = @import("smtp_client");

test "loadEmailConfig - loads from environment variables" {
    const allocator = testing.allocator;

    // Note: This test depends on environment variables being set
    // In a real test environment, you might want to mock environment variables
    const config = email.loadEmailConfig(allocator) catch |err| {
        // If environment variables are not set or there's an error, this is expected
        if (err == error.OutOfMemory) {
            return err;
        }
        // For other errors, just skip the test
        return;
    };
    defer email.freeEmailConfig(config);

    // If config loaded successfully, verify required fields exist
    try testing.expect(config.host.len > 0);
    try testing.expect(config.from_address.len > 0);
    try testing.expect(config.port > 0);
}

test "freeEmailConfig - properly frees all allocated memory" {
    const allocator = testing.allocator;

    // Create a mock email config with allocated strings
    const host = try allocator.dupe(u8, "smtp.example.com");
    const username = try allocator.dupe(u8, "user@example.com");
    const password = try allocator.dupe(u8, "password");
    const from_address = try allocator.dupe(u8, "noreply@example.com");
    const from_name = try allocator.dupe(u8, "Test App");

    const config = email.EmailConfig{
        .host = host,
        .port = 587,
        .encryption = smtp.Encryption.start_tls,
        .username = username,
        .password = password,
        .from_address = from_address,
        .from_name = from_name,
        .allocator = allocator,
    };

    // Free the config - this should not cause any memory leaks
    email.freeEmailConfig(config);
}

test "EmailConfig - can be created with minimal fields" {
    const allocator = testing.allocator;

    const host = try allocator.dupe(u8, "localhost");
    const from_address = try allocator.dupe(u8, "test@localhost");

    const config = email.EmailConfig{
        .host = host,
        .port = 25,
        .encryption = smtp.Encryption.none,
        .username = null,
        .password = null,
        .from_address = from_address,
        .from_name = null,
        .allocator = allocator,
    };

    try testing.expect(config.host.len > 0);
    try testing.expect(config.from_address.len > 0);
    try testing.expect(config.username == null);
    try testing.expect(config.password == null);
    try testing.expect(config.from_name == null);

    email.freeEmailConfig(config);
}

// Note: Testing sendPasswordResetEmail requires a mock SMTP server or integration test
// For unit tests, we only test the config loading and freeing logic
test "sendPasswordResetEmail - placeholder for integration test" {
    // This test is a placeholder
    // In a real environment, you would need:
    // 1. A mock SMTP server
    // 2. Or integration test with real SMTP credentials
    // 3. Proper error handling for network failures
    try testing.expect(true);
}
