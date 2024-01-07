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

    var totalSteps: usize = 0;
    for (map.keys()) |key| { // from Start to first Z
        if (key[2] != 'A') continue;
        var nextPoint = key;

        var step: usize = 0;
        searching: while (true) for (intructions) |i| {
            step += 1;
            const target = map.get(nextPoint).?;
            if (i == 'L') {
                nextPoint = target.left;
            } else {
                nextPoint = target.right;
            }
            if (nextPoint[2] == 'Z') break :searching;
        };
        print("for {s} - {s} found {d} steps\n", .{ key, nextPoint, step });
        totalSteps = lcm(totalSteps, step);
    }

    print("found in {} steps\n", .{totalSteps});
}

// LCM => Least common multiple
// GCD => Greatest common divisor (other names: GCF HCF)
pub fn lcm(a: anytype, b: anytype) @TypeOf(a, b) {
    if (a == 0) return b;
    if (b == 0) return a;
    return (a * b) / std.math.gcd(a, b);
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
