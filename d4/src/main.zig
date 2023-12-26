const std = @import("std");
const print = std.debug.print;

const FileName = "input.txt";

pub fn main() !void {
    const file = try std.fs.cwd().openFile(FileName, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    const buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(buf);

    // const total = part1(buf);
    const total = part2(buf);
    print("total is: {d}\n", .{total});
}

fn part2(buf: []u8) u32 {
    var it_lines = std.mem.splitSequence(u8, buf, "\n");
    var total = getTotalWinningCards(&it_lines, 0, true);
    it_lines.reset(); // count existing cards
    while (it_lines.next()) |_| total += 1;
    return total;
}
var inlineTotal: u32 = 0;

fn getTotalWinningCards(it: *std.mem.SplitIterator(u8, std.mem.DelimiterType.sequence), nestingLvl: u32, logging: bool) u32 {
    var total: u32 = 0;
    while (it.next()) |line| {
        if (logging) print("{s} {d}\n", .{ line, inlineTotal });

        const index = it.index;
        defer it.index = index; // reset the iterator

        var x = FindMatchCards(line);

        total += x;
        while (x > 1) : (x -= 1) {
            total += getTotalWinningCards(it, nestingLvl + 1, false);
            if (total > inlineTotal) {
                inlineTotal = total;
                print("lvl {d} - total:{d} - {s} \n", .{ nestingLvl, inlineTotal, line[0..10] });
            }
        }
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
    // print("{d} <- {s}\n", .{ cardMatches, card });
    return cardMatches;
}
