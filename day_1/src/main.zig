const std = @import("std");
const root = @import("root.zig");

fn lessThan(context: void, a: i64, b: i64) std.math.Order {
    _ = context;
    return std.math.order(a, b);
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const v = root.add(1, 2);
    std.debug.print("{}\n", .{v});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const leak_check = gpa.deinit();
        if (leak_check == std.heap.Check.leak)
            @panic("Leak Detected");
    }

    const priority_queue = std.PriorityDequeue(i64, void, lessThan);
    var column_1_priority_queue = priority_queue.init(allocator, {});
    defer column_1_priority_queue.deinit();
    var column_2_priority_queue = priority_queue.init(allocator, {});
    defer column_2_priority_queue.deinit();

    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.splitSequence(u8, line, "   ");
        const number_1_opt = split.next();
        const number_2_opt = split.next();
        if (number_1_opt != null and number_2_opt != null) {
            const number_1 = try std.fmt.parseInt(i64, number_1_opt.?, 10);
            try column_1_priority_queue.add(number_1);
            const number_2 = try std.fmt.parseInt(i64, number_2_opt.?, 10);
            try column_2_priority_queue.add(number_2);
        }
    }
    var total_distance: u64 = 0;
    while (column_1_priority_queue.count() != 0) {
        const number_1 = column_1_priority_queue.removeMin();
        const number_2 = column_2_priority_queue.removeMin();
        total_distance += @abs(number_2 - number_1);
    }
    std.debug.print("Total Distance {}", .{total_distance});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
