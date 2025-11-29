const std = @import("std");
const horizon = @import("horizon");
const dig = @import("dig");

const Context = horizon.Context;
const Errors = horizon.Errors;

const db_mod = @import("../../libs/db.zig");

/// Get all users with chainable query builder
pub fn getUsersHandler(context: *Context) Errors.Horizon!void {
    // Get database connection
    var db = try db_mod.getConnection(context.allocator);

    // Use chainable query builder to get users
    var result = try db.table("test_users")
        .select(&.{ "id", "name", "email", "age" })
        .where("age", ">=", .{ .integer = 18 })
        .orderBy("name", .asc)
        .limit(10)
        .get();
    defer result.deinit();

    // Build JSON response
    var users_list = try std.ArrayList(u8).initCapacity(context.allocator, 1024);
    defer users_list.deinit(context.allocator);

    var writer = users_list.writer(context.allocator);
    try writer.writeAll("[");

    for (result.rows, 0..) |row, i| {
        if (i > 0) try writer.writeAll(",");
        try writer.writeAll("{");

        if (row.get("id")) |id| {
            try writer.print("\"id\":{d},", .{id.integer});
        }
        if (row.get("name")) |name| {
            try writer.print("\"name\":\"{s}\",", .{name.text});
        }
        if (row.get("email")) |email| {
            try writer.print("\"email\":\"{s}\",", .{email.text});
        }
        if (row.get("age")) |age| {
            try writer.print("\"age\":{d}", .{age.integer});
        }

        try writer.writeAll("}");
    }

    try writer.writeAll("]");

    // Send JSON response
    try context.response.setHeader("Content-Type", "application/json");
    try context.response.send(try users_list.toOwnedSlice(context.allocator));
}

/// Get a single user by ID
pub fn getUserHandler(context: *Context) Errors.Horizon!void {
    // Get user ID from URL parameter
    const id_str = context.params.get("id") orelse return error.MissingParameter;
    const user_id = try std.fmt.parseInt(i64, id_str, 10);

    // Get database connection
    var db = try db_mod.getConnection(context.allocator);

    // Use chainable query builder to get user
    var result = try db.table("test_users")
        .select(&.{ "id", "name", "email", "age" })
        .where("id", "=", .{ .integer = user_id })
        .get();
    defer result.deinit();

    if (result.rows.len == 0) {
        try context.response.setStatus(404);
        try context.response.send("User not found");
        return;
    }

    const row = result.rows[0];

    // Build JSON response
    var user_json = try std.ArrayList(u8).initCapacity(context.allocator, 512);
    defer user_json.deinit(context.allocator);

    var writer = user_json.writer(context.allocator);
    try writer.writeAll("{");

    if (row.get("id")) |id| {
        try writer.print("\"id\":{d},", .{id.integer});
    }
    if (row.get("name")) |name| {
        try writer.print("\"name\":\"{s}\",", .{name.text});
    }
    if (row.get("email")) |email| {
        try writer.print("\"email\":\"{s}\",", .{email.text});
    }
    if (row.get("age")) |age| {
        try writer.print("\"age\":{d}", .{age.integer});
    }

    try writer.writeAll("}");

    // Send JSON response
    try context.response.setHeader("Content-Type", "application/json");
    try context.response.send(try user_json.toOwnedSlice(context.allocator));
}

/// Create a new user
pub fn createUserHandler(context: *Context) Errors.Horizon!void {
    // Parse request body
    const body = context.request.body orelse return error.MissingBody;

    // For simplicity, we'll parse JSON manually
    // In production, you'd use a proper JSON parser
    var name: []const u8 = undefined;
    var email: []const u8 = undefined;
    var age: i64 = undefined;

    // TODO: Proper JSON parsing
    // For now, this is just a placeholder
    _ = body;
    name = "John Doe";
    email = "john@example.com";
    age = 30;

    // Get database connection
    var db = try db_mod.getConnection(context.allocator);

    // Use chainable query builder to insert user
    try db.table("test_users")
        .addValue("name", .{ .text = name })
        .addValue("email", .{ .text = email })
        .addValue("age", .{ .integer = age })
        .execute();

    // Send success response
    try context.response.setStatus(201);
    try context.response.setHeader("Content-Type", "application/json");
    try context.response.send("{\"message\":\"User created successfully\"}");
}

/// Update a user
pub fn updateUserHandler(context: *Context) Errors.Horizon!void {
    // Get user ID from URL parameter
    const id_str = context.params.get("id") orelse return error.MissingParameter;
    const user_id = try std.fmt.parseInt(i64, id_str, 10);

    // Parse request body
    const body = context.request.body orelse return error.MissingBody;

    // TODO: Proper JSON parsing
    // For now, this is just a placeholder
    _ = body;

    // Get database connection
    var db = try db_mod.getConnection(context.allocator);

    // Use chainable query builder to update user
    try db.table("test_users")
        .set("name", .{ .text = "Updated Name" })
        .set("age", .{ .integer = 31 })
        .where("id", "=", .{ .integer = user_id })
        .execute();

    // Send success response
    try context.response.setHeader("Content-Type", "application/json");
    try context.response.send("{\"message\":\"User updated successfully\"}");
}

/// Delete a user
pub fn deleteUserHandler(context: *Context) Errors.Horizon!void {
    // Get user ID from URL parameter
    const id_str = context.params.get("id") orelse return error.MissingParameter;
    const user_id = try std.fmt.parseInt(i64, id_str, 10);

    // Get database connection
    var db = try db_mod.getConnection(context.allocator);

    // Use chainable query builder to delete user
    try db.table("test_users")
        .delete()
        .where("id", "=", .{ .integer = user_id })
        .execute();

    // Send success response
    try context.response.setHeader("Content-Type", "application/json");
    try context.response.send("{\"message\":\"User deleted successfully\"}");
}
