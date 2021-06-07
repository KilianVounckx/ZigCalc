const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
const stderr = std.io.getStdErr().writer();

const Lexer = @import("Lexer.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var buffer: [128]u8 = undefined;
    while (true) {
        try stdout.print("calc> ", .{});
        const line = (stdin.readUntilDelimiterOrEof(&buffer, '\n') catch |err| {
            try stderr.print("Input too long.\n", .{});
            continue;
        }).?;

        var lexer = Lexer.init(line);
        const tokens = lexer.tokenize(&arena.allocator) catch |err| switch (err) {
            Lexer.Error.InvalidCharacter, Lexer.Error.TooManyPoints, Lexer.Error.UnexpectedPoint => {
                try stderr.print("Lexer error: {}\n", .{err});
                continue;
            },
            else => return err,
        };

        std.debug.print("{any}\n", .{tokens});
    }
}