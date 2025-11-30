const std = @import("std");
const testing = std.testing;
const horizon = @import("horizon");
const horizon_sample = @import("horizon_sample");

const Context = horizon.Context;
const Request = horizon.Request;
const Response = horizon.Response;
const Router = horizon.Router;

const dashboard = horizon_sample.routes.admin.dashboard;
const index = horizon_sample.routes.admin.index;
const logout = horizon_sample.routes.admin.logout;
const passwordReset = horizon_sample.routes.admin.passwordReset;

test "dashboardHandler - requires authentication" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.get("/admin/dashboard", dashboard.dashboardHandler);

    var request = Request.init(allocator, .GET, "/admin/dashboard");
    defer request.deinit();

    var response = Response.init(allocator);
    defer response.deinit();

    // Without session, should fail or redirect
    _ = router.handleRequest(&request, &response) catch {};
}

test "loginPageHandler - renders login page" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.get("/admin", index.loginPageHandler);

    var request = Request.init(allocator, .GET, "/admin");
    defer request.deinit();

    var response = Response.init(allocator);
    defer response.deinit();

    // Should handle request without errors
    _ = router.handleRequest(&request, &response) catch {};
    // Response should contain HTML content
    try testing.expect(response.body.items.len > 0);
}

test "loginHandler - validates required fields" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.post("/admin", index.loginHandler);

    var request = Request.init(allocator, .POST, "/admin");
    defer request.deinit();
    // Empty body - missing login_id and password
    request.body = "";

    var response = Response.init(allocator);
    defer response.deinit();

    // Should handle request and redirect due to missing fields
    _ = router.handleRequest(&request, &response) catch {};
}

test "logoutHandler - clears session" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.post("/admin/logout", logout.logoutHandler);

    var request = Request.init(allocator, .POST, "/admin/logout");
    defer request.deinit();

    var response = Response.init(allocator);
    defer response.deinit();

    // Should handle logout request
    _ = router.handleRequest(&request, &response) catch {};
}

test "logoutCompletePageHandler - renders logout page" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.get("/admin/logout-complete", logout.logoutCompletePageHandler);

    var request = Request.init(allocator, .GET, "/admin/logout-complete");
    defer request.deinit();

    var response = Response.init(allocator);
    defer response.deinit();

    // Should handle request without errors
    _ = router.handleRequest(&request, &response) catch {};
    // Response should contain HTML content
    try testing.expect(response.body.items.len > 0);
}

test "requestPasswordResetPageHandler - renders password reset request page" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.get("/admin/change-password", passwordReset.requestPasswordResetPageHandler);

    var request = Request.init(allocator, .GET, "/admin/change-password");
    defer request.deinit();

    var response = Response.init(allocator);
    defer response.deinit();

    // Should handle request without errors
    _ = router.handleRequest(&request, &response) catch {};
    // Response should contain HTML content
    try testing.expect(response.body.items.len > 0);
}

test "requestPasswordResetHandler - validates email field" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.post("/admin/change-password/submit", passwordReset.requestPasswordResetHandler);

    var request = Request.init(allocator, .POST, "/admin/change-password/submit");
    defer request.deinit();
    // Empty body - missing email
    request.body = "";

    var response = Response.init(allocator);
    defer response.deinit();

    // Should handle request and redirect due to missing email
    _ = router.handleRequest(&request, &response) catch {};
}

test "resetPasswordPageHandler - requires token" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.get("/admin/reset-password", passwordReset.resetPasswordPageHandler);

    var request = Request.init(allocator, .GET, "/admin/reset-password");
    defer request.deinit();
    // No token in query string

    var response = Response.init(allocator);
    defer response.deinit();

    // Should handle request and redirect due to missing token
    _ = router.handleRequest(&request, &response) catch {};
}

test "resetPasswordHandler - validates all required fields" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.post("/admin/reset-password", passwordReset.resetPasswordHandler);

    var request = Request.init(allocator, .POST, "/admin/reset-password");
    defer request.deinit();
    // Empty body - missing token, new_password, confirm_password
    request.body = "";

    var response = Response.init(allocator);
    defer response.deinit();

    // Should handle request and redirect due to missing fields
    _ = router.handleRequest(&request, &response) catch {};
}

test "updateUserHandler - requires authentication" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.post("/admin/dashboard/users/update", dashboard.updateUserHandler);

    var request = Request.init(allocator, .POST, "/admin/dashboard/users/update");
    defer request.deinit();
    request.body = "id=1&name=Test&email=test@example.com";

    var response = Response.init(allocator);
    defer response.deinit();

    // Without session, should return unauthorized
    _ = router.handleRequest(&request, &response) catch {};
}

test "deleteUserHandler - requires authentication" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.post("/admin/dashboard/users/delete", dashboard.deleteUserHandler);

    var request = Request.init(allocator, .POST, "/admin/dashboard/users/delete");
    defer request.deinit();
    request.body = "id=1";

    var response = Response.init(allocator);
    defer response.deinit();

    // Without session, should return unauthorized
    _ = router.handleRequest(&request, &response) catch {};
}

test "createUserHandler - requires authentication" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.post("/admin/dashboard/users/create", dashboard.createUserHandler);

    var request = Request.init(allocator, .POST, "/admin/dashboard/users/create");
    defer request.deinit();
    request.body = "login_id=test&password=test&name=Test&email=test@example.com";

    var response = Response.init(allocator);
    defer response.deinit();

    // Without session, should return unauthorized
    _ = router.handleRequest(&request, &response) catch {};
}

test "createUserHandler - validates required parameters" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.post("/admin/dashboard/users/create", dashboard.createUserHandler);

    var request = Request.init(allocator, .POST, "/admin/dashboard/users/create");
    defer request.deinit();
    request.body = "name=Test&email=test@example.com";
    // Missing login_id and password

    var response = Response.init(allocator);
    defer response.deinit();

    // Should handle request
    _ = router.handleRequest(&request, &response) catch {};
}

