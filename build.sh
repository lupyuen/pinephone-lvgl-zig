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

  ## Compile LVGL Library from C to WebAssembly with Zig Compiler
  compile_lvgl widgets/lv_label.c lv_label.o
  compile_lvgl core/lv_obj.c lv_obj.o
  compile_lvgl misc/lv_mem.c lv_mem.o
  compile_lvgl core/lv_event.c lv_event.o
  compile_lvgl core/lv_obj_style.c lv_obj_style.o
  compile_lvgl core/lv_obj_pos.c lv_obj_pos.o
  compile_lvgl misc/lv_txt.c lv_txt.o
  compile_lvgl draw/lv_draw_label.c lv_draw_label.o
  compile_lvgl core/lv_obj_draw.c lv_obj_draw.o
  compile_lvgl misc/lv_area.c lv_area.o
  compile_lvgl core/lv_obj_scroll.c lv_obj_scroll.o
  compile_lvgl font/lv_font.c lv_font.o
  compile_lvgl core/lv_obj_class.c lv_obj_class.o
  compile_lvgl core/lv_obj_tree.c lv_obj_tree.o
  compile_lvgl hal/lv_hal_disp.c lv_hal_disp.o
  compile_lvgl misc/lv_anim.c lv_anim.o
  compile_lvgl misc/lv_tlsf.c lv_tlsf.o
  compile_lvgl core/lv_group.c lv_group.o
  compile_lvgl core/lv_indev.c lv_indev.o
  compile_lvgl draw/lv_draw_rect.c lv_draw_rect.o
  compile_lvgl draw/lv_draw_mask.c lv_draw_mask.o
  compile_lvgl misc/lv_style.c lv_style.o
  compile_lvgl misc/lv_ll.c lv_ll.o
  compile_lvgl core/lv_obj_style_gen.c lv_obj_style_gen.o
  compile_lvgl misc/lv_timer.c lv_timer.o
  compile_lvgl core/lv_disp.c lv_disp.o
  compile_lvgl core/lv_refr.c lv_refr.o
  compile_lvgl misc/lv_color.c lv_color.o
  compile_lvgl draw/lv_draw_line.c lv_draw_line.o
  compile_lvgl draw/lv_draw_img.c lv_draw_img.o
  compile_lvgl misc/lv_math.c lv_math.o
  compile_lvgl hal/lv_hal_indev.c lv_hal_indev.o
  compile_lvgl core/lv_theme.c lv_theme.o
  compile_lvgl hal/lv_hal_tick.c lv_hal_tick.o

  ## Compile the Zig LVGL App for WebAssembly 
  ## TODO: Change ".." to your NuttX Project Directory
  ## TODO: Try `zig build-exe` to fix `strlen` missing
  zig build-lib \
    --verbose-cimport \
    -target wasm32-freestanding \
    -dynamic \
    -rdynamic \
    -DFAR= \
    -lc \
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
    lv_event.o \
    lv_obj_style.o \
    lv_obj_pos.o \
    lv_txt.o \
    lv_draw_label.o \
    lv_obj_draw.o \
    lv_area.o \
    lv_obj_scroll.o \
    lv_font.o \
    lv_obj_class.o \
    lv_obj_tree.o \
    lv_hal_disp.o \
    lv_anim.o \
    lv_tlsf.o \
    lv_group.o \
    lv_indev.o \
    lv_draw_rect.o \
    lv_draw_mask.o \
    lv_style.o \
    lv_ll.o \
    lv_obj_style_gen.o \
    lv_timer.o \
    lv_disp.o \
    lv_refr.o \
    lv_color.o \
    lv_draw_line.o \
    lv_draw_img.o \
    lv_math.o \
    lv_hal_indev.o \
    lv_theme.o \
    lv_hal_tick.o \

  ## Compile the Zig LVGL App for PinePhone 
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

  ## Copy the compiled Zig LVGL App to NuttX and overwrite `lv_demo_widgets.*.o`
  ## TODO: Change ".." to your NuttX Project Directory
  cp lvgltest.o \
    ../apps/graphics/lvgl/lvgl/demos/widgets/lv_demo_widgets.*.o
}

## Compile LVGL Library from C to WebAssembly with Zig Compiler
## TODO: Change ".." to your NuttX Project Directory
function compile_lvgl {
  local source_file=$1  ## Input Source File (LVGL in C)
  local object_file=$2  ## Output Object File (WebAssembly)

  pushd ../apps/graphics/lvgl
  zig cc \
    -target wasm32-freestanding \
    -dynamic \
    -rdynamic \
    -lc \
    -DFAR= \
    -DLV_USE_LOG \
    -DLV_LOG_LEVEL=LV_LOG_LEVEL_TRACE \
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
    lvgl/src/$source_file \
    -o ../../../pinephone-lvgl-zig/$object_file
  popd
}

## Build the LVGL App (in Zig) and LVGL Library (in C) for PinePhone and WebAssembly
build_zig