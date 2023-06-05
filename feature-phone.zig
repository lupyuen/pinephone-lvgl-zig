//! LVGL Test App (for WebAssembly) that renders an LVGL Screen

/// Import the Zig Standard Library
const std = @import("std");
const builtin = @import("builtin");

/// Import the WebAssembly Logger
const wasmlog = @import("wasmlog.zig");

/// Import the LVGL Module
const lvgl = @import("lvgl.zig");

/// Import the LVGL Library from C
const c = lvgl.c;

///////////////////////////////////////////////////////////////////////////////
//  Main Function

/// We render an LVGL Screen with LVGL Widgets
pub export fn lv_demo_widgets() void {
    debug("lv_demo_widgets: start", .{});
    defer debug("lv_demo_widgets: end", .{});

    // Create the widgets for display
    createWidgets() catch |e| {
        // In case of error, quit
        std.log.err("createWidgets failed: {}", .{e});
        return;
    };

    // JavaScript should call handleTimer periodically to handle LVGL Tasks
}

/// Init the LVGL Display and Input
pub export fn initDisplay() void {
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
    indev_drv = std.mem.zeroes(c.lv_indev_drv_t);
    c.lv_indev_drv_init(&indev_drv);
    indev_drv.type = c.LV_INDEV_TYPE_POINTER;
    indev_drv.read_cb = readInput;
    _ = c.register_input(&indev_drv);
}

/// LVGL Callback Function to Flush Display
export fn flushDisplay(disp_drv: ?*c.lv_disp_drv_t, area: [*c]const c.lv_area_t, color_p: [*c]c.lv_color_t) void {
    _ = area;
    _ = color_p;
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
fn createWidgets() !void {
    debug("createWidgets: start", .{});
    defer debug("createWidgets: end", .{});

    // Init the Display Text to `+`
    display_text[0] = '+';

    // Create the Styles for Display, Call / Cancel Buttons, Digit Buttons
    display_style = std.mem.zeroes(c.lv_style_t);
    c.lv_style_init(&display_style);
    c.lv_style_set_flex_flow(&display_style, c.LV_FLEX_FLOW_ROW_WRAP);
    c.lv_style_set_flex_main_place(&display_style, c.LV_FLEX_ALIGN_SPACE_EVENLY);
    c.lv_style_set_layout(&display_style, c.LV_LAYOUT_FLEX);

    call_style = std.mem.zeroes(c.lv_style_t);
    c.lv_style_init(&call_style);
    c.lv_style_set_flex_flow(&call_style, c.LV_FLEX_FLOW_ROW_WRAP);
    c.lv_style_set_flex_main_place(&call_style, c.LV_FLEX_ALIGN_SPACE_EVENLY);
    c.lv_style_set_layout(&call_style, c.LV_LAYOUT_FLEX);

    digit_style = std.mem.zeroes(c.lv_style_t);
    c.lv_style_init(&digit_style);
    c.lv_style_set_flex_flow(&digit_style, c.LV_FLEX_FLOW_ROW_WRAP);
    c.lv_style_set_flex_main_place(&digit_style, c.LV_FLEX_ALIGN_SPACE_EVENLY);
    c.lv_style_set_layout(&digit_style, c.LV_LAYOUT_FLEX);

    // Create the Containers for Display, Call / Cancel Buttons, Digit Buttons
    const display_cont = c.lv_obj_create(c.lv_scr_act()).?;
    c.lv_obj_set_size(display_cont, 700, 150);
    c.lv_obj_align(display_cont, c.LV_ALIGN_TOP_MID, 0, 5);
    c.lv_obj_add_style(display_cont, &display_style, 0);

    const call_cont = c.lv_obj_create(c.lv_scr_act()).?;
    c.lv_obj_set_size(call_cont, 700, 200);
    c.lv_obj_align_to(call_cont, display_cont, c.LV_ALIGN_OUT_BOTTOM_MID, 0, 10);
    c.lv_obj_add_style(call_cont, &call_style, 0);

    const digit_cont = c.lv_obj_create(c.lv_scr_act()).?;
    c.lv_obj_set_size(digit_cont, 700, 800);
    c.lv_obj_align_to(digit_cont, call_cont, c.LV_ALIGN_OUT_BOTTOM_MID, 0, 10);
    c.lv_obj_add_style(digit_cont, &digit_style, 0);

    // Create the Display Label
    try createDisplayLabel(display_cont);

    // Create the Call and Cancel Buttons
    try createCallButtons(call_cont);

    // Create the Digit Buttons
    try createDigitButtons(digit_cont);
}

/// Create the Display Label
fn createDisplayLabel(cont: *c.lv_obj_t) !void {
    // Get the Container
    var container = lvgl.Object.init(cont);

    // Create a Label Widget
    display_label = try container.createLabel();

    // Wrap long lines in the label text
    display_label.setLongMode(c.LV_LABEL_LONG_WRAP);

    // Interpret color codes in the label text
    display_label.setRecolor(true);

    // Center align the label text
    display_label.setAlign(c.LV_TEXT_ALIGN_CENTER);

    // Set the label text and colors
    display_label.setText("#ff0000 HELLO# " ++ // Red Text
        "#00aa00 LVGL ON# " ++ // Green Text
        "#0000ff PINEPHONE!# " // Blue Text
    );

    // Set the label width
    display_label.setWidth(200);

    // Align the label to the top middle
    display_label.alignObject(c.LV_ALIGN_TOP_MID, 0, 0);
}

/// Create the Call and Cancel Buttons
/// https://docs.lvgl.io/8.3/examples.html#simple-buttons
fn createCallButtons(cont: *c.lv_obj_t) !void {
    var i: usize = 0;
    while (i < call_labels.len) : (i += 1) {
        const text = call_labels[i].ptr;
        const btn = c.lv_btn_create(cont);
        c.lv_obj_set_size(btn, 250, 100);
        _ = c.lv_obj_add_event_cb(btn, eventHandler, c.LV_EVENT_ALL, @intToPtr(*anyopaque, @ptrToInt(text)));

        const label = c.lv_label_create(btn);
        c.lv_label_set_text(label, text);
        c.lv_obj_center(label);
    }
}

/// Create the Digit Buttons
/// https://docs.lvgl.io/8.3/examples.html#simple-buttons
fn createDigitButtons(cont: *c.lv_obj_t) !void {
    var i: usize = 0;
    while (i < digit_labels.len) : (i += 1) {
        const text = digit_labels[i].ptr;
        const btn = c.lv_btn_create(cont);
        c.lv_obj_set_size(btn, 150, 120);
        _ = c.lv_obj_add_event_cb(btn, eventHandler, c.LV_EVENT_ALL, @intToPtr(*anyopaque, @ptrToInt(text)));

        const label = c.lv_label_create(btn);
        c.lv_label_set_text(label, text);
        c.lv_obj_center(label);
    }
}

/// Handle LVGL Button Event
/// https://docs.lvgl.io/8.3/examples.html#simple-buttons
export fn eventHandler(e: ?*c.lv_event_t) void {
    const code = c.lv_event_get_code(e);

    if (code == c.LV_EVENT_CLICKED) {
        // Handle Button Clicked
        debug("eventHandler: clicked", .{});

        // Get the length of Display Text
        const len = std.mem.indexOfSentinel(u8, 0, &display_text);

        // Get the Button Text
        const data = c.lv_event_get_user_data(e);
        const text = @ptrCast([*:0]u8, data);
        const span = std.mem.span(text);

        if (std.mem.eql(u8, span, "Call")) {
            // If Call is clicked, call the number
            const call_number = display_text[0..len :0];
            debug("Call {s}", .{call_number});

            if (builtin.cpu.arch == .wasm32 or builtin.cpu.arch == .wasm64) {
                debug("Running in WebAssembly, simulate the Phone Call", .{});
            } else {
                debug("Running on PinePhone, make an actual Phone Call", {});
            }
        } else if (std.mem.eql(u8, span, "Cancel")) {
            // If Cancel is clicked, erase the last digit
            if (len >= 2) {
                display_text[len - 1] = 0;
                c.lv_label_set_text(display_label.obj, display_text[0.. :0]);
            }
        } else {
            // Else append the digit clicked to the text
            display_text[len] = text[0];
            c.lv_label_set_text(display_label.obj, display_text[0.. :0]);
        }
    } else if (code == c.LV_EVENT_VALUE_CHANGED) {
        // Handle Button Toggled
        debug("eventHandler: toggled", .{});
    }
}

/// Labels for Call and Cancel Buttons
const call_labels = [_][]const u8{ "Call", "Cancel" };

/// Labels for Digit Buttons
const digit_labels = [_][]const u8{ "1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#" };

/// LVGL Display Text (Null-Terminated)
var display_text = std.mem.zeroes([64:0]u8);

/// LVGL Display Label
var display_label: lvgl.Label = undefined;

/// LVGL Styles for Containers (std.mem.zeroes crashes the compiler)
var display_style: c.lv_style_t = undefined;
var call_style: c.lv_style_t = undefined;
var digit_style: c.lv_style_t = undefined;

///////////////////////////////////////////////////////////////////////////////
//  LVGL Input

/// Called by JavaScript to execute LVGL Tasks periodically, passing the Elapsed Milliseconds
export fn handleTimer(ms: i32) i32 {
    // Set the Elapsed Milliseconds, don't allow time rewind
    if (ms > elapsed_ms) {
        elapsed_ms = @intCast(u32, ms);
    }
    // Handle LVGL Tasks
    _ = c.lv_timer_handler();
    return 0;
}

/// Called by JavaScript to notify Mouse Down and Mouse Up.
/// Return 1 if we're still waiting for LVGL to process the last input.
export fn notifyInput(pressed: i32, x: i32, y: i32) i32 {
    // If LVGL hasn't processed the last input, try again later
    if (input_updated) {
        return 1;
    }

    // Save the Input State and Input Coordinates
    if (pressed == 0) {
        input_state = c.LV_INDEV_STATE_RELEASED;
    } else {
        input_state = c.LV_INDEV_STATE_PRESSED;
    }
    input_x = @intCast(c.lv_coord_t, x);
    input_y = @intCast(c.lv_coord_t, y);
    input_updated = true;
    return 0;
}

/// LVGL Callback Function to read Input Device
export fn readInput(drv: [*c]c.lv_indev_drv_t, data: [*c]c.lv_indev_data_t) void {
    _ = drv;
    if (input_updated) {
        input_updated = false;
        c.set_input_data(data, input_state, input_x, input_y);
        debug("readInput: state={}, x={}, y={}", .{ input_state, input_x, input_y });
    }
}

/// True if LVGL Input State has been updated
var input_updated: bool = false;

/// LVGL Input State and Coordinates
var input_state: c.lv_indev_state_t = 0;
var input_x: c.lv_coord_t = 0;
var input_y: c.lv_coord_t = 0;

/// LVGL Input Device Driver (std.mem.zeroes crashes the compiler)
var indev_drv: c.lv_indev_drv_t = undefined;

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
