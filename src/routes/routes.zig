const std = @import("std");
const horizon = @import("horizon");

const indexHandler = @import("index.zig").indexHandler;
const adminHandler = @import("admin.zig").adminHandler;

pub const routes = .{
    .{ "GET", "", indexHandler },
    .{ "GET", "admin", adminHandler },
};
