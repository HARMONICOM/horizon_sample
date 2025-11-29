const std = @import("std");
const crypto = std.crypto;
const dig = @import("dig");
const horizon = @import("horizon");
const db = @import("../utils/db.zig");

pub const PasswordResetToken = struct {
    id: []const u8,
    user_id: []const u8,
    token: []const u8,
    expires_at: i64,
    used: bool,
    created_at: i64,
};

/// Generate a random token
pub fn generateToken(allocator: std.mem.Allocator) ![]const u8 {
    var random_bytes: [32]u8 = undefined;
    crypto.random.bytes(&random_bytes);

    // Convert to hex string
    const hex_digits = "0123456789abcdef";
    var hex = try std.ArrayList(u8).initCapacity(allocator, 64);
    errdefer hex.deinit(allocator);
    for (random_bytes) |byte| {
        try hex.append(allocator, hex_digits[byte >> 4]);
        try hex.append(allocator, hex_digits[byte & 0x0F]);
    }
    return try hex.toOwnedSlice(allocator);
}

/// Create a password reset token
pub fn createToken(allocator: std.mem.Allocator, user_id: []const u8) horizon.Errors.Horizon![]const u8 {
    const token = try generateToken(allocator);
    errdefer allocator.free(token);

    // Token expires in 24 hours
    const expires_at_timestamp = std.time.timestamp() + (24 * 60 * 60);
    const expires_at_str = try horizon.formatTimestamp(allocator, expires_at_timestamp);
    defer allocator.free(expires_at_str);

    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    var query_builder = (&conn).table("password_reset_tokens");

    // Try to parse user_id as integer first, otherwise use as text
    if (std.fmt.parseInt(i64, user_id, 10)) |id_int| {
        _ = query_builder.addValue("user_id", .{ .integer = id_int });
    } else |_| {
        _ = query_builder.addValue("user_id", .{ .text = user_id });
    }

    _ = query_builder.addValue("token", .{ .text = token });
    _ = query_builder.addValue("expires_at", .{ .text = expires_at_str });
    _ = query_builder.addValue("used", .{ .integer = 0 });

    query_builder.execute() catch |err| {
        return db.convertDigError(err);
    };

    return token;
}

/// Get token by token string
pub fn getTokenByToken(allocator: std.mem.Allocator, token_str: []const u8) horizon.Errors.Horizon!?PasswordResetToken {
    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    var query_builder = (&conn).table("password_reset_tokens");
    _ = query_builder.where("token", "=", .{ .text = token_str });

    var result = query_builder.get() catch |err| {
        return db.convertDigError(err);
    };
    defer result.deinit();

    if (result.rows.len == 0) {
        return null;
    }

    const row = result.rows[0];
    const id_value = row.get("id") orelse .null;
    const user_id_value = row.get("user_id") orelse .null;
    const token_value = row.get("token") orelse .null;
    const expires_at_value = row.get("expires_at") orelse .null;
    const used_value = row.get("used") orelse .null;
    const created_at_value = row.get("created_at") orelse .null;

    const id_str = switch (id_value) {
        .text => |t| try allocator.dupe(u8, t),
        .integer => |i| try std.fmt.allocPrint(allocator, "{d}", .{i}),
        .null => try allocator.dupe(u8, ""),
        else => try allocator.dupe(u8, ""),
    };
    const user_id_str = switch (user_id_value) {
        .text => |t| try allocator.dupe(u8, t),
        .integer => |i| try std.fmt.allocPrint(allocator, "{d}", .{i}),
        .null => try allocator.dupe(u8, ""),
        else => try allocator.dupe(u8, ""),
    };
    const token_value_str = switch (token_value) {
        .text => |t| try allocator.dupe(u8, t),
        .null => try allocator.dupe(u8, ""),
        else => try allocator.dupe(u8, ""),
    };
    const expires_at_int = switch (expires_at_value) {
        .text => |t| horizon.parseTimestamp(t),
        .integer => |i| i,
        .null => @as(i64, 0),
        else => @as(i64, 0),
    };
    const used_bool = switch (used_value) {
        .text => |t| std.mem.eql(u8, t, "true") or std.mem.eql(u8, t, "t") or std.mem.eql(u8, t, "1"),
        .integer => |i| i != 0,
        .null => false,
        else => false,
    };
    const created_at_int = switch (created_at_value) {
        .text => |t| horizon.parseTimestamp(t),
        .integer => |i| i,
        .null => @as(i64, 0),
        else => @as(i64, 0),
    };

    return PasswordResetToken{
        .id = id_str,
        .user_id = user_id_str,
        .token = token_value_str,
        .expires_at = expires_at_int,
        .used = used_bool,
        .created_at = created_at_int,
    };
}

/// Mark token as used
pub fn markTokenAsUsed(allocator: std.mem.Allocator, token_id: []const u8) horizon.Errors.Horizon!void {
    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    var query_builder = (&conn).table("password_reset_tokens");

    // Try to parse as integer first, otherwise use as text
    if (std.fmt.parseInt(i64, token_id, 10)) |id_int| {
        _ = query_builder.where("id", "=", .{ .integer = id_int });
    } else |_| {
        _ = query_builder.where("id", "=", .{ .text = token_id });
    }

    _ = query_builder.set("used", .{ .integer = 1 });

    query_builder.execute() catch |err| {
        return db.convertDigError(err);
    };
}
