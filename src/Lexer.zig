const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const Token = @import("Token.zig");

pub const Error = error {
    InvalidCharacter,
    TooManyPoints,
    InvalidNumber,
};

const Self = @This();

text: []const u8,
current_index: ?usize = null,
current_char: ?u8 = null,

pub fn init(text: []const u8) Self {
    var result = Self {.text = text};
    result.advance();
    return result;
}

pub fn advance(self: *Self) void {
    self.current_index = if (self.current_index == null)
        if (self.text.len > 0) @intCast(usize, 0) else null
    else if (self.current_index.? < self.text.len - 1)
        self.current_index.? + 1
    else
        null
    ;

    self.current_char = if (self.current_index == null)
        null
    else
        self.text[self.current_index.?]
    ;
}

pub fn generateTokens(self: *Self, allocator: *Allocator) !ArrayList(Token) {
    var result = ArrayList(Token).init(allocator);

    while (self.current_char) |char| {
        switch (char) {
            '+' => {
                try result.append(Token.operator(.plus));
                self.advance();
            },
            '-' => {
                try result.append(Token.operator(.minus));
                self.advance();
            },
            '*' => {
                try result.append(Token.operator(.multiply));
                self.advance();
            },
            '/' => {
                try result.append(Token.operator(.divide));
                self.advance();
            },
            '(' => {
                try result.append(Token.operator(.lparen));
                self.advance();
            },
            ')' => {
                try result.append(Token.operator(.rparen));
                self.advance();
            },
            '0'...'9' => try result.append(try self.generateNumber(allocator)),
            else => return Error.InvalidCharacter,
        }
    }

    return result;
}

pub fn generateNumber(self: *Self, allocator: *Allocator) !Token {
    var number_string = ArrayList(u8).init(allocator);

    var point_count: u2 = 0;

    while (self.current_char) |char| {
        switch (char) {
            '0'...'9', '.' => {
                if (char == '.') {
                    point_count += 1;
                    if (point_count > 1) {
                        return Error.TooManyPoints;
                    }
                }
                try number_string.append(char);
                self.advance();
            },
            else => break,
        }
    }

    if (number_string.items[number_string.items.len-1] == '.') {
        return Error.InvalidNumber;
    }

    const number = std.fmt.parseFloat(f64, number_string.items) catch |err| {
        return Error.InvalidNumber;
    };

    return Token.number(number);
}

pub fn format(
    self: Self,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
}