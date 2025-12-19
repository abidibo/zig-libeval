const std = @import("std");
const Operand = @import("operand.zig").Operand;
var cnt: i16 = 0;

pub const OperandNode = struct {
    id: i16 = 0,
    operand: Operand,
    depth: i16 = 0,
    parent: ?*Node = null, // Change undefined to null

    pub fn init(operand: Operand, depth: i16) OperandNode {
        cnt += 1;
        return OperandNode{ .id = cnt, .operand = operand, .depth = depth };
    }
};

pub const UnaryOperatorNode = struct {
    id: i16 = 0,
    symbol: []const u8 = "",
    depth: i16 = 0,
    leftChild: *Node = undefined,
    parent: ?*Node = null, // Change undefined to null

    pub fn init(symbol: []const u8, depth: i16, leftChild: *Node) UnaryOperatorNode {
        cnt += 1;
        return UnaryOperatorNode{ .id = cnt, .symbol = symbol, .depth = depth, .leftChild = leftChild };
    }
};

pub const BinaryOperatorNode = struct {
    id: i16 = 0,
    symbol: []const u8 = "",
    depth: i16 = 0,
    leftChild: *Node = undefined,
    rightChild: *Node = undefined,
    parent: ?*Node = null, // Change undefined to null

    pub fn init(symbol: []const u8, depth: i16, leftChild: *Node, rightChild: *Node) BinaryOperatorNode {
        cnt += 1;
        return BinaryOperatorNode{ .id = cnt, .symbol = symbol, .depth = depth, .leftChild = leftChild, .rightChild = rightChild };
    }
};

pub const Node = union(enum) {
    operand: OperandNode,
    unaryOperator: UnaryOperatorNode,
    binaryOperator: BinaryOperatorNode,

    // The "Virtual Method"
    pub fn getId(self: Node) i16 {
        // Switch on self to find out which active field to access
        // 'inline else' auto-generates cases for all fields
        // that share the structure!
        switch (self) {
            inline else => |impl| return impl.id,
        }
    }

    pub fn getDepth(self: Node) i16 {
        switch (self) {
            inline else => |impl| return impl.depth,
        }
    }

    pub fn getSymbol(self: Node) []const u8 {
        switch (self) {
            inline else => |impl| return impl.symbol,
        }
    }

    pub fn setParent(self: *Node, p: *Node) void {
        switch (self.*) {
            inline else => |*impl| impl.parent = p,
        }
    }

    pub fn destroy(self: *Node, allocator: std.mem.Allocator) void {
        // 1. Look at what kind of node this is
        switch (self.*) {
            // Operands have no children, nothing else to clean up inside
            .operand => {},

            // Unary operators have one child that must be destroyed first
            .unaryOperator => |un| {
                un.leftChild.destroy(allocator);
            },

            // Binary operators have two children that must be destroyed first
            .binaryOperator => |bin| {
                bin.leftChild.destroy(allocator);
                bin.rightChild.destroy(allocator);
            },
        }

        // 2. Finally, free the memory for the current node itself
        allocator.destroy(self);
    }
};
