const std = @import("std");
const Tokenizer = @import("tokenizer.zig");
const Node = @import("node.zig").Node;
const Operator = @import("operator.zig").Operator;
const Operand = @import("operand.zig").Operand;
const OperandNode = @import("node.zig").OperandNode;

pub const ShuntingYardError = error{EmptyExpression};

pub fn infixToTree(allocator: std.mem.Allocator, tokens: []Tokenizer.Token, operators: []const Operator) !*Node {
    var operatorStack = std.ArrayList(Tokenizer.Token){};
    defer operatorStack.deinit(allocator);

    _ = operators;

    var operandStack = std.ArrayList(*Node){};

    // Error handling: if the function fails halfway, we MUST clean up
    // the nodes already in the operandStack to avoid leaks.
    errdefer {
        for (operandStack.items) |node| allocator.destroy(node);
        operandStack.deinit(allocator);
    }

    for (tokens) |t| {
        switch (t.type) {
            .operand => {
                const op = try Operand.init(allocator, t);
                const node_ptr = try allocator.create(Node);
                node_ptr.* = Node{ .operand = OperandNode.init(op, 1) };
                try operandStack.append(allocator, node_ptr);
            },
            .open_paren => try operatorStack.append(allocator, t),
            .close_paren => {
                // Here you would pop from operatorStack until '('
                // and create sub-trees.
            },
            .operator => {
                // Here you would compare precedence and pop/build sub-trees.
            },
        }
    }

    // --- FINAL STEP: Build the tree from remaining items ---
    // In a real Shunting Yard, you'd loop here and pop operators
    // to join the remaining operands.

    if (operandStack.items.len == 0) return error.EmptyExpression;

    // Take the root out of the stack
    const root = operandStack.pop() orelse return error.EmptyExpression;

    // Clean up any leftovers (which would be a syntax error in math)
    for (operandStack.items) |node| allocator.destroy(node);
    operandStack.deinit(allocator);

    return root;
}
