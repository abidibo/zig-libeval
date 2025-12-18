const std = @import("std");
const Node = @import("node.zig").Node;
const Tokenizer = @import("tokenizer.zig");
const Config = @import("config.zig").Config;

pub const Evaluator = struct {
    _deps: std.StringHashMap(std.ArrayList(*Node)),

    pub fn init(allocator: std.mem.Allocator) Evaluator {
        return Evaluator{
            ._deps = std.StringHashMap(std.ArrayList(*Node)).init(allocator),
        };
    }

    // free all memory, free all lists inside the map
    pub fn deinit(self: *Evaluator, allocator: std.mem.Allocator) void {
        var it = self._deps.valueIterator();
        while (it.next()) |list| {
            list.deinit(allocator);
        }
        self._deps.deinit();
    }

    pub fn compile(self: *Evaluator, allocator: std.mem.Allocator, infix: []const u8) !void {
        const tokens: []Tokenizer.Token = try Tokenizer.tokenize(infix, Config.operators, allocator);
        defer allocator.free(tokens);

        std.debug.print("Tokens: {any}\n", .{tokens});

        _ = self;
    }
};
