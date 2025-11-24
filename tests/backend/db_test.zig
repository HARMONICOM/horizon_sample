const std = @import("std");
const testing = std.testing;
const dig = @import("dig");
const horizon = @import("horizon");
const horizon_sample = @import("horizon_sample");
const db = horizon_sample.utils.db;

test "getConfig - returns valid connection config" {
    const config = db.getConfig();

    try testing.expect(config.database_type == .postgresql);
    try testing.expect(config.port == 5432);
    try testing.expect(config.host.len > 0);
    try testing.expect(config.database.len > 0);
    try testing.expect(config.username.len > 0);
    try testing.expect(config.password.len > 0);
}

test "convertDigError - converts ConnectionFailed to ConnectionError" {
    const err: dig.errors.DigError = error.ConnectionFailed;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ConnectionError);
}

test "convertDigError - converts InvalidConnectionString to ConnectionError" {
    const err: dig.errors.DigError = error.InvalidConnectionString;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ConnectionError);
}

test "convertDigError - converts QueryExecutionFailed to ServerError" {
    const err: dig.errors.DigError = error.QueryExecutionFailed;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ServerError);
}

test "convertDigError - converts InvalidQuery to ServerError" {
    const err: dig.errors.DigError = error.InvalidQuery;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ServerError);
}

test "convertDigError - converts InvalidSchema to ServerError" {
    const err: dig.errors.DigError = error.InvalidSchema;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ServerError);
}

test "convertDigError - converts TypeMismatch to ServerError" {
    const err: dig.errors.DigError = error.TypeMismatch;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ServerError);
}

test "convertDigError - converts NotFound to ServerError" {
    const err: dig.errors.DigError = error.NotFound;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ServerError);
}

test "convertDigError - converts TransactionFailed to ServerError" {
    const err: dig.errors.DigError = error.TransactionFailed;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ServerError);
}

test "convertDigError - converts UnsupportedDatabase to ServerError" {
    const err: dig.errors.DigError = error.UnsupportedDatabase;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ServerError);
}

test "convertDigError - converts InvalidParameter to ServerError" {
    const err: dig.errors.DigError = error.InvalidParameter;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ServerError);
}

test "convertDigError - converts QueryBuildError to ServerError" {
    const err: dig.errors.DigError = error.QueryBuildError;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.ServerError);
}

test "convertDigError - converts OutOfMemory to OutOfMemory" {
    const err: dig.errors.DigError = error.OutOfMemory;
    const horizon_err = db.convertDigError(err);
    try testing.expect(horizon_err == horizon.Errors.Horizon.OutOfMemory);
}

