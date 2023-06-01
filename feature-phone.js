// Render LVGL in WebAssembly, compiled with Zig Compiler. Based on...
// https://github.com/daneelsan/minimal-zig-wasm-canvas/blob/master/script.js
// https://github.com/daneelsan/zig-wasm-logger/blob/master/script.js

// Log WebAssembly Messages from Zig to JavaScript Console
// https://github.com/daneelsan/zig-wasm-logger/blob/master/script.js
const text_decoder = new TextDecoder();
let console_log_buffer = "";

// WebAssembly Helper Functions
const wasm = {
    // WebAssembly Instance
    instance: undefined,

    // Init the WebAssembly Instance
    init: function (obj) {
        this.instance = obj.instance;
    },

    // Fetch the Zig String from a WebAssembly Pointer
    getString: function (ptr, len) {
        const memory = this.instance.exports.memory;
        return text_decoder.decode(
            new Uint8Array(memory.buffer, ptr, len)
        );
    },
};

// Export JavaScript Functions to Zig
const importObject = {
    // JavaScript Functions exported to Zig
    env: {
        // Render the LVGL Canvas from Zig to HTML
        // https://github.com/daneelsan/minimal-zig-wasm-canvas/blob/master/script.js
        render: function() {  // TODO: Add width and height

            // Get the WebAssembly Pointer to the LVGL Canvas Buffer
            console.log("render: start");
            const bufferOffset = wasm.instance.exports
                .getCanvasBuffer();
            console.log({ bufferOffset });

            // Load the WebAssembly Pointer into a JavaScript Image Data
            const memory = wasm.instance.exports.memory;
            const ptr = bufferOffset;
            const len = (canvas.width * canvas.height) * 4;
            const imageDataArray = new Uint8Array(memory.buffer, ptr, len)
            imageData.data.set(imageDataArray);

            // Render the Image Data to the HTML Canvas
            context.clearRect(0, 0, canvas.width, canvas.height);
            context.putImageData(imageData, 0, 0);
            console.log("render: end");
        },

        // Write to JavaScript Console from Zig
        // https://github.com/daneelsan/zig-wasm-logger/blob/master/script.js
        jsConsoleLogWrite: function(ptr, len) {
            console_log_buffer += wasm.getString(ptr, len);
        },

        // Flush JavaScript Console from Zig
        // https://github.com/daneelsan/zig-wasm-logger/blob/master/script.js
        jsConsoleLogFlush: function() {
            console.log(console_log_buffer);
            console_log_buffer = "";
        },
    }
};

// Get the HTML Canvas Context and Image Data
const canvas = window.document.getElementById("lvgl_canvas");
const context = canvas.getContext("2d");
const imageData = context.createImageData(canvas.width, canvas.height);
context.clearRect(0, 0, canvas.width, canvas.height);

// Handle Mouse Down on HTML Canvas
canvas.addEventListener("mousedown", (e) => {
    // Notify Zig of Mouse Down
    const x = e.offsetX;
    const y = e.offsetY;
    console.log({mousedown: {x, y}});
    wasm.instance.exports
        .notifyInput(1, x, y);
});

// Handle Mouse Up on HTML Canvas
canvas.addEventListener("mouseup", (e) => {
    // Notify Zig of Mouse Up
    x = e.offsetX;
    y = e.offsetY;
    console.log({mouseup: {x, y}});
    wasm.instance.exports
        .notifyInput(0, x, y);
});

// Handle Touch Start on HTML Canvas
canvas.addEventListener("touchstart", (e) => {
    // Notify Zig of Touch Start
    e.preventDefault();
    const touches = e.changedTouches;
    if (touches.length == 0) { return; }

    const x = touches[0].pageX;
    const y = touches[0].pageY;
    console.log({touchstart: {x, y}});
    wasm.instance.exports
        .notifyInput(1, x, y);
});

// Handle Touch End on HTML Canvas
canvas.addEventListener("touchend", (e) => {
    // Notify Zig of Touch End
    e.preventDefault();
    const touches = e.changedTouches;
    if (touches.length == 0) { return; }

    const x = touches[0].pageX;
    const y = touches[0].pageY;
    console.log({touchend: {x, y}});
    wasm.instance.exports
        .notifyInput(0, x, y);
});

// Main Function
function main() {
    console.log("main: start");
    const start_ms = Date.now();

    // Render the LVGL Widgets in Zig
    wasm.instance.exports
        .lv_demo_widgets();

    // Render Loop
    const loop = function() {

        // Compute the Elapsed Milliseconds
        const elapsed_ms = Date.now() - start_ms;

        // Handle LVGL Tasks to update the display
        wasm.instance.exports
            .handleTimer(elapsed_ms);

        // Loop to next frame
        window.requestAnimationFrame(loop);
        // Previously: window.setTimeout(loop, 100);
    };

    // Start the Render Loop
    loop();
    console.log("main: end");
};

// Load the WebAssembly Module and start the Main Function
async function bootstrap() {

    // Load the WebAssembly Module
    // https://developer.mozilla.org/en-US/docs/WebAssembly/JavaScript_interface/instantiateStreaming
    const result = await WebAssembly.instantiateStreaming(
        fetch("feature-phone.wasm"),
        importObject
    );

    // Store references to WebAssembly Functions and Memory exported by Zig
    wasm.init(result);

    // Start the Main Function
    main();
}

// Start the loading of WebAssembly Module
bootstrap();
