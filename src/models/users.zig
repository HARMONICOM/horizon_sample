const std = @import("std");
const dig = @import("dig");
const horizon = @import("horizon");
const db = @import("../utils/db.zig");

pub const User = struct {
    id: []const u8,
    name: []const u8,
    email: []const u8,
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
