const std = @import("std");
const everybody_codes = @import("everybody_codes");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const gpa_alloc = gpa.allocator();

    const args = try std.process.argsAlloc(gpa_alloc);
    defer std.process.argsFree(gpa_alloc, args);

    if (args.len < 3) {
        std.debug.print("Usage: {s} <file_name_str> <day_int>\n", .{args[0]});
        std.process.exit(1);
    }
    const puzzle_input_path = args[1];
    const day = std.fmt.parseInt(u32, args[2], 10) catch {
        std.debug.print("failed to parse day \"{s}\" to int.\n", .{args[2]});
        std.process.exit(1);
    };

    var arena = std.heap.ArenaAllocator.init(gpa_alloc);
    defer arena.deinit();
    const arena_alloc = arena.allocator();

    switch (day) {
        1 => {
            const puzzle_one_result = try everybody_codes.dayOnePuzzleOne(arena_alloc, puzzle_input_path);
            const puzzle_two_result = try everybody_codes.dayOnePuzzleTwo(arena_alloc, puzzle_input_path);
            std.debug.print("Puzzle one: {d}\n", .{puzzle_one_result});
            std.debug.print("Puzzle two: {d}\n", .{puzzle_two_result});
        },
        else => {
            std.debug.print("Not a valid day.\n", .{});
            std.process.exit(1);
        },
    }
}
