const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
const stderr = std.io.getStdErr().writer();

const Lexer = @import("Lexer.zig");
const Parser = @import("Parser.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var buffer: [128]u8 = undefined;
    while (true) {
        try stdout.print("calc> ", .{});
        const line = (stdin.readUntilDelimiterOrEof(&buffer, '\n') catch |err| {
            try stderr.print("Input too long.\n", .{});
            continue;
        }).?;

        var lexer = Lexer.init(line);
        var tokens = lexer.tokenize(&gpa.allocator) catch |err| switch (err) {
            Lexer.Error.InvalidCharacter, Lexer.Error.TooManyPoints, Lexer.Error.UnexpectedPoint => {
                try stderr.print("Lexer error: {}\n", .{err});
                continue;
            },
            else => return err,
        };
        defer gpa.allocator.free(tokens);

        var parser = Parser.init(tokens);
        var ast = parser.parse(&gpa.allocator) catch |err| switch (err) {
            Parser.Error.ExpectedNumber, Parser.Error.ExpectedSomething, Parser.Error.InvalidSyntax, Parser.Error.ExpectedRightParenthesis => {
                try stderr.print("Parser error: {}\n", .{err});
                continue;
            },
            else => return err,
        } orelse {
            try stdout.print("\n", .{});
            continue;
        };
        defer ast.deinit();

        std.debug.print("test: {}\n", .{ast.operation});
    }
}