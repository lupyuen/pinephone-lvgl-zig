![LVGL for PinePhone (and WebAssembly) with Zig and Apache NuttX RTOS](https://lupyuen.github.io/images/lvgl2-zig.jpg)

# LVGL for PinePhone (and WebAssembly) with Zig and Apache NuttX RTOS

Read the articles...

-   ["NuttX RTOS for PinePhone: Boot to LVGL"](https://lupyuen.github.io/articles/lvgl2)

-   ["Build an LVGL Touchscreen App with Zig"](https://lupyuen.github.io/articles/lvgl)

Can we build an __LVGL App in Zig__ for PinePhone... That will run on Apache NuttX RTOS?

Can we preview a PinePhone App with __Zig, LVGL and WebAssembly__ in a Web Browser? To make the UI Coding a little easier?

Let's find out!

# LVGL Zig App

Let's run this LVGL Zig App on PinePhone...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/c7a33f1fe3af4babaa8bc5502ca2b719ae95c2ca/lvgltest.zig#L55-L89

_How is createWidgetsWrapped called?_

`createWidgetsWrapped` will be called by the LVGL Widget Demo [`lv_demo_widgets`](https://github.com/lvgl/lvgl/blob/v8.3.3/demos/widgets/lv_demo_widgets.c#L96-L198), which we'll replace by this Zig version...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/c7a33f1fe3af4babaa8bc5502ca2b719ae95c2ca/lvgltest.zig#L32-L41

_Where's the Zig Wrapper for LVGL?_

Our Zig Wrapper for LVGL is defined here...

-   [lvgl.zig](https://github.com/lupyuen/pinephone-lvgl-zig/blob/main/lvgl.zig)

We also have a version of the LVGL Zig Code that doesn't call the Zig Wrapper...

-   [lvgltest.zig](https://github.com/lupyuen/pinephone-lvgl-zig/blob/c7a33f1fe3af4babaa8bc5502ca2b719ae95c2ca/lvgltest.zig#L91-L126)

# Build LVGL Zig App

NuttX Build runs this GCC Command to compile [lv_demo_widgets.c](https://github.com/lvgl/lvgl/blob/v8.3.3/demos/widgets/lv_demo_widgets.c#L96-L198) for PinePhone...

```bash
$ make --trace
...
cd $HOME/PinePhone/wip-nuttx/apps/graphics/lvgl
aarch64-none-elf-gcc
  -c
  -fno-common
  -Wall
  -Wstrict-prototypes
  -Wshadow
  -Wundef
  -Werror
  -Os
  -fno-strict-aliasing
  -fomit-frame-pointer
  -g
  -march=armv8-a
  -mtune=cortex-a53
  -isystem $HOME/PinePhone/wip-nuttx/nuttx/include
  -D__NuttX__ 
  -pipe
  -I $HOME/PinePhone/wip-nuttx/apps/graphics/lvgl
  -I "$HOME/PinePhone/wip-nuttx/apps/include"
  -Wno-format
  -Wno-unused-variable
  "-I./lvgl/src/core"
  "-I./lvgl/src/draw"
  "-I./lvgl/src/draw/arm2d"
  "-I./lvgl/src/draw/nxp"
  "-I./lvgl/src/draw/nxp/pxp"
  "-I./lvgl/src/draw/nxp/vglite"
  "-I./lvgl/src/draw/sdl"
  "-I./lvgl/src/draw/stm32_dma2d"
  "-I./lvgl/src/draw/sw"
  "-I./lvgl/src/draw/swm341_dma2d"
  "-I./lvgl/src/font"
  "-I./lvgl/src/hal"
  "-I./lvgl/src/misc"
  "-I./lvgl/src/widgets"
  "-DLV_ASSERT_HANDLER=ASSERT(0);"   
  lvgl/demos/widgets/lv_demo_widgets.c
  -o  lvgl/demos/widgets/lv_demo_widgets.c.Users.Luppy.PinePhone.wip-nuttx.apps.graphics.lvgl.o
```

We'll copy the above GCC Options to the Zig Compiler and build this Zig Program for PinePhone...

-   [lvgltest.zig](https://github.com/lupyuen/pinephone-lvgl-zig/blob/main/lvgltest.zig)

Here's the Shell Script...

```bash
## Build the LVGL Zig App
function build_zig {

  ## Go to LVGL Zig Folder
  pushd ../pinephone-lvgl-zig
  git pull

  ## Check that NuttX Build has completed and `lv_demo_widgets.*.o` exists
  if [ ! -f ../apps/graphics/lvgl/lvgl/demos/widgets/lv_demo_widgets.*.o ] 
  then
    echo "*** Error: Build NuttX first before building Zig app"
    exit 1
  fi

  ## Compile the Zig App for PinePhone 
  ## (armv8-a with cortex-a53)
  ## TODO: Change ".." to your NuttX Project Directory
  zig build-obj \
    --verbose-cimport \
    -target aarch64-freestanding-none \
    -mcpu cortex_a53 \
    -isystem "../nuttx/include" \
    -I "../apps/include" \
    -I "../apps/graphics/lvgl" \
    -I "../apps/graphics/lvgl/lvgl/src/core" \
    -I "../apps/graphics/lvgl/lvgl/src/draw" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/arm2d" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp/pxp" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp/vglite" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/sdl" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/stm32_dma2d" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/sw" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/swm341_dma2d" \
    -I "../apps/graphics/lvgl/lvgl/src/font" \
    -I "../apps/graphics/lvgl/lvgl/src/hal" \
    -I "../apps/graphics/lvgl/lvgl/src/misc" \
    -I "../apps/graphics/lvgl/lvgl/src/widgets" \
    lvgltest.zig

  ## Copy the compiled app to NuttX and overwrite `lv_demo_widgets.*.o`
  ## TODO: Change ".." to your NuttX Project Directory
  cp lvgltest.o \
    ../apps/graphics/lvgl/lvgl/demos/widgets/lv_demo_widgets.*.o

  ## Return to NuttX Folder
  popd
}

## Download the LVGL Zig App
git clone https://github.com/lupyuen/pinephone-lvgl-zig

## Build NuttX for PinePhone
cd nuttx
make -j

## Build the LVGL Zig App
build_zig

## Link the LVGL Zig App with NuttX
make -j
```

[(Original Build Script)](https://gist.github.com/lupyuen/aa1f5c0c45e6029b10e5e2f955d8386c)

[(Updated Build Script)](https://github.com/lupyuen/pinephone-lvgl-zig/blob/7ea517d66934fb17a8521e6629e9640670290db8/build.sh#L143-L173)

And our LVGL Zig App runs OK on PinePhone!

![LVGL for PinePhone with Zig and Apache NuttX RTOS](https://lupyuen.github.io/images/lvgl2-zig.jpg)

# Simulate PinePhone UI with Zig, LVGL and WebAssembly

We're now building a __Feature Phone UI__ for NuttX on PinePhone...

Can we simulate the Feature Phone UI with __Zig, LVGL and WebAssembly__ in a Web Browser? To make the UI Coding a little easier?

We have previously created a simple __LVGL App with Zig__ for PinePhone...

- [pinephone-lvgl-zig](https://github.com/lupyuen/pinephone-lvgl-zig)

Zig natively supports __WebAssembly__...

- [WebAssembly on Zig](https://ziglang.org/documentation/master/#WebAssembly)

So we might run __Zig + JavaScript__ in a Web Browser like so...

- [WebAssembly With Zig in a Web Browser](https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7)

But LVGL doesn't work with JavaScript yet. LVGL runs in a Web Browser by compiling with Emscripten and SDL...

- [LVGL with Emscripten and SDL](https://github.com/lvgl/lv_web_emscripten)

Therefore we shall do this...

1.  Use Zig to compile LVGL from C to WebAssembly [(With `zig cc`)](https://github.com/lupyuen/zig-bl602-nuttx#zig-compiler-as-drop-in-replacement-for-gcc)

1.  Use Zig to connect the JavaScript UI (canvas rendering + input events) to LVGL WebAssembly [(Like this)](https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7)

# WebAssembly Demo with Zig and JavaScript

We can run __Zig (WebAssembly) + JavaScript__ in a Web Browser like so...

- [WebAssembly With Zig in a Web Browser](https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7)

Let's run a simple demo...

- [demo/madelbrot.zig](demo/madelbrot.zig): Zig Program that compiles to WebAssembly

- [demo/game.js](demo/game.js): JavaScript that loads the Zig WebAssembly

- [demo/demo.html](demo/demo.html): HTML that calls the JavaScript

To compile Zig to WebAssembly...

```bash
git clone --recursive https://github.com/lupyuen/pinephone-lvgl-zig
cd pinephone-lvgl-zig
cd demo
zig build-lib \
  madelbrot.zig \
  -target wasm32-freestanding \
  -dynamic \
  -rdynamic
```

[(According to this)](https://ziglang.org/documentation/master/#Freestanding)

This produces the Compiled WebAssembly [`mandelbrot.wasm`](mandelbrot.wasm).

Start a Local Web Server. [(Like Web Server for Chrome)](https://chrome.google.com/webstore/detail/web-server-for-chrome/ofhbbkphhbklhfoeikjpcbhemlocgigb)

Browse to `demo/demo.html`. We should see the Mandelbrot Set yay!

![Mandelbrot Set rendered with Zig and WebAssembly](https://lupyuen.github.io/images/zig-wasm.png)

# Import JavaScript Functions into Zig

_How do we import JavaScript Functions into our Zig Program?_

This is documented here...

- [WebAssembly on Zig](https://ziglang.org/documentation/master/#WebAssembly)

In our Zig Program, this is how we import and call a JavaScript Function: [demo/madelbrot.zig](demo/madelbrot.zig)

```zig
// extern functions refer to the exterior JS namespace
// when importing wasm code, the `print` func must be provided
extern fn print(i32) void;
...
// Test printing to JavaScript Console.
// Warning: This is slow!
if (iterations == 1) { print(iterations); }
```

We define the JavaScript Function `print` when loading the WebAssembly Module in our JavaScript: [demo/game.js](demo/game.js)

```javascript
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
```

_Will this work for passing Strings and Buffers as parameters?_

Nope, the parameter will be passed as a number. (Probably a WebAssembly Data Address)

To pass Strings and Buffers between JavaScript and Zig, see [daneelsan/zig-wasm-logger](https://github.com/daneelsan/zig-wasm-logger)
 and [mitchellh/zig-js](https://github.com/mitchellh/zig-js)

TODO: Change `request.onload` to `fetch` [(Like this)](https://github.com/daneelsan/zig-wasm-logger/blob/master/script.js)

# Compile Zig LVGL App to WebAssembly

_Does our Zig LVGL App lvgltest.zig compile to WebAssembly?_

Let's take the earlier steps to compile our Zig LVGL App `lvgltest.zig`. To compile for WebAssembly, we change...

- `zig build-obj` to `zig build-lib`

- Target becomes `-target wasm32-freestanding`

- Remove `-mcpu`

- Add `-dynamic` and `-rdynamic`

Like this...

```bash
  ## Compile the Zig App for WebAssembly 
  ## TODO: Change ".." to your NuttX Project Directory
  zig build-lib \
    --verbose-cimport \
    -target wasm32-freestanding \
    -dynamic \
    -rdynamic \
    -isystem "../nuttx/include" \
    -I "../apps/include" \
    -I "../apps/graphics/lvgl" \
    -I "../apps/graphics/lvgl/lvgl/src/core" \
    -I "../apps/graphics/lvgl/lvgl/src/draw" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/arm2d" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp/pxp" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp/vglite" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/sdl" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/stm32_dma2d" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/sw" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/swm341_dma2d" \
    -I "../apps/graphics/lvgl/lvgl/src/font" \
    -I "../apps/graphics/lvgl/lvgl/src/hal" \
    -I "../apps/graphics/lvgl/lvgl/src/misc" \
    -I "../apps/graphics/lvgl/lvgl/src/widgets" \
    lvgltest.zig
```

[(According to this)](https://ziglang.org/documentation/master/#Freestanding)

OK no errors, this produces the Compiled WebAssembly `lvgltest.wasm`.

Now we tweak [`lvgltest.zig`](lvgltest.zig) for WebAssembly, and call it [`lvglwasm.zig`](lvglwasm.zig)...

```bash
  ## Compile the Zig App for WebAssembly 
  ## TODO: Change ".." to your NuttX Project Directory
  zig build-lib \
    --verbose-cimport \
    -target wasm32-freestanding \
    -dynamic \
    -isystem "../nuttx/include" \
    -I "../apps/include" \
    -I "../apps/graphics/lvgl" \
    -I "../apps/graphics/lvgl/lvgl/src/core" \
    -I "../apps/graphics/lvgl/lvgl/src/draw" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/arm2d" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp/pxp" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp/vglite" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/sdl" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/stm32_dma2d" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/sw" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/swm341_dma2d" \
    -I "../apps/graphics/lvgl/lvgl/src/font" \
    -I "../apps/graphics/lvgl/lvgl/src/hal" \
    -I "../apps/graphics/lvgl/lvgl/src/misc" \
    -I "../apps/graphics/lvgl/lvgl/src/widgets" \
    lvglwasm.zig
```

[(According to this)](https://ziglang.org/documentation/master/#Freestanding)

This produces the Compiled WebAssembly [`lvglwasm.wasm`](lvglwasm.wasm).

Start a Local Web Server. [(Like Web Server for Chrome)](https://chrome.google.com/webstore/detail/web-server-for-chrome/ofhbbkphhbklhfoeikjpcbhemlocgigb)

Browse to our HTML [`lvglwasm.html`](lvglwasm.html). Which calls our JavaScript [`lvglwasm.js`](lvglwasm.js) to load the Compiled WebAssembly.

Our JavaScript [`lvglwasm.js`](lvglwasm.js) calls the Zig Function `lv_demo_widgets` that's exported to WebAssembly by our Zig App [`lvglwasm.zig`](lvglwasm.zig).

But the WebAssembly won't load because we haven't fixed the WebAssembly Imports...

# Fix WebAssembly Imports

_What happens if we don't fix the WebAssembly Imports in our Zig Program?_

Suppose we forgot to import `puts()`. JavaScript Console will show this error when the Web Browser loads our Zig WebAssembly...

```text
Uncaught (in promise) LinkError:
WebAssembly.instantiate():
Import #0 module="env" function="puts" error:
function import requires a callable
```

_But we haven't compiled the LVGL Library to WebAssembly!_

Yep that's why LVGL Functions like `lv_label_create` are failing when the Web Browser loads our Zig WebAssembly...

```text
Uncaught (in promise) LinkError:
WebAssembly.instantiate():
Import #1 module="env" function="lv_label_create" error:
function import requires a callable
```

We need to compile the LVGL Library with `zig cc` and link it in...

# Compile LVGL to WebAssembly with Zig Compiler

_How to compile LVGL from C to WebAssembly with Zig Compiler?_

We'll use [`zig cc`](https://github.com/lupyuen/zig-bl602-nuttx#zig-compiler-as-drop-in-replacement-for-gcc), since Zig can compile C programs to WebAssembly.

In the previous section, we're missing the LVGL Function `lv_label_create` in our Zig WebAssembly Module.

`lv_label_create` is defined in this file...

```text
apps/lvgl/src/widgets/lv_label.c
```

According to `make --trace`, `lv_label.c` is compiled with...

```bash
## Compile LVGL in C
## TODO: Change "../../.." to your NuttX Project Directory
cd apps/graphics/lvgl
aarch64-none-elf-gcc \
  -c \
  -fno-common \
  -Wall \
  -Wstrict-prototypes \
  -Wshadow \
  -Wundef \
  -Werror \
  -Os \
  -fno-strict-aliasing \
  -fomit-frame-pointer \
  -ffunction-sections \
  -fdata-sections \
  -g \
  -march=armv8-a \
  -mtune=cortex-a53 \
  -isystem ../../../nuttx/include \
  -D__NuttX__  \
  -pipe \
  -I ../../../apps/graphics/lvgl \
  -I "../../../apps/include" \
  -Wno-format \
  -Wno-format-security \
  -Wno-unused-variable \
  "-I./lvgl/src/core" \
  "-I./lvgl/src/draw" \
  "-I./lvgl/src/draw/arm2d" \
  "-I./lvgl/src/draw/nxp" \
  "-I./lvgl/src/draw/nxp/pxp" \
  "-I./lvgl/src/draw/nxp/vglite" \
  "-I./lvgl/src/draw/sdl" \
  "-I./lvgl/src/draw/stm32_dma2d" \
  "-I./lvgl/src/draw/sw" \
  "-I./lvgl/src/draw/swm341_dma2d" \
  "-I./lvgl/src/font" \
  "-I./lvgl/src/hal" \
  "-I./lvgl/src/misc" \
  "-I./lvgl/src/widgets" \
  "-DLV_ASSERT_HANDLER=ASSERT(0);" \
  ./lvgl/src/widgets/lv_label.c \
  -o  lv_label.c.Users.Luppy.PinePhone.wip-nuttx.apps.graphics.lvgl.o
```

Let's use the Zig Compiler to compile `lv_label.c` from C to WebAssembly....

- Change `aarch64-none-elf-gcc` to `zig cc`

- Remove `-march`, `-mtune`

- Add the target `-target wasm32-freestanding`

- Add `-dynamic` and `-rdynamic`

- Add `-lc` (because we're calling C Standard Library)

- Add `-DFAR=` (because we won't need Far Pointers)

- Add `-DLV_USE_LOG` (to enable logging)

- Add `-DLV_LOG_LEVEL=LV_LOG_LEVEL_TRACE` (for detailed logging)

- Add `-DLV_MEM_SIZE=1000000` (for 1,000,000 bytes of dynamically-allocated memory)

- Change `"-DLV_ASSERT_HANDLER..."` to...

  ```text
  "-DLV_ASSERT_HANDLER={void lv_assert_handler(void); lv_assert_handler();}"
  ```

  (To handle Assertion Failures ourselves)

- Change the output to...

  ```text
  -o ../../../pinephone-lvgl-zig/lv_label.o`
  ```

Like this...

```bash
## Compile LVGL from C to WebAssembly
## TODO: Change "../../.." to your NuttX Project Directory
cd apps/graphics/lvgl
zig cc \
  -target wasm32-freestanding \
  -dynamic \
  -rdynamic \
  -lc \
  -DFAR= \
  -DLV_USE_LOG \
  -DLV_LOG_LEVEL=LV_LOG_LEVEL_TRACE \
  -DLV_MEM_SIZE=1000000 \
  "-DLV_ASSERT_HANDLER={void lv_assert_handler(void); lv_assert_handler();}" \
  -c \
  -fno-common \
  -Wall \
  -Wstrict-prototypes \
  -Wshadow \
  -Wundef \
  -Werror \
  -Os \
  -fno-strict-aliasing \
  -fomit-frame-pointer \
  -ffunction-sections \
  -fdata-sections \
  -g \
  -isystem ../../../nuttx/include \
  -D__NuttX__  \
  -pipe \
  -I ../../../apps/graphics/lvgl \
  -I "../../../apps/include" \
  -Wno-format \
  -Wno-format-security \
  -Wno-unused-variable \
  "-I./lvgl/src/core" \
  "-I./lvgl/src/draw" \
  "-I./lvgl/src/draw/arm2d" \
  "-I./lvgl/src/draw/nxp" \
  "-I./lvgl/src/draw/nxp/pxp" \
  "-I./lvgl/src/draw/nxp/vglite" \
  "-I./lvgl/src/draw/sdl" \
  "-I./lvgl/src/draw/stm32_dma2d" \
  "-I./lvgl/src/draw/sw" \
  "-I./lvgl/src/draw/swm341_dma2d" \
  "-I./lvgl/src/font" \
  "-I./lvgl/src/hal" \
  "-I./lvgl/src/misc" \
  "-I./lvgl/src/widgets" \
  ./lvgl/src/widgets/lv_label.c \
  -o ../../../pinephone-lvgl-zig/lv_label.o
```

This produces the Compiled WebAssembly `lv_label.o`.

_Will Zig Compiler let us link `lv_label.o` with our Zig LVGL App?_

Let's ask Zig Compiler to link `lv_label.o` with our Zig LVGL App [`lvglwasm.zig`](lvglwasm.zig)...

```bash
  ## Compile the Zig App for WebAssembly 
  ## TODO: Change ".." to your NuttX Project Directory
  zig build-lib \
    --verbose-cimport \
    -target wasm32-freestanding \
    -dynamic \
    -rdynamic \
    -lc \
    -DFAR= \
    -DLV_USE_LOG \
    -DLV_LOG_LEVEL=LV_LOG_LEVEL_TRACE \
    -DLV_MEM_SIZE=1000000 \
    "-DLV_ASSERT_HANDLER={void lv_assert_handler(void); lv_assert_handler();}" \
    -I . \
    -isystem "../nuttx/include" \
    -I "../apps/include" \
    -I "../apps/graphics/lvgl" \
    -I "../apps/graphics/lvgl/lvgl/src/core" \
    -I "../apps/graphics/lvgl/lvgl/src/draw" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/arm2d" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp/pxp" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/nxp/vglite" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/sdl" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/stm32_dma2d" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/sw" \
    -I "../apps/graphics/lvgl/lvgl/src/draw/swm341_dma2d" \
    -I "../apps/graphics/lvgl/lvgl/src/font" \
    -I "../apps/graphics/lvgl/lvgl/src/hal" \
    -I "../apps/graphics/lvgl/lvgl/src/misc" \
    -I "../apps/graphics/lvgl/lvgl/src/widgets" \
    lvglwasm.zig \
    lv_label.o
```

[(Source)](https://github.com/lupyuen/pinephone-lvgl-zig/blob/7ea517d66934fb17a8521e6629e9640670290db8/build.sh#L65-L141)

Now we see this error in the Web Browser...

```text
Uncaught (in promise) LinkError: 
WebAssembly.instantiate(): 
Import #0 module="env" function="lv_obj_clear_flag" error:
function import requires a callable
```

`lv_label_create` is no longer missing, because Zig Compiler has linked `lv_label.o` into our Zig LVGL App.

Yep Zig Compiler will happily link WebAssembly Object Files with our Zig App yay!

Now we need to compile `lv_obj_clear_flag` and the other LVGL Files from C to WebAssembly with Zig Compiler...

# Compile Entire LVGL Library to WebAssembly

When we track down `lv_obj_clear_flag` and the other Missing Functions (by sheer tenacity), we get this trail of LVGL Source Files that need to be compiled from C to WebAssembly...

```text
widgets/lv_label.c
core/lv_obj.c
misc/lv_mem.c
core/lv_event.c
core/lv_obj_style.c
core/lv_obj_pos.c
misc/lv_txt.c
draw/lv_draw_label.c
core/lv_obj_draw.c
misc/lv_area.c
core/lv_obj_scroll.c
font/lv_font.c
core/lv_obj_class.c
(And many more)
```

[(Based on LVGL 8.3.3)](https://github.com/lvgl/lvgl/tree/v8.3.3)

So we wrote a script to compile the above LVGL Source Files from C to WebAssembly with `zig cc`...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/1c7a3feb4500bb1103bdadc2907dd722d8e940cc/build.sh#L7-L177

Which calls `compile_lvgl` to compile a single LVGL Source File from C to WebAssembly with `zig cc`...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/1c7a3feb4500bb1103bdadc2907dd722d8e940cc/build.sh#L212-L267

_What happens after we compile the whole bunch of LVGL Source Files from C to WebAssembly?_

Now the Web Browser says that `strlen` is missing...

```text
Uncaught (in promise) LinkError: 
WebAssembly.instantiate(): 
Import #0 module="env" function="strlen" error: 
function import requires a callable
```

Let's fix `strlen`...

# C Standard Library is Missing

_But strlen should come from the C Standard Library! (musl)_

Not sure why `strlen` is missing, but we fixed it temporarily by copying from the Zig Library Source Code...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/e99593df6b46ced52f3f8ed644b9c6e455a9d682/lvglwasm.zig#L213-L265

This seems to be the [same problem mentioned here](https://github.com/andrewrk/lua-in-the-browser#status).

[(Referenced by this pull request)](https://github.com/ziglang/zig/pull/2512)

[(And this issue)](https://github.com/ziglang/zig/issues/5854)

TODO: Maybe because we didn't export `strlen` in our Main Program `lvglwasm.zig`?

TODO: Do we compile C Standard Library ourselves? From musl? Newlib? [wasi-libc](https://github.com/WebAssembly/wasi-libc)?

_What if we change the target to `wasm32-freestanding-musl`?_

Nope doesn't help, same problem.

_What if we use `zig build-exe` instead of `zig build-lib`?_

Sorry `zig build-exe` is meant for building WASI Executables. [(See this)](https://www.fermyon.com/wasm-languages/c-lang)

`zig build-exe` is not supposed to work for WebAssembly in the Web Browser. [(See this)](https://github.com/ziglang/zig/issues/1570#issuecomment-426370371)

# LVGL Porting Layer for WebAssembly

LVGL expects us to provide a `millis` function that returns the number of elapsed milliseconds...

```text
Uncaught (in promise) LinkError: 
WebAssembly.instantiate(): 
Import #0 module="env" function="millis" error: 
function import requires a callable
```

We implement `millis` ourselves for WebAssembly...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/39da0a4251a15b8a83d6631db37d554defc2daad/lvglwasm.zig#L134-L148

TODO: Fix `millis`. How would it work in WebAssembly? Using a counter?

# WebAssembly Logger for LVGL

Let's trace the LVGL Execution with a WebAssembly Logger.

(Remember: `printf` won't work in WebAssembly)

We set the Custom Logger for LVGL, so that we can print Log Messages to the JavaScript Console...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/f9dc7e1afba2f876c8397d753a79a9cb40b90b75/lvglwasm.zig#L32-L43

The Custom Logger is defined in our Zig Program...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/f9dc7e1afba2f876c8397d753a79a9cb40b90b75/lvglwasm.zig#L149-L152

`wasmlog` is our Zig Logger for WebAssembly: [wasmlog.zig](wasmlog.zig)

(Based on [daneelsan/zig-wasm-logger](https://github.com/daneelsan/zig-wasm-logger))

`jsConsoleLogWrite` and `jsConsoleLogFlush` are defined in our JavaScript...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/1b4e367095ec4ed4d8077758aa266f25f03564c9/lvglwasm.js#L14-L42

`wasm.getString` also comes from our JavaScript...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/1b4e367095ec4ed4d8077758aa266f25f03564c9/lvglwasm.js#L67-L87

Now we can see the LVGL Log Messages in the JavaScript Console yay! (Pic below)

```text
custom_logger: [Warn]	(0.001, +1)
lv_disp_get_scr_act:
no display registered to get its active screen
(in lv_disp.c line #54)
```

Let's initialise the LVGL Display...

![WebAssembly Logger for LVGL](https://lupyuen.github.io/images/zig-wasm2.png)

# Initialise LVGL Display

According to the LVGL Docs, this is how we inititialise and operate LVGL...

1.  Call `lv_init()`

1.  Register the LVGL Display and LVGL Input Devices

1.  Call `lv_tick_inc(x)` every x milliseconds in an interrupt to report the elapsed time to LVGL

1.  Call `lv_timer_handler()` every few milliseconds to handle LVGL related tasks

[(Source)](https://docs.lvgl.io/8.3/porting/project.html#initialization)

To register the LVGL Display, we should do this...

- [Create LVGL Draw Buffer](https://docs.lvgl.io/8.3/porting/display.html#draw-buffer)

- [Register LVGL Display](https://docs.lvgl.io/8.3/porting/display.html#examples)

But we can't do this in Zig...

```zig
// Nope! lv_disp_drv_t is an Opaque Type
var disp_drv = c.lv_disp_drv_t{};
c.lv_disp_drv_init(&disp_drv);
```

Because `lv_disp_drv_t` is an Opaque Type.

[(`lv_disp_drv_t` contains Bit Fields, hence it's Opaque)](https://lupyuen.github.io/articles/lvgl#appendix-zig-opaque-types)

Thus we apply this workaround to create `lv_disp_drv_t` in C...

- ["Fix Opaque Types"](https://lupyuen.github.io/articles/lvgl#fix-opaque-types)

And we get this LVGL Display Interface for Zig: [display.c](display.c)

Finally this is how we initialise the LVGL Display in Zig WebAssembly...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/1c7a3feb4500bb1103bdadc2907dd722d8e940cc/lvglwasm.zig#L39-L71

# LVGL Memory Allocation

_What happens if we don't set `-DLV_MEM_SIZE=1000000`?_

The LVGL Memory Allocation fails...

```text
lv_demo_widgets: start
[Info]	lv_init: begin 	(in lv_obj.c line #102)
[Warn]	lv_init: Log level is set to 'Trace' which makes LVGL much slower 	(in lv_obj.c line #176)
[Error]	block_next: Asserted at expression: !block_is_last(block) 	(in lv_tlsf.c line #458)
lv_assert_handler: assertion failed
[Error]	block_next: Asserted at expression: !block_is_last(block) 	(in lv_tlsf.c line #458)
lv_assert_handler: assertion failed
[Trace]	lv_init: finished 	(in lv_obj.c line #183)

[Info]	lv_mem_alloc: couldn't allocate memory (106824 bytes) 	(in lv_mem.c line #140)
[Info]	lv_mem_alloc: used:   1480 (  3 %), frag:   0 %, biggest free:  64056 	(in lv_mem.c line #146)
[Error]	lv_disp_drv_register: Asserted at expression: disp != NULL (Out of memory) 	(in lv_hal_disp.c line #162)
lv_assert_handler: assertion failed
```

[`lv_mem_alloc`](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_mem.c#L120-L148) calls [`lv_tlsf_malloc`](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_tlsf.c#L1098-L1104) and fails to allocate memory.

That's because the Dynamic Memory Pool is too small: We need 106,824 bytes but only 64,056 bytes are available.

Hence we set `-DLV_MEM_SIZE=1000000` in the Zig Compiler.

TODO: Why did [`block_next`](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_tlsf.c#L453-L460) fail? (`lv_tlsf.c` line #458)

[Two-Level Segregate Fit (TLSF) Allocator](http://www.gii.upv.es/tlsf/)

[`block_next`](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_tlsf.c#L453-L460) calls [`offset_to_block`](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_tlsf.c#L440-L444), which calls...
- [`tlsf_cast`](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_tlsf.c#L274)

# TODO

TODO: Why no screen found in [lv_obj_get_disp](https://github.com/lvgl/lvgl/blob/v8.3.3/src/core/lv_obj_tree.c#L270-L289)?

```text
[Trace]	lv_init: finished 	(in lv_obj.c line #183)
[Info]	lv_obj_create: begin 	(in lv_obj.c line #206)
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #287)
```

TODO: Call `lv_tick_inc` and `lv_timer_handler`

1.  Call `lv_tick_inc(x)` every x milliseconds in an interrupt to report the elapsed time to LVGL

1.  Call `lv_timer_handler()` every few milliseconds to handle LVGL related tasks

[(Source)](https://docs.lvgl.io/8.3/porting/project.html#initialization)

# Render LVGL Display in Web Browser

TODO: Render LVGL Display

TODO: Use Zig to connect the JavaScript UI (canvas rendering + input events) to LVGL WebAssembly [(Like this)](https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7)

https://github.com/daneelsan/minimal-zig-wasm-canvas

https://github.com/daneelsan/Dodgeballz/tree/master/src

https://github.com/daneelsan/zig-wefx/blob/master/wefx/WEFX.zig

# Zig with Rancher Desktop

The [Official Zig Download for macOS](https://ziglang.org/download/) no longer runs on my 10-year-old MacBook Pro that's stuck on macOS 10.15.7. 😢

To run the latest version of Zig Compiler, I use Rancher Desktop and VSCode Remote Containers...

- [VSCode Remote Containers on Rancher Desktop](https://docs.rancherdesktop.io/how-to-guides/vs-code-remote-containers)

Here's how...

1.  Install [Rancher Desktop](https://rancherdesktop.io/)

1.  In Rancher Desktop, click "Settings"...

    Set "Container Engine" to "dockerd (moby)"

    Under "Kubernetes", uncheck "Enable Kubernetes"

    (To reduce CPU Utilisation)

1.  Restart VSCode to use the new PATH

    Install the VSCode Docker Extension

    In VSCode, click the Docker icon in the Left Bar

1.  Under "Containers", click "+" and "New Dev Container"

    Select "Alpine"

1.  In a while, we'll see VSCode running inside the Alpine Linux Container

    We have finally Linux on macOS!

    ```text
    $ uname -a
    Linux bc0c45900671 5.15.96-0-virt #1-Alpine SMP Sun, 26 Feb 2023 15:14:12 +0000 x86_64 GNU/Linux
    ```

1.  Now we can download and run the latest and greatest Zig Compiler for Linux x64 [(from here)](https://ziglang.org/download/)

    ```bash
    wget https://ziglang.org/builds/zig-linux-x86_64-0.11.0-dev.3283+7cb3a6750.tar.xz
    tar -xvf zig-linux-x86_64-0.11.0-dev.3283+7cb3a6750.tar.xz 
    zig-linux-x86_64-0.11.0-dev.3283+7cb3a6750/zig version
    ```

1.  To install the NuttX Toolchain on Alpine Linux...

    ["Build Apache NuttX RTOS on Alpine Linux"](https://gist.github.com/lupyuen/880caa0547378028243b8cc5cfdc50a8)

1.  To forward Network Ports, click the "Ports" tab beside "Terminal"

    To configure other features in the Alpine Linux Container, edit the file `.devcontainer/devcontainer.json`

# Zig Version

(Here's what happens if we don't run Zig in a Container)

_Which version of Zig are we using?_

We're using an older version: `0.10.0-dev.2351+b64a1d5ab`

Sadly Zig 0.10.1 won't run on my 10-year-old MacBook Pro that's stuck on macOS 10.15.7 😢

```text
→ #  Compile the Zig App for PinePhone
  #  (armv8-a with cortex-a53)
  #  TODO: Change ".." to your NuttX Project Directory
  zig build-obj \
    --verbose-cimport \
    -target aarch64-freestanding-none \
    -mcpu cortex_a53 \
    -isystem "../nuttx/include" \
    -I "../apps/include" \
    lvgltest.zig

dyld: lazy symbol binding faileddyld: lazy symbol binding faileddyld: lazy symbol binding failed: Symbol not found: ___ulock_wai: Symbol not found: ___ulock_wait2
  Referenced from: /Users/Lupt2
  Referenced from: /Users/Lupdyld: lazy symbol binding failedpy/zig-macos-x86_64-0.10.1/zig (py/zig-macos-x86_64-0.10.1/zig (dyld: lazy symbol binding failedwhich was built for Mac OS X 11.: Symbol not found: ___ulock_wai: Symbol not found: ___ulock_waiwhich was built for Mac OS X 11.7)
  Expected in: /usr/lib/libSy: Symbol not found: ___ulock_wai7)
  Expected in: /usr/lib/libSystem.B.dylib

stem.B.dylib

t2
  Referenced from: /Users/Lupt2
  Referenced from: /Users/Lupt2
  Referenced from: /Users/Luppy/zig-macos-x86_64-0.10.1/zig (py/zig-macos-x86_64-0.10.1/zig (py/zig-macos-x86_64-0.10.1/zig (which was built for Mac OS X 11.which was built for Mac OS X 11.which was built for Mac OS X 11.7)
  Expected in: /usr/lib/libSy7)
  Expected in: /usr/lib/libSydyld: Symbol not found: ___ulock7)
  Expected in: /usr/lib/libSystem.B.dylib

stem.B.dylib

_wait2
  Referenced from: /Usersstem.B.dylib

/Luppy/zig-macos-x86_64-0.10.1/zdyld: Symbol not found: ___ulockig (which was built for Mac OS X_wait2
  Referenced from: /Users 11.7)
  Expected in: /usr/lib/ldyld: Symbol not found: ___ulockdyld: Symbol not found: ___ulock/Luppy/zig-macos-x86_64-0.10.1/zibSystem.B.dylib

_wait2
  Referenced from: /Usersig (which was built for Mac OS X_wait2
  Referenced from: /Users/Luppy/zig-macos-x86_64-0.10.1/z 11.7)
  Expected in: /usr/lib/l/Luppy/zig-macos-x86_64-0.10.1/zig (which was built for Mac OS XibSystem.B.dylib

ig (which was built for Mac OS X 11.7)
  Expected in: /usr/lib/l 11.7)
  Expected in: /usr/lib/libSystem.B.dylib

ibSystem.B.dylib

dyld: Symbol not found: ___ulockdyld: lazy symbol binding faileddyld: lazy symbol binding failed[1]    11157 abort      zig build-obj --verbose-cimport -target aarch64-freestanding-none -mcpu    -I
```

I tried building Zig from source, but it didn't work either...

# Build Zig from Source

The [Official Zig Download for macOS](https://ziglang.org/download/) no longer runs on my 10-year-old MacBook Pro that's stuck on macOS 10.15.7. (See the previous section)

So I tried building Zig from Source according to these instructions...

- [Building Zig from Source](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source)

Here's what I did...

```bash
brew install llvm
git clone --recursive https://github.com/ziglang/zig
cd zig

mkdir build
cd build
cmake .. -DZIG_STATIC_LLVM=ON -DCMAKE_PREFIX_PATH="$(brew --prefix llvm);$(brew --prefix zstd)"
make install
```

`brew install llvm` failed...

```text
==> cmake -G Unix Makefiles .. -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra;lld;lldb;mlir;polly -DLLVM_ENABLE_RUNTIMES=compiler-rt;libcxx;libcxxabi;libunwind;
==> cmake --build .
Last 15 lines from /Users/Luppy/Library/Logs/Homebrew/llvm/02.cmake:
[ 51%] Building CXX object lib/Transforms/Utils/CMakeFiles/LLVMTransformUtils.dir/ValueMapper.cpp.o
cd /tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/build/lib/Transforms/Utils && /usr/local/Homebrew/Library/Homebrew/shims/mac/super/clang++ -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -I/tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/build/lib/Transforms/Utils -I/tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/lib/Transforms/Utils -I/tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/build/include -I/tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/include -stdlib=libc++ -fPIC -fvisibility-inlines-hidden -Werror=date-time -Werror=unguarded-availability-new -Wall -Wextra -Wno-unused-parameter -Wwrite-strings -Wcast-qual -Wmissing-field-initializers -pedantic -Wno-long-long -Wc++98-compat-extra-semi -Wimplicit-fallthrough -Wcovered-switch-default -Wno-class-memaccess -Wno-noexcept-type -Wnon-virtual-dtor -Wdelete-non-virtual-dtor -Wsuggest-override -Wstring-conversion -Wmisleading-indentation -Wctad-maybe-unsupported -O3 -DNDEBUG -std=c++17 -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk -MD -MT lib/Transforms/Utils/CMakeFiles/LLVMTransformUtils.dir/ValueMapper.cpp.o -MF CMakeFiles/LLVMTransformUtils.dir/ValueMapper.cpp.o.d -o CMakeFiles/LLVMTransformUtils.dir/ValueMapper.cpp.o -c /tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/lib/Transforms/Utils/ValueMapper.cpp
[ 51%] Building CXX object lib/Transforms/Utils/CMakeFiles/LLVMTransformUtils.dir/VNCoercion.cpp.o
cd /tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/build/lib/Transforms/Utils && /usr/local/Homebrew/Library/Homebrew/shims/mac/super/clang++ -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -I/tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/build/lib/Transforms/Utils -I/tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/lib/Transforms/Utils -I/tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/build/include -I/tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/include -stdlib=libc++ -fPIC -fvisibility-inlines-hidden -Werror=date-time -Werror=unguarded-availability-new -Wall -Wextra -Wno-unused-parameter -Wwrite-strings -Wcast-qual -Wmissing-field-initializers -pedantic -Wno-long-long -Wc++98-compat-extra-semi -Wimplicit-fallthrough -Wcovered-switch-default -Wno-class-memaccess -Wno-noexcept-type -Wnon-virtual-dtor -Wdelete-non-virtual-dtor -Wsuggest-override -Wstring-conversion -Wmisleading-indentation -Wctad-maybe-unsupported -O3 -DNDEBUG -std=c++17 -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk -MD -MT lib/Transforms/Utils/CMakeFiles/LLVMTransformUtils.dir/VNCoercion.cpp.o -MF CMakeFiles/LLVMTransformUtils.dir/VNCoercion.cpp.o.d -o CMakeFiles/LLVMTransformUtils.dir/VNCoercion.cpp.o -c /tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/lib/Transforms/Utils/VNCoercion.cpp
[ 51%] Linking CXX static library ../../libLLVMTransformUtils.a
cd /tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/build/lib/Transforms/Utils && /usr/local/Cellar/cmake/3.26.4/bin/cmake -P CMakeFiles/LLVMTransformUtils.dir/cmake_clean_target.cmake
cd /tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/build/lib/Transforms/Utils && /usr/local/Cellar/cmake/3.26.4/bin/cmake -E cmake_link_script CMakeFiles/LLVMTransformUtils.dir/link.txt --verbose=1
"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/libtool" -static -no_warning_for_no_symbols -o ../../libLLVMTransformUtils.a CMakeFiles/LLVMTransformUtils.dir/AddDiscriminators.cpp.o CMakeFiles/LLVMTransformUtils.dir/AMDGPUEmitPrintf.cpp.o CMakeFiles/LLVMTransformUtils.dir/ASanStackFrameLayout.cpp.o CMakeFiles/LLVMTransformUtils.dir/AssumeBundleBuilder.cpp.o CMakeFiles/LLVMTransformUtils.dir/BasicBlockUtils.cpp.o CMakeFiles/LLVMTransformUtils.dir/BreakCriticalEdges.cpp.o CMakeFiles/LLVMTransformUtils.dir/BuildLibCalls.cpp.o CMakeFiles/LLVMTransformUtils.dir/BypassSlowDivision.cpp.o CMakeFiles/LLVMTransformUtils.dir/CallPromotionUtils.cpp.o CMakeFiles/LLVMTransformUtils.dir/CallGraphUpdater.cpp.o CMakeFiles/LLVMTransformUtils.dir/CanonicalizeAliases.cpp.o CMakeFiles/LLVMTransformUtils.dir/CanonicalizeFreezeInLoops.cpp.o CMakeFiles/LLVMTransformUtils.dir/CloneFunction.cpp.o CMakeFiles/LLVMTransformUtils.dir/CloneModule.cpp.o CMakeFiles/LLVMTransformUtils.dir/CodeExtractor.cpp.o CMakeFiles/LLVMTransformUtils.dir/CodeLayout.cpp.o CMakeFiles/LLVMTransformUtils.dir/CodeMoverUtils.cpp.o CMakeFiles/LLVMTransformUtils.dir/CtorUtils.cpp.o CMakeFiles/LLVMTransformUtils.dir/Debugify.cpp.o CMakeFiles/LLVMTransformUtils.dir/DemoteRegToStack.cpp.o CMakeFiles/LLVMTransformUtils.dir/EntryExitInstrumenter.cpp.o CMakeFiles/LLVMTransformUtils.dir/EscapeEnumerator.cpp.o CMakeFiles/LLVMTransformUtils.dir/Evaluator.cpp.o CMakeFiles/LLVMTransformUtils.dir/FixIrreducible.cpp.o CMakeFiles/LLVMTransformUtils.dir/FlattenCFG.cpp.o CMakeFiles/LLVMTransformUtils.dir/FunctionComparator.cpp.o CMakeFiles/LLVMTransformUtils.dir/FunctionImportUtils.cpp.o CMakeFiles/LLVMTransformUtils.dir/GlobalStatus.cpp.o CMakeFiles/LLVMTransformUtils.dir/GuardUtils.cpp.o CMakeFiles/LLVMTransformUtils.dir/HelloWorld.cpp.o CMakeFiles/LLVMTransformUtils.dir/InlineFunction.cpp.o CMakeFiles/LLVMTransformUtils.dir/InjectTLIMappings.cpp.o CMakeFiles/LLVMTransformUtils.dir/InstructionNamer.cpp.o CMakeFiles/LLVMTransformUtils.dir/IntegerDivision.cpp.o CMakeFiles/LLVMTransformUtils.dir/LCSSA.cpp.o CMakeFiles/LLVMTransformUtils.dir/LibCallsShrinkWrap.cpp.o CMakeFiles/LLVMTransformUtils.dir/Local.cpp.o CMakeFiles/LLVMTransformUtils.dir/LoopPeel.cpp.o CMakeFiles/LLVMTransformUtils.dir/LoopRotationUtils.cpp.o CMakeFiles/LLVMTransformUtils.dir/LoopSimplify.cpp.o CMakeFiles/LLVMTransformUtils.dir/LoopUnroll.cpp.o CMakeFiles/LLVMTransformUtils.dir/LoopUnrollAndJam.cpp.o CMakeFiles/LLVMTransformUtils.dir/LoopUnrollRuntime.cpp.o CMakeFiles/LLVMTransformUtils.dir/LoopUtils.cpp.o CMakeFiles/LLVMTransformUtils.dir/LoopVersioning.cpp.o CMakeFiles/LLVMTransformUtils.dir/LowerAtomic.cpp.o CMakeFiles/LLVMTransformUtils.dir/LowerGlobalDtors.cpp.o CMakeFiles/LLVMTransformUtils.dir/LowerIFunc.cpp.o CMakeFiles/LLVMTransformUtils.dir/LowerInvoke.cpp.o CMakeFiles/LLVMTransformUtils.dir/LowerMemIntrinsics.cpp.o CMakeFiles/LLVMTransformUtils.dir/LowerSwitch.cpp.o CMakeFiles/LLVMTransformUtils.dir/MatrixUtils.cpp.o CMakeFiles/LLVMTransformUtils.dir/MemoryOpRemark.cpp.o CMakeFiles/LLVMTransformUtils.dir/MemoryTaggingSupport.cpp.o CMakeFiles/LLVMTransformUtils.dir/Mem2Reg.cpp.o CMakeFiles/LLVMTransformUtils.dir/MetaRenamer.cpp.o CMakeFiles/LLVMTransformUtils.dir/MisExpect.cpp.o CMakeFiles/LLVMTransformUtils.dir/ModuleUtils.cpp.o CMakeFiles/LLVMTransformUtils.dir/NameAnonGlobals.cpp.o CMakeFiles/LLVMTransformUtils.dir/PredicateInfo.cpp.o CMakeFiles/LLVMTransformUtils.dir/PromoteMemoryToRegister.cpp.o CMakeFiles/LLVMTransformUtils.dir/RelLookupTableConverter.cpp.o CMakeFiles/LLVMTransformUtils.dir/ScalarEvolutionExpander.cpp.o CMakeFiles/LLVMTransformUtils.dir/SCCPSolver.cpp.o CMakeFiles/LLVMTransformUtils.dir/StripGCRelocates.cpp.o CMakeFiles/LLVMTransformUtils.dir/SSAUpdater.cpp.o CMakeFiles/LLVMTransformUtils.dir/SSAUpdaterBulk.cpp.o CMakeFiles/LLVMTransformUtils.dir/SampleProfileInference.cpp.o CMakeFiles/LLVMTransformUtils.dir/SampleProfileLoaderBaseUtil.cpp.o CMakeFiles/LLVMTransformUtils.dir/SanitizerStats.cpp.o CMakeFiles/LLVMTransformUtils.dir/SimplifyCFG.cpp.o CMakeFiles/LLVMTransformUtils.dir/SimplifyIndVar.cpp.o CMakeFiles/LLVMTransformUtils.dir/SimplifyLibCalls.cpp.o CMakeFiles/LLVMTransformUtils.dir/SizeOpts.cpp.o CMakeFiles/LLVMTransformUtils.dir/SplitModule.cpp.o CMakeFiles/LLVMTransformUtils.dir/StripNonLineTableDebugInfo.cpp.o CMakeFiles/LLVMTransformUtils.dir/SymbolRewriter.cpp.o CMakeFiles/LLVMTransformUtils.dir/UnifyFunctionExitNodes.cpp.o CMakeFiles/LLVMTransformUtils.dir/UnifyLoopExits.cpp.o CMakeFiles/LLVMTransformUtils.dir/Utils.cpp.o CMakeFiles/LLVMTransformUtils.dir/ValueMapper.cpp.o CMakeFiles/LLVMTransformUtils.dir/VNCoercion.cpp.o
[ 51%] Built target LLVMTransformUtils
[ 51%] Linking CXX static library ../../../libLLVMAMDGPUDisassembler.a
cd /tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/build/lib/Target/AMDGPU/Disassembler && /usr/local/Cellar/cmake/3.26.4/bin/cmake -P CMakeFiles/LLVMAMDGPUDisassembler.dir/cmake_clean_target.cmake
cd /tmp/llvm-20230523-44290-sxekyo/llvm-project-16.0.4.src/llvm/build/lib/Target/AMDGPU/Disassembler && /usr/local/Cellar/cmake/3.26.4/bin/cmake -E cmake_link_script CMakeFiles/LLVMAMDGPUDisassembler.dir/link.txt --verbose=1
"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/libtool" -static -no_warning_for_no_symbols -o ../../../libLLVMAMDGPUDisassembler.a CMakeFiles/LLVMAMDGPUDisassembler.dir/AMDGPUDisassembler.cpp.o
[ 51%] Built target LLVMAMDGPUDisassembler
make: *** [all] Error 2
```

So I tried building LLVM from source [(from here)](https://github.com/ziglang/zig/wiki/How-to-build-LLVM,-libclang,-and-liblld-from-source#posix)...

```bash
cd ~/Downloads
git clone --depth 1 --branch release/16.x https://github.com/llvm/llvm-project llvm-project-16
cd llvm-project-16
git checkout release/16.x

mkdir build-release
cd build-release
cmake ../llvm \
  -DCMAKE_INSTALL_PREFIX=$HOME/local/llvm16-release \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_PROJECTS="lld;clang" \
  -DLLVM_ENABLE_LIBXML2=OFF \
  -DLLVM_ENABLE_TERMINFO=OFF \
  -DLLVM_ENABLE_LIBEDIT=OFF \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_PARALLEL_LINK_JOBS=1 \
  -G Ninja
ninja install
```

But LLVM fails to build...

```text
→ ninja install

[1908/4827] Building CXX object lib/Target/AMDGPU/AsmParser/CMakeFiles/LLVMAMDGPUAsmParser.dir/AMDGPUAsmParser.cpp.o
FAILED: lib/Target/AMDGPU/AsmParser/CMakeFiles/LLVMAMDGPUAsmParser.dir/AMDGPUAsmParser.cpp.o
/Applications/Xcode.app/Contents/Developer/usr/bin/g++ -DGTEST_HAS_RTTI=0 -D_DEBUG -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -I/Users/Luppy/llvm-project-16/build-release/lib/Target/AMDGPU/AsmParser -I/Users/Luppy/llvm-project-16/llvm/lib/Target/AMDGPU/AsmParser -I/Users/Luppy/llvm-project-16/llvm/lib/Target/AMDGPU -I/Users/Luppy/llvm-project-16/build-release/lib/Target/AMDGPU -I/Users/Luppy/llvm-project-16/build-release/include -I/Users/Luppy/llvm-project-16/llvm/include -isystem /usr/local/include -fPIC -fvisibility-inlines-hidden -Werror=date-time -Werror=unguarded-availability-new -Wall -Wextra -Wno-unused-parameter -Wwrite-strings -Wcast-qual -Wmissing-field-initializers -pedantic -Wno-long-long -Wc++98-compat-extra-semi -Wimplicit-fallthrough -Wcovered-switch-default -Wno-noexcept-type -Wnon-virtual-dtor -Wdelete-non-virtual-dtor -Wstring-conversion -Wctad-maybe-unsupported -fdiagnostics-color -O3 -DNDEBUG -std=c++17 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk  -fno-exceptions -fno-rtti -UNDEBUG -MD -MT lib/Target/AMDGPU/AsmParser/CMakeFiles/LLVMAMDGPUAsmParser.dir/AMDGPUAsmParser.cpp.o -MF lib/Target/AMDGPU/AsmParser/CMakeFiles/LLVMAMDGPUAsmParser.dir/AMDGPUAsmParser.cpp.o.d -o lib/Target/AMDGPU/AsmParser/CMakeFiles/LLVMAMDGPUAsmParser.dir/AMDGPUAsmParser.cpp.o -c /Users/Luppy/llvm-project-16/llvm/lib/Target/AMDGPU/AsmParser/AMDGPUAsmParser.cpp
/Users/Luppy/llvm-project-16/llvm/lib/Target/AMDGPU/AsmParser/AMDGPUAsmParser.cpp:5490:13: error: no viable constructor or deduction guide for deduction of template arguments of 'tuple'
          ? std::tuple(HSAMD::V3::AssemblerDirectiveBegin,
            ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:625:5: note: candidate template ignored: requirement '__lazy_and<std::__1::is_same<std::__1::allocator_arg_t, const char *>, std::__1::__lazy_all<> >::value' was not satisfied [with _Tp = <>, _AllocArgT = const char *, _Alloc = char [21], _Dummy = true]
    tuple(_AllocArgT, _Alloc const& __a)
    ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:641:5: note: candidate template ignored: requirement '_CheckArgsConstructor<true, void>::__enable_implicit()' was not satisfied [with _Tp = <char [17], char [21]>, _Dummy = true]
    tuple(const _Tp& ... __t) _NOEXCEPT_((__all<is_nothrow_copy_constructible<_Tp>::value...>::value))
    ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:659:14: note: candidate template ignored: requirement '_CheckArgsConstructor<true, void>::__enable_explicit()' was not satisfied [with _Tp = <char [17], char [21]>, _Dummy = true]
    explicit tuple(const _Tp& ... __t) _NOEXCEPT_((__all<is_nothrow_copy_constructible<_Tp>::value...>::value))
             ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:677:7: note: candidate template ignored: substitution failure [with _Tp = <>, _Alloc = char [21], _Dummy = true]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
      tuple(allocator_arg_t, const _Alloc& __a, const _Tp& ... __t)
      ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:697:7: note: candidate template ignored: substitution failure [with _Tp = <>, _Alloc = char [21], _Dummy = true]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
      tuple(allocator_arg_t, const _Alloc& __a, const _Tp& ... __t)
      ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:723:9: note: candidate template ignored: substitution failure [with _Tp = <>, _Up = <char const (&)[17], char const (&)[21]>]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
        tuple(_Up&&... __u)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:756:9: note: candidate template ignored: substitution failure [with _Tp = <>, _Up = <char const (&)[17], char const (&)[21]>]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
        tuple(_Up&&... __u)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:783:9: note: candidate template ignored: substitution failure [with _Tp = <>, _Alloc = char [21], _Up = <>]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
        tuple(allocator_arg_t, const _Alloc& __a, _Up&&... __u)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:803:9: note: candidate template ignored: substitution failure [with _Tp = <>, _Alloc = char [21], _Up = <>]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
        tuple(allocator_arg_t, const _Alloc& __a, _Up&&... __u)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:612:23: note: candidate function template not viable: requires 0 arguments, but 2 were provided
    _LIBCPP_CONSTEXPR tuple()
                      ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:615:5: note: candidate function template not viable: requires 1 argument, but 2 were provided
    tuple(tuple const&) = default;
    ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:616:5: note: candidate function template not viable: requires 1 argument, but 2 were provided
    tuple(tuple&&) = default;
    ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:822:9: note: candidate function template not viable: requires single argument '__t', but 2 arguments were provided
        tuple(_Tuple&& __t) _NOEXCEPT_((is_nothrow_constructible<_BaseT, _Tuple>::value))
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:837:9: note: candidate function template not viable: requires single argument '__t', but 2 arguments were provided
        tuple(_Tuple&& __t) _NOEXCEPT_((is_nothrow_constructible<_BaseT, _Tuple>::value))
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:850:9: note: candidate function template not viable: requires 3 arguments, but 2 were provided
        tuple(allocator_arg_t, const _Alloc& __a, _Tuple&& __t)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:864:9: note: candidate function template not viable: requires 3 arguments, but 2 were provided
        tuple(allocator_arg_t, const _Alloc& __a, _Tuple&& __t)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:469:28: note: candidate function template not viable: requires 1 argument, but 2 were provided
class _LIBCPP_TEMPLATE_VIS tuple
                           ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:932:1: note: candidate function template not viable: requires 3 arguments, but 2 were provided
tuple(allocator_arg_t, const _Alloc&, tuple<_Args...> const&) -> tuple<_Args...>;
^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:934:1: note: candidate function template not viable: requires 3 arguments, but 2 were provided
tuple(allocator_arg_t, const _Alloc&, tuple<_Args...>&&) -> tuple<_Args...>;
^
/Users/Luppy/llvm-project-16/llvm/lib/Target/AMDGPU/AsmParser/AMDGPUAsmParser.cpp:5492:13: error: no viable constructor or deduction guide for deduction of template arguments of 'tuple'
          : std::tuple(HSAMD::AssemblerDirectiveBegin,
            ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:625:5: note: candidate template ignored: requirement '__lazy_and<std::__1::is_same<std::__1::allocator_arg_t, const char *>, std::__1::__lazy_all<> >::value' was not satisfied [with _Tp = <>, _AllocArgT = const char *, _Alloc = char [29], _Dummy = true]
    tuple(_AllocArgT, _Alloc const& __a)
    ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:641:5: note: candidate template ignored: requirement '_CheckArgsConstructor<true, void>::__enable_implicit()' was not satisfied [with _Tp = <char [25], char [29]>, _Dummy = true]
    tuple(const _Tp& ... __t) _NOEXCEPT_((__all<is_nothrow_copy_constructible<_Tp>::value...>::value))
    ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:659:14: note: candidate template ignored: requirement '_CheckArgsConstructor<true, void>::__enable_explicit()' was not satisfied [with _Tp = <char [25], char [29]>, _Dummy = true]
    explicit tuple(const _Tp& ... __t) _NOEXCEPT_((__all<is_nothrow_copy_constructible<_Tp>::value...>::value))
             ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:677:7: note: candidate template ignored: substitution failure [with _Tp = <>, _Alloc = char [29], _Dummy = true]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
      tuple(allocator_arg_t, const _Alloc& __a, const _Tp& ... __t)
      ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:697:7: note: candidate template ignored: substitution failure [with _Tp = <>, _Alloc = char [29], _Dummy = true]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
      tuple(allocator_arg_t, const _Alloc& __a, const _Tp& ... __t)
      ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:723:9: note: candidate template ignored: substitution failure [with _Tp = <>, _Up = <char const (&)[25], char const (&)[29]>]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
        tuple(_Up&&... __u)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:756:9: note: candidate template ignored: substitution failure [with _Tp = <>, _Up = <char const (&)[25], char const (&)[29]>]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
        tuple(_Up&&... __u)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:783:9: note: candidate template ignored: substitution failure [with _Tp = <>, _Alloc = char [29], _Up = <>]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
        tuple(allocator_arg_t, const _Alloc& __a, _Up&&... __u)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:803:9: note: candidate template ignored: substitution failure [with _Tp = <>, _Alloc = char [29], _Up = <>]: cannot reference member of primary template because deduced class template specialization 'tuple<>' is an explicit specialization
        tuple(allocator_arg_t, const _Alloc& __a, _Up&&... __u)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:612:23: note: candidate function template not viable: requires 0 arguments, but 2 were provided
    _LIBCPP_CONSTEXPR tuple()
                      ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:615:5: note: candidate function template not viable: requires 1 argument, but 2 were provided
    tuple(tuple const&) = default;
    ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:616:5: note: candidate function template not viable: requires 1 argument, but 2 were provided
    tuple(tuple&&) = default;
    ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:822:9: note: candidate function template not viable: requires single argument '__t', but 2 arguments were provided
        tuple(_Tuple&& __t) _NOEXCEPT_((is_nothrow_constructible<_BaseT, _Tuple>::value))
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:837:9: note: candidate function template not viable: requires single argument '__t', but 2 arguments were provided
        tuple(_Tuple&& __t) _NOEXCEPT_((is_nothrow_constructible<_BaseT, _Tuple>::value))
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:850:9: note: candidate function template not viable: requires 3 arguments, but 2 were provided
        tuple(allocator_arg_t, const _Alloc& __a, _Tuple&& __t)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:864:9: note: candidate function template not viable: requires 3 arguments, but 2 were provided
        tuple(allocator_arg_t, const _Alloc& __a, _Tuple&& __t)
        ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:469:28: note: candidate function template not viable: requires 1 argument, but 2 were provided
class _LIBCPP_TEMPLATE_VIS tuple
                           ^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:932:1: note: candidate function template not viable: requires 3 arguments, but 2 were provided
tuple(allocator_arg_t, const _Alloc&, tuple<_Args...> const&) -> tuple<_Args...>;
^
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../include/c++/v1/tuple:934:1: note: candidate function template not viable: requires 3 arguments, but 2 were provided
tuple(allocator_arg_t, const _Alloc&, tuple<_Args...>&&) -> tuple<_Args...>;
^
2 errors generated.
[1917/4827] Building CXX object lib/Target/AMDGPU/Disassembler/CMakeFiles/LLVMAMDGPUDisassembler.dir/AMDGPUDisassembler.cpp.o
ninja: build stopped: subcommand failed.
```

So I can't build Zig from source on my 10-year-old MacBook Pro 😢
