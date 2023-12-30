const std = @import("std");
const print = std.debug.print;

const FileName = "input.txt";

pub fn main() !void {
    const file = try std.fs.cwd().openFile(FileName, .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; //.init(std.heap.page_allocator);
    defer std.debug.assert(gpa.deinit() == .ok);
    var allocator = gpa.allocator();

    const buf = try file.readToEndAlloc(allocator, 256 * 256);
    defer allocator.free(buf);

    // parse
    var line_it = std.mem.splitAny(u8, buf, "\n\r");

    var time_it = std.mem.tokenizeAny(u8, line_it.next().?, ":TimeDistance\n\t\r");
    var distance_it = std.mem.tokenizeAny(u8, line_it.next().?, ":TimeDistance\n\t\r");

    const timeString = try std.mem.replaceOwned(u8, allocator, time_it.next().?, " ", "");
    const time = try std.fmt.parseInt(u64, timeString, 10);
    allocator.free(timeString);

    const distanceString = try std.mem.replaceOwned(u8, allocator, distance_it.next().?, " ", "");
    const distance = try std.fmt.parseInt(u64, distanceString, 10);
    allocator.free(distanceString);

    print("time {d:<4} | distance {d:<4}\n", .{ time, distance });

    var waysToWin: u64 = 0;

    var x: u64 = @divTrunc(time, 2);
    var search_direction: bool = true;
    var searchPoint: u64 = undefined;
    var endPoint: u64 = undefined;
    var startPoint: u64 = undefined;
    var totalSearch: usize = 0;

    // find search point .....[....*....]..
    while (true) : (totalSearch += 1) {
        if (getTravelTime(time, x) > distance) {
            searchPoint = x;
            break;
        }

        if (search_direction) {
            x = @divTrunc(time + x, 2);
        } else {
            x = @divTrunc(time - x, 2);
        }
        search_direction = !search_direction;
    }

    // find endpoint .....[........]*..
    x = @divTrunc(searchPoint + time, 2);
    while (true) : (totalSearch += 1) {
        if (getTravelTime(time, x) > distance) {
            endPoint = x;
            if (getTravelTime(time, x + 1) <= distance) {
                break;
            }
            x = @divTrunc(endPoint + time, 2);
            continue;
        }

        x = @divTrunc(x + @max(searchPoint, endPoint), 2);
    }

    // find start point .....*[........]..
    x = @divTrunc(time - searchPoint, 2);
    while (true) : (totalSearch += 1) {
        if (getTravelTime(time, x) > distance) {
            startPoint = x;
            if (getTravelTime(time, x - 1) <= distance) {
                break;
            }
            x = @divTrunc(startPoint, 2);
            continue;
        }

        x = @divTrunc(x + @min(searchPoint, startPoint), 2);
    }

    waysToWin = endPoint - startPoint + 1;

    print("\n Total ways to win: {d} in {} of {} \n", .{ waysToWin, totalSearch, time });
}

fn getTravelTime(maxTime: u64, buttonTime: u64) u64 {
    return (maxTime -% buttonTime) *% buttonTime;
}
