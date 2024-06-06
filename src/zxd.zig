const std = @import("std");

pub fn zxd(allocator: std.mem.Allocator, buffer: []const u8) ![]u8 {
    const columns = 16;
    const size = columns * 3 + buffer.len + 1; // hex representation = 2, space = 1, ascii = buffer.len, +1 extra space before ASCII
    const buf = try allocator.alloc(u8, size);

    @memset(buf, ' ');

    for (0..buffer.len) |i| {
        _ = try std.fmt.bufPrint(buf[i * 3 ..], "{x:0>2} ", .{buffer[i]});
    }

    for (0..buffer.len) |i| {
        const char = if (std.ascii.isPrint(buffer[i])) buffer[i] else '.';
        _ = try std.fmt.bufPrint(buf[columns * 3 + i + 1 ..], "{c}", .{char});
    }

    return buf;
}

const testing = std.testing;
const test_allocator = std.testing.allocator;

test "Basic hexdump" {
    const testBuff = [_]u8{ 'Z', 'I', 'G', ' ', 't', 'e', 's', 't' };
    const out = try zxd(test_allocator, &testBuff);
    defer test_allocator.free(out);

    const expected = "5a 49 47 20 74 65 73 74                          ZIG test";

    try testing.expect(std.mem.eql(u8, out, expected));
}
