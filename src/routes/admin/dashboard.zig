const std = @import("std");
const horizon = @import("horizon");

const Context = horizon.Context;
const Errors = horizon.Errors;
const SessionMiddleware = horizon.SessionMiddleware;
const StatusCode = horizon.StatusCode;
const urlDecode = horizon.urlDecode;

const users = @import("../../models/users.zig");

const index_template = @embedFile("../../views/admin/dashboard.zts");

pub fn dashboardHandler(context: *Context) Errors.Horizon!void {
    try ensureLoggedIn(context);

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

/// Ensure user is logged in, redirect to login page if not
fn ensureLoggedIn(context: *Context) Errors.Horizon!void {
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
}

/// Ensure user is logged in for API requests, return JSON error if not
fn ensureLoggedInApi(context: *Context) Errors.Horizon!bool {
    const session_opt = SessionMiddleware.getSession(context.request);
    if (session_opt) |session| {
        const logged_in_value = session.get("logged_in") orelse "";
        const is_logged_in = std.mem.eql(u8, logged_in_value, "true");
        if (!is_logged_in) {
            context.response.setStatus(StatusCode.unauthorized);
            try context.response.json("{\"message\":\"Unauthorized. Please login.\"}");
            return false;
        }
        return true;
    } else {
        context.response.setStatus(StatusCode.unauthorized);
        try context.response.json("{\"message\":\"Unauthorized. Please login.\"}");
        return false;
    }
}

/// POST /admin/dashboard/users/update - Update user basic information
pub fn updateUserHandler(context: *Context) Errors.Horizon!void {
    // Ensure the user is logged in as admin
    if (!try ensureLoggedInApi(context)) return;

    const body = context.request.body;

    var user_id: ?[]const u8 = null;
    var name: ?[]const u8 = null;
    var email: ?[]const u8 = null;

    // Parse application/x-www-form-urlencoded body
    var iter = std.mem.splitSequence(u8, body, "&");
    while (iter.next()) |pair| {
        if (std.mem.indexOf(u8, pair, "=")) |eq_pos| {
            const key = std.mem.trim(u8, pair[0..eq_pos], " ");
            const value_raw = pair[eq_pos + 1 ..];
            const value_with_plus = try std.mem.replaceOwned(u8, context.allocator, value_raw, "+", " ");
            defer context.allocator.free(value_with_plus);
            const decoded_value = try urlDecode(context.allocator, value_with_plus);
            defer context.allocator.free(decoded_value);

            if (std.mem.eql(u8, key, "id")) {
                user_id = try context.allocator.dupe(u8, decoded_value);
            } else if (std.mem.eql(u8, key, "name")) {
                name = try context.allocator.dupe(u8, decoded_value);
            } else if (std.mem.eql(u8, key, "email")) {
                email = try context.allocator.dupe(u8, decoded_value);
            }
        }
    }

    if (user_id == null or name == null or email == null) {
        context.response.setStatus(StatusCode.bad_request);
        try context.response.text("Missing required parameters");
        return;
    }
    defer {
        if (user_id) |id| context.allocator.free(id);
        if (name) |n| context.allocator.free(n);
        if (email) |e| context.allocator.free(e);
    }

    users.updateUserProfile(context.allocator, user_id.?, name.?, email.?) catch |err| {
        if (err == horizon.Errors.Horizon.ServerError) {
            context.response.setStatus(StatusCode.bad_request);
            try context.response.json("{\"message\":\"Email already exists\"}");
            return;
        }
        return err;
    };

    try context.response.json("{\"message\":\"User updated successfully\"}");
}

/// POST /admin/dashboard/users/delete - Delete user
pub fn deleteUserHandler(context: *Context) Errors.Horizon!void {
    // Ensure the user is logged in as admin
    if (!try ensureLoggedInApi(context)) return;

    const body = context.request.body;

    var user_id: ?[]const u8 = null;

    // Parse application/x-www-form-urlencoded body
    var iter = std.mem.splitSequence(u8, body, "&");
    while (iter.next()) |pair| {
        if (std.mem.indexOf(u8, pair, "=")) |eq_pos| {
            const key = std.mem.trim(u8, pair[0..eq_pos], " ");
            const value_raw = pair[eq_pos + 1 ..];
            const value_with_plus = try std.mem.replaceOwned(u8, context.allocator, value_raw, "+", " ");
            defer context.allocator.free(value_with_plus);
            const decoded_value = try urlDecode(context.allocator, value_with_plus);
            defer context.allocator.free(decoded_value);

            if (std.mem.eql(u8, key, "id")) {
                user_id = try context.allocator.dupe(u8, decoded_value);
            }
        }
    }

    if (user_id == null) {
        context.response.setStatus(StatusCode.bad_request);
        try context.response.text("Missing required parameters");
        return;
    }
    defer if (user_id) |id| context.allocator.free(id);

    try users.deleteUser(context.allocator, user_id.?);

    try context.response.json("{\"message\":\"User deleted successfully\"}");
}

/// POST /admin/dashboard/users/create - Create new user
pub fn createUserHandler(context: *Context) Errors.Horizon!void {
    // Ensure the user is logged in as admin
    if (!try ensureLoggedInApi(context)) return;

    const body = context.request.body;

    var login_id: ?[]const u8 = null;
    var password: ?[]const u8 = null;
    var name: ?[]const u8 = null;
    var email: ?[]const u8 = null;

    // Parse application/x-www-form-urlencoded body
    var iter = std.mem.splitSequence(u8, body, "&");
    while (iter.next()) |pair| {
        if (std.mem.indexOf(u8, pair, "=")) |eq_pos| {
            const key = std.mem.trim(u8, pair[0..eq_pos], " ");
            const value_raw = pair[eq_pos + 1 ..];
            const value_with_plus = try std.mem.replaceOwned(u8, context.allocator, value_raw, "+", " ");
            defer context.allocator.free(value_with_plus);
            const decoded_value = try urlDecode(context.allocator, value_with_plus);
            defer context.allocator.free(decoded_value);

            if (std.mem.eql(u8, key, "login_id")) {
                login_id = try context.allocator.dupe(u8, decoded_value);
            } else if (std.mem.eql(u8, key, "password")) {
                password = try context.allocator.dupe(u8, decoded_value);
            } else if (std.mem.eql(u8, key, "name")) {
                name = try context.allocator.dupe(u8, decoded_value);
            } else if (std.mem.eql(u8, key, "email")) {
                email = try context.allocator.dupe(u8, decoded_value);
            }
        }
    }

    if (login_id == null or password == null or name == null or email == null) {
        context.response.setStatus(StatusCode.bad_request);
        try context.response.text("Missing required parameters");
        return;
    }
    defer {
        if (login_id) |l| context.allocator.free(l);
        if (password) |p| context.allocator.free(p);
        if (name) |n| context.allocator.free(n);
        if (email) |e| context.allocator.free(e);
    }

    users.createUser(context.allocator, login_id.?, password.?, name.?, email.?) catch |err| {
        if (err == horizon.Errors.Horizon.ServerError) {
            context.response.setStatus(StatusCode.bad_request);
            try context.response.json("{\"message\":\"Login ID or email already exists\"}");
            return;
        }
        return err;
    };

    try context.response.json("{\"message\":\"User created successfully\"}");
}
