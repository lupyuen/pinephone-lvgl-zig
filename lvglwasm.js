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
    var bytes = request.response;
    WebAssembly.instantiate(bytes, {
        // JavaScript Environment exported to Zig
        env: {
            // JavaScript Print Function exported to Zig
            print: function(x) { console.log(x); },

            // Write to JavaScript Console from Zig
            jsConsoleLogWrite: function (ptr, len) {
                console_log_buffer += wasm.getString(ptr, len);
            },

            // Flush JavaScript Console from Zig
            jsConsoleLogFlush: function () {
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

// Get the HTML Canvas Context
const canvas = window.document.getElementById("game_canvas");
const ctx = canvas.getContext('2d');

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