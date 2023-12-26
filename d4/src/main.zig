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

fn part2(buf: []u8, allocator: *std.mem.Allocator) u32 {
    var it_lines = std.mem.splitSequence(u8, buf, "\n");
    var total: u32 = 0;
    //  getTotalWinningCards(&it_lines);
    var cache = std.AutoHashMap(u32, u32).init(allocator);

    while (it_lines.next()) |line| {
        total += 1;
        const cardId = getCardId(line);
        const cardVal = getTotalWinningCards(null);
        cache.put(cardId, cardVal) catch unreachable;
    }
    it_lines.reset(); // count existing cards
    return total;
}

fn getTotalWinningCards(it: *std.mem.SplitIterator(u8, std.mem.DelimiterType.sequence)) u32 {
    var total: u32 = 0;
    while (it.next()) |line| {
        const index = it.index;
        defer it.index = index; // reset the iterator

        var x = FindMatchCards(line);

        total += x;
        while (x > 1) : (x -= 1)
            total += getTotalWinningCards(it);
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

fn getCardId(card: []const u8) u32 {
    var it_section = std.mem.splitAny(u8, std.mem.trim(u8, card, "\n"), ":");
    const cardName = it_section.next() orelse unreachable;
    var it_cardName = std.mem.splitBackwards(u8, cardName, " ");
    return std.fmt.parseInt(u32, it_cardName.next().?, 10) catch unreachable;
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
