const std = @import("std");
const print = std.debug.print;

const FileName = "input.txt";

pub fn main() !void {
    const file = try std.fs.cwd().openFile(FileName, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(buf);

    var it_lines = std.mem.splitSequence(u8, buf, "\n");

    var total: u32 = 0;
    while (it_lines.next()) |line| {
        var it_section = std.mem.splitAny(u8, std.mem.trim(u8, line, "\n"), ":|");
        const cardName: []const u8 = std.mem.trim(u8, it_section.next().?, " ");
        print("{s}\n", .{cardName});
        const winingNumbers: []const u8 = std.mem.trim(u8, it_section.next().?, " ");
        print("{s}\n", .{winingNumbers});
        const myNumbers: []const u8 = std.mem.trim(u8, it_section.next().?, " ");
        print("{s}\n", .{myNumbers});

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
        total += std.math.pow(u32, 2, cardMatches) / 2;
    }

    print("total is: {d}\n", .{total});
}
