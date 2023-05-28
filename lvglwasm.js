// Based on
// https://github.com/daneelsan/zig-wasm-logger/blob/master/script.js
// https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7

// References to Exported Zig Functions
var Game;

// Load the WebAssembly Module
const request = new XMLHttpRequest();
request.open('GET', 'lvglwasm.wasm');
request.responseType = 'arraybuffer';
request.send();

// On Loading the WebAssembly Module...
request.onload = function() {
    const wasmMemoryArray = new Uint8Array(wasmMemory.buffer);

    var bytes = request.response;
    WebAssembly.instantiate(bytes, {
        // JavaScript Environment exported to Zig
        env: {
            // Render the LVGL Canvas from Zig to HTML
            // https://github.com/daneelsan/minimal-zig-wasm-canvas/blob/master/script.js
            render: function() {
                console.log("render: start");
                const bufferOffset = wasm.instance.exports.getCanvasBuffer();
                console.log({ bufferOffset });
                const imageDataArray = wasmMemoryArray.slice(
                    bufferOffset,
                    bufferOffset + (canvas.width * canvas.height) * 4
                );
                imageData.data.set(imageDataArray);
        
                context.clearRect(0, 0, canvas.width, canvas.height);
                context.putImageData(imageData, 0, 0);
                console.log("render: end");
            },

            // Write to JavaScript Console from Zig
            jsConsoleLogWrite: function(ptr, len) {
                console_log_buffer += wasm.getString(ptr, len);
            },

            // Flush JavaScript Console from Zig
            jsConsoleLogFlush: function() {
                console.log(console_log_buffer);
                console_log_buffer = "";
            },
        }
    }).then(result => {
        // Store references to WebAssembly Functions and Memory exported by Zig
        Game = result.instance.exports;
        wasm.init(result);

        // Start the Main Loop
        main();
    });
};

// WebAssembly Memory for copying the LVGL Canvas from Zig
var wasmMemory = new WebAssembly.Memory({
    initial: 2 /* pages */,
    maximum: 2 /* pages */,
});

// Get the HTML Canvas Context
const canvas = window.document.getElementById("game_canvas");
const context = canvas.getContext("2d");
const imageData = context.createImageData(canvas.width, canvas.height);
context.clearRect(0, 0, canvas.width, canvas.height);

// Main Loop
const main = function() {
    console.log("main: start");

    const loop = function() {
        console.log("loop: start");
        // TODO: Init LVGL

        // Render the LVGL Widgets
        Game.lv_demo_widgets();
        console.log("lv_demo_widgets: done");

        // TODO: Render the LVGL Display

        // loop to next frame. Disabled for now because it slows down the browser.
        // TODO: window.requestAnimationFrame(loop);

        console.log("loop: end");
    };
    loop();
    console.log("main: end");
};

// Log WebAssembly Messages from Zig to JavaScript Console
const text_decoder = new TextDecoder();
let console_log_buffer = "";

let wasm = {
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

// TODO
// async function bootstrap() {
//     wasm.init(
//         await WebAssembly.instantiateStreaming(
//             fetch("./example.wasm"),
//             importObject
//         )
//     );

//     const step = wasm.instance.exports.step;

//     const loop = (timestamp) => {
//         step(timestamp);
//         requestAnimationFrame(loop)
//     };
//     requestAnimationFrame(loop);
// }

// bootstrap();