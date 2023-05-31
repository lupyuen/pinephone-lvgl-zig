// LVGL Display Interface for Zig
// See https://lupyuen.github.io/articles/lvgl#fix-opaque-types
// From https://github.com/lupyuen/lvgltest-nuttx/blob/main/lcddev.c

#include <nuttx/config.h>
#include <lvgl/lvgl.h>
#include "display.h"

// Canvas Buffer for rendering LVGL Display
#define HOR_RES     720      // Horizontal Resolution
#define VER_RES     1280     // Vertical Resolution
#define BUFFER_ROWS VER_RES  // Number of rows to buffer
#define BUFFER_SIZE (HOR_RES * BUFFER_ROWS)
static lv_color_t canvas_buffer[BUFFER_SIZE];

lv_color_t *get_canvas_buffer(void)
{
  int count = 0;
  for (int i = 0; i < BUFFER_SIZE; i++) {
    if (canvas_buffer[i].full != 0xfff5f5f5) {  // TODO
      // lv_log("get_canvas_buffer: 0x%x", canvas_buffer[i].full);
      count++; 
    }
  }
  lv_log("get_canvas_buffer: %d non-empty pixels", count);
  lv_log("canvas_buffer: %p", canvas_buffer);
  return canvas_buffer;
}

/****************************************************************************
 * Name: get_disp_drv
 *
 * Description:
 *   Return the static instance of LVGL Display Driver, because Zig can't
 *   allocate structs wth bitfields inside.
 *
 ****************************************************************************/

lv_disp_drv_t *get_disp_drv(void)
{
  static lv_disp_drv_t disp_drv;
  return &disp_drv;
}

/****************************************************************************
 * Name: get_disp_buf
 *
 * Description:
 *   Return the static instance of LVGL Display Buffer, because Zig can't
 *   allocate structs wth bitfields inside.
 *
 ****************************************************************************/

lv_disp_draw_buf_t *get_disp_buf(void)
{
  static lv_disp_draw_buf_t disp_buf;
  return &disp_buf;
}

/****************************************************************************
 * Name: init_disp_drv
 *
 * Description:
 *   Initialise the LVGL Display Driver, because Zig can't access its fields.
 *
 ****************************************************************************/

void init_disp_drv(
  lv_disp_drv_t      *disp_drv,  // Display Driver
  lv_disp_draw_buf_t *disp_buf,  // Display Buffer
  void (*flush_cb)(lv_disp_drv_t *, const lv_area_t *, lv_color_t *),  // Callback Function to Flush the Display
  lv_coord_t hor_res,  // Horizontal Resolution
  lv_coord_t ver_res   // Vertical Resolution
) {
  LV_ASSERT(disp_drv != NULL);
  LV_ASSERT(disp_buf != NULL);
  LV_ASSERT(flush_cb != NULL);
  LV_ASSERT(hor_res <= HOR_RES);
  LV_ASSERT(ver_res <= VER_RES);

  // Init the Display Driver Struct
  lv_disp_drv_init(disp_drv);

  // Set the Display Buffer
  disp_drv->draw_buf = disp_buf;

  // Set the Callback Function to Flush the Display
  disp_drv->flush_cb = flush_cb;

  // Set the Horizontal and Vertical Resolution
  disp_drv->hor_res = hor_res;
  disp_drv->ver_res = ver_res;
}

/****************************************************************************
 * Name: init_disp_buf
 *
 * Description:
 *   Initialise the LVGL Display Buffer, because Zig can't access the fields.
 *
 ****************************************************************************/

void init_disp_buf(lv_disp_draw_buf_t *disp_buf)
{
  LV_ASSERT(disp_buf != NULL);
  lv_disp_draw_buf_init(disp_buf, canvas_buffer, NULL, BUFFER_SIZE);
}

// Register the LVGL Input Device Driver and return the LVGL Input Device
void *register_input(lv_indev_drv_t *indev_drv)
{
  lv_indev_t *indev = lv_indev_drv_register(indev_drv);
  LV_ASSERT(indev != NULL);
  return indev;
}

// Set the LVGL Input Device Data
void set_input_data(
  lv_indev_data_t *data,
  lv_indev_state_t state,
  lv_coord_t x,
  lv_coord_t y
) {
  LV_ASSERT(data != NULL);
  data->state = state;
  data->point.x = x;
  data->point.y = y;
}
