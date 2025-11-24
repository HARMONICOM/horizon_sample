const std = @import("std");
const net = std.net;
const horizon = @import("horizon");
const horizon_test = @import("horizon_test");

const Server = horizon.Server;
const Router = horizon.Router;
const SessionStore = horizon.SessionStore;
const SessionMiddleware = horizon.SessionMiddleware;
const RedisBackend = horizon.RedisBackend;

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
        .show_stack_trace = true,
    });
    try srv.router.middlewares.use(&error_middleware);

    // Session middleware (must be before routes that use sessions)
    // Use Redis backend for session storage
    const redis_host = std.posix.getenv("CACHE_HOST") orelse "cache";
    const redis_port_str = std.posix.getenv("CACHE_PORT") orelse "6379";
    const redis_port = try std.fmt.parseInt(u16, redis_port_str, 10);

    const session_ttl_str = std.posix.getenv("CACHE_TTL_SECONDS") orelse "3600";
    const session_ttl: i64 = std.fmt.parseInt(i64, session_ttl_str, 10) catch 3600;

    const redis_db_str = std.posix.getenv("CACHE_DB_NUMBER") orelse "0";
    const redis_db: u8 = std.fmt.parseInt(u8, redis_db_str, 10) catch 0;

    const redis_username = std.posix.getenv("CACHE_USERNAME");
    const redis_password = std.posix.getenv("CACHE_PASSWORD");

    var redis_backend = RedisBackend.initWithConfig(allocator, .{
        .host = redis_host,
        .port = redis_port,
        .db_number = redis_db,
        .username = redis_username,
        .password = redis_password,
        .prefix = "session:",
        .default_ttl = session_ttl,
    }) catch |err| {
        return err;
    };
    defer redis_backend.deinit();

    var session_store = SessionStore.initWithBackend(allocator, redis_backend.backend());
    defer session_store.deinit();
    const session_middleware = SessionMiddleware.init(&session_store);
    try srv.router.middlewares.use(&session_middleware);

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
