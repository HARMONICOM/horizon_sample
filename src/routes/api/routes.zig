const std = @import("std");
const horizon = @import("horizon");

const Context = horizon.Context;
const Errors = horizon.Errors;

const indexHandler = @import("index.zig").indexHandler;

/// OPTIONSリクエスト用のハンドラー（CORSミドルウェアが処理する）
fn optionsHandler(context: *Context) Errors.Horizon!void {
    _ = context;
    // CORSミドルウェアがOPTIONSリクエストを処理するため、ここでは何もしない
}

pub const routes = .{
    .{ "GET", "", indexHandler },
    .{ "OPTIONS", "", optionsHandler },
};
