const std = @import("std");
const print = std.debug.print;

const FileName = "input.txt";

pub fn main() !void {
    const file = try std.fs.cwd().openFile(FileName, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    const buf = try file.readToEndAlloc(allocator, 512 * 512);
    defer allocator.free(buf);

    const maps = readMaps(allocator, buf);

    const result: u32 = part2(buf, maps.items);

    print("\nthe lowest location is: {d}\n", .{result});
}

fn part2(buf: []u8, maps: []Map) u32 {
    var it_lines = std.mem.splitSequence(u8, buf, "\n");
    const seeds = it_lines.next().?;
    var it_seeds = std.mem.splitAny(u8, seeds, ": ");
    var result: u32 = undefined;

    while (it_seeds.next()) |seedStr| {
        const start: u32 = std.fmt.parseInt(u32, seedStr, 10) catch continue;
        const end: u32 = std.fmt.parseInt(u32, it_seeds.next().?, 10) catch continue;
        print("\n-- Seed range: {d}-{d} {s}\n", .{ start, end, "-" ** 40 });

        const location: u32 = GetRangeLocation(GetRange(start, end), maps);
        if (result > location) result = location;
    }

    return result;
}

fn GetRangeLocation(seedRange: Range, mappings: []Map) u32 {
    var result: u32 = undefined;
    var range = seedRange;

    print("\nprocessing {any}\n", .{range});
    var lastProcessedId: usize = undefined;

    for (0.., mappings) |i, map| {
        if (lastProcessedId == map.id) continue;

        const os = @max(range.from, map.range.from);
        const oe = @min(range.to, map.range.to);
        if (os < oe) // check if range is empty
        {
            if (os > range.from) {
                const x = GetRangeLocation(.{ .from = range.from, .to = os }, mappings[i..]);
                if (result > x) result = x;
            }

            if (range.to > oe) {
                const x = GetRangeLocation(.{ .from = oe, .to = range.to }, mappings[i..]);
                if (result > x) result = x;
            }

            const newRange = .{ .from = @abs(os - map.range.from) +% map.destination, .to = @abs(oe - map.range.from) +% map.destination };
            print("\t-> {d}-{d} to {d}-{d}\n", .{ range.from, range.to, newRange.from, newRange.to });
            range = newRange;
            lastProcessedId = map.id;
        }
    }

    // this will find the smallest location
    if (result > range.from) result = range.from;

    return result;
}

pub fn GetRange(start: u32, lenght: u32) Range {
    return .{ .from = start, .to = start +% lenght };
}

fn readMaps(allocator: std.mem.Allocator, buf: []u8) std.ArrayList(Map) {
    var it_lines = std.mem.splitSequence(u8, buf, "\n\n");
    _ = it_lines.next(); // ignore seeds

    var list = std.ArrayList(Map).init(allocator);

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

            const map = Map{ .id = sectionId, .destination = destination, .range = GetRange(source, lenght) };
            list.append(map) catch unreachable;
        }
    }
    return list;
}

const Map = struct {
    id: usize,
    destination: u32,
    range: Range,
};

const Range = struct {
    from: u32,
    to: u32,
};
