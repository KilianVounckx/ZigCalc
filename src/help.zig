const std = @import("std");

pub fn printStart(
    writer: std.io.Writer(std.fs.File, std.os.WriteError, std.fs.File.write),
) !void {
    try writer.print(
        \\Welcome To ZigCalc.
        \\
        \\[Type "exit" to exit, or "help" for help]
        \\
        \\
        \\
        , .{});
}

pub fn printHelp(
    writer: std.io.Writer(std.fs.File, std.os.WriteError, std.fs.File.write),
) !void {
    try writer.print(
        \\
        \\Command       Description
        \\-------       -----------
        \\help          Show this help.
        \\ans           The previous result.
        \\exit          Exit the calculator. 
        \\
        \\
        \\
        , .{});
}