const std = @import("std");
const net = std.net;
const horizon = @import("horizon");
const horizon_test = @import("horizon_test");

const Server = horizon.Server;
const Router = horizon.Router;

const routes = @import("routes/routes.zig").routes;

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

    const basic_auth_middleware = horizon.BasicAuth.init(
        "/admin",
        std.posix.getenv("ADMIN_BASIC_AUTH_USERNAME") orelse "admin",
        std.posix.getenv("ADMIN_BASIC_AUTH_PASSWORD") orelse "password123",
    );
    try srv.router.middlewares.use(&basic_auth_middleware);

    const static_middleware = horizon.StaticMiddleware.initWithConfig(.{
        .root_dir = "public",
        .url_prefix = "/",
        .enable_cache = true,
        .cache_max_age = 3600,
        .index_file = "index.html",
    });
    try srv.router.middlewares.use(&static_middleware);

    const cors_middleware = horizon.CorsMiddleware.initWithConfig(.{
        .allow_origin = "*",
        .allow_methods = "GET, POST, PUT, DELETE, OPTIONS",
        .allow_headers = "Content-Type, Authorization",
        .allow_credentials = true,
        .max_age = 3600,
    });
    try srv.router.middlewares.use(&cors_middleware);

    const error_middleware = horizon.ErrorMiddleware.initWithConfig(.{
        .format = .json,
        .custom_404_message = "Page not found",
        .custom_500_message = "Server error occurred",
    });
    try srv.router.middlewares.use(&error_middleware);

    try srv.router.mount("/", routes);

    try srv.listen();
}
