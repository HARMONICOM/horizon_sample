const std = @import("std");
const horizon = @import("horizon");

const Test = @import("../models/test.zig").Test;

const Context = horizon.Context;
const Errors = horizon.Errors;

const index_template = @embedFile("../views/index.zts");

pub fn indexHandler(context: *Context) Errors.Horizon!void {
    const query_result = Test(context.allocator) catch {
        return Errors.Horizon.ServerError;
    };
    defer query_result.pool.deinit();
    defer query_result.result.deinit();

    // 結果の行数を取得（SELECT 1の結果なので1行あるはず）
    const row = query_result.result.next() catch {
        return Errors.Horizon.ServerError;
    } orelse {
        return Errors.Horizon.ServerError;
    };
    const value = row.get(i32, 0);

    const formatted_message = try std.fmt.allocPrint(
        context.allocator,
        "Welcome to the World of Zig! {d}",
        .{value},
    );
    defer context.allocator.free(formatted_message);

    const props = .{
        .message = formatted_message,
    };

    const props_json = try std.json.Stringify.valueAlloc(context.allocator, props, .{});
    defer context.allocator.free(props_json);

    try context.response.renderHeader(index_template, .{
        .title = "Welcome to the World of Zig!",
        .props = props_json,
    });
}
