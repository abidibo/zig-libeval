const std = @import("std");
const Tokenizer = @import("tokenizer.zig");
const Node = @import("node.zig").Node;
const Operator = @import("operator.zig").Operator;
const Operand = @import("operand.zig").Operand;
const OperandNode = @import("node.zig").OperandNode;
const Config = @import("config.zig").Config;

pub const ShuntingYardError = error{
    EmptyExpression,
    UnbalancedParenthesis,
};

fn addOperatorNode(stack: *std.ArrayList(*Node), token: Tokenizer.Token) !void {
    if (token.type == Tokenizer.TokenType.open_paren) {
        return error.UnbalancedParenthesis;
    }

    // TODO: create the operator node that wll be added to the operand stack

    _ = stack;
}

pub fn infixToTree(allocator: std.mem.Allocator, tokens: []Tokenizer.Token, operators: []const Operator) !*Node {
    var operatorMap = std.StringHashMap(*const Operator).init(allocator);
    defer operatorMap.deinit(); // correct way to free the hash map

    for (Config.operators) |op| {
        try operatorMap.put(op.symbol, &op);
    }

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
            .operand => { // operands are all stacked
                const op = try Operand.init(allocator, t);
                const node_ptr = try allocator.create(Node);
                node_ptr.* = Node{ .operand = OperandNode.init(op, 1) };
                try operandStack.append(allocator, node_ptr);
            },
            .open_paren => try operatorStack.append(allocator, t), // open paren goes in the operator stack
            .close_paren => {
                // Here you would pop from operatorStack until '('
                // and create sub-trees.
            },
            .operator => {
                const op = operatorMap.get(t.value).?;

                while (operatorStack.items.len > 0) {
                    const top_token = operatorStack.items[operatorStack.items.len - 1];
                    const op2 = operatorMap.get(top_token.value) orelse break;
                    // pop all operators which have greater or equal precedence
                    if (op.comparePrecedence(op2) <= 0) {
                        _ = operatorStack.pop();
                        try addOperatorNode(&operandStack, top_token);
                    }
                }
            },
        }
    }

    if (operandStack.items.len == 0) return error.EmptyExpression;

    // Take the root out of the stack
    const root = operandStack.pop() orelse return error.EmptyExpression;

    // Clean up any leftovers (which would be a syntax error in math)
    for (operandStack.items) |node| allocator.destroy(node);
    operandStack.deinit(allocator);

    return root;
}
