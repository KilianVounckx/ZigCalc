const std = @import("std");
const Allocator = std.mem.Allocator;

const Node = @import("Node.zig");
const Token = @import("Token.zig");

pub const Error = error {
    ExpectedSomething,
    InvalidSyntax,
    ExpectedNumber,
    ExpectedRightParenthesis,
};

const Self = @This();

tokens: []Token,
current_index: ?usize = null,
current_token: ?Token = null,

pub fn init(tokens: []Token) Self {
    var result = Self{.tokens = tokens};
    result.advance();
    return result;
}

pub fn advance(self: *Self) void {
    self.current_index = if (self.current_index) |index|
        if (index < self.tokens.len - 1)
            index + 1
        else
            null
    else
        if (self.tokens.len > 0)
            @as(?usize, 0)
        else
            null;

    self.current_token = if (self.current_index) |index|
        self.tokens[index]
    else
        null;
}

pub fn parse(self: *Self, allocator: *Allocator) !?Node {
    if (self.current_token == null) {
        return null;
    }

    const result = try self.expression(allocator);

    if (self.current_token != null) {
        return Error.ExpectedSomething;
    }

    return result;
}

pub fn expression(self: *Self, allocator: *Allocator) !Node {
    var result = try self.term(allocator);

    while (self.current_token) |token| switch (token.token_type) {
        .plus => {
            self.advance();
            result = try Node.binaryOperation(
                allocator,
                .addition,
                result,
                try self.term(allocator),
            );
        },
        .minus => {
            self.advance();
            result = try Node.binaryOperation(
                allocator,
                .subtraction,
                result,
                try self.term(allocator),
            );
        },
        else => break,
    };

    return result;
}

pub fn term(self: *Self, allocator: *Allocator) !Node {
    var result = try self.factor(allocator);

    while (self.current_token) |token| switch (token.token_type) {
        .asterisk => {
            self.advance();
            result = try Node.binaryOperation(
                allocator,
                .multiplication,
                result,
                try self.factor(allocator),
            );
        },
        .slash => {
            self.advance();
            result = try Node.binaryOperation(
                allocator,
                .division,
                result,
                try self.factor(allocator),
            );
        },
        else => break,
    };

    return result;
}

pub fn factor(self: *Self, allocator: *Allocator) anyerror!Node {
    if (self.current_token) |token| switch (token.token_type) {
        .minus => {
            self.advance();
            return Node.unaryOperation(allocator, .negation, try self.factor(allocator));
        },
        .left_paren => {
            self.advance();
            var result = try self.expression(allocator);
            if (self.current_token) |new_token| switch (new_token.token_type) {
                .right_paren => {
                    self.advance();
                    return result;
                },
                else => return Error.ExpectedRightParenthesis,
            } else {
                return Error.ExpectedRightParenthesis;
            }
        },
        .number => {
            self.advance();
            return Node.number(allocator, token.value.?);
        },
        .ans => {
            self.advance();
            return Node.ans(allocator);
        },
        else => return Error.ExpectedNumber,
    } else {
        return Error.ExpectedSomething;
    }
}