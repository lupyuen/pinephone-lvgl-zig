//! LVGL Test App that renders an LVGL Screen and handles Touch Input

/// Import the Zig Standard Library
const std = @import("std");

/// Import the LVGL Module
const lvgl = @import("lvgl.zig");

/// Import the LVGL Library from C
const c = @cImport({
    // NuttX Defines
    @cDefine("__NuttX__", "");
    @cDefine("NDEBUG", "");

    // NuttX Header Files
    @cInclude("arch/types.h");
    @cInclude("../../nuttx/include/limits.h");
    @cInclude("stdio.h");
    @cInclude("nuttx/config.h");
    @cInclude("sys/boardctl.h");
    @cInclude("unistd.h");
    @cInclude("stddef.h");
    @cInclude("stdlib.h");

    // LVGL Header Files
    @cInclude("lvgl/lvgl.h");
});

///////////////////////////////////////////////////////////////////////////////
//  Main Function

/// Empty Main Function
// pub export fn main() void {}

/// Empty Start Function
// pub export fn _start() void {}

/// We render an LVGL Screen with LVGL Widgets
pub export fn lv_demo_widgets() void {

    // Set the Custom Logger for LVGL
    c.lv_log_register_print_cb(custom_logger);

    // Create the widgets for display (with Zig Wrapper)
    createWidgetsWrapped() catch |e| {
        // In case of error, quit
        std.log.err("createWidgetsWrapped failed: {}", .{e});
        return;
    };

    // Create the widgets for display (without Zig Wrapper)
    // createWidgetsUnwrapped()
    //     catch |e| {
    //         // In case of error, quit
    //         std.log.err("createWidgetsUnwrapped failed: {}", .{e});
    //         return;
    //     };
}

///////////////////////////////////////////////////////////////////////////////
//  Create Widgets

/// Create the LVGL Widgets that will be rendered on the display. Calls the
/// LVGL API that has been wrapped in Zig. Based on
/// https://docs.lvgl.io/master/widgets/label.html?highlight=lv_label_create#line-wrap-recoloring-and-scrolling
fn createWidgetsWrapped() !void {
    debug("createWidgetsWrapped: start", .{});
    defer {
        debug("createWidgetsWrapped: end", .{});
    }

    // Get the Active Screen
    var screen = try lvgl.getActiveScreen();

    // Create a Label Widget
    var label = try screen.createLabel();

    // Wrap long lines in the label text
    label.setLongMode(c.LV_LABEL_LONG_WRAP);

    // Interpret color codes in the label text
    label.setRecolor(true);

    // Center align the label text
    label.setAlign(c.LV_TEXT_ALIGN_CENTER);

    // Set the label text and colors
    label.setText("#ff0000 HELLO# " ++ // Red Text
        "#00aa00 LVGL ON# " ++ // Green Text
        "#0000ff PINEPHONE!# " // Blue Text
    );

    // Set the label width
    label.setWidth(200);

    // Align the label to the center of the screen, shift 30 pixels up
    label.alignObject(c.LV_ALIGN_CENTER, 0, -30);
}

/// Create the LVGL Widgets that will be rendered on the display. Calls the
/// LVGL API directly, without wrapping in Zig. Based on
/// https://docs.lvgl.io/master/widgets/label.html?highlight=lv_label_create#line-wrap-recoloring-and-scrolling
fn createWidgetsUnwrapped() !void {
    debug("createWidgetsUnwrapped: start", .{});
    defer {
        debug("createWidgetsUnwrapped: end", .{});
    }

    // Get the Active Screen
    const screen = c.lv_scr_act().?;

    // Create a Label Widget
    const label = c.lv_label_create(screen).?;

    // Wrap long lines in the label text
    c.lv_label_set_long_mode(label, c.LV_LABEL_LONG_WRAP);

    // Interpret color codes in the label text
    c.lv_label_set_recolor(label, true);

    // Center align the label text
    c.lv_obj_set_style_text_align(label, c.LV_TEXT_ALIGN_CENTER, 0);

    // Set the label text and colors
    c.lv_label_set_text(label, "#ff0000 HELLO# " ++ // Red Text
        "#00aa00 LVGL ON# " ++ // Green Text
        "#0000ff PINEPHONE!# " // Blue Text
    );

    // Set the label width
    c.lv_obj_set_width(label, 200);

    // Align the label to the center of the screen, shift 30 pixels up
    c.lv_obj_align(label, c.LV_ALIGN_CENTER, 0, -30);
}

///////////////////////////////////////////////////////////////////////////////
//  LVGL Porting Layer for WebAssembly

/// TODO: Return the number of elapsed milliseconds
export fn millis() u32 {
    elapsed_ms += 1;
    return elapsed_ms;
}

var elapsed_ms: u32 = 0;

/// TODO: Print a Stack Trace on Assertion Failure
export fn lv_assert_handler() void {
    print(3000);
}

/// TODO: Custom Logger for LVGL
export fn custom_logger(buf: [*:0]const u8) void {
    _ = buf;
    print(4000);
}

///////////////////////////////////////////////////////////////////////////////
//  Panic Handler

/// Called by Zig when it hits a Panic. We print the Panic Message, Stack Trace and halt. See
/// https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html
/// https://github.com/ziglang/zig/blob/master/lib/std/builtin.zig#L763-L847
pub fn panic(message: []const u8, _stack_trace: ?*std.builtin.StackTrace) noreturn {
    _ = message;
    print(1000); // TODO

    // Print the Panic Message
    _ = _stack_trace;
    // TODO: _ = puts("\n!ZIG PANIC!");
    // TODO: _ = puts(@ptrCast([*c]const u8, message));

    // Print the Stack Trace
    // _ = puts("Stack Trace:");
    var it = std.debug.StackIterator.init(@returnAddress(), null);
    while (it.next()) |return_address| {
        print(@intCast(i32, return_address));
        // Previously: _ = printf("%p\n", return_address);
    }

    // Halt
    while (true) {}
}

///////////////////////////////////////////////////////////////////////////////
//  Logging

/// Called by Zig for `std.log.debug`, `std.log.info`, `std.log.err`, ...
/// https://gist.github.com/leecannon/d6f5d7e5af5881c466161270347ce84d
pub fn log(
    comptime _message_level: std.log.Level,
    comptime _scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    _ = _message_level;
    _ = _scope;

    // Format the message
    var buf: [100]u8 = undefined; // Limit to 100 chars
    var slice = std.fmt.bufPrint(&buf, format, args) catch {
        print(2000);
        return;
    }; // TODO

    // Terminate the formatted message with a null
    var buf2: [buf.len + 1:0]u8 = undefined;
    std.mem.copy(u8, buf2[0..slice.len], slice[0..slice.len]);
    buf2[slice.len] = 0;

    // Print the formatted message
    // TODO: _ = puts(&buf2);
}

///////////////////////////////////////////////////////////////////////////////
//  Imported Functions and Variables

/// Extern functions refer to the exterior JS namespace
/// when importing wasm code, the `print` func must be provided
extern fn print(i32) void;

/// Aliases for Zig Standard Library
const assert = std.debug.assert;
const debug = std.log.debug;

///////////////////////////////////////////////////////////////////////////////
//  C Standard Library
//  From zig-macos-x86_64-0.10.0-dev.2351+b64a1d5ab/lib/zig/c.zig

export fn memset(dest: ?[*]u8, c2: u8, len: usize) callconv(.C) ?[*]u8 {
    @setRuntimeSafety(false);

    if (len != 0) {
        var d = dest.?;
        var n = len;
        while (true) {
            d.* = c2;
            n -= 1;
            if (n == 0) break;
            d += 1;
        }
    }

    return dest;
}

export fn memcpy(noalias dest: ?[*]u8, noalias src: ?[*]const u8, len: usize) callconv(.C) ?[*]u8 {
    @setRuntimeSafety(false);

    if (len != 0) {
        var d = dest.?;
        var s = src.?;
        var n = len;
        while (true) {
            d[0] = s[0];
            n -= 1;
            if (n == 0) break;
            d += 1;
            s += 1;
        }
    }

    return dest;
}

export fn strcpy(dest: [*:0]u8, src: [*:0]const u8) callconv(.C) [*:0]u8 {
    var i: usize = 0;
    while (src[i] != 0) : (i += 1) {
        dest[i] = src[i];
    }
    dest[i] = 0;

    return dest;
}

export fn strlen(s: [*:0]const u8) callconv(.C) usize {
    return std.mem.len(s);
}
