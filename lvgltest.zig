//! LVGL Test App that renders an LVGL Screen and handles Touch Input

/// Import the Zig Standard Library
const std = @import("std");

/// Import the LVGL Module
const lvgl = @import("lvgl.zig");

/// Import the LVGL Library from C
const c = @cImport({
    // NuttX Defines
    @cDefine("__NuttX__",  "");
    @cDefine("NDEBUG",     "");
    // @cDefine("LV_LVGL_H_INCLUDE_SIMPLE", "");

    // Workaround for "Unable to translate macro: undefined identifier `LL`"
    // @cDefine("LL", "");
    // @cDefine("__int_c_join(a, b)", "a");  //  Bypass zig/lib/include/stdint.h

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

/// We render an LVGL Screen with LVGL Widgets
pub export fn lv_demo_widgets() void {

    // Create the widgets for display
    createWidgetsUnwrapped()
        catch |e| {
            // In case of error, quit
            std.log.err("createWidgets failed: {}", .{e});
            return;
        };

    // To call the LVGL API that's wrapped in Zig, change
    // `createWidgetsUnwrapped` above to `createWidgetsWrapped`
}

///////////////////////////////////////////////////////////////////////////////
//  Create Widgets

/// Create the LVGL Widgets that will be rendered on the display. Calls the
/// LVGL API directly, without wrapping in Zig. Based on
/// https://docs.lvgl.io/master/widgets/label.html?highlight=lv_label_create#line-wrap-recoloring-and-scrolling
fn createWidgetsUnwrapped() !void {
    debug("createWidgetsUnwrapped", .{});

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
    c.lv_label_set_text(
        label, 
        "#ff0000 HELLO# " ++    // Red Text
        "#00aa00 PINEDIO# " ++  // Green Text
        "#0000ff STACK!# "      // Blue Text
    );

    // Set the label width
    c.lv_obj_set_width(label, 200);

    // Align the label to the center of the screen, shift 30 pixels up
    c.lv_obj_align(label, c.LV_ALIGN_CENTER, 0, -30);
}

/// Create the LVGL Widgets that will be rendered on the display. Calls the
/// LVGL API that has been wrapped in Zig. Based on
/// https://docs.lvgl.io/master/widgets/label.html?highlight=lv_label_create#line-wrap-recoloring-and-scrolling
fn createWidgetsWrapped() !void {
    debug("createWidgetsWrapped", .{});

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
    label.setText(
        "#ff0000 HELLO# " ++    // Red Text
        "#00aa00 PINEDIO# " ++  // Green Text
        "#0000ff STACK!# "      // Blue Text
    );

    // Set the label width
    label.setWidth(200);

    // Align the label to the center of the screen, shift 30 pixels up
    label.alignObject(c.LV_ALIGN_CENTER, 0, -30);
}

///////////////////////////////////////////////////////////////////////////////
//  Callbacks

///////////////////////////////////////////////////////////////////////////////
//  Panic Handler

/// Called by Zig when it hits a Panic. We print the Panic Message, Stack Trace and halt. See 
/// https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html
/// https://github.com/ziglang/zig/blob/master/lib/std/builtin.zig#L763-L847
pub fn panic(
    message: []const u8, 
    _stack_trace: ?*std.builtin.StackTrace
) noreturn {
    // Print the Panic Message
    _ = _stack_trace;
    _ = puts("\n!ZIG PANIC!");
    _ = puts(@ptrCast([*c]const u8, message));

    // Print the Stack Trace
    _ = puts("Stack Trace:");
    var it = std.debug.StackIterator.init(@returnAddress(), null);
    while (it.next()) |return_address| {
        _ = printf("%p\n", return_address);
    }

    // Halt
    while(true) {}
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
    var buf: [100]u8 = undefined;  // Limit to 100 chars
    var slice = std.fmt.bufPrint(&buf, format, args)
        catch { _ = puts("*** log error: buf too small"); return; };
    
    // Terminate the formatted message with a null
    var buf2: [buf.len + 1 : 0]u8 = undefined;
    std.mem.copy(
        u8, 
        buf2[0..slice.len], 
        slice[0..slice.len]
    );
    buf2[slice.len] = 0;

    // Print the formatted message
    _ = puts(&buf2);
}

///////////////////////////////////////////////////////////////////////////////
//  Imported Functions and Variables

/// For safety, we import these functions ourselves to enforce Null-Terminated Strings.
/// We changed `[*c]const u8` to `[*:0]const u8`
extern fn printf(format: [*:0]const u8, ...) c_int;
extern fn puts(str: [*:0]const u8) c_int;

/// Aliases for Zig Standard Library
const assert = std.debug.assert;
const debug  = std.log.debug;
