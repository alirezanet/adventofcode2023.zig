const std = @import("std");
const stdOut = std.io.getStdOut().writer();

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

const content = @embedFile("input.txt");

pub fn main() !void {
    defer std.debug.assert(gpa.deinit() == .ok);
    var it_lines = std.mem.tokenizeAny(u8, content, "\n\r");
    var lst = std.ArrayList(Record).init(allocator);
    defer lst.deinit();
    while (it_lines.next()) |line| {
        var it_camel = std.mem.tokenizeAny(u8, line, " ");
        const handStr = it_camel.next().?;
        const bid = std.fmt.parseInt(u32, it_camel.next().?, 10) catch unreachable;
        const hand = Hand.create(handStr);
        const rec = Record{ .handStr = handStr, .hand = hand, .bid = bid, .strength = hand.strength() };
        try lst.append(rec);
    }
    std.sort.insertion(Record, lst.items, {}, comparer);

    var total: u32 = 0;
    print("card\tstrength  bid rank\n", .{});
    for (1.., lst.items) |rank, rec| {
        total += rec.bid * @as(u32, @intCast(rank));
        print("{s}-{s} {d:<3} {d:<3} {d:<3} {s}\n", .{ rec.handStr, rec.hand.cards, rec.strength, rec.bid, rank, @tagName(rec.hand.handType) });
    }

    print("total winnings: {d}\n", .{total});
}

fn comparer(_: void, a: Record, b: Record) bool {
    return a.strength < b.strength;
}

fn getCardStreangth(card: u8) u8 {
    return switch (card) {
        'A' => 24,
        'K' => 23,
        'Q' => 22,
        'J' => 11,
        'T' => 20,
        '9' => 19,
        '8' => 18,
        '7' => 17,
        '6' => 16,
        '5' => 15,
        '4' => 14,
        '3' => 13,
        '2' => 12,
        else => unreachable,
    };
}

const HandType = enum(u8) {
    highCard = 1,
    onePair = 2,
    twoPair = 3,
    threeOfAKind = 4,
    fullHouse = 5,
    fourOfAKind = 6,
    fiveOfAKind = 7,

    fn getValue(self: HandType) u8 {
        return @intFromEnum(self);
    }
};

const Record = struct {
    handStr: []const u8,
    hand: Hand,
    bid: u32,
    strength: u64,
};

const Hand = struct {
    handType: HandType,
    originalCards: []const u8,
    cards: [5]u8,

    fn create(handStr: []const u8) Hand {
        std.debug.assert(handStr.len == 5);
        var hand: [5]u8 = undefined;
        std.mem.copyForwards(u8, &hand, handStr);

        var cardHashMap = std.AutoArrayHashMap(u8, u8).init(allocator);
        defer cardHashMap.deinit();

        // Find the best card and count J
        var max: u8 = 1;
        var bestCard: u8 = 0;
        var hasJ: bool = false;
        for (hand) |card| {
            if (card == 'J') hasJ = true;
            if (bestCard == 0 and card != 'J') bestCard = card;
            if (cardHashMap.contains(card)) {
                const value = cardHashMap.get(card).? + 1;
                if (value == max) {
                    if (getCardStreangth(card) > getCardStreangth(bestCard)) bestCard = card;
                }
                if (value > max and card != 'J') {
                    max = value;
                    bestCard = card;
                }
                cardHashMap.put(card, value) catch unreachable;
            } else {
                cardHashMap.put(card, 1) catch unreachable;
            }
        }

        // replace bestCard with J
        if (hasJ and bestCard > 0) {
            for (&hand) |*card| {
                if (card.* == 'J') card.* = bestCard;
            }
        }

        // count pairs
        cardHashMap.clearRetainingCapacity();
        max = 1;
        for (hand) |card| {
            if (cardHashMap.contains(card)) {
                const value = cardHashMap.get(card).? + 1;
                if (value > max) {
                    max = value;
                }
                cardHashMap.put(card, value) catch unreachable;
            } else {
                cardHashMap.put(card, 1) catch unreachable;
            }
        }

        return switch (cardHashMap.count()) {
            5 => Hand{ .originalCards = handStr, .handType = .highCard, .cards = hand },
            4 => Hand{ .originalCards = handStr, .handType = .onePair, .cards = hand },
            3 => switch (max) {
                3 => Hand{ .originalCards = handStr, .handType = .threeOfAKind, .cards = hand },
                else => Hand{ .originalCards = handStr, .handType = .twoPair, .cards = hand },
            },
            2 => switch (max) {
                4 => Hand{ .originalCards = handStr, .handType = .fourOfAKind, .cards = hand },
                else => Hand{ .originalCards = handStr, .handType = .fullHouse, .cards = hand },
            },
            1 => Hand{ .originalCards = handStr, .handType = .fiveOfAKind, .cards = hand },
            else => unreachable,
        };
    }

    fn strength(self: Hand) u64 {
        var result: u64 = self.handType.getValue();

        for (self.originalCards) |card| {
            const x: u8 = getCardStreangth(card);
            result *= switch (x) {
                0...9 => 10,
                10...99 => 100,
                else => unreachable,
            };
            result += x;
        }

        return result;
    }
};

pub fn print(comptime format: []const u8, args: anytype) void {
    return stdOut.print(format, args) catch unreachable;
}
