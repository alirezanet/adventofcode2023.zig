const std = @import("std");
const print = std.debug.print;

const FileName = "input.txt";

pub fn main() !void {
    const file = try std.fs.cwd().openFile(FileName, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buf = try file.readToEndAlloc(allocator, 512 * 512);
    defer allocator.free(buf);

    var it_lines = std.mem.splitSequence(u8, buf, "\n");

    var list = std.ArrayList(EnginePart).init(allocator);
    defer list.deinit();

    var ln: usize = 0;
    while (it_lines.next()) |line| {
        defer ln += 1;

        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            const c = line[i];

            // ignore empty space
            if (c == '.' or std.ascii.isWhitespace(c)) {
                continue;
            }

            // read digits
            if (std.ascii.isDigit(c)) {
                const startPos = i;

                while (i < line.len and std.ascii.isDigit(line[i])) : (i += 1) {}

                const part = EnginePart{ .lineNumber = ln, .startPos = startPos, .endPos = i, .partType = PartType.number, .value = line[startPos..i] };
                try list.append(part);
                i -= 1;
                continue;
            }

            // read symbol
            const part = EnginePart{ .lineNumber = ln, .startPos = i, .endPos = i + 1, .partType = PartType.symbol, .value = line[i .. i + 1] };
            try list.append(part);
        }
    }

    // try part1(list);
    try part2(list);
}

fn part2(list: std.ArrayList(EnginePart)) !void {
    var total: u32 = 0;

    itemLoop: for (list.items) |item| {
        var ratio: u32 = 0;
        var neighbourCounter: u8 = 0;
        if (item.partType == PartType.symbol and '*' == item.value[0]) {
            for (list.items) |neighbour| {
                neighbourPosition: for (neighbour.startPos..neighbour.endPos) |neighbourPos| {
                    const pos: i32 = @intCast(item.startPos);
                    const npos: i32 = @intCast(neighbourPos);
                    const lpos: i32 = @intCast(item.lineNumber);
                    const nlpos: i32 = @intCast(neighbour.lineNumber);

                    if (neighbour.partType == PartType.number and
                        (@abs(npos - pos)) <= 1 and
                        (@abs(nlpos - lpos) <= 1))
                    {
                        neighbourCounter += 1;
                        if (neighbourCounter <= 2) {
                            const val = try std.fmt.parseInt(u32, neighbour.value, 10);
                            if (ratio == 0) ratio = val else ratio *= val;
                            if (neighbourCounter == 2) {
                                total += ratio;
                                continue :itemLoop;
                            }
                        }
                        break :neighbourPosition; // we already found this neighbour
                    }
                }
            }
        }
    }

    print("total is: {}\n", .{total});
}

fn part1(list: std.ArrayList(EnginePart)) !void {
    var total: u32 = 0;
    for (list.items) |item| {
        if (item.partType == PartType.number) {
            // check if it has any symbol around
            var hasAdjacentSymbol = false;
            pos: for (item.startPos..item.endPos) |position| {
                for (list.items) |neighbour| {
                    const pos: i32 = @intCast(position);
                    const npos: i32 = @intCast(neighbour.startPos);
                    const lpos: i32 = @intCast(item.lineNumber);
                    const nlpos: i32 = @intCast(neighbour.lineNumber);
                    if (neighbour.partType == PartType.symbol and
                        (@abs(npos - pos)) <= 1 and
                        (@abs(nlpos - lpos) <= 1))
                    {
                        print("{s} = {s}\n", .{ item.value, neighbour.value });
                        hasAdjacentSymbol = true;
                        break :pos;
                    }
                }
            }
            if (hasAdjacentSymbol) {
                total += try std.fmt.parseInt(u32, item.value, 10);
            }
        }
    }

    print("total is: {}\n", .{total});
}

const PartType = enum { number, symbol };
const EnginePart = struct { lineNumber: usize, startPos: usize, endPos: usize, partType: PartType, value: []const u8 };
