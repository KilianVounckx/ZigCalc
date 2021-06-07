const std = @import("std");

const TokenType = enum {
    number,
    plus,
    minus,
    asterisk,
    slash,
    left_paren,
    right_paren,
    ans,
    exit,

    pub fn format(
        self: TokenType,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        switch (self) {
            .number => try writer.print("number", .{}),
            .plus => try writer.print("plus", .{}),
            .minus => try writer.print("minus", .{}),
            .asterisk => try writer.print("asterisk", .{}),
            .slash => try writer.print("slash", .{}),
            .left_paren => try writer.print("left_paren", .{}),
            .right_paren => try writer.print("right_paren", .{}),
            .ans => try writer.print("ans", .{}),
            .exit => try writer.print("exit", .{}),
        }
    }
};

const Self = @This();

token_type: TokenType = .number,
value: ?f64 = null,

pub fn init(token_type: TokenType) Self {
    return .{.token_type = token_type};
}

pub fn number(value: f64) Self {
    return .{.value = value};
}

pub fn format(
    self: Self,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    try writer.print("{}", .{self.token_type});
    if (self.value) |value| {
        try writer.print(":{d}", .{value});
    }
}