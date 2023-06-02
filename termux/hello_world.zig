/// Import the Zig Standard Library
const std = @import("std");

/// Import the Termux GUI Library from C
const c = @cImport({
    @cInclude("termuxgui/termuxgui.h");
});

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    std.debug.print("c.tgui_connection_create={}", &c.tgui_connection_create); ////

    // Create a connection to the plugin
    var conn: c.tgui_connection = null;
    if (c.tgui_connection_create(&conn) != 0) {
        std.debug.print("a", .{}); ////
        @panic("Failed to create Termux GUI Connection");
    }

    std.debug.print("b", .{}); ////

    // Display a hello world message
    _ = c.tgui_toast(conn, "Hello World!", false);

    std.debug.print("c", .{}); ////

    // Destroy the connection, although that's not needed when you exit after that,
    // the plugin cleans up after exited programs itself.
    c.tgui_connection_destroy(conn);

    std.debug.print("d", .{}); ////
}
