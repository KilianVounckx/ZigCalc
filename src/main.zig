const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

pub fn main() !void {
    var buffer: [100]u8 = undefined;
    while (true) {
        try stdout.print("calc> ", .{});
        const input = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')).?;
        try stdout.print("{}\n", .{input});
    }
}
