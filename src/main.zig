const std = @import("std");
const ziglibeval = @import("ziglibeval");
const Tokenizer = @import("tokenizer.zig");
const Config = @import("config.zig").Config;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    std.debug.print("INIT\n", .{});

    // Prints to stderr, ignoring potential errors.
    const infix: []const u8 = "var1 && 45";
    const tokens: []Tokenizer.Token = try Tokenizer.tokenize(infix, Config.operators, allocator);
    defer allocator.free(tokens);
    std.debug.print("Tokens: {any}\n", .{tokens});
    try ziglibeval.bufferedPrint();
}

// test "simple test" {
//     const gpa = std.testing.allocator;
//     var list: std.ArrayList(i32) = .empty;
//     defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
//     try list.append(gpa, 42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
//
// test "fuzz example" {
//     const Context = struct {
//         fn testOne(context: @This(), input: []const u8) anyerror!void {
//             _ = context;
//             // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
//             try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
//         }
//     };
//     try std.testing.fuzz(Context{}, Context.testOne, .{});
// }
