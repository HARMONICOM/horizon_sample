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

/// Format timestamp as PostgreSQL TIMESTAMP string
/// Converts Unix timestamp (seconds since 1970-01-01 00:00:00 UTC) to PostgreSQL TIMESTAMP format
/// Returns string in format: YYYY-MM-DD HH:MM:SS
fn formatTimestamp(allocator: std.mem.Allocator, timestamp: i64) ![]const u8 {
    // Ensure timestamp is non-negative for simplicity
    const ts = if (timestamp < 0) @as(i64, 0) else timestamp;

    // Calculate days since epoch (1970-01-01)
    var days = @divTrunc(ts, 86400);
    var seconds_in_day = @mod(ts, 86400);

    // Handle negative modulo
    if (seconds_in_day < 0) {
        days -= 1;
        seconds_in_day += 86400;
    }

    // Calculate year
    var year: i32 = 1970;
    var days_remaining = days;

    // Iterate through years
    while (days_remaining >= 0) {
        const days_in_year: i64 = if (isLeapYear(year)) 366 else 365;
        if (days_remaining < days_in_year) break;
        days_remaining -= days_in_year;
        year += 1;
    }

    // Calculate month and day
    const month_days = [_]i32{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    const is_leap = isLeapYear(year);

    var month: i32 = 1;
    var day: i32 = @as(i32, @intCast(days_remaining)) + 1;

    var m: usize = 0;
    while (m < 12) {
        var days_in_month = month_days[m];
        if (m == 1 and is_leap) {
            days_in_month = 29;
        }
        if (day > days_in_month) {
            day -= days_in_month;
            month += 1;
            m += 1;
        } else {
            break;
        }
    }

    // Calculate time components
    const hour = @as(i32, @intCast(@divTrunc(seconds_in_day, 3600)));
    const min = @as(i32, @intCast(@divTrunc(@mod(seconds_in_day, 3600), 60)));
    const sec = @as(i32, @intCast(@mod(seconds_in_day, 60)));

    // Format as YYYY-MM-DD HH:MM:SS (ensure values are in valid range)
    const safe_year = if (year < 1970) 1970 else if (year > 9999) 9999 else year;
    const safe_month = if (month < 1) 1 else if (month > 12) 12 else month;
    const safe_day = if (day < 1) 1 else if (day > 31) 31 else day;
    const safe_hour = if (hour < 0) 0 else if (hour > 23) 23 else hour;
    const safe_min = if (min < 0) 0 else if (min > 59) 59 else min;
    const safe_sec = if (sec < 0) 0 else if (sec > 59) 59 else sec;

    // Convert to unsigned integers to avoid sign display in format
    const year_u = @as(u32, @intCast(safe_year));
    const month_u = @as(u32, @intCast(safe_month));
    const day_u = @as(u32, @intCast(safe_day));
    const hour_u = @as(u32, @intCast(safe_hour));
    const min_u = @as(u32, @intCast(safe_min));
    const sec_u = @as(u32, @intCast(safe_sec));

    return std.fmt.allocPrint(
        allocator,
        "{d:0>4}-{d:0>2}-{d:0>2} {d:0>2}:{d:0>2}:{d:0>2}",
        .{ year_u, month_u, day_u, hour_u, min_u, sec_u },
    );
}

/// Check if year is a leap year
fn isLeapYear(year: i32) bool {
    return (@mod(year, 4) == 0 and @mod(year, 100) != 0) or (@mod(year, 400) == 0);
}

/// Parse PostgreSQL TIMESTAMP string to Unix timestamp
/// Converts PostgreSQL TIMESTAMP format (YYYY-MM-DD HH:MM:SS) to Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
fn parseTimestamp(timestamp_str: []const u8) i64 {
    // Parse YYYY-MM-DD HH:MM:SS format
    if (std.mem.indexOf(u8, timestamp_str, " ")) |space_pos| {
        const date_part = timestamp_str[0..space_pos];
        const time_part = timestamp_str[space_pos + 1 ..];

        var date_iter = std.mem.splitSequence(u8, date_part, "-");
        const year_str = date_iter.next() orelse return 0;
        const month_str = date_iter.next() orelse return 0;
        const day_str = date_iter.next() orelse return 0;

        var time_iter = std.mem.splitSequence(u8, time_part, ":");
        const hour_str = time_iter.next() orelse return 0;
        const min_str = time_iter.next() orelse return 0;
        const sec_str = time_iter.next() orelse return 0;

        const year = std.fmt.parseInt(i32, year_str, 10) catch return 0;
        const month = std.fmt.parseInt(i32, month_str, 10) catch return 0;
        const day = std.fmt.parseInt(i32, day_str, 10) catch return 0;
        const hour = std.fmt.parseInt(i32, hour_str, 10) catch return 0;
        const min = std.fmt.parseInt(i32, min_str, 10) catch return 0;
        const sec = std.fmt.parseInt(i32, sec_str, 10) catch return 0;

        // Calculate days since epoch (1970-01-01)
        var days: i64 = 0;
        var y: i32 = 1970;
        while (y < year) {
            days += if (isLeapYear(y)) 366 else 365;
            y += 1;
        }

        // Add days for months in the current year
        const month_days = [_]i32{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
        const is_leap = isLeapYear(year);
        var m: i32 = 1;
        while (m < month) {
            var days_in_month = month_days[@as(usize, @intCast(m - 1))];
            if (m == 2 and is_leap) {
                days_in_month = 29;
            }
            days += days_in_month;
            m += 1;
        }

        // Add days for the current month (day - 1 because day 1 is the first day)
        days += @as(i64, @intCast(day - 1));

        // Calculate seconds for the time of day
        const seconds_today = @as(i64, @intCast(hour * 3600 + min * 60 + sec));

        // Return total seconds since epoch
        return days * 86400 + seconds_today;
    }
    return 0;
}

/// Create a password reset token
pub fn createToken(allocator: std.mem.Allocator, user_id: []const u8) horizon.Errors.Horizon![]const u8 {
    const token = try generateToken(allocator);
    errdefer allocator.free(token);

    // Token expires in 24 hours
    const expires_at_timestamp = std.time.timestamp() + (24 * 60 * 60);
    const expires_at_str = try formatTimestamp(allocator, expires_at_timestamp);
    defer allocator.free(expires_at_str);

    var conn = db.connect(allocator) catch |err| {
        return db.convertDigError(err);
    };
    defer conn.disconnect();

    var query_builder = conn.table("password_reset_tokens") catch |err| {
        return db.convertDigError(err);
    };
    defer query_builder.deinit();

    // Try to parse user_id as integer first, otherwise use as text
    if (std.fmt.parseInt(i64, user_id, 10)) |id_int| {
        _ = query_builder.addValue("user_id", .{ .integer = id_int }) catch |err| {
            return db.convertDigError(err);
        };
    } else |_| {
        _ = query_builder.addValue("user_id", .{ .text = user_id }) catch |err| {
            return db.convertDigError(err);
        };
    }

    _ = query_builder.addValue("token", .{ .text = token }) catch |err| {
        return db.convertDigError(err);
    };
    _ = query_builder.addValue("expires_at", .{ .text = expires_at_str }) catch |err| {
        return db.convertDigError(err);
    };
    _ = query_builder.addValue("used", .{ .text = "false" }) catch |err| {
        return db.convertDigError(err);
    };

    _ = query_builder.execute() catch |err| {
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

    var query_builder = conn.table("password_reset_tokens") catch |err| {
        return db.convertDigError(err);
    };
    defer query_builder.deinit();

    _ = query_builder.where("token", "=", .{ .text = token_str }) catch |err| {
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
        .text => |t| parseTimestamp(t),
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
        .text => |t| parseTimestamp(t),
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

    var query_builder = conn.table("password_reset_tokens") catch |err| {
        return db.convertDigError(err);
    };
    defer query_builder.deinit();

    // Try to parse as integer first, otherwise use as text
    if (std.fmt.parseInt(i64, token_id, 10)) |id_int| {
        _ = query_builder.where("id", "=", .{ .integer = id_int }) catch |err| {
            return db.convertDigError(err);
        };
    } else |_| {
        _ = query_builder.where("id", "=", .{ .text = token_id }) catch |err| {
            return db.convertDigError(err);
        };
    }

    _ = query_builder.set("used", .{ .text = "true" }) catch |err| {
        return db.convertDigError(err);
    };

    _ = query_builder.execute() catch |err| {
        return db.convertDigError(err);
    };
}

