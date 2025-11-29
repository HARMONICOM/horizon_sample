const std = @import("std");
const dig = @import("dig");
const horizon = @import("horizon");

/// Get database connection configuration
pub fn getConfig() dig.types.ConnectionConfig {
    const db_type_str = std.posix.getenv("DB_TYPE") orelse "mysql";
    const database_type: dig.types.DatabaseType = if (std.mem.eql(u8, db_type_str, "postgresql"))
        .postgresql
    else if (std.mem.eql(u8, db_type_str, "mysql"))
        .mysql
    else
        .mysql; // default to mysql

    const default_port: u16 = if (database_type == .postgresql) 5432 else 3306;

    return dig.types.ConnectionConfig{
        .database_type = database_type,
        .port = default_port,
        .host = std.posix.getenv("DB_HOST") orelse "",
        .database = std.posix.getenv("DB_DATABASE") orelse "",
        .username = std.posix.getenv("DB_USERNAME") orelse "",
        .password = std.posix.getenv("DB_PASSWORD") orelse "",
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
