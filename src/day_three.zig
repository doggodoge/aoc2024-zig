const std = @import("std");

const Pair = struct {
    a: u32,
    b: u32,
};

pub fn p1(allocator: std.mem.Allocator, file_path: []const u8) !u64 {
    const bytes = try readFile(allocator, file_path);
    var mul_pairs = std.ArrayList(Pair){};
    const indices = try findAllMulIndices(allocator, bytes);

    for (indices) |i| {
        const pair = parseMul(i, bytes) catch continue;
        try mul_pairs.append(allocator, pair);
    }

    var total: u64 = 0;

    for (mul_pairs.items) |pair| {
        total += pair.a * pair.b;
    }

    return total;
}

fn parseMul(start: usize, line: []const u8) !Pair {
    const offset_past_first_opening_bracket = 4;
    const start_of_numbers = start + offset_past_first_opening_bracket;
    const end = std.mem.indexOfScalarPos(u8, line, start, ')').?;
    const mul = line[start_of_numbers..end];

    var split_iter = std.mem.splitScalar(u8, mul, ',');
    const a_str = split_iter.next() orelse return error.ParseMulFailed;
    const b_str = split_iter.next() orelse return error.ParseMulFailed;

    const a = try std.fmt.parseInt(u32, a_str, 10);
    const b = try std.fmt.parseInt(u32, b_str, 10);

    return .{
        .a = a,
        .b = b,
    };
}

fn findAllMulIndices(allocator: std.mem.Allocator, bytes: []const u8) ![]const usize {
    var mul_indices = std.ArrayList(usize){};
    var current_index: usize = 0;

    while (true) {
        const item_index = std.mem.indexOfPosLinear(u8, bytes, current_index, "mul(") orelse break;
        current_index = item_index + 1;
        try mul_indices.append(allocator, item_index);
    }

    return try mul_indices.toOwnedSlice(allocator);
}

fn readFile(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    return try std.fs.cwd().readFileAlloc(allocator, file_path, 50 * 1024 * 1024);
}
