const std = @import("std");
const Allocator = std.mem.Allocator;

const Operation = union(enum) {
    number: f64,
    addition,
    subtraction,
    multiplication,
    division,
    negation,
};

const Self = @This();

operation: Operation,
nodes: []Self,
allocator: *Allocator,

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

pub fn format(
    self: Self,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    switch (self.operation) {
        .number => |value| try writer.print("{d}", .{value}),
        .addition => try writer.print("({s}+{s})", .{self.nodes[0], self.nodes[1]}),
        .subtraction => try writer.print("({s}-{s})", .{self.nodes[0], self.nodes[1]}),
        .multiplication => try writer.print("({s}*{s})", .{self.nodes[0], self.nodes[1]}),
        .division => try writer.print("({s}/{s})", .{self.nodes[0], self.nodes[1]}),
        .negation => try writer.print("(-{s})", .{self.nodes[0]}),
    }
}