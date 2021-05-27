const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const Lexer = @import("Lexer.zig");
const LexerError = Lexer.Error;

pub fn main() !void {
    const allocator = &std.heap.ArenaAllocator.init(std.heap.page_allocator).allocator;

    var buffer: [100]u8 = undefined;
    while (true) {
        try stdout.print("calc> ", .{});
        const input = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')).?;

        var lexer = Lexer.init(input);
        var tokens = if (lexer.generateTokens(allocator)) |tokens|
            tokens
        else |err| switch (err) {
            LexerError.InvalidCharacter, LexerError.TooManyPoints, LexerError.InvalidNumber => {
                try stdout.print("{}\n", .{err});
                continue;
            },
            else => return err,
        };
        defer tokens.deinit();

        for (tokens.items) |token| {
            try stdout.print("{}, ", .{token});
        }
        try stdout.print("\n", .{});

        try stdout.print("\n", .{});
    }
}
