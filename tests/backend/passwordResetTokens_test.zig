const std = @import("std");
const testing = std.testing;
const horizon_sample = @import("horizon_sample");
const passwordResetTokens = horizon_sample.models.passwordResetTokens;

test "generateToken - generates valid hex token" {
    const allocator = testing.allocator;

    const token = try passwordResetTokens.generateToken(allocator);
    defer allocator.free(token);

    // Token should be 64 characters (32 bytes * 2 hex chars per byte)
    try testing.expect(token.len == 64);

    // Verify it's valid hex
    for (token) |char| {
        const is_hex = (char >= '0' and char <= '9') or (char >= 'a' and char <= 'f');
        try testing.expect(is_hex);
    }
}

test "generateToken - generates different tokens each time" {
    const allocator = testing.allocator;

    const token1 = try passwordResetTokens.generateToken(allocator);
    defer allocator.free(token1);

    const token2 = try passwordResetTokens.generateToken(allocator);
    defer allocator.free(token2);

    // Tokens should be different (very high probability)
    try testing.expect(!std.mem.eql(u8, token1, token2));
}

test "generateToken - generates multiple unique tokens" {
    const allocator = testing.allocator;
    const num_tokens = 100;
    var tokens = std.ArrayList([]const u8){};
    defer {
        for (tokens.items) |token| {
            allocator.free(token);
        }
        tokens.deinit(allocator);
    }

    var i: usize = 0;
    while (i < num_tokens) : (i += 1) {
        const token = try passwordResetTokens.generateToken(allocator);
        try tokens.append(allocator, token);
    }

    // Verify all tokens are unique
    for (tokens.items, 0..) |token1, idx1| {
        for (tokens.items[idx1 + 1 ..]) |token2| {
            try testing.expect(!std.mem.eql(u8, token1, token2));
        }
    }
}

