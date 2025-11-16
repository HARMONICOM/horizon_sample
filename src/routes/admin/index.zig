const std = @import("std");
const horizon = @import("horizon");

const Context = horizon.Context;
const Errors = horizon.Errors;

const index_template = @embedFile("../../views/admin/index.zts");

pub fn indexHandler(context: *Context) Errors.Horizon!void {
    const props = .{
        .message = "Welcome to the Admin Page!",
    };

    const props_json = try std.json.Stringify.valueAlloc(context.allocator, props, .{});
    defer context.allocator.free(props_json);

    try context.response.renderHeader(index_template, .{
        .title = "Welcome to the Admin Page!",
        .props = props_json,
    });
}
