const std = @import("std");

const stdOut_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdOut_file);
const stdOut = bw.writer();

pub var gpa = std.heap.GeneralPurposeAllocator(.{}){};

// these methods are not safe but good enough for test purposes

pub fn print(comptime format: []const u8, args: anytype) void {
    return stdOut.print(format, args) catch unreachable;
}

pub fn cleanUp() void {
    bw.flush() catch unreachable;
    std.debug.assert(gpa.deinit() == .ok);
}

pub fn strToArr(source: []const u8, comptime size: usize) [size]u8 {
    var key: [size]u8 = undefined;
    std.mem.copyForwards(u8, &key, source);
    return key;
}
