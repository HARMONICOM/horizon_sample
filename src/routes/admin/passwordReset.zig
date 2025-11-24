const std = @import("std");
const horizon = @import("horizon");
const users = @import("../../models/users.zig");
const passwordResetTokens = @import("../../models/passwordResetTokens.zig");
const email = @import("../../utils/email.zig");

const Context = horizon.Context;
const Errors = horizon.Errors;
const SessionMiddleware = horizon.SessionMiddleware;
const urlEncode = horizon.urlEncode;
const urlDecode = horizon.urlDecode;

const request_password_reset_template = @embedFile("../../views/admin/requestPasswordReset.zts");
const reset_password_template = @embedFile("../../views/admin/resetPassword.zts");

/// Send email in background thread
fn sendEmailInBackground(
    allocator: std.mem.Allocator,
    email_to_send: []const u8,
    reset_url_to_send: []const u8,
) void {
    defer {
        allocator.free(email_to_send);
        allocator.free(reset_url_to_send);
    }

    // Recreate EmailConfig in thread from environment variables
    // All strings are copied to ensure thread safety
    const email_config = email.loadEmailConfig(allocator) catch {
        return;
    };
    defer email.freeEmailConfig(email_config);

    email.sendPasswordResetEmail(email_config, email_to_send, reset_url_to_send) catch {
        return;
    };
}

/// GET /admin/change-password - Show password reset request page
pub fn requestPasswordResetPageHandler(context: *Context) Errors.Horizon!void {
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

    try context.response.renderHeader(request_password_reset_template, .{
        .title = "Password Reset",
        .props = props_json,
    });
}

/// POST /admin/change-password - Handle password reset request
pub fn requestPasswordResetHandler(context: *Context) Errors.Horizon!void {
    const body = context.request.body;

    // Parse form data
    var email_address: ?[]const u8 = null;

    var iter = std.mem.splitSequence(u8, body, "&");
    while (iter.next()) |pair| {
        if (std.mem.indexOf(u8, pair, "=")) |eq_pos| {
            const key = std.mem.trim(u8, pair[0..eq_pos], " ");
            const value_raw = pair[eq_pos + 1 ..];
            const value = try std.mem.replaceOwned(u8, context.allocator, value_raw, "+", " ");
            defer context.allocator.free(value);
            const decoded_value = try urlDecode(context.allocator, value);
            defer context.allocator.free(decoded_value);

            if (std.mem.eql(u8, key, "email")) {
                email_address = try context.allocator.dupe(u8, decoded_value);
            }
        }
    }

    if (email_address == null) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Please enter your email address");
        }
        try context.response.redirect("/admin/change-password");
        return;
    }
    defer if (email_address) |e| context.allocator.free(e);

    // Get user by email
    const user = try users.getUserByEmail(context.allocator, email_address.?);
    defer if (user) |u| {
        context.allocator.free(u.id);
        context.allocator.free(u.name);
        context.allocator.free(u.email);
        if (u.password) |pwd| context.allocator.free(pwd);
    };

    // Always show success message (security: don't reveal if email exists)
    const success_msg = "If the email address is registered, we have sent a password reset email";

    if (user == null) {
        // User not found, but don't reveal this
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_success", success_msg);
        }
        try context.response.redirect("/admin/change-password");
        return;
    }

    // Create password reset token
    const token = try passwordResetTokens.createToken(context.allocator, user.?.id);
    defer context.allocator.free(token);

    // Get base URL from environment or use default
    const base_url = std.posix.getenv("BASE_URL") orelse "http://localhost:5000";
    const reset_url = try std.fmt.allocPrint(
        context.allocator,
        "{s}/admin/reset-password?token={s}",
        .{ base_url, token },
    );
    defer context.allocator.free(reset_url);

    // Send email in background thread to avoid blocking
    const email_to_send = try context.allocator.dupe(u8, user.?.email);
    const reset_url_to_send = try context.allocator.dupe(u8, reset_url);
    const allocator_for_thread = context.allocator;

    // Create a thread to send email asynchronously
    // EmailConfig will be recreated in the thread from environment variables
    const thread = std.Thread.spawn(.{}, sendEmailInBackground, .{
        allocator_for_thread,
        email_to_send,
        reset_url_to_send,
    }) catch |err| {
        // Convert thread spawn errors to Horizon errors
        return switch (err) {
            error.OutOfMemory => error.OutOfMemory,
            else => error.ServerError,
        };
    };
    thread.detach();

    // Set flash message in session
    if (SessionMiddleware.getSession(context.request)) |session| {
        try session.set("flash_success", success_msg);
    }
    try context.response.redirect("/admin/change-password");
}

/// GET /admin/reset-password - Show password reset form
pub fn resetPasswordPageHandler(context: *Context) Errors.Horizon!void {
    const token = context.request.getQuery("token") orelse {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Invalid token");
        }
        try context.response.redirect("/admin/change-password");
        return;
    };

    // Verify token
    const token_data = try passwordResetTokens.getTokenByToken(context.allocator, token);
    defer if (token_data) |t| {
        context.allocator.free(t.id);
        context.allocator.free(t.user_id);
        context.allocator.free(t.token);
    };

    if (token_data == null) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Invalid token");
        }
        try context.response.redirect("/admin/change-password");
        return;
    }

    if (token_data.?.used) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "This token has already been used");
        }
        try context.response.redirect("/admin/change-password");
        return;
    }

    const now = std.time.timestamp();
    if (token_data.?.expires_at < now) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Token has expired");
        }
        try context.response.redirect("/admin/change-password");
        return;
    }

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
        token: []const u8,
    };
    const props = Props{
        .@"error" = error_message,
        .success = success_message,
        .token = token,
    };

    // Convert to JSON using std.json.Stringify.valueAlloc
    const props_json = try std.json.Stringify.valueAlloc(context.allocator, props, .{});
    defer context.allocator.free(props_json);

    try context.response.renderHeader(reset_password_template, .{
        .title = "Password Reset",
        .props = props_json,
    });
}

/// POST /admin/reset-password - Handle password reset
pub fn resetPasswordHandler(context: *Context) Errors.Horizon!void {
    const body = context.request.body;

    // Parse form data
    var token: ?[]const u8 = null;
    var new_password: ?[]const u8 = null;
    var confirm_password: ?[]const u8 = null;

    var iter = std.mem.splitSequence(u8, body, "&");
    while (iter.next()) |pair| {
        if (std.mem.indexOf(u8, pair, "=")) |eq_pos| {
            const key = std.mem.trim(u8, pair[0..eq_pos], " ");
            const value_raw = pair[eq_pos + 1 ..];
            const value = try std.mem.replaceOwned(u8, context.allocator, value_raw, "+", " ");
            defer context.allocator.free(value);
            const decoded_value = try urlDecode(context.allocator, value);
            defer context.allocator.free(decoded_value);

            if (std.mem.eql(u8, key, "token")) {
                token = try context.allocator.dupe(u8, decoded_value);
            } else if (std.mem.eql(u8, key, "new_password")) {
                new_password = try context.allocator.dupe(u8, decoded_value);
            } else if (std.mem.eql(u8, key, "confirm_password")) {
                confirm_password = try context.allocator.dupe(u8, decoded_value);
            }
        }
    }

    defer {
        if (token) |t| context.allocator.free(t);
        if (new_password) |p| context.allocator.free(p);
        if (confirm_password) |p| context.allocator.free(p);
    }

    // Validate inputs
    if (token == null or new_password == null or confirm_password == null) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Please fill in all fields");
        }
        const url = try std.fmt.allocPrint(context.allocator, "/admin/reset-password?token={s}", .{token orelse ""});
        defer context.allocator.free(url);
        try context.response.redirect(url);
        return;
    }

    if (new_password.?.len < 6) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "New password must be at least 6 characters");
        }
        const url = try std.fmt.allocPrint(context.allocator, "/admin/reset-password?token={s}", .{token.?});
        defer context.allocator.free(url);
        try context.response.redirect(url);
        return;
    }

    if (!std.mem.eql(u8, new_password.?, confirm_password.?)) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "New passwords do not match");
        }
        const url = try std.fmt.allocPrint(context.allocator, "/admin/reset-password?token={s}", .{token.?});
        defer context.allocator.free(url);
        try context.response.redirect(url);
        return;
    }

    // Verify token
    const token_data = try passwordResetTokens.getTokenByToken(context.allocator, token.?);
    defer if (token_data) |t| {
        context.allocator.free(t.id);
        context.allocator.free(t.user_id);
        context.allocator.free(t.token);
    };

    if (token_data == null) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Invalid token");
        }
        try context.response.redirect("/admin/change-password");
        return;
    }

    if (token_data.?.used) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "This token has already been used");
        }
        try context.response.redirect("/admin/change-password");
        return;
    }

    const now = std.time.timestamp();
    if (token_data.?.expires_at < now) {
        // Set flash message in session
        if (SessionMiddleware.getSession(context.request)) |session| {
            try session.set("flash_error", "Token has expired");
        }
        try context.response.redirect("/admin/change-password");
        return;
    }

    // Update password
    try users.updatePassword(context.allocator, token_data.?.user_id, new_password.?);

    // Mark token as used
    try passwordResetTokens.markTokenAsUsed(context.allocator, token_data.?.id);

    // Set flash message in session
    if (SessionMiddleware.getSession(context.request)) |session| {
        try session.set("flash_success", "Password has been changed");
    }
    try context.response.redirect("/admin");
}
