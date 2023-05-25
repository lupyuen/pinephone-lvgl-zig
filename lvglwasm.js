// From https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7

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
            print: function(x) { console.log(x); }
        }
    }).then(result => {
        // Store references to Zig functions
        Game = result.instance.exports;

        // Start the Main Loop
        main();
    });
};

// Get the HTML Canvas Context
const canvas = window.document.getElementById("game_canvas");
const ctx = canvas.getContext('2d');

// Main Loop
const main = function() {
    console.log("Main function started");

    const loop = function() {
        // TODO: Init LVGL

        // Render the LVGL Widgets
        Game.lv_demo_widgets();
        console.log("lv_demo_widgets done");

        // TODO: Render the LVGL Display

        // loop to next frame. Disabled for now because it slows down the browser.
        // TODO: window.requestAnimationFrame(loop);
    };
    loop();
};
