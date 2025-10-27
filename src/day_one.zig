const std = @import("std");

const Pair = struct {
    left: i32,
    right: i32,
};

pub fn p1(allocator: std.mem.Allocator, file_path: []const u8) !u64 {
    var pairs = try parseFile(allocator, file_path);
    defer pairs.deinit(allocator);

    std.mem.sort(i32, pairs.items(.left), {}, std.sort.asc(i32));
    std.mem.sort(i32, pairs.items(.right), {}, std.sort.asc(i32));

    const left_items: []const i32 = pairs.items(.left);
    const right_items: []const i32 = pairs.items(.right);

    var total_distance: u64 = 0;
    for (0..pairs.len) |i| {
        const left = left_items[i];
        const right = right_items[i];

        total_distance += @abs(left - right);
    }

    return total_distance;
}

pub fn p2(allocator: std.mem.Allocator, file_path: []const u8) !u64 {
    var pairs = try parseFile(allocator, file_path);
    defer pairs.deinit(allocator);

    std.mem.sort(i32, pairs.items(.left), {}, std.sort.asc(i32));
    std.mem.sort(i32, pairs.items(.right), {}, std.sort.asc(i32));

    const left_items: []const i32 = pairs.items(.left);
    const right_items: []const i32 = pairs.items(.right);

    var total_distance: u64 = 0;

    for (left_items) |left| {
        const left_count_in_right = duplicateCount(left, right_items);

        total_distance += @abs(left) * @as(u64, left_count_in_right);
    }

    return total_distance;
}

fn duplicateCount(item_to_count: i32, sorted_items: []const i32) usize {
    var count: usize = 0;

    for (sorted_items) |item| {
        count += @intFromBool(item == item_to_count);
    }

    return count;
}

fn parseFile(allocator: std.mem.Allocator, file_path: []const u8) !std.MultiArrayList(Pair) {
    const LINE_SIZE = 13;

    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const mapped_memory = try std.posix.mmap(null, file_size, std.posix.PROT.READ, .{ .TYPE = .SHARED }, file.handle, 0);
    defer std.posix.munmap(mapped_memory);

    var pairs = std.MultiArrayList(Pair){};

    var i: usize = 0;
    while (i < file_size) : (i += LINE_SIZE + 1) {
        const line = mapped_memory[i .. i + LINE_SIZE];
        const left = line[0..5];
        const right = line[8..LINE_SIZE];

        const left_number = try std.fmt.parseInt(i32, left, 10);
        const right_number = try std.fmt.parseInt(i32, right, 10);

        try pairs.append(allocator, .{
            .left = left_number,
            .right = right_number,
        });
    }

    return pairs;
}
