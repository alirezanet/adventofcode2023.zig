const std = @import("std");
const util = @import("util.zig");

const allocator = util.gpa.allocator();
const print = util.print;

const content = @embedFile("input.txt");

// part 1:
// const blackholeSize: usize = 2 - 1; // 2x

// part 2:
const blackholeSize: usize = 1000000 - 1; // 1000000x

pub fn main() !void {
    defer util.cleanUp();
    var universe = try Universe.init();
    defer universe.deinit();

    var galaxies = try getGalaxyCordinates(&universe.space);
    defer galaxies.deinit();

    var sum: usize = 0;
    for (0.., galaxies.items) |si, source| {
        for (galaxies.items[si..]) |destination|
            sum += getDistance(source, destination, &universe);
    }

    print("part2: {d}\n", .{sum});
}

fn getDistance(source: Cordinate, destication: Cordinate, universe: *Universe) usize {
    var h_distance = @max(source.col, destication.col) - @min(source.col, destication.col);
    for (universe.horizantalBalckhole.items) |x| {
        if (@min(source.col, destication.col) < x and x < @max(source.col, destication.col))
            h_distance += blackholeSize;
    }

    var v_distance = @max(source.row, destication.row) - @min(source.row, destication.row);
    for (universe.verticalBlackholes.items) |x| {
        if (@min(source.row, destication.row) < x and x < @max(source.row, destication.row))
            v_distance += blackholeSize;
    }

    return h_distance + v_distance;
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

const Cordinate = struct { row: usize, col: usize };
const Universe = struct {
    space: std.ArrayList(std.ArrayList(u1)),
    verticalBlackholes: std.ArrayList(usize),
    horizantalBalckhole: std.ArrayList(usize),

    pub fn init() !Universe {
        var space = std.ArrayList(std.ArrayList(u1)).init(allocator);
        var v_blackholes = std.ArrayList(usize).init(allocator);
        var h_blackholes = std.ArrayList(usize).init(allocator);

        var it_line = std.mem.tokenizeAny(u8, content, "\n\r");
        {
            var row: usize = 0;
            while (it_line.next()) |line| {
                defer row += 1;
                var columns = try std.ArrayList(u1).initCapacity(allocator, line.len);

                for (line) |c| {
                    const value: u1 = if (c == '.') 0 else 1;
                    columns.appendAssumeCapacity(value);
                }
                try space.append(columns);

                // vertical blackholes (expansion)
                if (std.mem.allEqual(u1, columns.items, 0)) {
                    try v_blackholes.append(row);
                }
            }
        }

        // horizantal blackholes (expansion)
        for (0..space.items[0].items.len) |col| {
            var hasGalaxy = false;

            for (0..space.items.len) |row| {
                if (space.items[row].items[col] == 1) {
                    hasGalaxy = true;
                    break;
                }
            }

            if (!hasGalaxy)
                try h_blackholes.append(col);
        }

        return Universe{
            .space = space,
            .verticalBlackholes = v_blackholes,
            .horizantalBalckhole = h_blackholes,
        };
    }
    pub fn deinit(this: *Universe) void {
        this.verticalBlackholes.deinit();
        this.horizantalBalckhole.deinit();
        for (this.space.items) |col| col.deinit();
        this.space.deinit();
    }
};
