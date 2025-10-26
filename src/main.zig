const std = @import("std");
const everybody_codes = @import("everybody_codes");

const PARSE_FAILED_MESSAGE = "Failed to parse arg \"{s}\" as int.\n";

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 3) {
        std.debug.print("Usage: {s} <int> <int>\n", .{args[0]});
        std.process.exit(1);
    }

    const a = std.fmt.parseInt(u32, args[1], 10) catch {
        std.debug.print(PARSE_FAILED_MESSAGE, .{args[1]});
        std.process.exit(1);
    };
    const b = std.fmt.parseInt(u32, args[2], 10) catch {
        std.debug.print(PARSE_FAILED_MESSAGE, .{args[2]});
        std.process.exit(1);
    };

    std.debug.print("{d} + {d} = {d}\n", .{ a, b, addTwoNumbers(a, b) });
}

fn addTwoNumbers(a: u32, b: u32) u32 {
    return a + b;
}
