const std = @import("std");
const util = @import("util.zig");

const allocator = util.gpa.allocator();
const print = util.print;

const content = @embedFile("input.txt");

pub fn main() !void {
    var space = try parseSpace();
    defer cleanUp(&space);

    // for (space.items) |row| {
    //     for (row.items) |col| {
    //         print("{b}", .{col});
    //     }
    //     print("\n", .{});
    // }

    var galaxies = try getGalaxyCordinates(&space);
    defer galaxies.deinit();

    var sum: usize = 0;
    for (0.., galaxies.items) |si, source| {
        for (galaxies.items[si..]) |destination| {
            const distance = getDistance(source, destination);
            sum += distance;
        }
    }
    print("part1: {d}\n", .{sum});
}

fn getDistance(source: Cordinate, destication: Cordinate) usize {
    const x = @max(source.col, destication.col) - @min(source.col, destication.col);
    const y = @max(source.row, destication.row) - @min(source.row, destication.row);
    return x + y;
}

fn parseSpace() !std.ArrayList(std.ArrayList(u1)) {
    var space = std.ArrayList(std.ArrayList(u1)).init(allocator);
    var it_line = std.mem.tokenizeAny(u8, content, "\n\r");

    while (it_line.next()) |line| {
        var columns = try std.ArrayList(u1).initCapacity(allocator, line.len);

        for (line) |c| {
            const value: u1 = if (c == '.') 0 else 1;
            columns.appendAssumeCapacity(value);
        }
        try space.append(columns);

        // vertical cosmic expansion
        if (std.mem.allEqual(u1, columns.items, 0)) {
            try space.append(try columns.clone());
        }
    }

    // horizantal cosmic expansion
    var col: usize = 0;
    while (space.items[0].items.len > col) : (col += 1) {
        var hasGalaxy = false;

        for (0..space.items.len) |row| {
            if (space.items[row].items[col] == 1) {
                hasGalaxy = true;
                break;
            }
        }

        if (!hasGalaxy) {
            for (0..space.items.len) |row| {
                try space.items[row].insert(col, 0);
            }
            col += 1;
        }
    }

    return space;
}

fn getGalaxyCordinates(space: *std.ArrayList(std.ArrayList(u1))) !std.ArrayList(Cordinate) {
    var cordinates = std.ArrayList(Cordinate).init(allocator);
    for (0..space.items.len) |row| {
        for (0..space.items[row].items.len) |col| {
            if (space.items[row].items[col] == 1) {
                try cordinates.append(.{ .col = col, .row = row });
            }
        }
    }
    return cordinates;
}

fn cleanUp(space: *std.ArrayList(std.ArrayList(u1))) void {
    defer util.cleanUp();
    defer space.deinit();
    defer for (space.items) |col| col.deinit();
}

const Cordinate = struct { row: usize, col: usize };
