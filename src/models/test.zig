const std = @import("std");
const pg = @import("pg");
const Pool = @import("../libs/db.zig").Pool;

pub fn Test(allocator: std.mem.Allocator) !struct { pool: *pg.Pool, result: *pg.Result } {
    const pool = try Pool(allocator);
    const result = try pool.query("SELECT 1", .{});
    return .{ .pool = pool, .result = result };
}
