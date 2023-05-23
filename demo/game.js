// From https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7

// References to Exported Zig Functions
const Game = {
    'print': null,
    'get_pixel_color': null,
};

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
        ctx.fillRect(0, 0, 100, 100);
        for (var x = 0; x < 10; x++) {
            for (var y = 0; y < 10; y++) {
                var cell = Game.get_pixel_color(x, y);
                if (cell == 1) {
                    ctx.fillStyle = "red";
                } else if (cell == 2) {
                    ctx.fillStyle = "grey";
                } else {
                    ctx.fillStyle = "white";
                }
                ctx.fillRect(x*10, y*10, (x*10)+10, (y*10)+10);
            }
        }

        // loop to next frame
        window.requestAnimationFrame(loop);
    };
    loop();
};
