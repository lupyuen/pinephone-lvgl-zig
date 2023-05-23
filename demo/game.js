// From https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7
request = new XMLHttpRequest();
request.open('GET', 'game.wasm');
request.responseType = 'arraybuffer';
request.send();

request.onload = function() {
    var bytes = request.response;
    WebAssembly.instantiate(bytes, {
        env: {}
    }).then(result => {
        // store references to Zig functions
        get_pos = result.instance.export.get_pos;
        // repeat etc ...
    });
};