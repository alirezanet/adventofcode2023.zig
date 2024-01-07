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

    var map = std.AutoArrayHashMap([3]u8, Route).init(allocator);
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
    }

    // find the starting points
    var sp = std.ArrayList([3]u8).init(allocator);
    defer sp.deinit();

    for (map.keys()) |key| {
        if (key[2] != 'A') continue;
        try sp.append(key);
    }

    var step: usize = 0;
    var nextPoint = sp;
    loop: while (true) inst: for (intructions) |direction| {
        walkToNextPoint(&nextPoint, &map, direction);
        step += 1;

        if (step % 10000 == 0) print("step: {}\n", .{step});

        for (nextPoint.items) |x| if (x[2] != 'Z') continue :inst;
        break :loop;
    };

    print("found in {} steps\n", .{step});
}

pub fn walkToNextPoint(nextPoint: *std.ArrayList([3]u8), map: *std.AutoArrayHashMap([3]u8, Route), direction: u8) void {
    for (0..nextPoint.items.len) |i| {
        const source = map.get(nextPoint.items[i]).?;
        var target: [3]u8 = undefined;
        if (direction == 'L') {
            target = source.left;
        } else {
            target = source.right;
        }
        nextPoint.items[i] = target;
    }
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
