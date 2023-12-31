const std = @import("std");
const util = @import("util.zig");

const allocator = util.gpa.allocator();
const print = util.print;

const content = @embedFile("input.txt");

pub fn main() !void {
    defer util.cleanUp();

    var total: i32 = 0;
    var it_lines = std.mem.tokenizeAny(u8, content, "\n\r");
    while (it_lines.next()) |line| {
        var numTokens = std.mem.tokenize(u8, line, " ");
        var numbers = std.ArrayList(i32).init(allocator);
        defer numbers.deinit();

        while (numTokens.next()) |token| {
            const n = try std.fmt.parseInt(i32, token, 10);
            try numbers.append(n);
        }
        print("{any} \n", .{numbers.items});

        // const x = part1(numbers.items);
        const x = part2(numbers.items);
        total += x;
    }

    print("result: {d}\n", .{total});
}

fn part1(lst: []i32) i32 {
    return findNext(lst);
}

fn part2(lst: []i32) i32 {
    std.mem.reverse(i32, lst);
    return findNext(lst);
}

fn findNext(lst: []i32) i32 {
    if (std.mem.allEqual(i32, lst, lst[0])) return lst[0];

    var subList = std.ArrayList(i32).initCapacity(allocator, lst.len - 1) catch unreachable;
    defer subList.deinit();

    var i: usize = 0;
    while (i < lst.len - 1) : (i += 1)
        subList.appendAssumeCapacity(lst[i + 1] - lst[i]);

    return findNext(subList.items) + lst[lst.len - 1];
}

test "findNext" {
    // zeros
    var x = [_]i32{ 0, 0, 0, 0, 0, 0 };
    try std.testing.expectEqual(@as(i32, 0), findNext(x[0..]));

    // constant number
    x = [_]i32{ 2, 2, 2, 2, 2, 2 };
    try std.testing.expectEqual(@as(i32, 2), findNext(x[0..]));

    // constant diff
    x = [_]i32{ 0, 3, 6, 9, 12, 15 };
    try std.testing.expectEqual(@as(i32, 18), findNext(x[0..]));

    // negative numbers
    x = [_]i32{ -6, -3, 0, 3, 6, 9 };
    try std.testing.expectEqual(@as(i32, 12), findNext(x[0..]));

    // static growth
    x = [_]i32{ 1, 3, 6, 10, 15, 21 };
    try std.testing.expectEqual(@as(i32, 28), findNext(x[0..]));

    // random growth
    x = [_]i32{ 10, 13, 16, 21, 30, 45 };
    try std.testing.expectEqual(@as(i32, 68), findNext(x[0..]));
}
