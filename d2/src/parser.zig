const std = @import("std");
const print = std.debug.print;

pub fn parseGames(fileName: []const u8, allocator: std.mem.Allocator) ![]Game {
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    var it = std.mem.splitSequence(u8, content, "\n");
    var result = std.ArrayList(Game).init(allocator);

    while (it.next()) |line| {
        const trimmedLine = std.mem.trim(u8, line, "\r");
        if (trimmedLine.len < 4) continue;
        const game = Game.Create(trimmedLine, allocator);
        result.append(game) catch unreachable;
    }

    return result.items;
}

pub const CubeType = enum { green, blue, red };
pub const Cube = struct {
    cubeType: CubeType,
    count: u8,

    pub fn Create(magicStr: []const u8) Cube {
        const trimmedStr = std.mem.trim(u8, magicStr, " ");
        var it = std.mem.splitSequence(u8, trimmedStr, " ");

        const count = std.fmt.parseInt(u8, it.next().?, 10) catch unreachable;
        const cubeType = std.meta.stringToEnum(CubeType, it.next().?) orelse unreachable;

        return Cube{ .count = count, .cubeType = cubeType };
    }
};

pub const CubeSet = struct {
    cubes: []Cube,

    pub fn Create(magicStr: []const u8, allocator: std.mem.Allocator) CubeSet {
        var it = std.mem.splitSequence(u8, magicStr, ",");

        var cubes = std.ArrayList(Cube).init(allocator);

        while (it.next()) |cube_str| {
            const cube = Cube.Create(cube_str);
            cubes.append(cube) catch unreachable;
        }

        return CubeSet{ .cubes = cubes.items };
    }
};

pub const Game = struct {
    number: u8,
    cubeset: []CubeSet,

    pub fn Create(magicStr: []const u8, allocator: std.mem.Allocator) Game {

        // split game and cubes
        var it = std.mem.splitSequence(u8, magicStr, ":");
        const game = it.next().?;
        const cubes = it.next().?;

        // parse game number
        var it_game = std.mem.splitBackwardsSequence(u8, game, " ");
        const number = std.fmt.parseInt(u8, it_game.next().?, 10) catch unreachable;

        // parse cubes
        var it_cubes = std.mem.splitSequence(u8, cubes, ";");
        var cubesets = std.ArrayList(CubeSet).init(allocator);

        while (it_cubes.next()) |cubeset_magic_str| {
            const cubeset = CubeSet.Create(cubeset_magic_str, allocator);
            cubesets.append(cubeset) catch unreachable;
        }

        return Game{ .number = number, .cubeset = cubesets.items };
    }
};
