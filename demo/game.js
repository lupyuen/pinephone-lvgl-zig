// From https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7

// References to Exported Zig Functions
var Game;

// Load the WebAssembly Module
const request = new XMLHttpRequest();
request.open('GET', 'madelbrot.wasm');
request.responseType = 'arraybuffer';
request.send();

request.onload = function() {
    var bytes = request.response;
    WebAssembly.instantiate(bytes, {
        env: {}
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
        ctx.fillStyle = "white"; // clear the canvas
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        for (var x = 0; x < canvas.width; x++) {
            for (var y = 0; y < canvas.height; y++) {
                // Get the Pixel Color
                var cell = Game.get_pixel_color(x, y);

                // Render the Pixel
                if (cell < 10) {
                    ctx.fillStyle = "red";
                } else if (cell < 128) {
                    ctx.fillStyle = "grey";
                } else {
                    ctx.fillStyle = "white";
                }
                ctx.fillRect(x, y, x + 1, y + 1);
            }
        }

        // loop to next frame
        ////window.requestAnimationFrame(loop);
    };
    loop();
};
