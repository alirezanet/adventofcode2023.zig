const std = @import("std");
const util = @import("util.zig");

const allocator = util.gpa.allocator();
const print = util.print;

const content = @embedFile("input.txt");

pub fn main() !void {
    defer util.cleanUp();

    var it_lines = std.mem.tokenizeAny(u8, content, "\n\r");
    const intructions = it_lines.next().?;

    print("instructions: {s}\n", .{intructions});

    var map = std.AutoHashMap([3]u8, Route).init(allocator);
    defer map.deinit();

    // parse routes
    while (it_lines.next()) |line| {
        var it_route = std.mem.tokenizeAny(u8, line, " =(,)");
        const route = Route{
            .source = strToArr(it_route.next().?),
            .left = strToArr(it_route.next().?),
            .right = strToArr(it_route.next().?),
        };

        try map.put(route.source, route);
        print("{}\n", .{route});
    }

    const startPoint: [3]u8 = .{'A'} ** 3;
    const endPoint: [3]u8 = .{'Z'} ** 3;

    var nextPoint = startPoint;
    var step: usize = 0;
    searching: while (true) {
        for (intructions) |i| {
            step += 1;
            const target = map.get(nextPoint).?;
            if (std.mem.eql(u8, &target.source, &endPoint)) break :searching;
            if (i == 'L') {
                nextPoint = target.left;
            } else {
                nextPoint = target.right;
            }
        }
    }

    print("found in {} steps\n", .{step - 1});
}

pub fn strToArr(source: []const u8) [3]u8 {
    var key: [3]u8 = undefined;
    std.mem.copyForwards(u8, &key, source);
    return key;
}

const Route = struct {
    source: [3]u8,
    left: [3]u8,
    right: [3]u8,
};
