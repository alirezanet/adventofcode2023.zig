const std = @import("std");
const util = @import("util.zig");

const allocator = util.gpa.allocator();
const print = util.print;

const content = @embedFile("test2.txt");

pub fn main() !void {
    defer util.cleanUp();

    var data = std.ArrayList(u8).init(allocator);
    defer data.deinit();

    // convert string to array
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

    // find path
    var area = std.AutoArrayHashMap(usize, u8).init(allocator);
    defer area.deinit();
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
    }

    var tiles = std.AutoArrayHashMap(usize, void).init(allocator);
    defer tiles.deinit();

    // find possible tiles
    for (0..data.items.len) |i| {
        if (!area.contains(i)) data.items[i] = '.' else continue;
        const cRow: usize = getRow(i, r);

        var j = i + 1;
        var pairCross: usize = 0;
        var cross: usize = 0;
        while (j < data.items.len and getRow(j, r) == cRow) : (j += 1) {
            // var up: usize = 0;
            // var down: usize = 0;
            switch (data.items[j]) {
                '|' => cross += 1,
                '.', '-' => continue,
                else => {},
            }
        }
        if (cross == 0) continue else {
            pairCross = cross;
            cross = 0;
        }

        j = if (i == 0) i else i - 1;
        while (j > 0 and getRow(j, r) == cRow) : (j -= 1) {
            switch (data.items[j]) {
                '|' => cross += 1,
                '.', '-' => continue,
                else => {},
            }
        }

        if (cross == 0 or (pairCross + cross) % 2 != 0) continue else {
            pairCross = 0;
            cross = 0;
        }

        j = i + r;
        while (j < data.items.len) : (j += r) {
            switch (data.items[j]) {
                '-' => cross += 1,
                else => {},
            }
        }
        if (cross == 0) continue else {
            pairCross = cross;
            cross = 0;
        }

        j = if (i > r) i - r else r;
        while (j > r) : (j -= r) {
            switch (data.items[j]) {
                '-' => cross += 1,
                else => {},
            }
        }

        if (cross == 0 or (pairCross + cross) % 2 != 0) continue;
        try tiles.put(i, {});
    }

    // print
    for (0.., data.items) |i, c| {
        if (i % r == 0 or i == r) print("\n", .{});
        if (tiles.contains(i))
            print("{c}", .{'I'})
        else if (area.contains(i))
            print("{c}", .{area.get(i).?})
        else
            print("{c}", .{c});
    }

    print("\ntotal tiles: {}\n", .{tiles.keys().len});
}

fn getRow(index: usize, rowLength: usize) usize {
    if (index == rowLength) return 0;
    return index / rowLength;
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
