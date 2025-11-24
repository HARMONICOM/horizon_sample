const std = @import("std");
const horizon = @import("horizon");
const users = @import("../../models/users.zig");

const Context = horizon.Context;
const Errors = horizon.Errors;
const SessionMiddleware = horizon.SessionMiddleware;
const Response = horizon.Response;
const urlEncode = horizon.urlEncode;
const urlDecode = horizon.urlDecode;

const login_template = @embedFile("../../views/admin/index.zts");

/// GET /admin - Show login page
pub fn loginPageHandler(context: *Context) Errors.Horizon!void {
    var error_message: []const u8 = "";
    var error_message_owned: ?[]u8 = null;
    var success_message: []const u8 = "";
    var success_message_owned: ?[]u8 = null;
    defer {
        if (error_message_owned) |msg| context.allocator.free(msg);
        if (success_message_owned) |msg| context.allocator.free(msg);
    }

    // Get flash messages from session
    if (SessionMiddleware.getSession(context.request)) |session| {
        if (session.get("flash_error")) |msg| {
            // Copy the message before removing from session
            error_message_owned = try context.allocator.dupe(u8, msg);
            error_message = error_message_owned.?;
            // Remove flash message after reading
            _ = session.remove("flash_error");
        }
        if (session.get("flash_success")) |msg| {
            // Copy the message before removing from session
            success_message_owned = try context.allocator.dupe(u8, msg);
            success_message = success_message_owned.?;
            // Remove flash message after reading
            _ = session.remove("flash_success");
        }
    }

    // Prepare data structure for JSON serialization
    const Props = struct {
        @"error": []const u8,
        success: []const u8,
    };
    const props = Props{
        .@"error" = error_message,
        .success = success_message,
    };

    // Convert to JSON using std.json.Stringify.valueAlloc
    const props_json = try std.json.Stringify.valueAlloc(context.allocator, props, .{});
    defer context.allocator.free(props_json);

    try context.response.renderHeader(login_template, .{
        .title = "Login",
        .props = props_json,
    });
}

/// POST /admin - Handle login
pub fn loginHandler(context: *Context) Errors.Horizon!void {
    const body = context.request.body;

    // Parse form data
    var login_id: ?[]const u8 = null;
    var password: ?[]const u8 = null;

    var iter = std.mem.splitSequence(u8, body, "&");
    while (iter.next()) |pair| {
        if (std.mem.indexOf(u8, pair, "=")) |eq_pos| {
            const key = std.mem.trim(u8, pair[0..eq_pos], " ");
            const value_raw = pair[eq_pos + 1 ..];
            const value = try std.mem.replaceOwned(u8, context.allocator, value_raw, "+", " ");
            defer context.allocator.free(value);
            const decoded_value = try urlDecode(context.allocator, value);
            defer context.allocator.free(decoded_value);

            if (std.mem.eql(u8, key, "login_id")) {
                login_id = try context.allocator.dupe(u8, decoded_value);
            } else if (std.mem.eql(u8, key, "password")) {
                password = try context.allocator.dupe(u8, decoded_value);
            }
        }
    }

    if (login_id == null or password == null) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Please enter your login ID and password");
        }
        try context.response.redirect("/admin");
        return;
    }
    defer {
        if (login_id) |l| context.allocator.free(l);
        if (password) |p| context.allocator.free(p);
    }

    // Get user by login_id
    const user = try users.getUserByLoginId(context.allocator, login_id.?);
    defer if (user) |u| {
        context.allocator.free(u.id);
        context.allocator.free(u.name);
        context.allocator.free(u.email);
        if (u.password) |pwd| context.allocator.free(pwd);
    };

    if (user == null or user.?.password == null) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Login ID or password is incorrect");
        }
        try context.response.redirect("/admin");
        return;
    }

    // Verify password
    if (!users.verifyPassword(password.?, user.?.password.?)) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Login ID or password is incorrect");
        }
        try context.response.redirect("/admin");
        return;
    }

    // Set session
    if (SessionMiddleware.getSession(context.request)) |session| {
        try session.set("user_id", user.?.id);
        try session.set("user_email", user.?.email);
        try session.set("logged_in", "true");
    } else {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Failed to create session");
        }
        try context.response.redirect("/admin");
        return;
    }

    // Redirect to dashboard
    try context.response.redirect("/admin/dashboard");
}
