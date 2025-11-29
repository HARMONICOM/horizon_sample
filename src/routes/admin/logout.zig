const std = @import("std");
const horizon = @import("horizon");
const Errors = horizon.Errors;
const SessionMiddleware = horizon.SessionMiddleware;
const Response = horizon.Response;

const Context = horizon.Context;

const logout_complete_template = @embedFile("../../views/admin/logoutComplete.zts");

/// POST /admin/logout - Handle logout
pub fn logoutHandler(context: *Context) Errors.Horizon!void {
    if (SessionMiddleware.getSession(context.request)) |session| {
        // Clear session data
        _ = session.remove("user_id");
        _ = session.remove("user_email");
        _ = session.remove("logged_in");
    }

    // Redirect to logout complete page
    try context.response.redirect("/admin/logout-complete");
}

/// GET /admin/logout-complete - Show logout complete page
pub fn logoutCompletePageHandler(context: *Context) Errors.Horizon!void {
    // Prepare data structure for JSON serialization
    const Props = struct {
        @"error": []const u8,
        success: []const u8,
    };
    const props = Props{
        .@"error" = "",
        .success = "Logged out successfully",
    };

    // Convert to JSON using std.json.Stringify.valueAlloc
    const props_json = try std.json.Stringify.valueAlloc(context.allocator, props, .{});
    defer context.allocator.free(props_json);

    try context.response.renderHeader(logout_complete_template, .{
        .title = "Logout Complete",
        .props = props_json,
    });
}
