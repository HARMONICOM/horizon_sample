const std = @import("std");
const horizon = @import("horizon");

const indexHandler = @import("index.zig").indexHandler;

pub const routes = .{
    .{ "GET", "", indexHandler },
};
