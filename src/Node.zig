const std = @import("std");
const Allocator = std.mem.Allocator;

const calculator = @import("main.zig");

pub const Error = error {
    DivisionByZero,
};

const Operation = union(enum) {
    number: f64,
    addition,
    subtraction,
    multiplication,
    division,
    negation,
    ans,
};

const Self = @This();

operation: Operation,
nodes: []Self,
allocator: *Allocator,

pub fn ans(allocator: *Allocator) !Self {
    const nodes = try allocator.alloc(Self, 0);
    errdefer nodes.deinit();

    return Self{
        .operation = .ans,
        .nodes = nodes,
        .allocator = allocator,
    };
}

pub fn number(allocator: *Allocator, value: f64) !Self {
    const nodes = try allocator.alloc(Self, 0);
    errdefer nodes.deinit();

    return Self{
        .operation = .{.number = value},
        .nodes = nodes,
        .allocator = allocator,
    };
}

pub fn unaryOperation(allocator: *Allocator, operation: Operation, node: Self) !Self {
    var nodes = try allocator.alloc(Self, 1);
    errdefer nodes.deinit();
    nodes[0] = node;

    return Self{
        .operation = operation,
        .nodes = nodes,
        .allocator = allocator,
    };
}

pub fn binaryOperation(allocator: *Allocator, operation: Operation, left: Self, right: Self) !Self {
    var nodes = try allocator.alloc(Self, 2);
    errdefer nodes.deinit();
    nodes[0] = left;
    nodes[1] = right;

    return Self{
        .operation = operation,
        .nodes = nodes,
        .allocator = allocator,
    };
}

pub fn deinit(self: *Self) void {
    for (self.nodes) |*node| {
        node.deinit();
    }
    self.allocator.free(self.nodes);
}

pub fn interpret(self: Self) anyerror!f64 {
    switch (self.operation) {
        .number => |value| return value,
        .addition => return (try self.nodes[0].interpret()) + (try self.nodes[1].interpret()),
        .subtraction => return (try self.nodes[0].interpret()) - (try self.nodes[1].interpret()),
        .multiplication => return (try self.nodes[0].interpret()) * (try self.nodes[1].interpret()),
        .division => {
            const right = try self.nodes[1].interpret();
            if (right == 0) {
                return Error.DivisionByZero;
            }
            return (try self.nodes[0].interpret()) / right;
        },
        .negation => return -(try self.nodes[0].interpret()),
        .ans => return calculator.ans,
    }
}