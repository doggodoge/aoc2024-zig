const std = @import("std");
const eql = std.mem.eql;
const Allocator = std.mem.Allocator;
const splitScalar = std.mem.splitScalar;

// The iterator approach is verbose and honestly not the best way to do things.
// New idea:
// 1. From each position, reach out 4 chars in every direction.
// 2. Check for XMAS, and SAMX.
// 3. ???
// 4. Profit

pub fn p1(allocator: Allocator, file_path: []const u8) !u64 {
    const result = try parseFile(allocator, file_path);
    defer allocator.free(result.grid);
    defer allocator.free(result.buffer);

    var xmas_count: u64 = 0;

    for (0..result.grid.len) |y| {
        for (0..result.grid[0].len) |x| {
            xmas_count += countXmasInPosition(result.grid, x, y);
        }
    }

    return xmas_count;
}

const Direction = struct {
    x: isize,
    y: isize,
};

fn countXmasInPosition(grid: [][]const u8, x: usize, y: usize) u64 {
    var xmas_count: u64 = 0;

    const directions = [_]Direction{
        .{ .x = 0, .y = 1 }, // north
        .{ .x = 0, .y = -1 }, // south
        .{ .x = 1, .y = 0 }, // east
        .{ .x = -1, .y = 0 }, // west
        .{ .x = 1, .y = 1 }, // north-east
        .{ .x = 1, .y = -1 }, // south-east
        .{ .x = -1, .y = 1 }, // north-west
        .{ .x = -1, .y = -1 }, // south-west
    };

    for (directions) |direction| {
        var current_x: isize = @intCast(x);
        var current_y: isize = @intCast(y);

        var buffer = [_]u8{ 0, 0, 0, 0 };
        var valid = true;

        for (0..4) |i| {
            const is_x_out_of_bounds = current_x < 0 or current_x >= @as(isize, @intCast(grid[0].len));
            const is_y_out_of_bounds = current_y < 0 or current_y >= @as(isize, @intCast(grid.len));
            if (is_x_out_of_bounds or is_y_out_of_bounds) {
                valid = false;
                break;
            }

            buffer[i] = grid[@intCast(current_y)][@intCast(current_x)];
            current_x += direction.x;
            current_y += direction.y;
        }

        if (valid and eql(u8, &buffer, "XMAS")) {
            xmas_count += 1;
        }
    }

    return xmas_count;
}

const ParseResult = struct {
    grid: [][]const u8,
    buffer: []const u8,
};

fn parseFile(allocator: Allocator, file_path: []const u8) !ParseResult {
    const max_bytes = 1024 * 1024 * 500;
    const bytes = try std.fs.cwd().readFileAlloc(allocator, file_path, max_bytes);
    errdefer allocator.free(bytes);

    var grid = std.ArrayList([]const u8){};
    errdefer grid.deinit(allocator);

    var rows = splitScalar(u8, bytes, '\n');

    while (rows.next()) |row| {
        try grid.append(allocator, row);
    }

    return .{
        .grid = try grid.toOwnedSlice(allocator),
        .buffer = bytes,
    };
}
