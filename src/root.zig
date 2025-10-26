const std = @import("std");

// Maybe the lists are only off by a small amount! To find out, pair up the numbers
// and measure how far apart they are. Pair up the smallest number in the left
// list with the smallest number in the right list, then the second-smallest
// left number with the second-smallest right number, and so on.

// Within each pair, figure out how far apart the two numbers are; you'll need
// to add up all of those distances. For example, if you pair up a 3 from the
// left list with a 7 from the right list, the distance apart is 4; if you pair
// up a 9 with a 3, the distance apart is 6.

const Pair = struct {
    left: i32,
    right: i32,
};

pub fn dayOnePuzzleOne(allocator: std.mem.Allocator, file_path: []const u8) !u32 {
    var pairs = try parseFile(allocator, file_path);
    defer pairs.deinit(allocator);

    std.mem.sort(i32, pairs.items(.left), {}, std.sort.asc(i32));
    std.mem.sort(i32, pairs.items(.right), {}, std.sort.asc(i32));

    const left_items: []const i32 = pairs.items(.left);
    const right_items: []const i32 = pairs.items(.right);

    var total_distance: u32 = 0;
    for (0..pairs.len) |i| {
        const left = left_items[i];
        const right = right_items[i];

        total_distance += @abs(left - right);
    }

    return total_distance;
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
