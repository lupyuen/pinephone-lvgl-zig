/// Import the Zig Standard Library
const std = @import("std");

/// Import the Termux GUI Library from C
const c = @cImport({
    @cInclude("termuxgui/termuxgui.h");
});

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // Create a connection to the plugin
    var conn = c.tgui_connection{};
    if (c.tgui_connection_create(&conn) != 0) {
        @panic("Failed to create Termux GUI Connection");
    }

    // Display a hello world message
    c.tgui_toast(conn, "Hello World!", false);

    // Destroy the connection, although that's not needed when you exit after that,
    // the plugin cleans up after exited programs itself.
    c.tgui_connection_destroy(c);
}
