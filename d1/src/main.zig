const std = @import("std");
const print = std.debug.print;
const isDigit = std.ascii.isDigit;

pub fn main() !void {

    // Read file
    var file = try std.fs.cwd().openFile("part1.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

    var total: i32 = 0;
    while (try stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        var len: usize = line.len - 1;
        var numberStr: [2]u8 = undefined;

        for (0..len) |i| {
            if (isDigit(line[i])) {
                numberStr[0] = line[i];
                break;
            }
        }

        while (len >= 0) : (len -= 1) {
            if (isDigit(line[len])) {
                numberStr[1] = line[len];
                break;
            }
        }

        const number = std.fmt.parseInt(i32, numberStr[0..], 10) catch {
            print("Invalid Input!\n", .{});
            return;
        };

        total += number;
        print("number is: {}\n", .{number});
    }

    print("total is: {}\n", .{total});
}
