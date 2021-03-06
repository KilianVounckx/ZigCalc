const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Token = @import("Token.zig");

pub const Error = error{
    InvalidCharacter,
    TooManyPoints,
    UnexpectedPoint,
};

const Self = @This();

text: []const u8,
current_index: ?usize = null,
current_char: ?u8 = null,

pub fn init(text: []const u8) Self {
    var result = Self{ .text = text };
    result.advance();
    return result;
}

pub fn advance(self: *Self) void {
    self.current_index = if (self.current_index) |index|
        if (index < self.text.len - 1)
            index + 1
        else
            null
    else if (self.text.len > 0)
        @as(?usize, 0)
    else
        null;

    self.current_char = if (self.current_index) |index|
        self.text[index]
    else
        null;
}

pub fn tokenize(self: *Self, allocator: *Allocator) ![]Token {
    var result = ArrayList(Token).init(allocator);
    errdefer result.deinit();

    while (self.current_char) |char| switch (char) {
        ' ', '\n', '\t' => self.advance(),
        '+' => {
            try result.append(Token.init(.plus));
            self.advance();
        },
        '-' => {
            try result.append(Token.init(.minus));
            self.advance();
        },
        '*' => {
            try result.append(Token.init(.asterisk));
            self.advance();
        },
        '/' => {
            try result.append(Token.init(.slash));
            self.advance();
        },
        '^' => {
            try result.append(Token.init(.circumflex));
            self.advance();
        },
        '(' => {
            try result.append(Token.init(.left_paren));
            self.advance();
        },
        ')' => {
            try result.append(Token.init(.right_paren));
            self.advance();
        },
        '0'...'9' => try result.append(try self.tokenizeNumber(allocator)),
        'a' => try result.append(try self.tokenizeAns(allocator)),
        'e' => try result.append(try self.tokenizeExit(allocator)),
        'h' => try result.append(try self.tokenizeHelp(allocator)),
        else => return Error.InvalidCharacter,
    };

    return result.toOwnedSlice();
}

pub fn tokenizeNumber(self: *Self, allocator: *Allocator) !Token {
    var number_string = ArrayList(u8).init(allocator);
    defer number_string.deinit();

    var has_point = false;

    while (self.current_char) |char| switch (char) {
        '0'...'9' => {
            try number_string.append(char);
            self.advance();
        },
        '.' => if (has_point) {
            return Error.TooManyPoints;
        } else {
            has_point = true;
            try number_string.append(char);
            self.advance();
        },
        else => break,
    };

    if (number_string.items[number_string.items.len - 1] == '.') {
        return Error.UnexpectedPoint;
    }

    return Token.number(try std.fmt.parseFloat(f64, number_string.items));
}

pub fn tokenizeAns(self: *Self, allocator: *Allocator) !Token {
    self.advance();
    if (self.current_char) |char| switch (char) {
        'n' => {},
        else => return Error.InvalidCharacter,
    };
    self.advance();
    if (self.current_char) |char| switch (char) {
        's' => {},
        else => return Error.InvalidCharacter,
    };
    self.advance();

    return Token.init(.ans);
}

pub fn tokenizeExit(self: *Self, allocator: *Allocator) !Token {
    self.advance();
    if (self.current_char) |char| switch (char) {
        'x' => {},
        else => return Error.InvalidCharacter,
    };
    self.advance();
    if (self.current_char) |char| switch (char) {
        'i' => {},
        else => return Error.InvalidCharacter,
    };
    self.advance();

    if (self.current_char) |char| switch (char) {
        't' => {},
        else => return Error.InvalidCharacter,
    };
    self.advance();

    return Token.init(.exit);
}

pub fn tokenizeHelp(self: *Self, allocator: *Allocator) !Token {
    self.advance();
    if (self.current_char) |char| switch (char) {
        'e' => {},
        else => return Error.InvalidCharacter,
    };
    self.advance();
    if (self.current_char) |char| switch (char) {
        'l' => {},
        else => return Error.InvalidCharacter,
    };
    self.advance();
    if (self.current_char) |char| switch (char) {
        'p' => {},
        else => return Error.InvalidCharacter,
    };
    self.advance();

    return Token.init(.help);
}
