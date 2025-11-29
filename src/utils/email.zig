const std = @import("std");
const smtp = @import("smtp_client");
const horizon = @import("horizon");

const Errors = horizon.Errors;

const password_reset_text_template = @embedFile("../views/mail/passwordResetText.zts");
const password_reset_html_template = @embedFile("../views/mail/passwordResetHtml.zts");

pub const EmailConfig = struct {
    host: []const u8,
    port: u16,
    encryption: smtp.Encryption,
    username: ?[]const u8 = null,
    password: ?[]const u8 = null,
    from_address: []const u8,
    from_name: ?[]const u8 = null,
    allocator: std.mem.Allocator,
};

/// Load email configuration from environment variables
/// All strings are copied to ensure thread safety
pub fn loadEmailConfig(allocator: std.mem.Allocator) !EmailConfig {
    const host_env = std.posix.getenv("MAIL_HOST") orelse "localhost";
    const host = try allocator.dupe(u8, host_env);

    const port_str = std.posix.getenv("MAIL_PORT") orelse "25";
    const port = std.fmt.parseInt(u16, port_str, 10) catch 25;

    const encryption_str = std.posix.getenv("MAIL_ENCRYPTION") orelse "none";
    const encryption: smtp.Encryption = if (std.mem.eql(u8, encryption_str, "tls"))
        .tls
    else if (std.mem.eql(u8, encryption_str, "start_tls"))
        .start_tls
    else if (std.mem.eql(u8, encryption_str, "insecure"))
        .insecure
    else
        .none;

    const username_env = std.posix.getenv("MAIL_USERNAME");
    const username = if (username_env) |u|
        if (u.len > 0) try allocator.dupe(u8, u) else null
    else
        null;

    const password_env = std.posix.getenv("MAIL_PASSWORD");
    const password = if (password_env) |p|
        if (p.len > 0) try allocator.dupe(u8, p) else null
    else
        null;

    const from_address_env = std.posix.getenv("MAIL_FROM_ADDRESS") orelse "noreply@localhost";
    const from_address = try allocator.dupe(u8, from_address_env);

    const from_name_env = std.posix.getenv("MAIL_FROM_NAME");
    const from_name = if (from_name_env) |n| try allocator.dupe(u8, n) else null;

    return EmailConfig{
        .host = host,
        .port = port,
        .encryption = encryption,
        .username = username,
        .password = password,
        .from_address = from_address,
        .from_name = from_name,
        .allocator = allocator,
    };
}

/// Free email configuration resources
pub fn freeEmailConfig(config: EmailConfig) void {
    config.allocator.free(config.host);
    if (config.username) |u| config.allocator.free(u);
    if (config.password) |p| config.allocator.free(p);
    config.allocator.free(config.from_address);
    if (config.from_name) |n| config.allocator.free(n);
}

/// Send password reset email
pub fn sendPasswordResetEmail(config: EmailConfig, to_email: []const u8, reset_url: []const u8) Errors.Horizon!void {
    const smtp_config = smtp.Config{
        .host = config.host,
        .port = config.port,
        .encryption = config.encryption,
        .username = config.username,
        .password = config.password,
        .allocator = config.allocator,
    };

    const from_name_str = if (config.from_name) |name| name else "System Administrator";
    const subject = "Password Reset Request";

    // Load templates and replace placeholders
    const text_body = try std.fmt.allocPrint(
        config.allocator,
        password_reset_text_template,
        .{reset_url},
    );
    defer config.allocator.free(text_body);

    const html_body = try std.fmt.allocPrint(
        config.allocator,
        password_reset_html_template,
        .{ reset_url, reset_url },
    );
    defer config.allocator.free(html_body);

    smtp.send(.{
        .from = .{ .name = from_name_str, .address = config.from_address },
        .to = &.{.{ .address = to_email }},
        .subject = subject,
        .text_body = text_body,
        .html_body = html_body,
    }, smtp_config) catch |err| {
        return switch (err) {
            error.OutOfMemory => error.OutOfMemory,
            else => error.ServerError,
        };
    };
}
