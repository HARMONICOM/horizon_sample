const std = @import("std");
const crypto = std.crypto;
const dig = @import("dig");
const horizon = @import("horizon");
const db = @import("../utils/db.zig");
const Sha256 = crypto.hash.sha2.Sha256;

pub const User = struct {
    id: []const u8,
    name: []const u8,
    email: []const u8,
    password: ?[]const u8 = null,
};

pub fn GetUserList(allocator: std.mem.Allocator) horizon.Errors.Horizon!std.ArrayList(User) {
    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    var query_builder = conn.table("users") catch |err| {
        return db.convertDigError(err);
    };
    defer query_builder.deinit();

    var result = query_builder.get() catch |err| {
        return db.convertDigError(err);
    };
    defer result.deinit();

    var list: std.ArrayList(User) = .{};
    errdefer list.deinit(allocator);

    for (result.rows) |row| {
        const id_value = row.get("id") orelse .null;
        const name_value = row.get("name") orelse .null;
        const email_value = row.get("email") orelse .null;

        const id_str = switch (id_value) {
            .text => |t| try allocator.dupe(u8, t),
            .integer => |i| try std.fmt.allocPrint(allocator, "{d}", .{i}),
            .null => try allocator.dupe(u8, ""),
            else => try allocator.dupe(u8, ""),
        };
        const name_str = switch (name_value) {
            .text => |t| try allocator.dupe(u8, t),
            .null => try allocator.dupe(u8, ""),
            else => try allocator.dupe(u8, ""),
        };
        const email_str = switch (email_value) {
            .text => |t| try allocator.dupe(u8, t),
            .null => try allocator.dupe(u8, ""),
            else => try allocator.dupe(u8, ""),
        };

        try list.append(allocator, User{
            .id = id_str,
            .name = name_str,
            .email = email_str,
        });
    }

    return list;
}

/// Hash password using SHA-256
pub fn hashPassword(allocator: std.mem.Allocator, password: []const u8) ![]const u8 {
    var hasher = Sha256.init(.{});
    hasher.update(password);
    var hash: [32]u8 = undefined;
    hasher.final(&hash);

    // Convert to hex string manually
    const hex_digits = "0123456789abcdef";
    var hex = std.ArrayList(u8){};
    errdefer hex.deinit(allocator);
    for (hash) |byte| {
        try hex.append(allocator, hex_digits[byte >> 4]);
        try hex.append(allocator, hex_digits[byte & 0x0F]);
    }
    return try hex.toOwnedSlice(allocator);
}

/// Verify password
pub fn verifyPassword(password: []const u8, hashed_password: []const u8) bool {
    var hasher = Sha256.init(.{});
    hasher.update(password);
    var hash: [32]u8 = undefined;
    hasher.final(&hash);

    // Convert to hex string manually
    const hex_digits = "0123456789abcdef";
    var hex_buf: [64]u8 = undefined;
    var i: usize = 0;
    for (hash) |byte| {
        hex_buf[i] = hex_digits[byte >> 4];
        hex_buf[i + 1] = hex_digits[byte & 0x0F];
        i += 2;
    }
    return std.mem.eql(u8, &hex_buf, hashed_password);
}

/// Get user by email
pub fn getUserByEmail(allocator: std.mem.Allocator, email: []const u8) horizon.Errors.Horizon!?User {
    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    // Trim whitespace from email
    const trimmed_email = std.mem.trim(u8, email, " \t\n\r");
    const email_to_search = try allocator.dupe(u8, trimmed_email);
    defer allocator.free(email_to_search);

    var query_builder = conn.table("users") catch |err| {
        return db.convertDigError(err);
    };
    defer query_builder.deinit();

    _ = query_builder.where("email", "=", .{ .text = email_to_search }) catch |err| {
        return db.convertDigError(err);
    };

    var result = query_builder.get() catch |err| {
        return db.convertDigError(err);
    };
    defer result.deinit();

    if (result.rows.len == 0) {
        return null;
    }

    const row = result.rows[0];
    const id_value = row.get("id") orelse .null;
    const name_value = row.get("name") orelse .null;
    const email_value = row.get("email") orelse .null;
    const password_value = row.get("password_hash") orelse row.get("password") orelse .null;

    const id_str = switch (id_value) {
        .text => |t| try allocator.dupe(u8, t),
        .integer => |i| try std.fmt.allocPrint(allocator, "{d}", .{i}),
        .null => try allocator.dupe(u8, ""),
        else => try allocator.dupe(u8, ""),
    };
    const name_str = switch (name_value) {
        .text => |t| try allocator.dupe(u8, t),
        .null => try allocator.dupe(u8, ""),
        else => try allocator.dupe(u8, ""),
    };
    const email_str = switch (email_value) {
        .text => |t| try allocator.dupe(u8, t),
        .null => try allocator.dupe(u8, ""),
        else => try allocator.dupe(u8, ""),
    };
    const password_str = switch (password_value) {
        .text => |t| try allocator.dupe(u8, t),
        .null => null,
        else => null,
    };

    return User{
        .id = id_str,
        .name = name_str,
        .email = email_str,
        .password = password_str,
    };
}

/// Get user by login_id
pub fn getUserByLoginId(allocator: std.mem.Allocator, login_id: []const u8) horizon.Errors.Horizon!?User {
    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    var query_builder = conn.table("users") catch |err| {
        return db.convertDigError(err);
    };
    defer query_builder.deinit();

    _ = query_builder.where("login_id", "=", .{ .text = login_id }) catch |err| {
        return db.convertDigError(err);
    };

    var result = query_builder.get() catch |err| {
        return db.convertDigError(err);
    };
    defer result.deinit();

    if (result.rows.len == 0) {
        return null;
    }

    const row = result.rows[0];
    const id_value = row.get("id") orelse .null;
    const name_value = row.get("name") orelse .null;
    const email_value = row.get("email") orelse .null;
    const password_value = row.get("password_hash") orelse row.get("password") orelse .null;

    const id_str = switch (id_value) {
        .text => |t| try allocator.dupe(u8, t),
        .integer => |i| try std.fmt.allocPrint(allocator, "{d}", .{i}),
        .null => try allocator.dupe(u8, ""),
        else => try allocator.dupe(u8, ""),
    };
    const name_str = switch (name_value) {
        .text => |t| try allocator.dupe(u8, t),
        .null => try allocator.dupe(u8, ""),
        else => try allocator.dupe(u8, ""),
    };
    const email_str = switch (email_value) {
        .text => |t| try allocator.dupe(u8, t),
        .null => try allocator.dupe(u8, ""),
        else => try allocator.dupe(u8, ""),
    };
    const password_str = switch (password_value) {
        .text => |t| try allocator.dupe(u8, t),
        .null => null,
        else => null,
    };

    return User{
        .id = id_str,
        .name = name_str,
        .email = email_str,
        .password = password_str,
    };
}

/// Update user password
pub fn updatePassword(allocator: std.mem.Allocator, user_id: []const u8, new_password: []const u8) horizon.Errors.Horizon!void {
    const hashed_password = try hashPassword(allocator, new_password);
    defer allocator.free(hashed_password);

    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    var query_builder = conn.table("users") catch |err| {
        return db.convertDigError(err);
    };
    defer query_builder.deinit();

    // Try to parse as integer first, otherwise use as text
    if (std.fmt.parseInt(i64, user_id, 10)) |id_int| {
        _ = query_builder.where("id", "=", .{ .integer = id_int }) catch |err| {
            return db.convertDigError(err);
        };
    } else |_| {
        _ = query_builder.where("id", "=", .{ .text = user_id }) catch |err| {
            return db.convertDigError(err);
        };
    }

    _ = query_builder.set("password_hash", .{ .text = hashed_password }) catch |err| {
        return db.convertDigError(err);
    };

    _ = query_builder.execute() catch |err| {
        return db.convertDigError(err);
    };
}
