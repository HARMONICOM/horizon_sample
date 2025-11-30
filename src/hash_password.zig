const std = @import("std");
const horizon = @import("horizon");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <password>\n", .{args[0]});
        return;
    }

    const password = args[1];

    const hash = try horizon.crypto.hashPassword(allocator, password);
    defer allocator.free(hash);

    std.debug.print("{s}\n", .{hash});
}

