const std = @import("std");
const pg = @import("pg");

pub fn Pool(allocator: std.mem.Allocator) !*pg.Pool {
    return try pg.Pool.init(allocator, .{ .size = 5, .connect = .{
        .port = 5432,
        .host = std.posix.getenv("DB_HOST") orelse "127.0.0.1",
    }, .auth = .{
        .username = std.posix.getenv("DB_USER") orelse "postgres",
        .database = std.posix.getenv("DB_DATABASE") orelse "postgres",
        .password = std.posix.getenv("DB_PASSWORD") orelse "postgres",
        .timeout = 10_000,
    } });
}
