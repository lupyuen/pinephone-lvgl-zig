lv_color_t *get_canvas_buffer(void);

void *register_input(lv_indev_drv_t *indev_drv);

void set_input_data(
  lv_indev_data_t *data,
  lv_indev_state_t state,
  lv_coord_t x,
  lv_coord_t y
);

/****************************************************************************
 * Name: get_disp_drv
 *
 * Description:
 *   Return the static instance of Display Driver, because Zig can't
 *   allocate structs wth bitfields inside.
 *
 ****************************************************************************/

lv_disp_drv_t *get_disp_drv(void);

/****************************************************************************
 * Name: get_disp_buf
 *
 * Description:
 *   Return the static instance of Display Buffer, because Zig can't
 *   allocate structs wth bitfields inside.
 *
 ****************************************************************************/

lv_disp_draw_buf_t *get_disp_buf(void);

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
);

/****************************************************************************
 * Name: init_disp_buf
 *
 * Description:
 *   Initialise the Display Buffer, because Zig can't access the fields.
 *
 ****************************************************************************/

void init_disp_buf(lv_disp_draw_buf_t *disp_buf);
