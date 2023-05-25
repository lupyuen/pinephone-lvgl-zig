#!/usr/bin/env bash
#  Build LVGL App (in Zig) and LVGL Library (in C) for PinePhone and WebAssembly

set -e  #  Exit when any command fails
set -x  #  Echo commands

## Build the LVGL App (in Zig) and LVGL Library (in C) for PinePhone and WebAssembly
## TODO: Change ".." to your NuttX Project Directory
function build_zig {

  ## Check that NuttX Build has completed and `lv_demo_widgets.*.o` exists
  if [ ! -f ../apps/graphics/lvgl/lvgl/demos/widgets/lv_demo_widgets.*.o ] 
  then
    echo "*** Error: Build NuttX first before building Zig app"
    exit 1
  fi

  ## Compile the Zig LVGL App for PinePhone 
  ## (armv8-a with cortex-a53)
  ## TODO: Change ".." to your NuttX Project Directory
  # zig build-obj \
  #   --verbose-cimport \
  #   -target aarch64-freestanding-none \
  #   -mcpu cortex_a53 \
  #   -isystem "../nuttx/include" \
  #   -I "../apps/include" \
  #   -I "../apps/graphics/lvgl" \
  #   -I "../apps/graphics/lvgl/lvgl/src/core" \
  #   -I "../apps/graphics/lvgl/lvgl/src/draw" \
  #   -I "../apps/graphics/lvgl/lvgl/src/draw/arm2d" \
  #   -I "../apps/graphics/lvgl/lvgl/src/draw/nxp" \
  #   -I "../apps/graphics/lvgl/lvgl/src/draw/nxp/pxp" \
  #   -I "../apps/graphics/lvgl/lvgl/src/draw/nxp/vglite" \
  #   -I "../apps/graphics/lvgl/lvgl/src/draw/sdl" \
  #   -I "../apps/graphics/lvgl/lvgl/src/draw/stm32_dma2d" \
  #   -I "../apps/graphics/lvgl/lvgl/src/draw/sw" \
  #   -I "../apps/graphics/lvgl/lvgl/src/draw/swm341_dma2d" \
  #   -I "../apps/graphics/lvgl/lvgl/src/font" \
  #   -I "../apps/graphics/lvgl/lvgl/src/hal" \
  #   -I "../apps/graphics/lvgl/lvgl/src/misc" \
  #   -I "../apps/graphics/lvgl/lvgl/src/widgets" \
  #   lvgltest.zig

  ## Compile LVGL Library from C to WebAssembly with Zig Compiler
  pushd ../apps/graphics/lvgl
  zig cc \
    -target wasm32-freestanding \
    -dynamic \
    -rdynamic \
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
    "-DLV_ASSERT_HANDLER=ASSERT(0);" \
    ./lvgl/src/widgets/lv_label.c \
    -o ../../../pinephone-lvgl-zig/lv_label.o

  zig cc \
    -target wasm32-freestanding \
    -dynamic \
    -rdynamic \
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
    "-DLV_ASSERT_HANDLER=ASSERT(0);" \
    ./lvgl/src/core/lv_obj.c \
    -o ../../../pinephone-lvgl-zig/lv_obj.o

  zig cc \
    -target wasm32-freestanding \
    -dynamic \
    -rdynamic \
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
    "-DLV_ASSERT_HANDLER=ASSERT(0);" \
    ./lvgl/src/misc/lv_mem.c \
    -o ../../../pinephone-lvgl-zig/lv_mem.o

  popd

  ## Compile the Zig LVGL App for WebAssembly 
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
    lvglwasm.zig \
    lv_label.o \
    lv_mem.o \
    lv_obj.o \

  exit ####

  ## Copy the compiled app to NuttX and overwrite `lv_demo_widgets.*.o`
  ## TODO: Change ".." to your NuttX Project Directory
  cp lvgltest.o \
    ../apps/graphics/lvgl/lvgl/demos/widgets/lv_demo_widgets.*.o
}

## Build the LVGL App (in Zig) and LVGL Library (in C) for PinePhone and WebAssembly
build_zig
