//! LVGL Feature Phone UI for PinePhone and WebAssembly.
//! This app runs on PinePhone with Apache NuttX RTOS, and in a Web Browser with WebAssembly.
//! https://lupyuen.github.io/articles/lvgl4

/// Import the Zig Standard Library
const std = @import("std");
const builtin = @import("builtin");

/// Import the LVGL Module
const lvgl = @import("lvgl.zig");

/// Import the LVGL Library from C
const c = lvgl.c;

/// Import the functions specific to WebAssembly and Apache NuttX RTOS
pub usingnamespace switch (builtin.cpu.arch) {
    .wasm32, .wasm64 => @import("wasm.zig"),
    else => @import("nuttx.zig"),
};

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

///////////////////////////////////////////////////////////////////////////////
//  Create Widgets

/// Create the LVGL Widgets that will be rendered on the display
fn createWidgets() !void {
    debug("createWidgets: start", .{});
    defer debug("createWidgets: end", .{});

    // Create the Style for the Containers
    // https://docs.lvgl.io/8.3/layouts/flex.html#arrange-items-in-rows-with-wrap-and-even-spacing
    cont_style = std.mem.zeroes(c.lv_style_t);
    c.lv_style_init(&cont_style);
    c.lv_style_set_flex_flow(&cont_style, c.LV_FLEX_FLOW_ROW_WRAP);
    c.lv_style_set_flex_main_place(&cont_style, c.LV_FLEX_ALIGN_SPACE_EVENLY);
    c.lv_style_set_layout(&cont_style, c.LV_LAYOUT_FLEX);

    // Create the Container for Display (700 x 150 pixels)
    // https://docs.lvgl.io/8.3/layouts/flex.html#arrange-items-in-rows-with-wrap-and-even-spacing
    const display_cont = c.lv_obj_create(c.lv_scr_act()).?;
    c.lv_obj_set_size(display_cont, 700, 150);
    c.lv_obj_align(display_cont, c.LV_ALIGN_TOP_MID, 0, 5);
    c.lv_obj_add_style(display_cont, &cont_style, 0);

    // Create the Container for Call / Cancel Buttons (700 x 200 pixels)
    const call_cont = c.lv_obj_create(c.lv_scr_act()).?;
    c.lv_obj_set_size(call_cont, 700, 200);
    c.lv_obj_align_to(call_cont, display_cont, c.LV_ALIGN_OUT_BOTTOM_MID, 0, 10);
    c.lv_obj_add_style(call_cont, &cont_style, 0);

    // Create the Container for Digit Buttons (700 x 800 pixels)
    const digit_cont = c.lv_obj_create(c.lv_scr_act()).?;
    c.lv_obj_set_size(digit_cont, 700, 800);
    c.lv_obj_align_to(digit_cont, call_cont, c.LV_ALIGN_OUT_BOTTOM_MID, 0, 10);
    c.lv_obj_add_style(digit_cont, &cont_style, 0);

    // Create the Display Label
    try createDisplayLabel(display_cont);

    // Create the Call and Cancel Buttons
    try createCallButtons(call_cont);

    // Create the Digit Buttons
    try createDigitButtons(digit_cont);
}

/// Create the Display Label
fn createDisplayLabel(cont: *c.lv_obj_t) !void {
    // Init the Display Text to `+`
    display_text[0] = '+';

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
    // For each Button: Call and Connect...
    for (call_labels) |text| {
        // Create a Button of 250 x 100 pixels
        const btn = c.lv_btn_create(cont);
        c.lv_obj_set_size(btn, 250, 100);

        // Center the Button Label: Call or Cancel
        const label = c.lv_label_create(btn);
        c.lv_label_set_text(label, text.ptr);
        c.lv_obj_center(label);

        // Set the Event Callback Function and Callback Data for the Button
        const data = @intToPtr(*anyopaque, @ptrToInt(text.ptr));
        _ = c.lv_obj_add_event_cb(btn, eventHandler, c.LV_EVENT_ALL, data);
    }
}

/// Create the Digit Buttons
/// https://docs.lvgl.io/8.3/examples.html#simple-buttons
fn createDigitButtons(cont: *c.lv_obj_t) !void {
    // For each Digit Button...
    for (digit_labels) |text| {
        // Create a Button of 150 x 120 pixels
        const btn = c.lv_btn_create(cont);
        c.lv_obj_set_size(btn, 150, 120);

        // Center the Button Label
        const label = c.lv_label_create(btn);
        c.lv_label_set_text(label, text.ptr);
        c.lv_obj_center(label);

        // Set the Event Callback Function and Callback Data for the Button
        const data = @intToPtr(*anyopaque, @ptrToInt(text.ptr));
        _ = c.lv_obj_add_event_cb(btn, eventHandler, c.LV_EVENT_ALL, data);
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

/// LVGL Style for Containers (std.mem.zeroes crashes the compiler)
var cont_style: c.lv_style_t = undefined;

///////////////////////////////////////////////////////////////////////////////
//  Handle Events

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

        // Handle the identified button...
        if (std.mem.eql(u8, span, "Call")) {
            // If Call is clicked, call the number
            const call_number = display_text[0..len :0];
            debug("Call {s}", .{call_number});

            if (builtin.cpu.arch == .wasm32 or builtin.cpu.arch == .wasm64) {
                debug("Running in WebAssembly, simulate the Phone Call", .{});
            } else {
                debug("Running on PinePhone, make an actual Phone Call", .{});
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

///////////////////////////////////////////////////////////////////////////////
//  Imported Functions and Variables

/// Aliases for Zig Standard Library
const assert = std.debug.assert;
const debug = std.log.debug;
