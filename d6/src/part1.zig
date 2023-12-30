const std = @import("std");
const print = std.debug.print;

const FileName = "input.txt";

pub fn main() !void {
    const file = try std.fs.cwd().openFile(FileName, .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; //.init(std.heap.page_allocator);
    // defer gpa.deinit();
    var allocator = gpa.allocator();

    const buf = try file.readToEndAlloc(allocator, 512 * 512);
    defer allocator.free(buf);

    // parse
    var line_it = std.mem.splitAny(u8, buf, "\n\r");
    var time_it = std.mem.tokenizeAny(u8, line_it.next().?, " :TimeDistance");
    var distance_it = std.mem.tokenizeAny(u8, line_it.next().?, " :TimeDistance");

    var totalWaysToWin: u32 = 1;
    while (time_it.next()) |timeString| {
        const time = try std.fmt.parseInt(usize, timeString, 10);
        const distance = try std.fmt.parseInt(usize, distance_it.next().?, 10);
        print("time {d:<4} | distance {d:<4}\n", .{ time, distance });

        var waysToWin: u32 = 0;

        for (1..distance) |i| {
            if (time < i) break;

            const travel: usize = (time - i) * i;
            if (travel > distance) {
                print("Hold for {}ms to travel {}mm\n", .{ i, travel });
                waysToWin += 1;
            }
        }
        totalWaysToWin *= waysToWin;
    }

    print("\n Total ways to win: {d}\n", .{totalWaysToWin});
}
