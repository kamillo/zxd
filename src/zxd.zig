const std = @import("std");

pub fn zxd(allocator: std.mem.Allocator, buffer: []const u8) ![]u8 {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();

    // const args = try std.process.argsAlloc(allocator);
    // defer std.process.argsFree(allocator, args);

    // if (args.len < 2) {
    // std.debug.print("Usage: {s} <path_to_file>", .{args[0]});
    // return;
    // }

    // const file = try std.fs.cwd().openFile(args[1], .{ .mode = .read_only });
    // defer file.close();

    // const columns: u8 = 16;

    // const buffer = try allocator.alloc(u8, columns);
    // defer allocator.free(buffer);
    // var buffer: [columns]u8 = undefined;
    // const stdout = std.io.getStdOut().writer();
    // TODO: create custom BufferedWriter
    // var buffered = std.io.bufferedReader(file.reader());
    // const reader = buffered.reader();
    // const stat = try file.stat();

    // var offset: u64 = 0;
    // while (true) {
    // const offset = try reader.getPos();
    // printf("{x:0>8}: ", .{offset});

    // const bytes = try reader.readAll(&buffer);
    // offset += bytes;
    const size = buffer.len * 4; // hex representation = 2, space = 1, ascii = 1
    const buf = try allocator.alloc(u8, size);
    // var fbs = std.io.fixedBufferStream(buf);

    for (0..buffer.len) |i| {
        _ = try std.fmt.bufPrint(buf[i * 3 ..], "{x:0>2} ", .{buffer[i]});
        // printf("{x:0>2} ", .{buffer[i]});
    }

    for (0..buffer.len) |i| {
        const char = if (std.ascii.isPrint(buffer[i])) buffer[i] else '.';
        _ = try std.fmt.bufPrint(buf[buffer.len * 3 + i ..], "{c}", .{char});
        // printf("{c}", .{char});
    }
    //    const stdout = std.io.getStdOut().writer();

    // var bufferedw = std.io.bufferedWriter(stdout);
    // try bufferedWriter.flush();

    // if (bytes != buffer.len) {
    // break;
    // }

    // printf("\n", .{});
    // }
    //
    //
    //std.debug.print("{d} : 0x{x}", .{ read, buffer[0] });
    return buf;
}

const stdout = std.io.getStdOut().writer();
var bufferedWriter = std.io.bufferedWriter(stdout);

pub fn printf(comptime format: []const u8, args: anytype) void {
    const writer = bufferedWriter.writer();

    writer.print(format, args) catch {
        bufferedWriter.flush() catch {
            return;
        };

        return;
    };

    // buffered.flush();
}

const testing = std.testing;
const test_allocator = std.testing.allocator;

test "Basic hexdump" {
    const testBuff = [_]u8{ 'Z', 'I', 'G', ' ', 't', 'e', 's', 't' };
    const out = try zxd(test_allocator, &testBuff);
    defer test_allocator.free(out);

    try testing.expect(std.mem.eql(u8, out, "5a 49 47 20 74 65 73 74 ZIG test"));
}
