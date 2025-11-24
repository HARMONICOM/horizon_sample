const std = @import("std");
const testing = std.testing;
const horizon_sample = @import("horizon_sample");
const users = horizon_sample.models.users;

test "hashPassword - generates valid SHA-256 hash" {
    const allocator = testing.allocator;
    const password = "testpassword123";

    const hash = try users.hashPassword(allocator, password);
    defer allocator.free(hash);

    // SHA-256 produces 64-character hex string
    try testing.expect(hash.len == 64);

    // Verify it's valid hex
    for (hash) |char| {
        const is_hex = (char >= '0' and char <= '9') or (char >= 'a' and char <= 'f');
        try testing.expect(is_hex);
    }
}

test "hashPassword - same password produces same hash" {
    const allocator = testing.allocator;
    const password = "testpassword123";

    const hash1 = try users.hashPassword(allocator, password);
    defer allocator.free(hash1);

    const hash2 = try users.hashPassword(allocator, password);
    defer allocator.free(hash2);

    try testing.expectEqualStrings(hash1, hash2);
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

