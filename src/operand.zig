const std = @import("std");
const Tokenizer = @import("tokenizer.zig");
const Regex = @import("regex").Regex;

pub const OperandError = error{
    InvalidOperand,
};

pub const OperandType = enum { literal, variable };

pub const Operand = struct {
    type: OperandType,
    value: ?f64,

    pub fn init(allocator: std.mem.Allocator, token: Tokenizer.Token) !Operand {
        var literalRegex: Regex = try Regex.compile(allocator, "^[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+$");
        var varRegex: Regex = try Regex.compile(allocator, "^[a-zA-Z][a-zA-Z0-9]*$");
        defer {
            literalRegex.deinit();
            varRegex.deinit();
        }

        if (std.mem.eql(u8, token.value, "true")) {
            return Operand{ .type = OperandType.literal, .value = 1.0 };
        } else if (std.mem.eql(u8, token.value, "false")) {
            return Operand{ .type = OperandType.literal, .value = 0.0 };
        } else if (try literalRegex.find(token.value)) |_| {
            return Operand{ .type = OperandType.literal, .value = std.fmt.parseFloat(f64, token.value) catch unreachable };
        } else if (try varRegex.find(token.value)) |_| {
            return Operand{ .type = OperandType.variable, .value = undefined };
        }

        // else throw error
        return error.InvalidOperand;
    }
};
