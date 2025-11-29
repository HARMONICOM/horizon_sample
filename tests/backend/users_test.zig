const std = @import("std");
const testing = std.testing;
const horizon = @import("horizon");
const horizon_sample = @import("horizon_sample");
const users = horizon_sample.models.users;

test "hashPassword - generates valid Argon2id hash" {
    const allocator = testing.allocator;
    const password = "testpassword123";

    const hash = try users.hashPassword(allocator, password);
    defer allocator.free(hash);

    // Argon2id PHC format should start with $argon2id$
    try testing.expect(std.mem.startsWith(u8, hash, "$argon2id$"));

    // Hash should be reasonably long
    try testing.expect(hash.len > 50);
}

test "hashPassword - same password verifies correctly with different hashes" {
    const allocator = testing.allocator;
    const password = "testpassword123";

    const hash1 = try users.hashPassword(allocator, password);
    defer allocator.free(hash1);

    const hash2 = try users.hashPassword(allocator, password);
    defer allocator.free(hash2);

    // Argon2id uses random salt, so hashes are different
    try testing.expect(!std.mem.eql(u8, hash1, hash2));

    // But both should verify correctly with the original password
    try testing.expect(users.verifyPassword(password, hash1));
    try testing.expect(users.verifyPassword(password, hash2));
}

test "hashPassword - different passwords produce different hashes" {
    const allocator = testing.allocator;
    const password1 = "testpassword123";
    const password2 = "testpassword456";

    const hash1 = try users.hashPassword(allocator, password1);
    defer allocator.free(hash1);

    const hash2 = try users.hashPassword(allocator, password2);
    defer allocator.free(hash2);

    try testing.expect(!std.mem.eql(u8, hash1, hash2));
}

test "verifyPassword - correct password matches hash" {
    const allocator = testing.allocator;
    const password = "testpassword123";

    const hash = try users.hashPassword(allocator, password);
    defer allocator.free(hash);

    const is_valid = users.verifyPassword(password, hash);
    try testing.expect(is_valid);
}

test "verifyPassword - incorrect password does not match hash" {
    const allocator = testing.allocator;
    const password = "testpassword123";
    const wrong_password = "wrongpassword";

    const hash = try users.hashPassword(allocator, password);
    defer allocator.free(hash);

    const is_valid = users.verifyPassword(wrong_password, hash);
    try testing.expect(!is_valid);
}

test "verifyPassword - empty password" {
    const allocator = testing.allocator;
    const password = "";

    const hash = try users.hashPassword(allocator, password);
    defer allocator.free(hash);

    const is_valid = users.verifyPassword(password, hash);
    try testing.expect(is_valid);

    const is_invalid = users.verifyPassword("wrong", hash);
    try testing.expect(!is_invalid);
}

test "verifyPassword - long password" {
    const allocator = testing.allocator;
    const password = "a" ** 1000; // 1000 character password

    const hash = try users.hashPassword(allocator, password);
    defer allocator.free(hash);

    const is_valid = users.verifyPassword(password, hash);
    try testing.expect(is_valid);
}

test "verifyPassword - special characters" {
    const allocator = testing.allocator;
    const password = "!@#$%^&*()_+-=[]{}|;:,.<>?";

    const hash = try users.hashPassword(allocator, password);
    defer allocator.free(hash);

    const is_valid = users.verifyPassword(password, hash);
    try testing.expect(is_valid);
}

test "createUser - creates user successfully" {
    const allocator = testing.allocator;
    const login_id = "test_create_user_1";
    const password = "testpassword123";
    const name = "Test Create User";
    const email = "test_create_user_1@example.com";

    // Create user
    try users.createUser(allocator, login_id, password, name, email);

    // Verify user was created by fetching it
    const user = try users.getUserByLoginId(allocator, login_id);
    defer if (user) |u| {
        allocator.free(u.id);
        allocator.free(u.name);
        allocator.free(u.email);
        if (u.password) |pwd| allocator.free(pwd);
    };

    try testing.expect(user != null);
    try testing.expectEqualStrings(name, user.?.name);
    try testing.expectEqualStrings(email, user.?.email);

    // Verify password
    const is_valid = users.verifyPassword(password, user.?.password.?);
    try testing.expect(is_valid);

    // Cleanup: delete the test user
    try users.deleteUser(allocator, user.?.id);
}

test "createUser - creates user with email lookup" {
    const allocator = testing.allocator;
    const login_id = "test_create_user_2";
    const password = "testpassword456";
    const name = "Test Create User 2";
    const email = "test_create_user_2@example.com";

    // Create user
    try users.createUser(allocator, login_id, password, name, email);

    // Verify user was created by fetching it by email
    const user = try users.getUserByEmail(allocator, email);
    defer if (user) |u| {
        allocator.free(u.id);
        allocator.free(u.name);
        allocator.free(u.email);
        if (u.password) |pwd| allocator.free(pwd);
    };

    try testing.expect(user != null);

    // Get and verify login_id
    const fetched_login_id = try getUserLoginId(allocator, user.?.id);
    defer allocator.free(fetched_login_id);
    try testing.expectEqualStrings(login_id, fetched_login_id);

    try testing.expectEqualStrings(name, user.?.name);
    try testing.expectEqualStrings(email, user.?.email);

    // Cleanup: delete the test user
    try users.deleteUser(allocator, user.?.id);
}

test "createUser - fails with duplicate login_id" {
    const allocator = testing.allocator;
    const login_id = "test_duplicate_login";
    const password = "testpassword789";
    const name = "Test Duplicate User";
    const email1 = "test_duplicate_1@example.com";
    const email2 = "test_duplicate_2@example.com";

    // Create first user
    try users.createUser(allocator, login_id, password, name, email1);

    // Try to create second user with same login_id (should fail)
    const result = users.createUser(allocator, login_id, password, name, email2);
    try testing.expectError(horizon.Errors.Horizon.ServerError, result);

    // Cleanup: delete the first user
    const user = try users.getUserByLoginId(allocator, login_id);
    defer if (user) |u| {
        allocator.free(u.id);
        allocator.free(u.name);
        allocator.free(u.email);
        if (u.password) |pwd| allocator.free(pwd);
    };
    if (user) |u| {
        try users.deleteUser(allocator, u.id);
    }
}

test "createUser - fails with duplicate email" {
    const allocator = testing.allocator;
    const login_id1 = "test_duplicate_email_1";
    const login_id2 = "test_duplicate_email_2";
    const password = "testpassword012";
    const name = "Test Duplicate Email User";
    const email = "test_duplicate_email@example.com";

    // Create first user
    try users.createUser(allocator, login_id1, password, name, email);

    // Try to create second user with same email (should fail)
    const result = users.createUser(allocator, login_id2, password, name, email);
    try testing.expectError(horizon.Errors.Horizon.ServerError, result);

    // Cleanup: delete the first user
    const user = try users.getUserByLoginId(allocator, login_id1);
    defer if (user) |u| {
        allocator.free(u.id);
        allocator.free(u.name);
        allocator.free(u.email);
        if (u.password) |pwd| allocator.free(pwd);
    };
    if (user) |u| {
        try users.deleteUser(allocator, u.id);
    }
}

// Helper function to get login_id from user id
fn getUserLoginId(allocator: std.mem.Allocator, user_id: []const u8) ![]const u8 {
    const db = horizon_sample.utils.db;
    var conn = try db.connect(allocator);
    defer conn.disconnect();

    const id_int = try std.fmt.parseInt(i64, user_id, 10);
    var result = try conn.table("users")
        .select(&.{"login_id"})
        .where("id", "=", .{ .integer = id_int })
        .get();
    defer result.deinit();

    if (result.rows.len == 0) {
        return error.NotFound;
    }

    const login_id_value = result.rows[0].get("login_id") orelse .null;
    return switch (login_id_value) {
        .text => |t| try allocator.dupe(u8, t),
        else => error.NotFound,
    };
}
