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

    var buffer: [16]u8 = undefined;
    var offset: u64 = 0;

    while (true) {
        //@memset(&buffer, 0);
        const bytes = try reader.readAll(&buffer);
        const out = try zxd.zxd(allocator, buffer[0..bytes]);
        defer allocator.free(out);

        printf("{x:0>8}: {s}\n", .{ offset, out });

        offset += bytes;

        if (bytes != buffer.len) {
            break;
        }
    }
}

pub fn printf(comptime format: []const u8, args: anytype) void {
    const stdout = std.io.getStdOut().writer();
    var bufferedWriter = std.io.bufferedWriter(stdout);
    const writer = bufferedWriter.writer();

    writer.print(format, args) catch {
        bufferedWriter.flush() catch {
            return;
        };

        return;
    };

    bufferedWriter.flush() catch {
        return;
    };
}
