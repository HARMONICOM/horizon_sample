const std = @import("std");
const horizon = @import("horizon");

const Context = horizon.Context;
const Errors = horizon.Errors;
const SessionMiddleware = horizon.SessionMiddleware;

const users = @import("../../models/users.zig");

const index_template = @embedFile("../../views/admin/dashboard.zts");

pub fn dashboardHandler(context: *Context) Errors.Horizon!void {
    // Check if user is logged in
    const is_logged_in = if (SessionMiddleware.getSession(context.request)) |session|
        std.mem.eql(u8, session.get("logged_in") orelse "", "true")
    else
        false;

    if (!is_logged_in) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Login required");
        }
        try context.response.redirect("/admin");
        return;
    }

    // Get logged in user email from session
    const user_email = if (SessionMiddleware.getSession(context.request)) |session|
        session.get("user_email") orelse "Unknown"
    else
        "Unknown";

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
        .message = "Welcome to Admin Dashboard",
        .user_email = user_email,
        .users = user_list.items,
    };

    // Convert to JSON using std.json.Stringify.valueAlloc
    const props_json = try std.json.Stringify.valueAlloc(context.allocator, props, .{});
    defer context.allocator.free(props_json);

    try context.response.renderHeader(index_template, .{
        .title = "Admin Dashboard",
        .props = props_json,
    });
}
