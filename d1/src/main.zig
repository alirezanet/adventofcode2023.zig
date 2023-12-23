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

    var total: u32 = 0;
    while (try stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line_untr| {
        const str = std.mem.trim(u8, getNormalizedLine(line_untr), "\r");

        var len: usize = str.len;
        var numberStr: [2]u8 = undefined;

        // find the first number
        for (0..len) |i| {
            if (isDigit(str[i])) {
                numberStr[0] = str[i];
                break;
            }
        }

        // find the last number
        while (len > 0) : (len -= 1) {
            if (isDigit(str[len - 1])) {
                numberStr[1] = str[len - 1];
                break;
            }
        }

        const number = std.fmt.parseInt(u32, numberStr[0..], 10) catch {
            print("Invalid Input!: {s}\n", .{line_untr});
            return;
        };

        total += number;
    }

    print("total is: {d}\n", .{total});
}

fn getNormalizedLine(input: []u8) []u8 {
    var i: usize = 0;
    while (i < input.len) : (i += 1) {
        if ((i + 3) <= input.len and std.mem.eql(u8, "one", input[i .. i + 3])) {
            input[i] = '1';
        } else if ((i + 3) <= input.len and std.mem.eql(u8, "two", input[i .. i + 3])) {
            input[i] = '2';
        } else if ((i + 5) <= input.len and std.mem.eql(u8, "three", input[i .. i + 5])) {
            input[i] = '3';
        } else if ((i + 4) <= input.len and std.mem.eql(u8, "four", input[i .. i + 4])) {
            input[i] = '4';
        } else if ((i + 4) <= input.len and std.mem.eql(u8, "five", input[i .. i + 4])) {
            input[i] = '5';
        } else if ((i + 3) <= input.len and std.mem.eql(u8, "six", input[i .. i + 3])) {
            input[i] = '6';
        } else if ((i + 5) <= input.len and std.mem.eql(u8, "seven", input[i .. i + 5])) {
            input[i] = '7';
        } else if ((i + 5) <= input.len and std.mem.eql(u8, "eight", input[i .. i + 5])) {
            input[i] = '8';
        } else if ((i + 4) <= input.len and std.mem.eql(u8, "nine", input[i .. i + 4])) {
            input[i] = '9';
        }
    }
    return input;
}
