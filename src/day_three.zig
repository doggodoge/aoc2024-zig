const std = @import("std");

pub fn p1(allocator: std.mem.Allocator, file_path: []const u8) !void {
    const bytes = try readFile(allocator, file_path);
    const lines_iter = std.mem.splitScalar(u8, bytes, '\n');

    _ = lines_iter;
}

pub fn readFile(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    return try std.fs.cwd().readFileAlloc(allocator, file_path, 50 * 1024 * 1024);
}
