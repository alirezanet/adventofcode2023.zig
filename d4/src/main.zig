const std = @import("std");
const print = std.debug.print;

const FileName = "input.txt";

var dic: std.AutoArrayHashMap(usize, u32) = undefined;
var inlineTotal: u32 = 0;

pub fn main() !void {
    const file = try std.fs.cwd().openFile(FileName, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    const buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(buf);

    dic = std.AutoArrayHashMap(usize, u32).init(allocator);
    defer dic.deinit();

    // const total = part1(buf);
    const total = part2(buf);
    print("total is: {d}\n", .{total});
}

fn part2(buf: []u8) u32 {
    var total: u32 = 0;
    var index: usize = 0;
    var it_lines = std.mem.splitSequence(u8, buf, "\n");
    while (it_lines.next()) |line| {
        defer index += 1;
        const c = FindMatchCards(line);
        dic.put(index, c) catch print("{d}", .{c});
        total += 1;
    }
    total += getTotalWinningCards(0, index, 0, true);
    return total;
}

fn getTotalWinningCards(start: usize, end: usize, nestingLvl: u32, logging: bool) u32 {
    var total: u32 = 0;
    for (start..end) |i| {
        if (logging) print("Processing Game {d}\n", .{i + 1});

        const x: u32 = dic.get(i).?;
        if (x > 0) {
            total += getTotalWinningCards(i + 1, i + 1 + x, nestingLvl + 1, false);
        }

        total += x;
    }
    return total;
}

fn part1(buf: []u8) u32 {
    var it_lines = std.mem.splitSequence(u8, buf, "\n");

    var total: u32 = 0;
    while (it_lines.next()) |line|
        total += std.math.pow(u32, 2, FindMatchCards(line)) / 2;

    return total;
}

fn FindMatchCards(card: []const u8) u32 {
    var it_section = std.mem.splitAny(u8, std.mem.trim(u8, card, "\n"), ":|");
    _ = it_section.next() orelse unreachable;
    const winingNumbers: []const u8 = std.mem.trim(u8, it_section.next().?, " ");
    const myNumbers: []const u8 = std.mem.trim(u8, it_section.next().?, " ");

    var it_winningNumbers = std.mem.splitAny(u8, winingNumbers, " ");
    var it_myNumbers = std.mem.splitAny(u8, myNumbers, " ");

    var cardMatches: u32 = 0;
    while (it_winningNumbers.next()) |winningNumStr| {
        const wNumber = std.fmt.parseUnsigned(u8, winningNumStr, 10) catch continue;
        while (it_myNumbers.next()) |myNumStr| {
            const myNumber = std.fmt.parseUnsigned(u8, myNumStr, 10) catch continue;

            if (wNumber == myNumber) {
                cardMatches += 1;
            }
        }
        it_myNumbers.reset();
    }
    print("{d} <- {s}\n", .{ cardMatches, card });
    return cardMatches;
}
