const std = @import("std");
const net = std.net;
const horizon = @import("horizon");
const horizon_test = @import("horizon_test");

const Server = horizon.Server;
const Router = horizon.Router;

const routes = @import("routes/routes.zig").routes;
const routes_admin = @import("routes/admin/routes.zig").routes;
const routes_api = @import("routes/api/routes.zig").routes;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const port_str = std.posix.getenv("PORT") orelse "5000";
    const port = try std.fmt.parseInt(u16, port_str, 10);
    const address = try net.Address.resolveIp("0.0.0.0", port);
    var srv = Server.init(allocator, address);
    srv.show_routes_on_startup = true;
    defer srv.deinit();

    const logging_middleware = horizon.LoggingMiddleware.init();
    try srv.router.middlewares.use(&logging_middleware);

    // global middleware
    const static_middleware = horizon.StaticMiddleware.initWithConfig(.{
        .root_dir = "public",
        .url_prefix = "/",
        .enable_cache = true,
        .cache_max_age = 3600,
        .index_file = "index.html",
    });
    try srv.router.middlewares.use(&static_middleware);

    const error_middleware = horizon.ErrorMiddleware.initWithConfig(.{
        .format = .json,
        .custom_404_message = "Page not found",
        .custom_500_message = "Server error occurred",
    });
    try srv.router.middlewares.use(&error_middleware);

    // root routes
    try srv.router.mount("/", routes);

    // admin routes
    var admin_middleware_chain = horizon.Middleware.Chain.init(allocator);
    defer admin_middleware_chain.deinit();
    const basic_auth_middleware = horizon.BasicAuthMiddleware.init(
        std.posix.getenv("ADMIN_BASIC_AUTH_USERNAME") orelse "admin",
        std.posix.getenv("ADMIN_BASIC_AUTH_PASSWORD") orelse "password123",
    );
    try admin_middleware_chain.use(&basic_auth_middleware);

    try srv.router.mountWithMiddleware("/admin", routes_admin, &admin_middleware_chain);

    // api routes
    var api_middleware_chain = horizon.Middleware.Chain.init(allocator);
    defer api_middleware_chain.deinit();

    const allow_credentials_str = std.posix.getenv("API_CORS_ALLOW_CREDENTIALS");
    const allow_credentials = if (allow_credentials_str) |str|
        std.mem.eql(u8, str, "true") or std.mem.eql(u8, str, "1")
    else
        true;

    const max_age_str = std.posix.getenv("API_CORS_MAX_AGE");
    const max_age: ?u32 = if (max_age_str) |str|
        std.fmt.parseInt(u32, str, 10) catch null
    else
        @as(?u32, 3600);

    const cors_middleware = horizon.CorsMiddleware.initWithConfig(.{
        .allow_origin = std.posix.getenv("API_CORS_ALLOW_ORIGIN") orelse "http://localhost:5000",
        .allow_methods = std.posix.getenv("API_CORS_ALLOW_METHODS") orelse "GET, POST, PUT, DELETE, OPTIONS",
        .allow_headers = std.posix.getenv("API_CORS_ALLOW_HEADERS") orelse "Content-Type, Authorization",
        .allow_credentials = allow_credentials,
        .max_age = max_age,
    });
    try api_middleware_chain.use(&cors_middleware);

    try srv.router.mountWithMiddleware("/api", routes_api, &api_middleware_chain);

    // listen
    try srv.listen();
}
