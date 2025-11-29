const std = @import("std");
const dig = @import("dig");
const horizon = @import("horizon");
const db = @import("../utils/db.zig");

pub const User = struct {
    id: []const u8,
    name: []const u8,
    email: []const u8,
    password: ?[]const u8 = null,
};

/// Update user basic profile (name, email)
pub fn updateUserProfile(allocator: std.mem.Allocator, user_id: []const u8, name: []const u8, email: []const u8) horizon.Errors.Horizon!void {
    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    // Convert user_id string to integer
    const id_int = std.fmt.parseInt(i64, user_id, 10) catch |err| {
        return switch (err) {
            error.InvalidCharacter, error.Overflow => horizon.Errors.Horizon.InvalidRequest,
        };
    };
    conn.table("users")
        .set("name", .{ .text = name })
        .set("email", .{ .text = email })
        .where("id", "=", .{ .integer = id_int })
        .execute() catch |err| {
        return db.convertDigError(err);
    };
}

/// Delete user by id
pub fn deleteUser(allocator: std.mem.Allocator, user_id: []const u8) horizon.Errors.Horizon!void {
    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    // Convert user_id string to integer
    const id_int = std.fmt.parseInt(i64, user_id, 10) catch |err| {
        return switch (err) {
            error.InvalidCharacter, error.Overflow => horizon.Errors.Horizon.InvalidRequest,
        };
    };
    conn.table("users")
        .delete()
        .where("id", "=", .{ .integer = id_int })
        .execute() catch |err| {
        return db.convertDigError(err);
    };
}

pub fn GetUserList(allocator: std.mem.Allocator) horizon.Errors.Horizon!std.ArrayList(User) {
    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    var result = conn.table("users").get() catch |err| {
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

/// Hash password using Argon2id with random salt
/// Delegates to horizon.crypto.hashPassword
pub fn hashPassword(allocator: std.mem.Allocator, password: []const u8) horizon.Errors.Horizon![]const u8 {
    return horizon.crypto.hashPassword(allocator, password) catch |err| {
        return switch (err) {
            error.OutOfMemory => error.OutOfMemory,
            else => error.ServerError,
        };
    };
}

/// Verify password against Argon2id PHC format hash string
/// Delegates to horizon.crypto.verifyPassword
pub fn verifyPassword(password: []const u8, hashed_password: []const u8) bool {
    return horizon.crypto.verifyPassword(password, hashed_password);
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

    var result = conn.table("users")
        .where("email", "=", .{ .text = email_to_search }).get() catch |err| {
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

    var result = conn.table("users")
        .where("login_id", "=", .{ .text = login_id }).get() catch |err| {
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

    // Convert user_id string to integer
    const id_int = std.fmt.parseInt(i64, user_id, 10) catch |err| {
        return switch (err) {
            error.InvalidCharacter, error.Overflow => horizon.Errors.Horizon.InvalidRequest,
        };
    };

    conn.table("users")
        .where("id", "=", .{ .integer = id_int })
        .set("password_hash", .{ .text = hashed_password })
        .execute() catch |err| {
        return db.convertDigError(err);
    };
}

/// Create new user
pub fn createUser(allocator: std.mem.Allocator, login_id: []const u8, password: []const u8, name: []const u8, email: []const u8) horizon.Errors.Horizon!void {
    const hashed_password = try hashPassword(allocator, password);
    defer allocator.free(hashed_password);

    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    conn.table("users")
        .addValue("login_id", .{ .text = login_id })
        .addValue("password_hash", .{ .text = hashed_password })
        .addValue("name", .{ .text = name })
        .addValue("email", .{ .text = email })
        .execute() catch |err| {
        return db.convertDigError(err);
    };
}
