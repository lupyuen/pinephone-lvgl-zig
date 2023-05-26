// LVGL Display Interface for Zig
// See https://lupyuen.github.io/articles/lvgl#fix-opaque-types
// From https://github.com/lupyuen/lvgltest-nuttx/blob/main/lcddev.c

#include <nuttx/config.h>
#include <lvgl/lvgl.h>

// Display Buffer
#define HOR_RES     720  // Horizontal Resolution
#define BUFFER_ROWS 10   // Number of rows to buffer
#define BUFFER_SIZE (HOR_RES * BUFFER_ROWS)
static lv_color_t buffer[BUFFER_SIZE];

/****************************************************************************
 * Name: get_disp_drv
 *
 * Description:
 *   Return the static instance of Display Driver, because Zig can't
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
 *   Return the static instance of Display Buffer, because Zig can't
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
 *   Initialise the Display Driver, because Zig can't access its fields.
 *
 ****************************************************************************/

void init_disp_drv(
  lv_disp_drv_t      *disp_drv,  // Display Driver
  lv_disp_draw_buf_t *disp_buf,  // Display Buffer
  void (*flush_cb)(lv_disp_drv_t *, const lv_area_t *, lv_color_t *),  // Callback Function to Flush the Display
  lv_coord_t hor_res,  // Horizontal Resolution
  lv_coord_t ver_res   // Vertical Resolution
) {
  assert(disp_drv != NULL);
  assert(disp_buf != NULL);
  assert(flush_cb != NULL);
  assert(hor_res <= HOR_RES);

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
 *   Initialise the Display Buffer, because Zig can't access the fields.
 *
 ****************************************************************************/

void init_disp_buf(lv_disp_draw_buf_t *disp_buf)
{
  assert(disp_buf != NULL);
  lv_disp_draw_buf_init(disp_buf, buffer, NULL, BUFFER_SIZE);
}
