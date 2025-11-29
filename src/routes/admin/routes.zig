const std = @import("std");
const horizon = @import("horizon");

const loginPageHandler = @import("index.zig").loginPageHandler;
const loginHandler = @import("index.zig").loginHandler;
const logoutHandler = @import("logout.zig").logoutHandler;
const logoutCompletePageHandler = @import("logout.zig").logoutCompletePageHandler;
const dashboard_mod = @import("dashboard.zig");
const dashboardHandler = dashboard_mod.dashboardHandler;
const updateUserHandler = dashboard_mod.updateUserHandler;
const deleteUserHandler = dashboard_mod.deleteUserHandler;
const createUserHandler = dashboard_mod.createUserHandler;
const requestPasswordResetPageHandler = @import("passwordReset.zig").requestPasswordResetPageHandler;
const requestPasswordResetHandler = @import("passwordReset.zig").requestPasswordResetHandler;
const resetPasswordPageHandler = @import("passwordReset.zig").resetPasswordPageHandler;
const resetPasswordHandler = @import("passwordReset.zig").resetPasswordHandler;

pub const routes = .{
    .{ "GET", "", loginPageHandler },
    .{ "POST", "", loginHandler },
    .{ "GET", "/dashboard", dashboardHandler },
    .{ "POST", "/dashboard/users/create", createUserHandler },
    .{ "POST", "/dashboard/users/update", updateUserHandler },
    .{ "POST", "/dashboard/users/delete", deleteUserHandler },
    .{ "POST", "/logout", logoutHandler },
    .{ "GET", "/logout-complete", logoutCompletePageHandler },
    .{ "GET", "/change-password", requestPasswordResetPageHandler },
    .{ "POST", "/change-password/submit", requestPasswordResetHandler },
    .{ "GET", "/reset-password", resetPasswordPageHandler },
    .{ "POST", "/reset-password", resetPasswordHandler },
};
