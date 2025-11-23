const std = @import("std");
const horizon = @import("horizon");

const Context = horizon.Context;
const Errors = horizon.Errors;

const users = @import("../../models/users.zig");

const index_template = @embedFile("../../views/admin/index.zts");

pub fn indexHandler(context: *Context) Errors.Horizon!void {
    var user_list = try users.GetUserList(context.allocator);
    defer {
        for (user_list.items) |user| {
            context.allocator.free(user.id);
            context.allocator.free(user.name);
            context.allocator.free(user.email);
        }
        user_list.deinit(context.allocator);
    }

    // Prepare data structure for JSON serialization
    const props = .{
        .users = user_list.items,
    };

    // Convert to JSON using std.json.fmt
    const props_json = try std.fmt.allocPrint(
        context.allocator,
        "{f}",
        .{std.json.fmt(props, .{})},
    );
    defer context.allocator.free(props_json);

    try context.response.renderHeader(index_template, .{
        .title = "Welcome to the Admin Page!",
        .props = props_json,
    });
}
