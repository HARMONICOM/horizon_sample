const std = @import("std");
const horizon = @import("horizon");

const loginPageHandler = @import("index.zig").loginPageHandler;
const loginHandler = @import("index.zig").loginHandler;
const logoutHandler = @import("logout.zig").logoutHandler;
const logoutCompletePageHandler = @import("logout.zig").logoutCompletePageHandler;
const dashboardHandler = @import("dashboard.zig").dashboardHandler;
const requestPasswordResetPageHandler = @import("passwordReset.zig").requestPasswordResetPageHandler;
const requestPasswordResetHandler = @import("passwordReset.zig").requestPasswordResetHandler;
const resetPasswordPageHandler = @import("passwordReset.zig").resetPasswordPageHandler;
const resetPasswordHandler = @import("passwordReset.zig").resetPasswordHandler;

pub const routes = .{
    .{ "GET", "", loginPageHandler },
    .{ "POST", "", loginHandler },
    .{ "GET", "/dashboard", dashboardHandler },
    .{ "POST", "/logout", logoutHandler },
    .{ "GET", "/logout-complete", logoutCompletePageHandler },
    .{ "GET", "/change-password", requestPasswordResetPageHandler },
    .{ "POST", "/change-password/submit", requestPasswordResetHandler },
    .{ "GET", "/reset-password", resetPasswordPageHandler },
    .{ "POST", "/reset-password", resetPasswordHandler },
};
