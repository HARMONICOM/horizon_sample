const std = @import("std");
const dig = @import("dig");
const horizon = @import("horizon");

/// Get database connection configuration
pub fn getConfig() dig.types.ConnectionConfig {
    return dig.types.ConnectionConfig{
        .database_type = .postgresql,
        .port = 5432,
        .host = std.posix.getenv("DB_HOST") orelse "127.0.0.1",
        .database = std.posix.getenv("DB_DATABASE") orelse "postgres",
        .username = std.posix.getenv("DB_USER") orelse "postgres",
        .password = std.posix.getenv("DB_PASSWORD") orelse "postgres",
    };
}

/// Connect to database
pub fn connect(allocator: std.mem.Allocator) dig.errors.DigError!dig.db {
    const config = getConfig();
    return try dig.db.connect(allocator, config);
}

/// Convert DigError to Horizon error
pub fn convertDigError(err: dig.errors.DigError) horizon.Errors.Horizon {
    return switch (err) {
        error.ConnectionFailed => horizon.Errors.Horizon.ConnectionError,
        error.InvalidConnectionString => horizon.Errors.Horizon.ConnectionError,
        error.QueryExecutionFailed => horizon.Errors.Horizon.ServerError,
        error.InvalidQuery => horizon.Errors.Horizon.ServerError,
        error.InvalidSchema => horizon.Errors.Horizon.ServerError,
        error.TypeMismatch => horizon.Errors.Horizon.ServerError,
        error.NotFound => horizon.Errors.Horizon.ServerError,
        error.TransactionFailed => horizon.Errors.Horizon.ServerError,
        error.UnsupportedDatabase => horizon.Errors.Horizon.ServerError,
        error.InvalidParameter => horizon.Errors.Horizon.ServerError,
        error.QueryBuildError => horizon.Errors.Horizon.ServerError,
        error.OutOfMemory => horizon.Errors.Horizon.OutOfMemory,
    };
}
