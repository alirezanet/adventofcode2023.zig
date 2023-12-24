const std = @import("std");
const parser = @import("parser.zig");
const print = std.debug.print;

const FileName = "input.txt";
const MaxRed = 12;
const MaxGreen = 13;
const MaxBlue = 14;

pub fn main() !void {
    // create global allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    const games: []parser.Game = try parser.parseGames(FileName, allocator);
    defer allocator.free(games);

    var total: u32 = 0;
    for (games) |game| {
        const isPossible = isGameItPossible(game);
        print("game {d}: {}\n", .{ game.number, isPossible });
        if (isPossible) {
            total += game.number;
        }
    }

    print("total is {d}\n", .{total});
}

fn isGameItPossible(game: parser.Game) bool {
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
