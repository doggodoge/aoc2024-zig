const std = @import("std");

// The iterator approach is verbose and honestly not the best way to do things.
// New idea:
// 1. From each position, reach out 4 chars in every direction.
// 2. Check for XMAS, and SAMX.
// 3. ???
// 4. Profit

const HorizontalIterator = struct {
    grid: [][]const u8,
    row: usize,
    col: usize,

    pub fn init(grid: [][]const u8) HorizontalIterator {
        return .{
            .grid = grid,
            .row = 0,
            .col = 0,
        };
    }

    pub fn next(self: *HorizontalIterator) ?u8 {
        if (self.row >= self.grid.len) return null;

        if (self.col >= self.grid[self.row].len) {
            self.row += 1;
            self.col = 0;
            if (self.row >= self.grid.len) return null;
        }

        const value = self.grid[self.row][self.col];
        self.col += 1;

        return value;
    }
};

pub fn p1(allocator: std.mem.Allocator, file_path: []const u8) !u64 {
    const result = try parseFile(allocator, file_path);
    defer allocator.free(result.grid);
    defer allocator.free(result.buffer);

    std.debug.print("{any}\n", .{result.grid});

    return 0;
}

const ParseResult = struct {
    grid: [][]const u8,
    buffer: []const u8,
};

fn parseFile(allocator: std.mem.Allocator, file_path: []const u8) !ParseResult {
    const max_bytes = 1024 * 1024 * 500;
    const bytes = try std.fs.cwd().readFileAlloc(allocator, file_path, max_bytes);
    errdefer allocator.free(bytes);

    var grid = std.ArrayList([]const u8){};
    errdefer grid.deinit(allocator);

    var rows = std.mem.splitScalar(u8, bytes, '\n');

    while (rows.next()) |row| {
        try grid.append(allocator, row);
    }

    return .{
        .grid = try grid.toOwnedSlice(allocator),
        .buffer = bytes,
    };
}
