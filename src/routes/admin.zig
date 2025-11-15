const std = @import("std");
const horizon = @import("horizon");

const Test = @import("../models/test.zig").Test;

const Context = horizon.Context;
const Errors = horizon.Errors;

const admin_template = @embedFile("../views/admin.zts");

pub fn adminHandler(context: *Context) Errors.Horizon!void {
    const props = .{
        .message = "Welcome to the Admin Page!",
    };

    const props_json = try std.json.Stringify.valueAlloc(context.allocator, props, .{});
    defer context.allocator.free(props_json);

    try context.response.renderHeader(admin_template, .{
        .title = "Welcome to the Admin Page!",
        .props = props_json,
    });
}
