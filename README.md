![LVGL for PinePhone with Zig and Apache NuttX RTOS](https://lupyuen.github.io/images/lvgl2-zig.jpg)

# LVGL for PinePhone with Zig and Apache NuttX RTOS

Read the articles...

-   ["NuttX RTOS for PinePhone: Boot to LVGL"](https://lupyuen.github.io/articles/lvgl2)

-   ["Build an LVGL Touchscreen App with Zig"](https://lupyuen.github.io/articles/lvgl)

Can we build an LVGL App for PinePhone in Zig... That will run on Apache NuttX RTOS?

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

[(See the Build Script)](https://gist.github.com/lupyuen/aa1f5c0c45e6029b10e5e2f955d8386c)

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

TODO: Use Zig to compile LVGL from C to WebAssembly [(With `zig cc`)](https://github.com/lupyuen/zig-bl602-nuttx#zig-compiler-as-drop-in-replacement-for-gcc)

TODO: Use Zig to connect the JavaScript UI (canvas rendering + input events) to LVGL WebAssembly [(Like this)](https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7)

# WebAssembly Demo with Zig and JavaScript

We can run __Zig (WebAssembly) + JavaScript__ in a Web Browser like so...

- [WebAssembly With Zig in a Web Browser](https://dev.to/sleibrock/webassembly-with-zig-pt-ii-ei7)

Let's run a simple demo...

- [demo/madelbrot.zig](demo/madelbrot.zig): Zig Program

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
  -dynamic
```

This produces the Compiled WebAssembly `mandelbrot.wasm`.

Start a Local Web Server. [(Like Web Server for Chrome)](https://chrome.google.com/webstore/detail/web-server-for-chrome/ofhbbkphhbklhfoeikjpcbhemlocgigb)

Browse to `demo/demo.html`. We should see the Mandelbrot Set yay!

# Zig Version

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
