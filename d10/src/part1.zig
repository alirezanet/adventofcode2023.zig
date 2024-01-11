const std = @import("std");
const util = @import("util.zig");

const allocator = util.gpa.allocator();
const print = util.print;

const content = @embedFile("input.txt");

pub fn main() !void {
    defer util.cleanUp();

    var data = std.ArrayList(u8).init(allocator);
    defer data.deinit();

    // convert string to array
    var it_lines = std.mem.tokenizeAny(u8, content, "\n\r");
    var r: usize = 0;
    while (it_lines.next()) |line| {
        if (r == 0) r = line.len;
        for (line) |c| try data.append(c);
    }

    // find the starting point
    var start: usize = 0;
    for (0.., data.items) |i, c| {
        if (c == 'S') {
            start = i;
            break;
        }
    }

    // move to the end of loop
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

        dir = next > i;
        jumped = @max(next, i) - @min(next, i) > 1;
        i = next;
        step += 1;
    }

    // part 1
    print("farthest: {}\n", .{step / 2});
}

fn findS(data: []u8, startIdx: usize, r: usize) u8 {
    const north: u8 = if (startIdx > r) data[startIdx - r] else '.';
    const south: u8 = if (data.len - r > startIdx) data[startIdx + r] else '.';
    const east: u8 = if (@max(r, startIdx + 1) % @min(r, startIdx + 1) == 0) '.' else data[startIdx + 1];
    const west: u8 = if (@max(r, startIdx + 1) % @min(r, startIdx + 1) == 1) '.' else data[startIdx + 1];

    // TODO: add all cases
    if ((east == '-' or east == 'J') and south == '|') return 'F';
    if (west == '-' and north == '|') return 'J';
    if (west == '-' and south == '|') return '7';
    if (east == '-' and north == '|') return 'L';
    if (west == '-' and east == '-') return '-';
    if (south == 'J' and north == '7') return '|';
    if (south == '|' and north == '|') return '|';

    std.debug.print("N:{c} S:{c} E:{c} W:{c}\n", .{ north, south, east, west });
    unreachable;
}
