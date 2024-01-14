const std = @import("std");
const util = @import("util.zig");

const allocator = util.gpa.allocator();
const print = util.print;

const content = @embedFile("input.txt");

pub fn main() !void {
    defer util.cleanUp();

    var data = std.ArrayList(u8).init(allocator);
    defer data.deinit();

    // parse
    var it_lines = std.mem.tokenizeAny(u8, content, "\n\r");
    var r: usize = 0;
    var start: usize = 0;
    var idx: usize = 0;
    while (it_lines.next()) |line| {
        if (r == 0) r = line.len;
        for (line) |c| {
            if (c == 'S') start = idx;
            try data.append(c);
            idx += 1;
        }
    }

    var area = std.AutoArrayHashMap(usize, u8).init(allocator);
    defer area.deinit();

    // part 1
    {
        var i: usize = start;
        var jumped = if (data.items[i] != '-') true else false;
        var dir = true;
        var step: usize = 0;
        var firstTurn = true;
        while (true) {
            var c = data.items[i];
            if (firstTurn) {
                c = findS(data.items, start, r);
                firstTurn = false;
            }

            const next: usize = switch (c) {
                '-' => if (dir) i + 1 else i - 1,
                '|' => if (dir) i + r else i - r,
                '7' => if (jumped) i - 1 else i + r,
                'F' => if (jumped) i + 1 else i + r,
                'J' => if (jumped) i - 1 else i - r,
                'L' => if (jumped) i + 1 else i - r,
                'S' => break,
                else => {
                    std.debug.print("\nC:{c}  Dir:{}\n", .{ c, dir });
                    unreachable;
                },
            };

            try area.put(i, c);

            dir = next > i;
            jumped = @max(next, i) - @min(next, i) > 1;

            i = next;
            step += 1;
        }

        print("part 1 - farthest: {}\n", .{step / 2});
    }

    // part 2
    var tiles: usize = 0;
    for (0..data.items.len) |i| {
        var c: u8 = '.';
        defer print("{c}", .{c});
        defer if (i % r == 0 or i == r) print("\n", .{});

        if (area.contains(i)) {
            // c = data.items[i]; //// this will print the maze
            continue;
        }

        var cross: usize = 0;
        var dir: ?bool = null;

        var j = i + r;
        while (j < data.items.len) : (j += r) {
            if (!area.contains(j)) continue;
            switch (data.items[j]) {
                '-' => cross += 1,
                '7', 'J' => {
                    if (dir == null)
                        dir = true
                    else if (dir.?)
                        dir = null
                    else {
                        cross += 1;
                        dir = null;
                    }
                },
                'L', 'F' => {
                    if (dir == null)
                        dir = false
                    else if (!dir.?)
                        dir = null
                    else {
                        cross += 1;
                        dir = null;
                    }
                },
                else => {},
            }
        }
        if (cross == 0 or cross % 2 == 0) continue;
        tiles += 1;
        c = 'I';
    }

    print("\npart 2 - total tiles enclosed by the loop: {}\n", .{tiles});
}

fn findS(data: []u8, startIdx: usize, r: usize) u8 {
    const north: u8 = if (startIdx > r) data[startIdx - r] else '.';
    const south: u8 = if (data.len - r > startIdx) data[startIdx + r] else '.';
    const east: u8 = if (@max(r, startIdx + 1) % @min(r, startIdx + 1) == 0) '.' else data[startIdx + 1];
    const west: u8 = if (@max(r, startIdx + 1) % @min(r, startIdx + 1) == 1) '.' else data[startIdx + 1];

    if ((east == '-' or east == 'J' or east == '7') and (south == '|' or south == 'J')) return 'F';
    if (west == '-' and north == '|') return 'J';
    if ((west == '-' or west == 'F') and south == '|') return '7';
    if (east == '-' and north == '|') return 'L';
    if (west == '-' and east == '-') return '-';
    if (south == 'J' and north == '7') return '|';
    if (south == '|' and north == '|') return '|';

    std.debug.print("N:{c} S:{c} E:{c} W:{c}\n", .{ north, south, east, west });
    unreachable;
}
