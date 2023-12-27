const std = @import("std");
const print = std.debug.print;

const Map = struct { id: usize, destination: u32, source: u32, lenght: u32 };
const FileName = "input.txt";

pub fn main() !void {
    const file = try std.fs.cwd().openFile(FileName, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    const buf = try file.readToEndAlloc(allocator, 512 * 512);
    defer allocator.free(buf);

    var result: u32 = undefined;

    const maps = readMaps(&allocator, buf);
    const seeds = try readSeeds(&allocator, buf);

    for (seeds) |seed| {
        const location: u32 = getLocation(maps, seed);
        print("Seed {d} = location: {d}\n", .{ seed, location });
        if (result > location)
            result = location;
    }
    print("result is: {d}\n", .{result});
}

fn getLocation(maps: std.ArrayList(Map), seed: u32) u32 {
    var x = seed;
    var lastProcessedId: usize = undefined;
    for (0.., maps.items) |i, map| {
        if (lastProcessedId == map.id) continue;

        const next: ?Map = if (i < maps.items.len - 1) maps.items[i + 1] else null;
        if (x >= map.source and x < map.source +% map.lenght) {
            x = @abs(x - map.source) + map.destination;
            lastProcessedId = map.id; // flag id as proccesed
            // print("{d} {d} \n", .{ map.id, x });
        } else if (next == null or next.?.id != map.id) {
            // print("{d} {d} \n", .{ map.id, x });
        }
    }
    return x;
}

fn readSeeds(allocator: *std.mem.Allocator, buf: []u8) ![]u32 {
    var it_lines = std.mem.splitSequence(u8, buf, "\n");

    const seeds = it_lines.next().?;
    var it_seeds = std.mem.splitAny(u8, seeds, ": ");
    var seedArray = std.ArrayList(u32).init(allocator.*);

    while (it_seeds.next()) |seedStr| {
        const seed: u32 = std.fmt.parseInt(u32, seedStr, 10) catch continue;
        try seedArray.append(seed);
    }

    return seedArray.items;
}

fn readMaps(allocator: *std.mem.Allocator, buf: []u8) std.ArrayList(Map) {
    var it_lines = std.mem.splitSequence(u8, buf, "\n\n");
    _ = it_lines.next(); // ignore seeds

    var list = std.ArrayList(Map).init(allocator.*);

    var sectionId: usize = 0;
    while (it_lines.next()) |section| {
        defer sectionId += 1;
        var it_section = std.mem.tokenizeSequence(u8, section, "\n");
        _ = it_section.next().?; // map name

        while (it_section.next()) |mappings| {
            var it_map = std.mem.tokenizeSequence(u8, mappings, " ");
            const destination = std.fmt.parseInt(u32, it_map.next().?, 10) catch unreachable;
            const source = std.fmt.parseInt(u32, it_map.next().?, 10) catch unreachable;
            const lenght = std.fmt.parseInt(u32, it_map.next().?, 10) catch unreachable;

            const map = Map{ .id = sectionId, .destination = destination, .source = source, .lenght = lenght };
            list.append(map) catch unreachable;
        }
    }

    return list;
}
