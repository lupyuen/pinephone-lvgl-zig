//! LVGL Test App (for WebAssembly) that renders an LVGL Screen

/// Import the Zig Standard Library
const std = @import("std");

/// Import the LVGL Module
const lvgl = @import("lvgl.zig");

/// Import the WebAssembly Logger
const wasmlog = @import("wasmlog.zig");

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

    // LVGL Display Interface for Zig
    @cInclude("display.h");
});

///////////////////////////////////////////////////////////////////////////////
//  Main Function

/// We render an LVGL Screen with LVGL Widgets
pub export fn lv_demo_widgets() void {
    debug("lv_demo_widgets: start", .{});
    defer debug("lv_demo_widgets: end", .{});

    // Create the Memory Allocator for malloc
    memory_allocator = std.heap.FixedBufferAllocator.init(&memory_buffer);

    // Set the Custom Logger for LVGL
    c.lv_log_register_print_cb(custom_logger);

    // Init LVGL
    c.lv_init();

    // Fetch pointers to Display Driver and Display Buffer
    const disp_drv = c.get_disp_drv();
    const disp_buf = c.get_disp_buf();

    // Init Display Buffer and Display Driver as pointers
    c.init_disp_buf(disp_buf);
    c.init_disp_drv(disp_drv, // Display Driver
        disp_buf, // Display Buffer
        flushDisplay, // Callback Function to Flush Display
        720, // Horizontal Resolution
        1280 // Vertical Resolution
    );

    // Register the Display Driver
    const disp = c.lv_disp_drv_register(disp_drv);
    _ = disp;

    // Register the Input Device
    // https://docs.lvgl.io/8.3/porting/indev.html
    c.lv_indev_drv_init(&indev_drv);
    indev_drv.type = c.LV_INDEV_TYPE_POINTER;
    indev_drv.read_cb = readInput;
    _ = c.register_input(&indev_drv);

    // Create the widgets for display (with Zig Wrapper)
    createWidgetsWrapped() catch |e| {
        // In case of error, quit
        std.log.err("createWidgetsWrapped failed: {}", .{e});
        return;
    };

    // JavaScript should call handleTimer periodically to handle LVGL Tasks
}

/// LVGL Callback Function to Flush Display
export fn flushDisplay(disp_drv: ?*c.lv_disp_drv_t, area: [*c]const c.lv_area_t, color_p: [*c]c.lv_color_t) void {
    _ = area;
    _ = color_p;
    debug("flushDisplay: start", .{});
    defer debug("flushDisplay: end", .{});

    // Call the Web Browser JavaScript to render the LVGL Canvas Buffer
    render();

    // Notify LVGL that the display is flushed
    c.lv_disp_flush_ready(disp_drv);
}

/// Return a WebAssembly Pointer to the LVGL Canvas Buffer for JavaScript Rendering
export fn getCanvasBuffer() [*]u8 {
    const buf = c.get_canvas_buffer();
    return @ptrCast([*]u8, buf);
}

///////////////////////////////////////////////////////////////////////////////
//  Create Widgets

/// Create the LVGL Widgets that will be rendered on the display. Calls the
/// LVGL API that has been wrapped in Zig. Based on
/// https://docs.lvgl.io/master/widgets/label.html?highlight=lv_label_create#line-wrap-recoloring-and-scrolling
fn createWidgetsWrapped() !void {
    debug("createWidgetsWrapped: start", .{});
    defer debug("createWidgetsWrapped: end", .{});

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

    // Create a Button Widget
    createButton();
}

/// Create the LVGL Widgets that will be rendered on the display. Calls the
/// LVGL API directly, without wrapping in Zig. Based on
/// https://docs.lvgl.io/master/widgets/label.html?highlight=lv_label_create#line-wrap-recoloring-and-scrolling
fn createWidgetsUnwrapped() !void {
    debug("createWidgetsUnwrapped: start", .{});
    defer debug("createWidgetsUnwrapped: end", .{});

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

    // Create a Button Widget
    createButton();
}

/// Create an LVGL Button
/// https://docs.lvgl.io/8.3/examples.html#simple-buttons
fn createButton() void {
    const btn = c.lv_btn_create(c.lv_scr_act());
    _ = c.lv_obj_add_event_cb(btn, eventHandler, c.LV_EVENT_ALL, null);
    c.lv_obj_align(btn, c.LV_ALIGN_CENTER, 0, 40);

    const label = c.lv_label_create(btn);
    c.lv_label_set_text(label, "Button");
    c.lv_obj_center(label);
}

/// Handle LVGL Button Event
/// https://docs.lvgl.io/8.3/examples.html#simple-buttons
export fn eventHandler(e: ?*c.lv_event_t) void {
    const code = c.lv_event_get_code(e);
    if (code == c.LV_EVENT_CLICKED) {
        debug("eventHandler: clicked", .{});
    } else if (code == c.LV_EVENT_VALUE_CHANGED) {
        debug("eventHandler: toggled", .{});
    }
}

///////////////////////////////////////////////////////////////////////////////
//  LVGL Input

/// Called by JavaScript to execute LVGL Tasks periodically, passing the Elapsed Milliseconds
export fn handleTimer(ms: i32) void {
    // Set the Elapsed Milliseconds, don't allow time rewind
    if (ms > elapsed_ms) {
        elapsed_ms = @intCast(u32, ms);
    }
    // Handle LVGL Tasks
    _ = c.lv_timer_handler();
}

/// Called by JavaScript to notify Mouse Down and Mouse Up
export fn notifyInput(pressed: i32, x: i32, y: i32) void {
    if (pressed == 0) {
        input_state = c.LV_INDEV_STATE_RELEASED;
    } else {
        input_state = c.LV_INDEV_STATE_PRESSED;
    }
    input_x = @intCast(c.lv_coord_t, x);
    input_y = @intCast(c.lv_coord_t, y);
    input_updated = true;
}

/// LVGL Callback Function to read Input Device
export fn readInput(drv: [*c]c.lv_indev_drv_t, data: [*c]c.lv_indev_data_t) void {
    _ = drv;
    if (input_updated) {
        input_updated = false;
        c.set_input_data(data, input_state, input_x, input_y);
    }
}

/// True if LVGL Input State has been updated
var input_updated: bool = false;

/// LVGL Input State and Coordinates
var input_state: c.lv_indev_state_t = 0;
var input_x: c.lv_coord_t = 0;
var input_y: c.lv_coord_t = 0;

/// LVGL Input Device Driver
/// TODO: std.mem.zeroes crashes the compiler
var indev_drv = c.lv_indev_drv_t{
    .type = 0,
    .read_cb = null,
    .feedback_cb = null,
    .user_data = null,
    .disp = null,
    .read_timer = null,
    .scroll_limit = 0,
    .scroll_throw = 0,
    .gesture_min_velocity = 0,
    .gesture_limit = 0,
    .long_press_time = 0,
    .long_press_repeat_time = 0,
};

///////////////////////////////////////////////////////////////////////////////
//  LVGL Porting Layer for WebAssembly

/// TODO: Return the number of elapsed milliseconds
export fn millis() u32 {
    elapsed_ms += 1;
    return elapsed_ms;
}

/// Number of elapsed milliseconds
var elapsed_ms: u32 = 0;

/// On Assertion Failure, print a Stack Trace and halt
export fn lv_assert_handler() void {
    @panic("*** lv_assert_handler: ASSERTION FAILED");
}

/// Custom Logger for LVGL that writes to JavaScript Console
export fn custom_logger(buf: [*c]const u8) void {
    wasmlog.Console.log("{s}", .{buf});
}

///////////////////////////////////////////////////////////////////////////////
//  Memory Allocator for malloc

/// Zig replacement for malloc
export fn malloc(size: usize) ?*anyopaque {
    // TODO: Save the slice length
    const mem = memory_allocator.allocator().alloc(u8, size) catch {
        @panic("*** malloc error: out of memory");
    };
    return mem.ptr;
}

/// Zig replacement for realloc
export fn realloc(old_mem: [*c]u8, size: usize) ?*anyopaque {
    // TODO: Call realloc instead
    // const mem = memory_allocator.allocator().realloc(old_mem[0..???], size) catch {
    //     @panic("*** realloc error: out of memory");
    // };
    const mem = memory_allocator.allocator().alloc(u8, size) catch {
        @panic("*** realloc error: out of memory");
    };
    _ = memcpy(mem.ptr, old_mem, size);
    if (old_mem != null) {
        // TODO: How to free without the slice length?
        // memory_allocator.allocator().free(old_mem[0..???]);
    }
    return mem.ptr;
}

/// Zig replacement for free
export fn free(mem: [*c]u8) void {
    if (mem == null) {
        @panic("*** free error: pointer is null");
    }
    // TODO: How to free without the slice length?
    // memory_allocator.allocator().free(mem[0..???]);
}

/// Memory Allocator for malloc
var memory_allocator: std.heap.FixedBufferAllocator = undefined;

/// Memory Buffer for malloc
var memory_buffer = std.mem.zeroes([1024 * 1024]u8);

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
        wasmlog.Console.log("*** log error: buf too small", .{});
        return;
    };

    // Print the formatted message
    wasmlog.Console.log("{s}", .{slice});
}

///////////////////////////////////////////////////////////////////////////////
//  Imported Functions and Variables

/// JavaScript Functions imported into Zig WebAssembly
extern fn render() void;

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

export fn strcmp(s1: [*:0]const u8, s2: [*:0]const u8) callconv(.C) c_int {
    return std.cstr.cmp(s1, s2);
}

export fn strlen(s: [*:0]const u8) callconv(.C) usize {
    return std.mem.len(s);
}
