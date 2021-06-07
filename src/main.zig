const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
const stderr = std.io.getStdErr().writer();

pub fn main() !void {
    var buffer: [128]u8 = undefined;
    while (true) {
        try stdout.print("calc> ", .{});
        const line = (stdin.readUntilDelimiterOrEof(&buffer, '\n') catch |err| {
            try stderr.print("Input too long.\n", .{});
            continue;
        }).?;

        try stdout.print("{s}\n", .{line});
    }
}