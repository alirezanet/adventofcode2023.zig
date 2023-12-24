const std = @import("std");
const parser = @import("parser.zig");
const print = std.debug.print;

const FileName = "input.txt";

pub fn main() !void {
    // create global allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    const games: []parser.Game = try parser.parseGames(FileName, allocator);
    defer allocator.free(games);

    // part1(games);
    part2(games);
}

fn part2(games: []parser.Game) void {
    var total: u32 = 0;
    for (games) |game| {
        var red: u32 = 0;
        var green: u32 = 0;
        var blue: u32 = 0;
        for (game.cubeset) |set| {
            for (set.cubes) |cube| {
                if (cube.cubeType == .red and cube.count > red) {
                    red = cube.count;
                } else if (cube.cubeType == .green and cube.count > green) {
                    green = cube.count;
                } else if (cube.cubeType == .blue and cube.count > blue) {
                    blue = cube.count;
                }
            }
        }

        total += red * green * blue;
        // print("power game {d}: {d}\n", .{ game.number, red * green * blue });
    }

    print("total is: {d}\n", .{total});
}

fn part1(games: []parser.Game) !void {
    var total: u32 = 0;
    for (games) |game| {
        const isPossible = isPossibleGame(game);
        print("game {d}: {}\n", .{ game.number, isPossible });
        if (isPossible) {
            total += game.number;
        }
    }

    print("total is {d}\n", .{total});
}

fn isPossibleGame(game: parser.Game) bool {
    const MaxRed = 12;
    const MaxGreen = 13;
    const MaxBlue = 14;
    for (game.cubeset) |set| {
        for (set.cubes) |cube| {
            const isPossible = switch (cube.cubeType) {
                .red => cube.count <= MaxRed,
                .green => cube.count <= MaxGreen,
                .blue => cube.count <= MaxBlue,
            };
            if (!isPossible) return false;
        }
    }
    return true;
}
