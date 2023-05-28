// Render Zig Program in WebAssembly. Based on...
// https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7
// https://github.com/daneelsan/zig-wasm-logger/blob/master/script.js

// References to Exported Zig Functions
let Game;

// Export JavaScript Functions to Zig
let importObject = {
    // JavaScript Environment exported to Zig
    env: {
        // JavaScript Print Function exported to Zig
        print: function(x) { console.log(x); }
    }
};

// Get the HTML Canvas Context
const canvas = window.document.getElementById("game_canvas");
const context = canvas.getContext("2d");

// Main Function
function main() {
    console.log("main: start");

    // Render Loop
    const loop = function() {
        console.log("loop: start");

        // Clear the HTML Canvas
        context.fillStyle = "white";
        context.fillRect(0, 0, canvas.width, canvas.height);

        // For every Pixel in HTML Canvas...
        for (let x = 0; x < canvas.width; x++) {
            for (let y = 0; y < canvas.height; y++) {

                // Get the Pixel Color from Zig
                const color = Game.instance.exports
                    .get_pixel_color(x, y);

                // Render the Pixel in HTML Canvas
                if (color < 10) {
                    context.fillStyle = "red";
                } else if (color < 128) {
                    context.fillStyle = "grey";
                } else {
                    context.fillStyle = "white";
                }
                context.fillRect(x, y, x + 1, y + 1);
            }
        }

        // Loop to next frame. Disabled for now because it slows down the browser.
        // TODO: window.requestAnimationFrame(loop);

        console.log("loop: end");
    };
    loop();
    console.log("main: end");
};

// Load the WebAssembly Module
// https://developer.mozilla.org/en-US/docs/WebAssembly/JavaScript_interface/instantiateStreaming
async function bootstrap() {

    // Store references to WebAssembly Functions and Memory exported by Zig
    Game = await WebAssembly.instantiateStreaming(
        fetch("mandelbrot.wasm"),
        importObject
    );

    // Start the Main Function
    main();
}

// Start the loading of WebAssembly Module
bootstrap();
