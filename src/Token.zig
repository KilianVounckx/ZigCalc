const std = @import("std");

pub const TokenType = enum {
    number,
    plus,
    minus,
    multiply,
    divide,
    lparen,
    rparen,

    pub fn format(
        self: TokenType,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        switch (self) {
            .number => try writer.print("{s}", .{"number"}),
            .plus => try writer.print("{s}", .{"plus"}),
            .minus => try writer.print("{s}", .{"minus"}),
            .multiply => try writer.print("{s}", .{"multiply"}),
            .divide => try writer.print("{s}", .{"divide"}),
            .lparen => try writer.print("{s}", .{"lparen"}),
            .rparen => try writer.print("{s}", .{"rparen"}),
        }
    }
};

const Self = @This();

token_type: TokenType,
value: ?f64 = null,

pub fn operator(token_type: TokenType) Self {
    return .{
        .token_type = token_type,
    };
}

pub fn number(value: f64) Self {
    return .{
        .token_type = .number,
        .value = value
    };
}

pub fn format(
    self: Self,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    try writer.print("{s}", .{self.token_type});
    if (self.value) |value| {
        try writer.print(":{d}", .{value});
    }
}