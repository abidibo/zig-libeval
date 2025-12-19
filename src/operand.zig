const std = @import("std");
const Tokenizer = @import("tokenizer.zig");

pub const OperandError = error{
    InvalidOperand,
};

pub const OperandType = enum { literal, variable };

pub const Operand = struct {
    type: OperandType,
    value: ?f64,

    pub fn init(allocator: std.mem.Allocator, token: Tokenizer.Token) !Operand {
        _ = allocator;
        const first_char = token.value[0];

        if (std.mem.eql(u8, token.value, "true")) {
            return Operand{ .type = OperandType.literal, .value = 1.0 };
        } else if (std.mem.eql(u8, token.value, "false")) {
            return Operand{ .type = OperandType.literal, .value = 0.0 };
        } else if (std.ascii.isDigit(first_char) or (first_char == '.' and token.value.len > 1)) {
            const value = try std.fmt.parseFloat(f64, token.value);
            return Operand{ .type = OperandType.literal, .value = value };
        } else if (std.ascii.isAlphabetic(first_char)) {
            return Operand{ .type = OperandType.variable, .value = null };
        }

        return OperandError.InvalidOperand;
    }
};
