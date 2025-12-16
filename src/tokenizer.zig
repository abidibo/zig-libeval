const Operator = @import("operator.zig").Operator;
const std = @import("std");
const Regex = @import("regex").Regex;

pub const TokenType = enum { open_paren, close_paren, operator, operand };
pub const Token = struct { type: TokenType, value: []const u8 };

pub const Pattern = struct {
    type: TokenType,
    regex: Regex,

    pub fn init(allocator: std.mem.Allocator, t: TokenType, regex_str: []const u8) !Pattern {
        const compiled: Regex = try Regex.compile(allocator, regex_str);
        return Pattern{ .type = t, .regex = compiled };
    }

    pub fn deinit(self: *Pattern) void {
        self.regex.deinit();
    }

    pub fn match(self: Pattern, str: []const u8) !?[]const u8 {
        // regex.find usually returns an optional Match object with a .slice field
        if (try self.regex.find(str)) |m| {
            return m.slice; // Return the actual matched text (e.g. "123" or "(")
        }
        return null;
    }
};

pub fn tokenize(
    infix: []const u8,
    operators: []const Operator,
    allocator: std.mem.Allocator,
) ![]Token {

    // first we construct the patterns used to extract the next token
    var patterns = std.ArrayList(Pattern){};
    defer {
        for (patterns.items) |*p| p.deinit();
        patterns.deinit(allocator);
    }

    // open paren pattern
    try patterns.append(allocator, try Pattern.init(allocator, TokenType.open_paren, "^\\("));
    // close paren pattern
    try patterns.append(allocator, try Pattern.init(allocator, TokenType.close_paren, "^\\)"));
    // operand pattern
    try patterns.append(allocator, try Pattern.init(allocator, TokenType.operand, "^(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+|[a-zA-Z][a-zA-Z0-9]*)"));

    for (operators) |op| {
        try patterns.append(allocator, try Pattern.init(allocator, TokenType.operator, op.regex_str));
    }

    var tokens = std.ArrayList(Token){};
    errdefer tokens.deinit(allocator); // free only on error
    var cursor: usize = 0;

    while (cursor < infix.len) {
        const c = infix[cursor];
        if (c == ' ' or c == '\t' or c == '\n' or c == '\r') {
            cursor += 1;
            continue;
        }

        var matched = false;

        for (patterns.items) |p| {
            // Capture the 'matched_text' returned by match()
            if (try p.match(infix[cursor..])) |matched_text| {
                const token = Token{ .type = p.type, .value = matched_text };
                try tokens.append(allocator, token);
                cursor += matched_text.len;
                matched = true;
                break;
            }
        }

        // Safety: If no pattern matches, you are stuck in an infinite loop.
        // You should handle invalid characters or at least break.
        if (!matched) {
            std.debug.print("Error: Unknown token at index {d}: {c}\n", .{ cursor, infix[cursor] });
            return error.InvalidToken; // Or simply break/cursor++ to skip
        }
    }

    return try tokens.toOwnedSlice(allocator);
}
