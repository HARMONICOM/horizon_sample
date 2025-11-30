//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

// Re-export dependencies for sub-modules
pub const horizon = @import("horizon");
pub const dig = @import("dig");

// Export models for testing
pub const models = struct {
    pub const users = @import("models/users.zig");
    pub const passwordResetTokens = @import("models/passwordResetTokens.zig");
};

// Export utils for testing
pub const utils = struct {
    pub const db = @import("utils/db.zig");
    pub const email = @import("utils/email.zig");
};

// Export routes for testing
pub const routes = struct {
    pub const index = @import("routes/index.zig");
    pub const api = struct {
        pub const index = @import("routes/api/index.zig");
    };
    pub const admin = struct {
        pub const routes = @import("routes/admin/routes.zig");
        pub const index = @import("routes/admin/index.zig");
        pub const dashboard = @import("routes/admin/dashboard.zig");
        pub const logout = @import("routes/admin/logout.zig");
        pub const passwordReset = @import("routes/admin/passwordReset.zig");
    };
};

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try stdout.flush(); // Don't forget to flush!
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
