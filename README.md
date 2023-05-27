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

(We removed our Custom Panic Handler, the default one works fine for WebAssembly)

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

- Add `-DLV_MEM_CUSTOM=1` (because we're using `malloc` instead of LVGL's TLSF Allocator)

- Add `-DLV_USE_LOG=1` (to enable logging)

- Add `-DLV_LOG_LEVEL=LV_LOG_LEVEL_TRACE` (for detailed logging)

- For extra logging...

  ```text
  -DLV_LOG_TRACE_OBJ_CREATE=1 \
  -DLV_LOG_TRACE_TIMER=1 \
  -DLV_LOG_TRACE_MEM=1 \
  ```

- Change `"-DLV_ASSERT_HANDLER..."` to...

  ```text
  "-DLV_ASSERT_HANDLER={void lv_assert_handler(void); lv_assert_handler();}"
  ```

  [(To handle Assertion Failures ourselves)](https://github.com/lupyuen/pinephone-lvgl-zig/blob/bee0e8d8ab9eae3a8c7cea6c64cc7896a5678f53/lvglwasm.zig#L170-L190)

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
  -DLV_MEM_CUSTOM=1 \
  -DLV_USE_LOG=1 \
  -DLV_LOG_LEVEL=LV_LOG_LEVEL_TRACE \
  -DLV_LOG_TRACE_OBJ_CREATE=1 \
  -DLV_LOG_TRACE_TIMER=1 \
  -DLV_LOG_TRACE_MEM=1 \
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
    -DLV_MEM_CUSTOM=1 \
    -DLV_USE_LOG=1 \
    -DLV_LOG_LEVEL=LV_LOG_LEVEL_TRACE \
    -DLV_LOG_TRACE_OBJ_CREATE=1 \
    -DLV_LOG_TRACE_TIMER=1 \
    -DLV_LOG_TRACE_MEM=1 \
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

https://github.com/lupyuen/pinephone-lvgl-zig/blob/bee0e8d8ab9eae3a8c7cea6c64cc7896a5678f53/lvglwasm.zig#L170-L190

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

_What happens if we omit `-DLV_MEM_CUSTOM=1`?_

By default, LVGL uses the [Two-Level Segregate Fit (TLSF) Allocator](http://www.gii.upv.es/tlsf/) for Heap Memory.

But TLSF Allocator fails in [`block_next`](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_tlsf.c#L453-L460)...

```text
main: start
loop: start
lv_demo_widgets: start
before lv_init
[Info]	lv_init: begin 	(in lv_obj.c line #102)
[Trace]	lv_mem_alloc: allocating 76 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a700 	(in lv_mem.c line #160)
[Trace]	lv_mem_alloc: allocating 28 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a750 	(in lv_mem.c line #160)
[Warn]	lv_init: Log level is set to 'Trace' which makes LVGL much slower 	(in lv_obj.c line #176)
[Trace]	lv_mem_realloc: reallocating 0x14 with 8 size 	(in lv_mem.c line #196)
[Error]	block_next: Asserted at expression: !block_is_last(block) 	(in lv_tlsf.c line #459)

004a5b4a:0x29ab2 Uncaught (in promise) RuntimeError: unreachable
    at std.builtin.default_panic (004a5b4a:0x29ab2)
    at lv_assert_handler (004a5b4a:0x2ac6c)
    at block_next (004a5b4a:0xd5b3)
    at lv_tlsf_realloc (004a5b4a:0xe226)
    at lv_mem_realloc (004a5b4a:0x20f1)
    at lv_layout_register (004a5b4a:0x75d8)
    at lv_flex_init (004a5b4a:0x16afe)
    at lv_extra_init (004a5b4a:0x16ae5)
    at lv_init (004a5b4a:0x3f28)
    at lv_demo_widgets (004a5b4a:0x29bb9)
```

Thus we set `-DLV_MEM_CUSTOM=1` to use `malloc` instead of LVGL's TLSF Allocator.

([`block_next`](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_tlsf.c#L453-L460) calls [`offset_to_block`](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_tlsf.c#L440-L444), which calls [`tlsf_cast`](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_tlsf.c#L274). Maybe the Pointer Cast doesn't work for Clang WebAssembly?)

_But Zig doesn't support `malloc` for WebAssembly!_

We used Zig's FixedBufferAllocator...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/6cb8fee917d07c268e32e8bcb88018e0b8ab981f/lvglwasm.zig#L38-L44

To implement `malloc` ourselves...

https://github.com/lupyuen/pinephone-lvgl-zig/blob/6cb8fee917d07c268e32e8bcb88018e0b8ab981f/lvglwasm.zig#L195-L232

[(If we ever remove `-DLV_MEM_CUSTOM=1`, remember to set `-DLV_MEM_SIZE=1000000`)](https://github.com/lupyuen/pinephone-lvgl-zig/blob/aa080fb2ce55f9959cce2b6fff7e5fd5c9907cd6/README.md#lvgl-memory-allocation)

# TODO

```text
main: start
loop: start
lv_demo_widgets: start
before lv_init
[Info]	lv_init: begin 	(in lv_obj.c line #102)
[Trace]	lv_mem_alloc: allocating 32 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x19fc8 	(in lv_mem.c line #160)
[Trace]	lv_mem_alloc: allocating 28 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x19fe8 	(in lv_mem.c line #160)
[Warn]	lv_init: Log level is set to 'Trace' which makes LVGL much slower 	(in lv_obj.c line #176)
[Trace]	lv_mem_realloc: reallocating 0 with 8 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a004 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0 with 32 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a00c 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a004 with 16 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a02c 	(in lv_mem.c line #215)
[Trace]	lv_init: finished 	(in lv_obj.c line #183)
after lv_init
before lv_disp_drv_register
lv_disp_drv_register
&_lv_disp_ll=0x19db8
_lv_ll_get_len(&_lv_disp_ll)=0
[Trace]	lv_mem_alloc: allocating 360 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a03c 	(in lv_mem.c line #160)
lv_disp_drv_register: disp=0x1a03c
_lv_ll_get_len(&_lv_disp_ll)=1
_lv_ll_get_head(&_lv_disp_ll)=0x1a03c
[Trace]	lv_mem_alloc: allocating 84 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a1a4 	(in lv_mem.c line #160)
[Trace]	lv_mem_alloc: allocating 32 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a1f8 	(in lv_mem.c line #160)
[Trace]	lv_mem_alloc: allocating 584 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a218 	(in lv_mem.c line #160)
[Trace]	lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a460 	(in lv_mem.c line #160)
[Trace]	lv_mem_realloc: reallocating 0x1a460 with 18 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a46c 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a46c with 24 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a47e 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a47e with 30 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a496 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a496 with 36 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a4b4 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a4b4 with 42 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a4d8 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a4d8 with 48 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a502 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a502 with 54 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a532 	(in lv_mem.c line #215)
[Trace]	lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a568 	(in lv_mem.c line #160)
[Trace]	lv_mem_realloc: reallocating 0x1a568 with 18 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a574 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a574 with 24 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a586 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a586 with 30 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a59e 	(in lv_mem.c line #215)
[Trace]	lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a5bc 	(in lv_mem.c line #160)
[Trace]	lv_mem_realloc: reallocating 0x1a5bc with 18 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a5c8 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a5c8 with 24 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a5da 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a5da with 30 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a5f2 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a5f2 with 36 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a610 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a610 with 42 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a634 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a634 with 48 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a65e 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a65e with 54 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a68e 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a68e with 60 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a6c4 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a6c4 with 66 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a700 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a700 with 72 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a742 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a742 with 78 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a78a 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a78a with 84 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a7d8 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a7d8 with 90 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a82c 	(in lv_mem.c line #215)
[Trace]	lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a886 	(in lv_mem.c line #160)
[Trace]	lv_mem_realloc: reallocating 0x1a886 with 18 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a892 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a892 with 24 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a8a4 	(in lv_mem.c line #215)
[Trace]	lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a8bc 	(in lv_mem.c line #160)
[Trace]	lv_mem_realloc: reallocating 0x1a8bc with 18 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a8c8 	(in lv_mem.c line #215)
[Trace]	lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x1a8da 	(in lv_mem.c line #160)
[Trace]	lv_mem_realloc: reallocating 0x1a8da with 18 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a8e6 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a8e6 with 24 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a8f8 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a8f8 with 30 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a910 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a910 with 36 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a92e 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a92e with 42 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a952 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x1a952 with 48 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x1a97c 	(in lv_mem.c line #215)
[Trace]	(0.100, +1)	 lv_mem_realloc: reallocating 0x1a97c with 54 size 	(in lv_mem.c line #196)
[Trace]	(0.101, +1)	 lv_mem_realloc: allocated at 0x1a9ac 	(in lv_mem.c line #215)
[Trace]	(0.102, +1)	 lv_mem_realloc: reallocating 0x1a9ac with 60 size 	(in lv_mem.c line #196)
[Trace]	(0.103, +1)	 lv_mem_realloc: allocated at 0x1a9e2 	(in lv_mem.c line #215)
[Trace]	(0.104, +1)	 lv_mem_realloc: reallocating 0x1a9e2 with 66 size 	(in lv_mem.c line #196)
[Trace]	(0.105, +1)	 lv_mem_realloc: allocated at 0x1aa1e 	(in lv_mem.c line #215)
[Trace]	(0.106, +1)	 lv_mem_realloc: reallocating 0x1aa1e with 72 size 	(in lv_mem.c line #196)
[Trace]	(0.107, +1)	 lv_mem_realloc: allocated at 0x1aa60 	(in lv_mem.c line #215)
[Trace]	(0.108, +1)	 lv_mem_realloc: reallocating 0x1aa60 with 78 size 	(in lv_mem.c line #196)
[Trace]	(0.109, +1)	 lv_mem_realloc: allocated at 0x1aaa8 	(in lv_mem.c line #215)
[Trace]	(0.110, +1)	 lv_mem_realloc: reallocating 0x1aaa8 with 84 size 	(in lv_mem.c line #196)
[Trace]	(0.111, +1)	 lv_mem_realloc: allocated at 0x1aaf6 	(in lv_mem.c line #215)
[Trace]	(0.112, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.113, +1)	 lv_mem_alloc: allocated at 0x1ab4a 	(in lv_mem.c line #160)
[Trace]	(0.114, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.115, +1)	 lv_mem_alloc: allocated at 0x1ab56 	(in lv_mem.c line #160)
[Trace]	(0.116, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.117, +1)	 lv_mem_alloc: allocated at 0x1ab62 	(in lv_mem.c line #160)
[Trace]	(0.118, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.119, +1)	 lv_mem_alloc: allocated at 0x1ab6e 	(in lv_mem.c line #160)
[Trace]	(0.120, +1)	 lv_mem_realloc: reallocating 0x1ab6e with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.121, +1)	 lv_mem_realloc: allocated at 0x1ab7a 	(in lv_mem.c line #215)
[Trace]	(0.122, +1)	 lv_mem_realloc: reallocating 0x1ab7a with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.123, +1)	 lv_mem_realloc: allocated at 0x1ab8c 	(in lv_mem.c line #215)
[Trace]	(0.124, +1)	 lv_mem_realloc: reallocating 0x1ab8c with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.125, +1)	 lv_mem_realloc: allocated at 0x1aba4 	(in lv_mem.c line #215)
[Trace]	(0.126, +1)	 lv_mem_realloc: reallocating 0x1aba4 with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.127, +1)	 lv_mem_realloc: allocated at 0x1abc2 	(in lv_mem.c line #215)
[Trace]	(0.128, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.129, +1)	 lv_mem_alloc: allocated at 0x1abe6 	(in lv_mem.c line #160)
[Trace]	(0.130, +1)	 lv_mem_realloc: reallocating 0x1abe6 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.131, +1)	 lv_mem_realloc: allocated at 0x1abf2 	(in lv_mem.c line #215)
[Trace]	(0.132, +1)	 lv_mem_realloc: reallocating 0x1abf2 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.133, +1)	 lv_mem_realloc: allocated at 0x1ac04 	(in lv_mem.c line #215)
[Trace]	(0.134, +1)	 lv_mem_realloc: reallocating 0x1ac04 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.135, +1)	 lv_mem_realloc: allocated at 0x1ac1c 	(in lv_mem.c line #215)
[Trace]	(0.136, +1)	 lv_mem_realloc: reallocating 0x1ac1c with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.137, +1)	 lv_mem_realloc: allocated at 0x1ac3a 	(in lv_mem.c line #215)
[Trace]	(0.138, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.139, +1)	 lv_mem_alloc: allocated at 0x1ac5e 	(in lv_mem.c line #160)
[Trace]	(0.140, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.141, +1)	 lv_mem_alloc: allocated at 0x1ac6a 	(in lv_mem.c line #160)
[Trace]	(0.142, +1)	 lv_mem_realloc: reallocating 0x1ac6a with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.143, +1)	 lv_mem_realloc: allocated at 0x1ac76 	(in lv_mem.c line #215)
[Trace]	(0.144, +1)	 lv_mem_realloc: reallocating 0x1ac76 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.145, +1)	 lv_mem_realloc: allocated at 0x1ac88 	(in lv_mem.c line #215)
[Trace]	(0.146, +1)	 lv_mem_realloc: reallocating 0x1ac88 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.147, +1)	 lv_mem_realloc: allocated at 0x1aca0 	(in lv_mem.c line #215)
[Trace]	(0.148, +1)	 lv_mem_realloc: reallocating 0x1aca0 with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.149, +1)	 lv_mem_realloc: allocated at 0x1acbe 	(in lv_mem.c line #215)
[Trace]	(0.150, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.151, +1)	 lv_mem_alloc: allocated at 0x1ace2 	(in lv_mem.c line #160)
[Trace]	(0.152, +1)	 lv_mem_realloc: reallocating 0x1ace2 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.153, +1)	 lv_mem_realloc: allocated at 0x1acee 	(in lv_mem.c line #215)
[Trace]	(0.154, +1)	 lv_mem_realloc: reallocating 0x1acee with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.155, +1)	 lv_mem_realloc: allocated at 0x1ad00 	(in lv_mem.c line #215)
[Trace]	(0.156, +1)	 lv_mem_realloc: reallocating 0x1ad00 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.157, +1)	 lv_mem_realloc: allocated at 0x1ad18 	(in lv_mem.c line #215)
[Trace]	(0.158, +1)	 lv_mem_realloc: reallocating 0x1ad18 with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.159, +1)	 lv_mem_realloc: allocated at 0x1ad36 	(in lv_mem.c line #215)
[Trace]	(0.160, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.161, +1)	 lv_mem_alloc: allocated at 0x1ad5a 	(in lv_mem.c line #160)
[Trace]	(0.162, +1)	 lv_mem_realloc: reallocating 0x1ad5a with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.163, +1)	 lv_mem_realloc: allocated at 0x1ad66 	(in lv_mem.c line #215)
[Trace]	(0.164, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.165, +1)	 lv_mem_alloc: allocated at 0x1ad78 	(in lv_mem.c line #160)
[Trace]	(0.166, +1)	 lv_mem_realloc: reallocating 0x1ad78 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.167, +1)	 lv_mem_realloc: allocated at 0x1ad84 	(in lv_mem.c line #215)
[Trace]	(0.168, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.169, +1)	 lv_mem_alloc: allocated at 0x1ad96 	(in lv_mem.c line #160)
[Trace]	(0.170, +1)	 lv_mem_realloc: reallocating 0x1ad96 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.171, +1)	 lv_mem_realloc: allocated at 0x1ada2 	(in lv_mem.c line #215)
[Trace]	(0.172, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.173, +1)	 lv_mem_alloc: allocated at 0x1adb4 	(in lv_mem.c line #160)
[Trace]	(0.174, +1)	 lv_mem_realloc: reallocating 0x1adb4 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.175, +1)	 lv_mem_realloc: allocated at 0x1adc0 	(in lv_mem.c line #215)
[Trace]	(0.176, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.177, +1)	 lv_mem_alloc: allocated at 0x1add2 	(in lv_mem.c line #160)
[Trace]	(0.178, +1)	 lv_mem_realloc: reallocating 0x1add2 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.179, +1)	 lv_mem_realloc: allocated at 0x1adde 	(in lv_mem.c line #215)
[Trace]	(0.180, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.181, +1)	 lv_mem_alloc: allocated at 0x1adf0 	(in lv_mem.c line #160)
[Trace]	(0.182, +1)	 lv_mem_realloc: reallocating 0x1adf0 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.183, +1)	 lv_mem_realloc: allocated at 0x1adfc 	(in lv_mem.c line #215)
[Trace]	(0.184, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.185, +1)	 lv_mem_alloc: allocated at 0x1ae0e 	(in lv_mem.c line #160)
[Trace]	(0.186, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.187, +1)	 lv_mem_alloc: allocated at 0x1ae1a 	(in lv_mem.c line #160)
[Trace]	(0.188, +1)	 lv_mem_realloc: reallocating 0x1ae1a with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.189, +1)	 lv_mem_realloc: allocated at 0x1ae26 	(in lv_mem.c line #215)
[Trace]	(0.190, +1)	 lv_mem_realloc: reallocating 0x1ae26 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.191, +1)	 lv_mem_realloc: allocated at 0x1ae38 	(in lv_mem.c line #215)
[Trace]	(0.192, +1)	 lv_mem_realloc: reallocating 0x1ae38 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.193, +1)	 lv_mem_realloc: allocated at 0x1ae50 	(in lv_mem.c line #215)
[Trace]	(0.194, +1)	 lv_mem_realloc: reallocating 0x1ae50 with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.195, +1)	 lv_mem_realloc: allocated at 0x1ae6e 	(in lv_mem.c line #215)
[Trace]	(0.196, +1)	 lv_mem_realloc: reallocating 0x1ae6e with 42 size 	(in lv_mem.c line #196)
[Trace]	(0.197, +1)	 lv_mem_realloc: allocated at 0x1ae92 	(in lv_mem.c line #215)
[Trace]	(0.198, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.199, +1)	 lv_mem_alloc: allocated at 0x1aebc 	(in lv_mem.c line #160)
[Trace]	(0.200, +1)	 lv_mem_realloc: reallocating 0x1aebc with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.201, +1)	 lv_mem_realloc: allocated at 0x1aec8 	(in lv_mem.c line #215)
[Trace]	(0.202, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.203, +1)	 lv_mem_alloc: allocated at 0x1aeda 	(in lv_mem.c line #160)
[Trace]	(0.204, +1)	 lv_mem_realloc: reallocating 0x1aeda with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.205, +1)	 lv_mem_realloc: allocated at 0x1aee6 	(in lv_mem.c line #215)
[Trace]	(0.206, +1)	 lv_mem_realloc: reallocating 0x1aee6 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.207, +1)	 lv_mem_realloc: allocated at 0x1aef8 	(in lv_mem.c line #215)
[Trace]	(0.208, +1)	 lv_mem_realloc: reallocating 0x1aef8 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.209, +1)	 lv_mem_realloc: allocated at 0x1af10 	(in lv_mem.c line #215)
[Trace]	(0.210, +1)	 lv_mem_realloc: reallocating 0x1af10 with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.211, +1)	 lv_mem_realloc: allocated at 0x1af2e 	(in lv_mem.c line #215)
[Trace]	(0.212, +1)	 lv_mem_realloc: reallocating 0x1af2e with 42 size 	(in lv_mem.c line #196)
[Trace]	(0.213, +1)	 lv_mem_realloc: allocated at 0x1af52 	(in lv_mem.c line #215)
[Trace]	(0.214, +1)	 lv_mem_realloc: reallocating 0x1af52 with 48 size 	(in lv_mem.c line #196)
[Trace]	(0.215, +1)	 lv_mem_realloc: allocated at 0x1af7c 	(in lv_mem.c line #215)
[Trace]	(0.216, +1)	 lv_mem_realloc: reallocating 0x1af7c with 54 size 	(in lv_mem.c line #196)
[Trace]	(0.217, +1)	 lv_mem_realloc: allocated at 0x1afac 	(in lv_mem.c line #215)
[Trace]	(0.218, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.219, +1)	 lv_mem_alloc: allocated at 0x1afe2 	(in lv_mem.c line #160)
[Trace]	(0.220, +1)	 lv_mem_realloc: reallocating 0x1afe2 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.221, +1)	 lv_mem_realloc: allocated at 0x1afee 	(in lv_mem.c line #215)
[Trace]	(0.222, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.223, +1)	 lv_mem_alloc: allocated at 0x1b000 	(in lv_mem.c line #160)
[Trace]	(0.224, +1)	 lv_mem_realloc: reallocating 0x1b000 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.225, +1)	 lv_mem_realloc: allocated at 0x1b00c 	(in lv_mem.c line #215)
[Trace]	(0.226, +1)	 lv_mem_realloc: reallocating 0x1b00c with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.227, +1)	 lv_mem_realloc: allocated at 0x1b01e 	(in lv_mem.c line #215)
[Trace]	(0.228, +1)	 lv_mem_realloc: reallocating 0x1b01e with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.229, +1)	 lv_mem_realloc: allocated at 0x1b036 	(in lv_mem.c line #215)
[Trace]	(0.230, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.231, +1)	 lv_mem_alloc: allocated at 0x1b054 	(in lv_mem.c line #160)
[Trace]	(0.232, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.233, +1)	 lv_mem_alloc: allocated at 0x1b060 	(in lv_mem.c line #160)
[Trace]	(0.234, +1)	 lv_mem_realloc: reallocating 0x1b060 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.235, +1)	 lv_mem_realloc: allocated at 0x1b06c 	(in lv_mem.c line #215)
[Trace]	(0.236, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.237, +1)	 lv_mem_alloc: allocated at 0x1b07e 	(in lv_mem.c line #160)
[Trace]	(0.238, +1)	 lv_mem_realloc: reallocating 0x1b07e with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.239, +1)	 lv_mem_realloc: allocated at 0x1b08a 	(in lv_mem.c line #215)
[Trace]	(0.240, +1)	 lv_mem_realloc: reallocating 0x1b08a with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.241, +1)	 lv_mem_realloc: allocated at 0x1b09c 	(in lv_mem.c line #215)
[Trace]	(0.242, +1)	 lv_mem_realloc: reallocating 0x1b09c with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.243, +1)	 lv_mem_realloc: allocated at 0x1b0b4 	(in lv_mem.c line #215)
[Trace]	(0.244, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.245, +1)	 lv_mem_alloc: allocated at 0x1b0d2 	(in lv_mem.c line #160)
[Trace]	(0.246, +1)	 lv_mem_realloc: reallocating 0x1b0d2 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.247, +1)	 lv_mem_realloc: allocated at 0x1b0de 	(in lv_mem.c line #215)
[Trace]	(0.248, +1)	 lv_mem_realloc: reallocating 0x1b0de with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.249, +1)	 lv_mem_realloc: allocated at 0x1b0f0 	(in lv_mem.c line #215)
[Trace]	(0.250, +1)	 lv_mem_realloc: reallocating 0x1b0f0 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.251, +1)	 lv_mem_realloc: allocated at 0x1b108 	(in lv_mem.c line #215)
[Trace]	(0.252, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.253, +1)	 lv_mem_alloc: allocated at 0x1b126 	(in lv_mem.c line #160)
[Trace]	(0.254, +1)	 lv_mem_realloc: reallocating 0x1b126 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.255, +1)	 lv_mem_realloc: allocated at 0x1b132 	(in lv_mem.c line #215)
[Trace]	(0.256, +1)	 lv_mem_realloc: reallocating 0x1b132 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.257, +1)	 lv_mem_realloc: allocated at 0x1b144 	(in lv_mem.c line #215)
[Trace]	(0.258, +1)	 lv_mem_realloc: reallocating 0x1b144 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.259, +1)	 lv_mem_realloc: allocated at 0x1b15c 	(in lv_mem.c line #215)
[Trace]	(0.260, +1)	 lv_mem_realloc: reallocating 0x1b15c with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.261, +1)	 lv_mem_realloc: allocated at 0x1b17a 	(in lv_mem.c line #215)
[Trace]	(0.262, +1)	 lv_mem_realloc: reallocating 0x1b17a with 42 size 	(in lv_mem.c line #196)
[Trace]	(0.263, +1)	 lv_mem_realloc: allocated at 0x1b19e 	(in lv_mem.c line #215)
[Trace]	(0.264, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.265, +1)	 lv_mem_alloc: allocated at 0x1b1c8 	(in lv_mem.c line #160)
[Trace]	(0.266, +1)	 lv_mem_realloc: reallocating 0x1b1c8 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.267, +1)	 lv_mem_realloc: allocated at 0x1b1d4 	(in lv_mem.c line #215)
[Trace]	(0.268, +1)	 lv_mem_realloc: reallocating 0x1b1d4 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.269, +1)	 lv_mem_realloc: allocated at 0x1b1e6 	(in lv_mem.c line #215)
[Trace]	(0.270, +1)	 lv_mem_realloc: reallocating 0x1b1e6 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.271, +1)	 lv_mem_realloc: allocated at 0x1b1fe 	(in lv_mem.c line #215)
[Trace]	(0.272, +1)	 lv_mem_realloc: reallocating 0x1b1fe with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.273, +1)	 lv_mem_realloc: allocated at 0x1b21c 	(in lv_mem.c line #215)
[Trace]	(0.274, +1)	 lv_mem_realloc: reallocating 0x1b21c with 42 size 	(in lv_mem.c line #196)
[Trace]	(0.275, +1)	 lv_mem_realloc: allocated at 0x1b240 	(in lv_mem.c line #215)
[Trace]	(0.276, +1)	 lv_mem_realloc: reallocating 0x1b240 with 48 size 	(in lv_mem.c line #196)
[Trace]	(0.277, +1)	 lv_mem_realloc: allocated at 0x1b26a 	(in lv_mem.c line #215)
[Trace]	(0.278, +1)	 lv_mem_realloc: reallocating 0x1b26a with 54 size 	(in lv_mem.c line #196)
[Trace]	(0.279, +1)	 lv_mem_realloc: allocated at 0x1b29a 	(in lv_mem.c line #215)
[Trace]	(0.280, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.281, +1)	 lv_mem_alloc: allocated at 0x1b2d0 	(in lv_mem.c line #160)
[Trace]	(0.282, +1)	 lv_mem_realloc: reallocating 0x1b2d0 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.283, +1)	 lv_mem_realloc: allocated at 0x1b2dc 	(in lv_mem.c line #215)
[Trace]	(0.284, +1)	 lv_mem_realloc: reallocating 0x1b2dc with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.285, +1)	 lv_mem_realloc: allocated at 0x1b2ee 	(in lv_mem.c line #215)
[Trace]	(0.286, +1)	 lv_mem_realloc: reallocating 0x1b2ee with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.287, +1)	 lv_mem_realloc: allocated at 0x1b306 	(in lv_mem.c line #215)
[Trace]	(0.288, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.289, +1)	 lv_mem_alloc: allocated at 0x1b324 	(in lv_mem.c line #160)
[Trace]	(0.290, +1)	 lv_mem_realloc: reallocating 0x1b324 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.291, +1)	 lv_mem_realloc: allocated at 0x1b330 	(in lv_mem.c line #215)
[Trace]	(0.292, +1)	 lv_mem_realloc: reallocating 0x1b330 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.293, +1)	 lv_mem_realloc: allocated at 0x1b342 	(in lv_mem.c line #215)
[Trace]	(0.294, +1)	 lv_mem_realloc: reallocating 0x1b342 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.295, +1)	 lv_mem_realloc: allocated at 0x1b35a 	(in lv_mem.c line #215)
[Trace]	(0.296, +1)	 lv_mem_realloc: reallocating 0x1b35a with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.297, +1)	 lv_mem_realloc: allocated at 0x1b378 	(in lv_mem.c line #215)
[Trace]	(0.298, +1)	 lv_mem_realloc: reallocating 0x1b378 with 42 size 	(in lv_mem.c line #196)
[Trace]	(0.299, +1)	 lv_mem_realloc: allocated at 0x1b39c 	(in lv_mem.c line #215)
[Trace]	(0.300, +1)	 lv_mem_realloc: reallocating 0x1b39c with 48 size 	(in lv_mem.c line #196)
[Trace]	(0.301, +1)	 lv_mem_realloc: allocated at 0x1b3c6 	(in lv_mem.c line #215)
[Trace]	(0.302, +1)	 lv_mem_realloc: reallocating 0x1b3c6 with 54 size 	(in lv_mem.c line #196)
[Trace]	(0.303, +1)	 lv_mem_realloc: allocated at 0x1b3f6 	(in lv_mem.c line #215)
[Trace]	(0.304, +1)	 lv_mem_realloc: reallocating 0x1b3f6 with 60 size 	(in lv_mem.c line #196)
[Trace]	(0.305, +1)	 lv_mem_realloc: allocated at 0x1b42c 	(in lv_mem.c line #215)
[Trace]	(0.306, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.307, +1)	 lv_mem_alloc: allocated at 0x1b468 	(in lv_mem.c line #160)
[Trace]	(0.308, +1)	 lv_mem_realloc: reallocating 0x1b468 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.309, +1)	 lv_mem_realloc: allocated at 0x1b474 	(in lv_mem.c line #215)
[Trace]	(0.310, +1)	 lv_mem_realloc: reallocating 0x1b474 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.311, +1)	 lv_mem_realloc: allocated at 0x1b486 	(in lv_mem.c line #215)
[Trace]	(0.312, +1)	 lv_mem_realloc: reallocating 0x1b486 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.313, +1)	 lv_mem_realloc: allocated at 0x1b49e 	(in lv_mem.c line #215)
[Trace]	(0.314, +1)	 lv_mem_realloc: reallocating 0x1b49e with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.315, +1)	 lv_mem_realloc: allocated at 0x1b4bc 	(in lv_mem.c line #215)
[Trace]	(0.316, +1)	 lv_mem_realloc: reallocating 0x1b4bc with 42 size 	(in lv_mem.c line #196)
[Trace]	(0.317, +1)	 lv_mem_realloc: allocated at 0x1b4e0 	(in lv_mem.c line #215)
[Trace]	(0.318, +1)	 lv_mem_realloc: reallocating 0x1b4e0 with 48 size 	(in lv_mem.c line #196)
[Trace]	(0.319, +1)	 lv_mem_realloc: allocated at 0x1b50a 	(in lv_mem.c line #215)
[Trace]	(0.320, +1)	 lv_mem_realloc: reallocating 0x1b50a with 54 size 	(in lv_mem.c line #196)
[Trace]	(0.321, +1)	 lv_mem_realloc: allocated at 0x1b53a 	(in lv_mem.c line #215)
[Trace]	(0.322, +1)	 lv_mem_realloc: reallocating 0x1b53a with 60 size 	(in lv_mem.c line #196)
[Trace]	(0.323, +1)	 lv_mem_realloc: allocated at 0x1b570 	(in lv_mem.c line #215)
[Trace]	(0.324, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.325, +1)	 lv_mem_alloc: allocated at 0x1b5ac 	(in lv_mem.c line #160)
[Trace]	(0.326, +1)	 lv_mem_realloc: reallocating 0x1b5ac with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.327, +1)	 lv_mem_realloc: allocated at 0x1b5b8 	(in lv_mem.c line #215)
[Trace]	(0.328, +1)	 lv_mem_realloc: reallocating 0x1b5b8 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.329, +1)	 lv_mem_realloc: allocated at 0x1b5ca 	(in lv_mem.c line #215)
[Trace]	(0.330, +1)	 lv_mem_realloc: reallocating 0x1b5ca with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.331, +1)	 lv_mem_realloc: allocated at 0x1b5e2 	(in lv_mem.c line #215)
[Trace]	(0.332, +1)	 lv_mem_realloc: reallocating 0x1b5e2 with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.333, +1)	 lv_mem_realloc: allocated at 0x1b600 	(in lv_mem.c line #215)
[Trace]	(0.334, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.335, +1)	 lv_mem_alloc: allocated at 0x1b624 	(in lv_mem.c line #160)
[Trace]	(0.336, +1)	 lv_mem_realloc: reallocating 0x1b624 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.337, +1)	 lv_mem_realloc: allocated at 0x1b630 	(in lv_mem.c line #215)
[Trace]	(0.338, +1)	 lv_mem_realloc: reallocating 0x1b630 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.339, +1)	 lv_mem_realloc: allocated at 0x1b642 	(in lv_mem.c line #215)
[Trace]	(0.340, +1)	 lv_mem_realloc: reallocating 0x1b642 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.341, +1)	 lv_mem_realloc: allocated at 0x1b65a 	(in lv_mem.c line #215)
[Trace]	(0.342, +1)	 lv_mem_realloc: reallocating 0x1b65a with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.343, +1)	 lv_mem_realloc: allocated at 0x1b678 	(in lv_mem.c line #215)
[Trace]	(0.344, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.345, +1)	 lv_mem_alloc: allocated at 0x1b69c 	(in lv_mem.c line #160)
[Trace]	(0.346, +1)	 lv_mem_realloc: reallocating 0x1b69c with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.347, +1)	 lv_mem_realloc: allocated at 0x1b6a8 	(in lv_mem.c line #215)
[Trace]	(0.348, +1)	 lv_mem_realloc: reallocating 0x1b6a8 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.349, +1)	 lv_mem_realloc: allocated at 0x1b6ba 	(in lv_mem.c line #215)
[Trace]	(0.350, +1)	 lv_mem_realloc: reallocating 0x1b6ba with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.351, +1)	 lv_mem_realloc: allocated at 0x1b6d2 	(in lv_mem.c line #215)
[Trace]	(0.352, +1)	 lv_mem_realloc: reallocating 0x1b6d2 with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.353, +1)	 lv_mem_realloc: allocated at 0x1b6f0 	(in lv_mem.c line #215)
[Trace]	(0.354, +1)	 lv_mem_realloc: reallocating 0x1b6f0 with 42 size 	(in lv_mem.c line #196)
[Trace]	(0.355, +1)	 lv_mem_realloc: allocated at 0x1b714 	(in lv_mem.c line #215)
[Trace]	(0.356, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.357, +1)	 lv_mem_alloc: allocated at 0x1b73e 	(in lv_mem.c line #160)
[Trace]	(0.358, +1)	 lv_mem_realloc: reallocating 0x1b73e with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.359, +1)	 lv_mem_realloc: allocated at 0x1b74a 	(in lv_mem.c line #215)
[Trace]	(0.360, +1)	 lv_mem_realloc: reallocating 0x1b74a with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.361, +1)	 lv_mem_realloc: allocated at 0x1b75c 	(in lv_mem.c line #215)
[Trace]	(0.362, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.363, +1)	 lv_mem_alloc: allocated at 0x1b774 	(in lv_mem.c line #160)
[Trace]	(0.364, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.365, +1)	 lv_mem_alloc: allocated at 0x1b780 	(in lv_mem.c line #160)
[Trace]	(0.366, +1)	 lv_mem_realloc: reallocating 0x1b780 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.367, +1)	 lv_mem_realloc: allocated at 0x1b78c 	(in lv_mem.c line #215)
[Trace]	(0.368, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.369, +1)	 lv_mem_alloc: allocated at 0x1b79e 	(in lv_mem.c line #160)
[Trace]	(0.370, +1)	 lv_mem_realloc: reallocating 0x1b79e with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.371, +1)	 lv_mem_realloc: allocated at 0x1b7aa 	(in lv_mem.c line #215)
[Trace]	(0.372, +1)	 lv_mem_realloc: reallocating 0x1b7aa with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.373, +1)	 lv_mem_realloc: allocated at 0x1b7bc 	(in lv_mem.c line #215)
[Trace]	(0.374, +1)	 lv_mem_realloc: reallocating 0x1b7bc with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.375, +1)	 lv_mem_realloc: allocated at 0x1b7d4 	(in lv_mem.c line #215)
[Trace]	(0.376, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.377, +1)	 lv_mem_alloc: allocated at 0x1b7f2 	(in lv_mem.c line #160)
[Trace]	(0.378, +1)	 lv_mem_realloc: reallocating 0x1b7f2 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.379, +1)	 lv_mem_realloc: allocated at 0x1b7fe 	(in lv_mem.c line #215)
[Trace]	(0.380, +1)	 lv_mem_realloc: reallocating 0x1b7fe with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.381, +1)	 lv_mem_realloc: allocated at 0x1b810 	(in lv_mem.c line #215)
[Trace]	(0.382, +1)	 lv_mem_realloc: reallocating 0x1b810 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.383, +1)	 lv_mem_realloc: allocated at 0x1b828 	(in lv_mem.c line #215)
[Trace]	(0.384, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.385, +1)	 lv_mem_alloc: allocated at 0x1b846 	(in lv_mem.c line #160)
[Trace]	(0.386, +1)	 lv_mem_realloc: reallocating 0x1b846 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.387, +1)	 lv_mem_realloc: allocated at 0x1b852 	(in lv_mem.c line #215)
[Trace]	(0.388, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.389, +1)	 lv_mem_alloc: allocated at 0x1b864 	(in lv_mem.c line #160)
[Trace]	(0.390, +1)	 lv_mem_realloc: reallocating 0x1b864 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.391, +1)	 lv_mem_realloc: allocated at 0x1b870 	(in lv_mem.c line #215)
[Trace]	(0.392, +1)	 lv_mem_realloc: reallocating 0x1b870 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.393, +1)	 lv_mem_realloc: allocated at 0x1b882 	(in lv_mem.c line #215)
[Trace]	(0.394, +1)	 lv_mem_realloc: reallocating 0x1b882 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.395, +1)	 lv_mem_realloc: allocated at 0x1b89a 	(in lv_mem.c line #215)
[Trace]	(0.396, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.397, +1)	 lv_mem_alloc: allocated at 0x1b8b8 	(in lv_mem.c line #160)
[Trace]	(0.398, +1)	 lv_mem_realloc: reallocating 0x1b8b8 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.399, +1)	 lv_mem_realloc: allocated at 0x1b8c4 	(in lv_mem.c line #215)
[Trace]	(0.400, +1)	 lv_mem_realloc: reallocating 0x1b8c4 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.401, +1)	 lv_mem_realloc: allocated at 0x1b8d6 	(in lv_mem.c line #215)
[Trace]	(0.402, +1)	 lv_mem_realloc: reallocating 0x1b8d6 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.403, +1)	 lv_mem_realloc: allocated at 0x1b8ee 	(in lv_mem.c line #215)
[Trace]	(0.404, +1)	 lv_mem_realloc: reallocating 0x1b8ee with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.405, +1)	 lv_mem_realloc: allocated at 0x1b90c 	(in lv_mem.c line #215)
[Trace]	(0.406, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.407, +1)	 lv_mem_alloc: allocated at 0x1b930 	(in lv_mem.c line #160)
[Trace]	(0.408, +1)	 lv_mem_realloc: reallocating 0x1b930 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.409, +1)	 lv_mem_realloc: allocated at 0x1b93c 	(in lv_mem.c line #215)
[Trace]	(0.410, +1)	 lv_mem_realloc: reallocating 0x1b93c with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.411, +1)	 lv_mem_realloc: allocated at 0x1b94e 	(in lv_mem.c line #215)
[Trace]	(0.412, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.413, +1)	 lv_mem_alloc: allocated at 0x1b966 	(in lv_mem.c line #160)
[Trace]	(0.414, +1)	 lv_mem_realloc: reallocating 0x1b966 with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.415, +1)	 lv_mem_realloc: allocated at 0x1b972 	(in lv_mem.c line #215)
[Trace]	(0.416, +1)	 lv_mem_realloc: reallocating 0x1b972 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.417, +1)	 lv_mem_realloc: allocated at 0x1b984 	(in lv_mem.c line #215)
[Trace]	(0.418, +1)	 lv_mem_realloc: reallocating 0x1b984 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.419, +1)	 lv_mem_realloc: allocated at 0x1b99c 	(in lv_mem.c line #215)
[Trace]	(0.420, +1)	 lv_mem_realloc: reallocating 0x1b99c with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.421, +1)	 lv_mem_realloc: allocated at 0x1b9ba 	(in lv_mem.c line #215)
[Trace]	(0.422, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.423, +1)	 lv_mem_alloc: allocated at 0x1b9de 	(in lv_mem.c line #160)
[Trace]	(0.424, +1)	 lv_mem_realloc: reallocating 0x1b9de with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.425, +1)	 lv_mem_realloc: allocated at 0x1b9ea 	(in lv_mem.c line #215)
[Trace]	(0.426, +1)	 lv_mem_realloc: reallocating 0x1b9ea with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.427, +1)	 lv_mem_realloc: allocated at 0x1b9fc 	(in lv_mem.c line #215)
[Trace]	(0.428, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.429, +1)	 lv_mem_alloc: allocated at 0x1ba14 	(in lv_mem.c line #160)
[Trace]	(0.430, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.431, +1)	 lv_mem_alloc: allocated at 0x1ba20 	(in lv_mem.c line #160)
[Trace]	(0.432, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.433, +1)	 lv_mem_alloc: allocated at 0x1ba2c 	(in lv_mem.c line #160)
[Trace]	(0.434, +1)	 lv_mem_realloc: reallocating 0x1ba2c with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.435, +1)	 lv_mem_realloc: allocated at 0x1ba38 	(in lv_mem.c line #215)
[Trace]	(0.436, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.437, +1)	 lv_mem_alloc: allocated at 0x1ba4a 	(in lv_mem.c line #160)
[Trace]	(0.438, +1)	 lv_mem_realloc: reallocating 0x1ba4a with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.439, +1)	 lv_mem_realloc: allocated at 0x1ba56 	(in lv_mem.c line #215)
[Trace]	(0.440, +1)	 lv_mem_realloc: reallocating 0x1ba56 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.441, +1)	 lv_mem_realloc: allocated at 0x1ba68 	(in lv_mem.c line #215)
[Trace]	(0.442, +1)	 lv_mem_realloc: reallocating 0x1ba68 with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.443, +1)	 lv_mem_realloc: allocated at 0x1ba80 	(in lv_mem.c line #215)
[Trace]	(0.444, +1)	 lv_mem_realloc: reallocating 0x1ba80 with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.445, +1)	 lv_mem_realloc: allocated at 0x1ba9e 	(in lv_mem.c line #215)
[Trace]	(0.446, +1)	 lv_mem_realloc: reallocating 0x1ba9e with 42 size 	(in lv_mem.c line #196)
[Trace]	(0.447, +1)	 lv_mem_realloc: allocated at 0x1bac2 	(in lv_mem.c line #215)
[Trace]	(0.448, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.449, +1)	 lv_mem_alloc: allocated at 0x1baec 	(in lv_mem.c line #160)
[Trace]	(0.450, +1)	 lv_mem_realloc: reallocating 0x1baec with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.451, +1)	 lv_mem_realloc: allocated at 0x1baf8 	(in lv_mem.c line #215)
[Trace]	(0.452, +1)	 lv_mem_realloc: reallocating 0x1baf8 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.453, +1)	 lv_mem_realloc: allocated at 0x1bb0a 	(in lv_mem.c line #215)
[Trace]	(0.454, +1)	 lv_mem_realloc: reallocating 0x1bb0a with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.455, +1)	 lv_mem_realloc: allocated at 0x1bb22 	(in lv_mem.c line #215)
[Trace]	(0.456, +1)	 lv_mem_realloc: reallocating 0x1bb22 with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.457, +1)	 lv_mem_realloc: allocated at 0x1bb40 	(in lv_mem.c line #215)
[Trace]	(0.458, +1)	 lv_mem_realloc: reallocating 0x1bb40 with 42 size 	(in lv_mem.c line #196)
[Trace]	(0.459, +1)	 lv_mem_realloc: allocated at 0x1bb64 	(in lv_mem.c line #215)
[Trace]	(0.460, +1)	 lv_mem_realloc: reallocating 0x1bb64 with 48 size 	(in lv_mem.c line #196)
[Trace]	(0.461, +1)	 lv_mem_realloc: allocated at 0x1bb8e 	(in lv_mem.c line #215)
[Trace]	(0.462, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.463, +1)	 lv_mem_alloc: allocated at 0x1bbbe 	(in lv_mem.c line #160)
[Trace]	(0.464, +1)	 lv_mem_realloc: reallocating 0x1bbbe with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.465, +1)	 lv_mem_realloc: allocated at 0x1bbca 	(in lv_mem.c line #215)
[Trace]	(0.466, +1)	 lv_mem_realloc: reallocating 0x1bbca with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.467, +1)	 lv_mem_realloc: allocated at 0x1bbdc 	(in lv_mem.c line #215)
[Trace]	(0.468, +1)	 lv_mem_realloc: reallocating 0x1bbdc with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.469, +1)	 lv_mem_realloc: allocated at 0x1bbf4 	(in lv_mem.c line #215)
[Trace]	(0.470, +1)	 lv_mem_realloc: reallocating 0x1bbf4 with 36 size 	(in lv_mem.c line #196)
[Trace]	(0.471, +1)	 lv_mem_realloc: allocated at 0x1bc12 	(in lv_mem.c line #215)
[Trace]	(0.472, +1)	 lv_mem_realloc: reallocating 0x1bc12 with 42 size 	(in lv_mem.c line #196)
[Trace]	(0.473, +1)	 lv_mem_realloc: allocated at 0x1bc36 	(in lv_mem.c line #215)
[Info]	(0.474, +1)	 lv_obj_create: begin 	(in lv_obj.c line #206)
[Trace]	(0.475, +1)	 lv_obj_class_create_obj: Creating object with 0x12054 class on 0 parent 	(in lv_obj_class.c line #45)
[Trace]	(0.476, +1)	 lv_mem_alloc: allocating 36 bytes 	(in lv_mem.c line #127)
[Trace]	(0.477, +1)	 lv_mem_alloc: allocated at 0x1bc60 	(in lv_mem.c line #160)
[Trace]	(0.478, +1)	 lv_obj_class_create_obj: creating a screen 	(in lv_obj_class.c line #55)
[Trace]	(0.479, +1)	 lv_mem_alloc: allocating 4 bytes 	(in lv_mem.c line #127)
[Trace]	(0.480, +1)	 lv_mem_alloc: allocated at 0x1bc84 	(in lv_mem.c line #160)
screen_cnt1=1
new screen1=0x1bc60
scr=0x1bc60
d->screen_cnt=1
scr=0x1bc60
d->screen_cnt=1
[Trace]	(0.481, +1)	 lv_mem_realloc: reallocating 0 with 8 size 	(in lv_mem.c line #196)
[Trace]	(0.482, +1)	 lv_mem_realloc: allocated at 0x1bc88 	(in lv_mem.c line #215)
[Trace]	(0.483, +1)	 lv_mem_realloc: reallocating 0x1bc88 with 16 size 	(in lv_mem.c line #196)
[Trace]	(0.484, +1)	 lv_mem_realloc: allocated at 0x1bc90 	(in lv_mem.c line #215)
[Trace]	(0.485, +1)	 lv_mem_realloc: reallocating 0x1bc90 with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.486, +1)	 lv_mem_realloc: allocated at 0x1bca0 	(in lv_mem.c line #215)
[Trace]	(0.487, +1)	 lv_obj_constructor: begin 	(in lv_obj.c line #403)
[Trace]	(0.488, +1)	 lv_obj_constructor: finished 	(in lv_obj.c line #428)
scr=0x1bc60
d->screen_cnt=1
scr=0x1bc60
d->screen_cnt=1
scr=0x1bc60
d->screen_cnt=1
004a0f6e:0x4b0f Uncaught (in promise) RuntimeError: memory access out of bounds
    at lv_obj_get_style_prop (004a0f6e:0x4b0f)
    at lv_obj_refresh_style (004a0f6e:0x48a9)
    at lv_obj_class_init_obj (004a0f6e:0xc56b)
    at lv_obj_create (004a0f6e:0x3e1a)
    at lv_disp_drv_register (004a0f6e:0xcc0d)
    at lv_demo_widgets (004a0f6e:0x298ea)
    at loop (14)
    at main (5)
    at lvglwasm.js:40:9
```

TODO: Call `lv_tick_inc` and `lv_timer_handler`

1.  Call `lv_tick_inc(x)` every x milliseconds in an interrupt to report the elapsed time to LVGL

1.  Call `lv_timer_handler()` every few milliseconds to handle LVGL related tasks

[(Source)](https://docs.lvgl.io/8.3/porting/project.html#initialization)

# LVGL Screen Found

_Why does LVGL say "no screen found" in [lv_obj_get_disp](https://github.com/lvgl/lvgl/blob/v8.3.3/src/core/lv_obj_tree.c#L270-L289)?_

That's because the Display Linked List `_lv_disp_ll` is allocated by `LV_ITERATE_ROOTS` in [_lv_gc_clear_roots](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_gc.c#L42)...

And we forgot to compile [_lv_gc_clear_roots](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_gc.c#L42). Duh!

After compiling [_lv_gc_clear_roots](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_gc.c#L42) and [lv_gc.c](https://github.com/lvgl/lvgl/blob/v8.3.3/src/misc/lv_gc.c#L42), this "no screen found" error no longer appears...

```text
main: start
loop: start
lv_demo_widgets: start
before lv_init
[Info]	lv_init: begin 	(in lv_obj.c line #102)
[Trace]	lv_mem_alloc: allocating 76 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x19d78 	(in lv_mem.c line #160)
[Trace]	lv_mem_alloc: allocating 28 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x19dc4 	(in lv_mem.c line #160)
[Warn]	lv_init: Log level is set to 'Trace' which makes LVGL much slower 	(in lv_obj.c line #176)
[Trace]	lv_mem_realloc: reallocating 0x14 with 8 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x19de0 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x19de0 with 32 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x19de8 	(in lv_mem.c line #215)
[Trace]	lv_mem_realloc: reallocating 0x19de8 with 16 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x19e08 	(in lv_mem.c line #215)
[Trace]	lv_init: finished 	(in lv_obj.c line #183)
after lv_init
before lv_disp_drv_register
lv_disp_drv_register
[Trace]	lv_mem_alloc: allocating 106000 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x19e18 	(in lv_mem.c line #160)
lv_disp_drv_register: disp=0x19e18
[Trace]	lv_mem_alloc: allocating 84 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x33c28 	(in lv_mem.c line #160)
[Trace]	lv_mem_alloc: allocating 106000 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x33c7c 	(in lv_mem.c line #160)
[Info]	lv_obj_create: begin 	(in lv_obj.c line #206)
[Trace]	lv_obj_class_create_obj: Creating object with 0x12014 class on 0 parent 	(in lv_obj_class.c line #45)
[Trace]	lv_mem_alloc: allocating 36 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x4da8c 	(in lv_mem.c line #160)
[Trace]	lv_obj_class_create_obj: creating a screen 	(in lv_obj_class.c line #55)
[Trace]	lv_mem_alloc: allocating 4 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x4dab0 	(in lv_mem.c line #160)
screen_cnt1=1
new screen1=0x4da8c
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	lv_obj_constructor: begin 	(in lv_obj.c line #403)
[Trace]	lv_obj_constructor: finished 	(in lv_obj.c line #428)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Info]	lv_obj_create: begin 	(in lv_obj.c line #206)
[Trace]	lv_obj_class_create_obj: Creating object with 0x12014 class on 0 parent 	(in lv_obj_class.c line #45)
[Trace]	lv_mem_alloc: allocating 36 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x4dab4 	(in lv_mem.c line #160)
[Trace]	lv_obj_class_create_obj: creating a screen 	(in lv_obj_class.c line #55)
[Trace]	lv_mem_realloc: reallocating 0x4dab0 with 8 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x4dad8 	(in lv_mem.c line #215)
screen_cnt2=2
new screen2=0x4dab4
obj->parent=0
scr=0x4dab4
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dab4
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	lv_obj_constructor: begin 	(in lv_obj.c line #403)
[Trace]	lv_obj_constructor: finished 	(in lv_obj.c line #428)
obj->parent=0
scr=0x4dab4
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dab4
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dab4
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dab4
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dab4
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Info]	lv_obj_create: begin 	(in lv_obj.c line #206)
[Trace]	lv_obj_class_create_obj: Creating object with 0x12014 class on 0 parent 	(in lv_obj_class.c line #45)
[Trace]	lv_mem_alloc: allocating 36 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x4dae0 	(in lv_mem.c line #160)
[Trace]	lv_obj_class_create_obj: creating a screen 	(in lv_obj_class.c line #55)
[Trace]	lv_mem_realloc: reallocating 0x4dad8 with 12 size 	(in lv_mem.c line #196)
[Trace]	lv_mem_realloc: allocated at 0x4db04 	(in lv_mem.c line #215)
screen_cnt2=3
new screen2=0x4dae0
obj->parent=0
scr=0x4dae0
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dae0
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	lv_obj_constructor: begin 	(in lv_obj.c line #403)
[Trace]	lv_obj_constructor: finished 	(in lv_obj.c line #428)
obj->parent=0
scr=0x4dae0
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dae0
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dae0
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dae0
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dae0
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	lv_mem_alloc: allocating 28 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x4db10 	(in lv_mem.c line #160)
obj->parent=0
scr=0x4dab4
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dab4
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dab4
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	lv_mem_alloc: allocating 28 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x4db2c 	(in lv_mem.c line #160)
obj->parent=0
scr=0x4dae0
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dae0
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4dae0
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
lv_disp_drv_register OK
after lv_disp_drv_register
createWidgetsWrapped: start
[Info]	lv_label_create: begin 	(in lv_label.c line #75)
[Trace]	lv_obj_class_create_obj: Creating object with 0x10000 class on 0x4da8c parent 	(in lv_obj_class.c line #45)
[Trace]	lv_mem_alloc: allocating 76 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x4db48 	(in lv_mem.c line #160)
[Trace]	lv_obj_class_create_obj: creating normal object 	(in lv_obj_class.c line #86)
[Trace]	lv_mem_alloc: allocating 28 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x4db94 	(in lv_mem.c line #160)
[Trace]	lv_mem_alloc: allocating 4 bytes 	(in lv_mem.c line #127)
[Trace]	lv_mem_alloc: allocated at 0x4dbb0 	(in lv_mem.c line #160)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	lv_obj_constructor: begin 	(in lv_obj.c line #403)
[Trace]	lv_obj_constructor: finished 	(in lv_obj.c line #428)
[Trace]	lv_label_constructor: begin 	(in lv_label.c line #691)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	(0.100, +1)	 lv_mem_alloc: allocating 5 bytes 	(in lv_mem.c line #127)
[Trace]	(0.101, +1)	 lv_mem_alloc: allocated at 0x4dbb4 	(in lv_mem.c line #160)
obj->parent=0
scr=0x4da8c
[Warn]	(0.102, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.103, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.104, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	(0.105, +1)	 lv_label_constructor: finished 	(in lv_label.c line #721)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.106, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.107, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.108, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.109, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.110, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.111, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.112, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.113, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.114, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.115, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.116, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.117, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.118, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.119, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.120, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.121, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.122, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.123, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	(0.124, +1)	 lv_mem_realloc: reallocating 0 with 8 size 	(in lv_mem.c line #196)
[Trace]	(0.125, +1)	 lv_mem_realloc: allocated at 0x4dbb9 	(in lv_mem.c line #215)
[Trace]	(0.126, +1)	 lv_mem_alloc: allocating 8 bytes 	(in lv_mem.c line #127)
[Trace]	(0.127, +1)	 lv_mem_alloc: allocated at 0x4dbc1 	(in lv_mem.c line #160)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.128, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.129, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.130, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.131, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.132, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.133, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.134, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.135, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.136, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.137, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.138, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	(0.139, +1)	 lv_mem_free: freeing 0x4dbb4 	(in lv_mem.c line #171)
[Trace]	(0.140, +1)	 lv_mem_alloc: allocating 53 bytes 	(in lv_mem.c line #127)
[Trace]	(0.141, +1)	 lv_mem_alloc: allocated at 0x4dbc9 	(in lv_mem.c line #160)
obj->parent=0
scr=0x4da8c
[Warn]	(0.142, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.143, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.144, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	(0.145, +1)	 lv_mem_alloc: allocating 12 bytes 	(in lv_mem.c line #127)
[Trace]	(0.146, +1)	 lv_mem_alloc: allocated at 0x4dbfe 	(in lv_mem.c line #160)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.147, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.148, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.149, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.150, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.151, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.152, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.153, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.154, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.155, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	(0.156, +1)	 lv_mem_realloc: reallocating 0x4dbfe with 18 size 	(in lv_mem.c line #196)
[Trace]	(0.157, +1)	 lv_mem_realloc: allocated at 0x4dc0a 	(in lv_mem.c line #215)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.158, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.159, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.160, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.161, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.162, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.163, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.164, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.165, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.166, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	(0.167, +1)	 lv_mem_realloc: reallocating 0x4dc0a with 24 size 	(in lv_mem.c line #196)
[Trace]	(0.168, +1)	 lv_mem_realloc: allocated at 0x4dc1c 	(in lv_mem.c line #215)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.169, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.170, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.171, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.172, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.173, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.174, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.175, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.176, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.177, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
[Trace]	(0.178, +1)	 lv_mem_realloc: reallocating 0x4dc1c with 30 size 	(in lv_mem.c line #196)
[Trace]	(0.179, +1)	 lv_mem_realloc: allocated at 0x4dc34 	(in lv_mem.c line #215)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.180, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.181, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.182, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.183, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.184, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.185, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.186, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0x4da8c
scr=0x4da8c
[Warn]	(0.187, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
obj->parent=0
scr=0x4da8c
[Warn]	(0.188, +1)	 lv_obj_get_disp: No screen found 	(in lv_obj_tree.c line #290)
createWidgetsWrapped: end
lv_timer_handler: start
[Trace]	(0.189, +1)	 lv_timer_handler: begin 	(in lv_timer.c line #69)
[Trace]	(0.193, +4)	 lv_timer_handler: finished (-1 ms until the next timer call) 	(in lv_timer.c line #144)
lv_timer_handler: end
lv_timer_handler: start
[Trace]	(0.194, +1)	 lv_timer_handler: begin 	(in lv_timer.c line #69)
[Trace]	(0.198, +4)	 lv_timer_handler: finished (-1 ms until the next timer call) 	(in lv_timer.c line #144)
lv_timer_handler: end
lv_timer_handler: start
[Trace]	(0.199, +1)	 lv_timer_handler: begin 	(in lv_timer.c line #69)
[Trace]	(0.203, +4)	 lv_timer_handler: finished (-1 ms until the next timer call) 	(in lv_timer.c line #144)
lv_timer_handler: end
lv_timer_handler: start
[Trace]	(0.204, +1)	 lv_timer_handler: begin 	(in lv_timer.c line #69)
[Trace]	(0.208, +4)	 lv_timer_handler: finished (-1 ms until the next timer call) 	(in lv_timer.c line #144)
lv_timer_handler: end
lv_timer_handler: start
[Trace]	(0.209, +1)	 lv_timer_handler: begin 	(in lv_timer.c line #69)
[Trace]	(0.213, +4)	 lv_timer_handler: finished (-1 ms until the next timer call) 	(in lv_timer.c line #144)
lv_timer_handler: end
lv_timer_handler: start
[Trace]	(0.214, +1)	 lv_timer_handler: begin 	(in lv_timer.c line #69)
[Trace]	(0.218, +4)	 lv_timer_handler: finished (-1 ms until the next timer call) 	(in lv_timer.c line #144)
lv_timer_handler: end
lv_timer_handler: start
[Trace]	(0.219, +1)	 lv_timer_handler: begin 	(in lv_timer.c line #69)
[Trace]	(0.223, +4)	 lv_timer_handler: finished (-1 ms until the next timer call) 	(in lv_timer.c line #144)
lv_timer_handler: end
lv_timer_handler: start
[Trace]	(0.224, +1)	 lv_timer_handler: begin 	(in lv_timer.c line #69)
[Trace]	(0.228, +4)	 lv_timer_handler: finished (-1 ms until the next timer call) 	(in lv_timer.c line #144)
lv_timer_handler: end
lv_timer_handler: start
[Trace]	(0.229, +1)	 lv_timer_handler: begin 	(in lv_timer.c line #69)
[Trace]	(0.233, +4)	 lv_timer_handler: finished (-1 ms until the next timer call) 	(in lv_timer.c line #144)
lv_timer_handler: end
lv_timer_handler: start
[Trace]	(0.234, +1)	 lv_timer_handler: begin 	(in lv_timer.c line #69)
[Trace]	(0.238, +4)	 lv_timer_handler: finished (-1 ms until the next timer call) 	(in lv_timer.c line #144)
lv_timer_handler: end
lv_demo_widgets: end
lv_demo_widgets: done
loop: end
main: end
```

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
