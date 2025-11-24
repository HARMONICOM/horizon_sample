const std = @import("std");
const testing = std.testing;
const horizon = @import("horizon");
const horizon_sample = @import("horizon_sample");
const Router = horizon.Router;
const Request = horizon.Request;
const Response = horizon.Response;
const Errors = horizon.Errors;

const indexHandler = horizon_sample.routes.index.indexHandler;
const apiIndexHandler = horizon_sample.routes.api.index.indexHandler;

test "indexHandler - returns HTML response" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.get("", indexHandler);

    var request = Request.init(allocator, .GET, "");
    defer request.deinit();

    var response = Response.init(allocator);
    defer response.deinit();

    try router.handleRequest(&request, &response);

    try testing.expect(response.status == .ok);
    const content_type = response.headers.get("Content-Type");
    try testing.expect(content_type != null);
    // Template rendering sets Content-Type to text/html
    try testing.expect(std.mem.indexOf(u8, content_type.?, "text/html") != null);
}

test "apiIndexHandler - returns JSON response" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.get("/api", apiIndexHandler);

    var request = Request.init(allocator, .GET, "/api");
    defer request.deinit();

    var response = Response.init(allocator);
    defer response.deinit();

    try router.handleRequest(&request, &response);

    try testing.expect(response.status == .ok);
    const content_type = response.headers.get("Content-Type");
    try testing.expect(content_type != null);
    try testing.expect(std.mem.indexOf(u8, content_type.?, "application/json") != null);

    // Verify JSON contains expected message
    try testing.expect(std.mem.indexOf(u8, response.body.items, "Hello, World!") != null);
    try testing.expect(std.mem.indexOf(u8, response.body.items, "message") != null);
}

test "apiIndexHandler - JSON structure is valid" {
    const allocator = testing.allocator;
    var router = Router.init(allocator);
    defer router.deinit();

    try router.get("/api", apiIndexHandler);

    var request = Request.init(allocator, .GET, "/api");
    defer request.deinit();

    var response = Response.init(allocator);
    defer response.deinit();

    try router.handleRequest(&request, &response);

    try testing.expect(response.status == .ok);

    // Parse JSON to verify structure (using Zig 0.15.2 API)
    const JsonValue = struct {
        message: []const u8,
    };

    const parsed = try std.json.parseFromSlice(JsonValue, allocator, response.body.items, .{});
    defer parsed.deinit();

    try testing.expect(parsed.value.message.len > 0);
    try testing.expectEqualStrings("Hello, World!", parsed.value.message);
}

