const std = @import("std");

pub fn p1(allocator: std.mem.Allocator, file_path: []const u8) !u64 {
    const puzzle_input = try parseFile(allocator, file_path);
    const total_reports = puzzle_input.len;

    var total_unsafe_reports: u64 = 0;

    for (puzzle_input) |report| {
        const problems = doesAscOrDescChainBreak(report) + isBadDistance(report);

        if (problems > 0) {
            total_unsafe_reports += 1;
        }
    }

    return total_reports - total_unsafe_reports;
}

pub fn p2(allocator: std.mem.Allocator, file_path: []const u8) !u64 {
    const puzzle_input = try parseFile(allocator, file_path);
    const total_reports = puzzle_input.len;

    var total_unsafe_reports: u64 = 0;

    for (puzzle_input) |report| {
        const problems = doesAscOrDescChainBreak(report) + isBadDistance(report);

        if (problems > 1) {
            total_unsafe_reports += 1;
        }
    }

    return total_reports - total_unsafe_reports;
}

fn doesAscOrDescChainBreak(report: []const u32) u32 {
    var problems: u32 = 0;

    var window = std.mem.window(u32, report, 2, 1);

    const first_window = window.next().?;
    const is_ascending = first_window[0] < first_window[1];

    while (window.next()) |win| {
        if ((is_ascending and win[0] > win[1]) or (!is_ascending and win[0] < win[1])) {
            problems += 1;
        }
    }

    return problems;
}

fn isBadDistance(report: []const u32) u32 {
    var problems: u32 = 0;
    var window = std.mem.window(u32, report, 2, 1);

    while (window.next()) |win| {
        const left = @as(i64, win[0]);
        const right = @as(i64, win[1]);
        const distance = @abs(left - right);

        if (distance < 1 or distance > 3) {
            problems += 1;
        }
    }

    return problems;
}

fn parseFile(allocator: std.mem.Allocator, file_path: []const u8) ![][]u32 {
    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();
    const file_size = try file.getEndPos();

    const mapped_memory = try std.posix.mmap(null, file_size, std.posix.PROT.READ, .{ .TYPE = .SHARED }, file.handle, 0);
    defer std.posix.munmap(mapped_memory);

    var lines = std.mem.splitScalar(u8, mapped_memory, '\n');

    var nums = std.ArrayList([]u32){};

    while (lines.next()) |line| {
        var numbers = std.mem.splitScalar(u8, line, ' ');
        var inner_nums = std.ArrayList(u32){};

        while (numbers.next()) |number| {
            const parsed_number = try std.fmt.parseInt(u32, number, 10);
            try inner_nums.append(allocator, parsed_number);
        }

        try nums.append(allocator, try inner_nums.toOwnedSlice(allocator));
    }

    return try nums.toOwnedSlice(allocator);
}
