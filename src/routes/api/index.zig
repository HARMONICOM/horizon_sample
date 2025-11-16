const std = @import("std");
const horizon = @import("horizon");

const Context = horizon.Context;
const Errors = horizon.Errors;

pub fn indexHandler(context: *Context) Errors.Horizon!void {
    const props = .{
        .message = "Hello, World!",
    };

    const props_json = try std.json.Stringify.valueAlloc(context.allocator, props, .{});
    defer context.allocator.free(props_json);

    try context.response.json(props_json);
}
