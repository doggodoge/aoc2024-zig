const std = @import("std");

const PairWithIdx = struct {
    idx: usize,
    a: u32,
    b: u32,
};

pub fn p1(allocator: std.mem.Allocator, file_path: []const u8) !u64 {
    const bytes = try readFile(allocator, file_path);
    defer allocator.free(bytes);

    const mul_pairs = try getMulPairs(allocator, bytes);
    defer allocator.free(mul_pairs);

    var total: u64 = 0;

    for (mul_pairs) |pair| {
        total += pair.a * pair.b;
    }

    return total;
}

pub fn p2(allocator: std.mem.Allocator, file_path: []const u8) !u64 {
    const bytes = try readFile(allocator, file_path);
    defer allocator.free(bytes);

    const mul_pairs = try getMulPairs(allocator, bytes);
    defer allocator.free(mul_pairs);

    const yes_indices = try findAllIndices(allocator, bytes, "do()");
    defer allocator.free(yes_indices);

    const no_indices = try findAllIndices(allocator, bytes, "don't()");
    defer allocator.free(no_indices);

    var total: u64 = 0;

    for (mul_pairs) |pair| {
        var last_yes: usize = 0;
        var last_no: usize = 0;

        for (yes_indices) |yes_idx| {
            if (yes_idx > pair.idx) break;
            last_yes = yes_idx;
        }

        for (no_indices) |no_idx| {
            if (no_idx > pair.idx) break;
            last_no = no_idx;
        }

        var should_skip = last_no > last_yes;
        if (last_yes == 0 and last_no == 0) should_skip = false;

        if (should_skip) continue;
        total += pair.a * pair.b;
    }

    return total;
}

fn getMulPairs(allocator: std.mem.Allocator, bytes: []const u8) ![]PairWithIdx {
    const indices = try findAllIndices(allocator, bytes, "mul(");
    defer allocator.free(indices);

    var mul_pairs = std.ArrayList(PairWithIdx){};
    defer mul_pairs.deinit(allocator);

    for (indices) |i| {
        const pair = parseMul(i, bytes) catch continue;
        try mul_pairs.append(allocator, pair);
    }

    return mul_pairs.toOwnedSlice(allocator);
}

fn parseMul(start: usize, line: []const u8) !PairWithIdx {
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
        .idx = start,
        .a = a,
        .b = b,
    };
}

fn findAllIndices(allocator: std.mem.Allocator, haystack: []const u8, needle: []const u8) ![]const usize {
    var mul_indices = std.ArrayList(usize){};
    var current_index: usize = 0;

    while (true) {
        const item_index = std.mem.indexOfPosLinear(u8, haystack, current_index, needle) orelse break;
        current_index = item_index + 1;
        try mul_indices.append(allocator, item_index);
    }

    return try mul_indices.toOwnedSlice(allocator);
}

fn readFile(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    return try std.fs.cwd().readFileAlloc(allocator, file_path, 50 * 1024 * 1024);
}
