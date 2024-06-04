const std = @import("std");
const zxd = @import("zxd.zig");
const fs = std.fs;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <path_to_file>", .{args[0]});
        return;
    }

    const file = try fs.cwd().openFile(args[1], .{ .mode = .read_only });
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    const reader = buffered.reader();

    const columns: u8 = 16;
    var buffer: [columns]u8 = undefined;
    while (true) {
        const bytes = try reader.readAll(&buffer);

        const out = try zxd.zxd(allocator, &buffer);
        defer allocator.free(out);

        if (bytes != buffer.len) {
            break;
        }
    }
}
