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

  ## Compile our LVGL Display Driver from C to WebAssembly with Zig Compiler
  compile_lvgl ../../../../../pinephone-lvgl-zig/display.c display.o

  ## Compile LVGL Library from C to WebAssembly with Zig Compiler
  compile_lvgl font/lv_font_montserrat_14.c lv_font_montserrat_14.o
  compile_lvgl font/lv_font_montserrat_20.c lv_font_montserrat_20.o
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
  compile_lvgl misc/lv_log.c lv_log.o
  compile_lvgl misc/lv_printf.c lv_printf.o
  compile_lvgl misc/lv_fs.c lv_fs.o
  compile_lvgl draw/lv_draw.c lv_draw.o
  compile_lvgl draw/lv_img_decoder.c lv_img_decoder.o
  compile_lvgl extra/lv_extra.c lv_extra.o
  compile_lvgl extra/layouts/flex/lv_flex.c lv_flex.o
  compile_lvgl extra/layouts/grid/lv_grid.c lv_grid.o
  compile_lvgl draw/sw/lv_draw_sw.c lv_draw_sw.o
  compile_lvgl draw/sw/lv_draw_sw_rect.c lv_draw_sw_rect.o
  compile_lvgl draw/lv_img_cache.c lv_img_cache.o
  compile_lvgl draw/lv_img_buf.c lv_img_buf.o
  compile_lvgl draw/sw/lv_draw_sw_arc.c lv_draw_sw_arc.o
  compile_lvgl draw/sw/lv_draw_sw_letter.c lv_draw_sw_letter.o
  compile_lvgl draw/sw/lv_draw_sw_blend.c lv_draw_sw_blend.o
  compile_lvgl draw/sw/lv_draw_sw_layer.c lv_draw_sw_layer.o
  compile_lvgl draw/sw/lv_draw_sw_transform.c lv_draw_sw_transform.o
  compile_lvgl draw/sw/lv_draw_sw_polygon.c lv_draw_sw_polygon.o
  compile_lvgl draw/sw/lv_draw_sw_line.c lv_draw_sw_line.o
  compile_lvgl draw/sw/lv_draw_sw_img.c lv_draw_sw_img.o
  compile_lvgl draw/sw/lv_draw_sw_gradient.c lv_draw_sw_gradient.o
  compile_lvgl draw/lv_draw_transform.c lv_draw_transform.o
  compile_lvgl extra/themes/default/lv_theme_default.c lv_theme_default.o
  compile_lvgl font/lv_font_fmt_txt.c lv_font_fmt_txt.o
  compile_lvgl draw/lv_draw_layer.c lv_draw_layer.o
  compile_lvgl misc/lv_style_gen.c lv_style_gen.o
  compile_lvgl misc/lv_gc.c lv_gc.o
  compile_lvgl misc/lv_utils.c lv_utils.o
  compile_lvgl widgets/lv_btn.c lv_btn.o
  compile_lvgl core/lv_indev_scroll.c lv_indev_scroll.o

  ## Compile the Zig LVGL App for WebAssembly 
  ## TODO: Change ".." to your NuttX Project Directory
  zig build-lib \
    --verbose-cimport \
    -target wasm32-freestanding \
    -dynamic \
    -rdynamic \
    -lc \
    -DFAR= \
    -DLV_MEM_CUSTOM=1 \
    -DLV_FONT_MONTSERRAT_14=1 \
    -DLV_FONT_MONTSERRAT_20=1 \
    -DLV_FONT_DEFAULT_MONTSERRAT_20=1 \
    -DLV_USE_FONT_PLACEHOLDER=1 \
    -DLV_USE_LOG=1 \
    -DLV_LOG_LEVEL=LV_LOG_LEVEL_TRACE \
    -DLV_LOG_TRACE_OBJ_CREATE=1 \
    "-DLV_ASSERT_HANDLER={void lv_assert_handler(void); lv_assert_handler();}" \
    -I . \
    \
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
    \
    lvglwasm.zig \
    display.o \
    lv_font_montserrat_14.o \
    lv_font_montserrat_20.o \
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
    lv_log.o \
    lv_printf.o \
    lv_fs.o \
    lv_draw.o \
    lv_img_decoder.o \
    lv_extra.o \
    lv_flex.o \
    lv_grid.o \
    lv_draw_sw.o \
    lv_draw_sw_rect.o \
    lv_img_cache.o \
    lv_img_buf.o \
    lv_draw_sw_arc.o \
    lv_draw_sw_letter.o \
    lv_draw_sw_blend.o \
    lv_draw_sw_layer.o \
    lv_draw_sw_transform.o \
    lv_draw_sw_polygon.o \
    lv_draw_sw_line.o \
    lv_draw_sw_img.o \
    lv_draw_sw_gradient.o \
    lv_draw_transform.o \
    lv_theme_default.o \
    lv_font_fmt_txt.o \
    lv_draw_layer.o \
    lv_style_gen.o \
    lv_gc.o \
    lv_utils.o \
    lv_btn.o \
    lv_indev_scroll.o \

  ## Compile the Zig LVGL App for PinePhone 
  ## (armv8-a with cortex-a53)
  ## TODO: Change ".." to your NuttX Project Directory
  zig build-obj \
    --verbose-cimport \
    -target aarch64-freestanding-none \
    -mcpu cortex_a53 \
    \
    -isystem "../nuttx/include" \
    -I . \
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
    -DLV_MEM_CUSTOM=1 \
    -DLV_FONT_MONTSERRAT_14=1 \
    -DLV_FONT_MONTSERRAT_20=1 \
    -DLV_FONT_DEFAULT_MONTSERRAT_20=1 \
    -DLV_USE_FONT_PLACEHOLDER=1 \
    -DLV_USE_LOG=1 \
    -DLV_LOG_LEVEL=LV_LOG_LEVEL_TRACE \
    -DLV_LOG_TRACE_OBJ_CREATE=1 \
    "-DLV_ASSERT_HANDLER={void lv_assert_handler(void); lv_assert_handler();}" \
    \
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

## Build the Feature Phone Zig LVGL App for WebAssembly 
## TODO: Change ".." to your NuttX Project Directory
function build_feature_phone_wasm {
  zig build-lib \
    --verbose-cimport \
    -target wasm32-freestanding \
    -dynamic \
    -rdynamic \
    -lc \
    -DFAR= \
    -DLV_MEM_CUSTOM=1 \
    -DLV_FONT_MONTSERRAT_14=1 \
    -DLV_FONT_MONTSERRAT_20=1 \
    -DLV_FONT_DEFAULT_MONTSERRAT_20=1 \
    -DLV_USE_FONT_PLACEHOLDER=1 \
    -DLV_USE_LOG=1 \
    -DLV_LOG_LEVEL=LV_LOG_LEVEL_TRACE \
    -DLV_LOG_TRACE_OBJ_CREATE=1 \
    "-DLV_ASSERT_HANDLER={void lv_assert_handler(void); lv_assert_handler();}" \
    -I . \
    \
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
    \
    feature-phone.zig \
    display.o \
    lv_font_montserrat_14.o \
    lv_font_montserrat_20.o \
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
    lv_log.o \
    lv_printf.o \
    lv_fs.o \
    lv_draw.o \
    lv_img_decoder.o \
    lv_extra.o \
    lv_flex.o \
    lv_grid.o \
    lv_draw_sw.o \
    lv_draw_sw_rect.o \
    lv_img_cache.o \
    lv_img_buf.o \
    lv_draw_sw_arc.o \
    lv_draw_sw_letter.o \
    lv_draw_sw_blend.o \
    lv_draw_sw_layer.o \
    lv_draw_sw_transform.o \
    lv_draw_sw_polygon.o \
    lv_draw_sw_line.o \
    lv_draw_sw_img.o \
    lv_draw_sw_gradient.o \
    lv_draw_transform.o \
    lv_theme_default.o \
    lv_font_fmt_txt.o \
    lv_draw_layer.o \
    lv_style_gen.o \
    lv_gc.o \
    lv_utils.o \
    lv_btn.o \
    lv_indev_scroll.o \

}

## Compile the Feature Phone Zig LVGL App for Apache NuttX RTOS
function build_feature_phone_nuttx {
  ## Compile the Zig LVGL App for PinePhone 
  ## (armv8-a with cortex-a53)
  ## TODO: Change ".." to your NuttX Project Directory
  zig build-obj \
    --verbose-cimport \
    -target aarch64-freestanding-none \
    -mcpu cortex_a53 \
    \
    -isystem "../nuttx/include" \
    -I . \
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
    feature-phone.zig

  ## Copy the compiled Zig LVGL App to NuttX and overwrite `lv_demo_widgets.*.o`
  ## TODO: Change ".." to your NuttX Project Directory
  cp lvgltest.o \
    ../apps/graphics/lvgl/lvgl/demos/widgets/lv_demo_widgets.*.o
}

## Build the LVGL App (in Zig) and LVGL Library (in C) for PinePhone and WebAssembly
build_zig

## Compile the Feature Phone Zig LVGL App for WebAssembly 
build_feature_phone_wasm

## Compile the Feature Phone Zig LVGL App for Apache NuttX RTOS
build_feature_phone_nuttx
