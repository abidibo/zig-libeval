const std = @import("std");
const Operator = @import("operator.zig").Operator;

pub const TokenizerError = error{
    InvalidToken,
    EndOfStream,
};

pub const TokenType = enum { open_paren, close_paren, operator, operand };
pub const Token = struct { type: TokenType, value: []const u8 };

fn isOperatorChar(c: u8) bool {
    return c == '&' or c == '|' or c == '!' or c == '=' or c == '>' or c == '<';
}

fn matchLongestOperator(cursor: usize, infix: []const u8, operators: []const Operator) ?[]const u8 {
    var longest_match: ?[]const u8 = null;
    for (operators) |op| {
        if (std.mem.startsWith(u8, infix[cursor..], op.symbol)) {
            if (longest_match == null or op.symbol.len > longest_match.?.len) {
                longest_match = op.symbol;
            }
        }
    }
    return longest_match;
}

pub fn tokenize(
    infix: []const u8,
    operators: []const Operator,
    allocator: std.mem.Allocator,
) ![]Token {
    var tokens = std.ArrayList(Token){};
    errdefer tokens.deinit(allocator);

    var cursor: usize = 0;
    while (cursor < infix.len) {
        const c = infix[cursor];

        switch (c) {
            ' ', '\t', '\n', '\r' => {
                cursor += 1;
            },
            '(' => {
                try tokens.append(allocator, .{ .type = .open_paren, .value = infix[cursor .. cursor + 1] });
                cursor += 1;
            },
            ')' => {
                try tokens.append(allocator, .{ .type = .close_paren, .value = infix[cursor .. cursor + 1] });
                cursor += 1;
            },
            '0'...'9' => {
                const start = cursor;
                var end = cursor + 1;
                var has_dot = false;
                while (end < infix.len) {
                    const next_c = infix[end];
                    if (std.ascii.isDigit(next_c)) {
                        end += 1;
                    } else if (next_c == '.' and !has_dot) {
                        has_dot = true;
                        end += 1;
                    } else {
                        break;
                    }
                }
                try tokens.append(allocator, .{ .type = .operand, .value = infix[start..end] });
                cursor = end;
            },
            'a'...'z', 'A'...'Z' => {
                const start = cursor;
                var end = cursor + 1;
                while (end < infix.len and std.ascii.isAlphanumeric(infix[end])) {
                    end += 1;
                }
                try tokens.append(allocator, .{ .type = .operand, .value = infix[start..end] });
                cursor = end;
            },
            else => {
                if (isOperatorChar(c)) {
                    if (matchLongestOperator(cursor, infix, operators)) |op_symbol| {
                        try tokens.append(allocator, .{ .type = .operator, .value = op_symbol });
                        cursor += op_symbol.len;
                    } else {
                        return TokenizerError.InvalidToken;
                    }
                } else {
                    return TokenizerError.InvalidToken;
                }
            },
        }
    }

    return tokens.toOwnedSlice(allocator);
}
