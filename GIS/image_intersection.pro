;+
; NAME:
;
; image_intersection
;
; AUTHOR:
;
; Wei Lin
; wei.lin@mail.bnu.edu.cn
;
; PURPOSE:
;
;    To get values from image 1 within the intersection region of 2 images
;
; CALLING SEQUENCE:
;
;    result = image_intersection(image1, image2)
;
; ARGUMENTS:
;
;    image1: a structure with 6 elements
;      value: calculating index
;      x_left: x coordinates of start point of image
;      y_top: y coordinates of start point of  image
;      N_col: number of columns of image
;      N_row: number of rows of image
;      pixel_size: pixel size of image

;    image2: a struct with at least 5 elements
;      x_left: x coordinates of start point of image
;      y_top: y coordinates of start point of  image
;      N_col: number of columns of image
;      N_row: number of rows of image
;      pixel_size: pixel size of image
;
; OUTPUTS:
;
;    A structure with the same elements as image1
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:

function image_intersection, image1, image2

  if image1.pixel_size ne image2.pixel_size then return,-1
  
  image1_x_left = image1.x_left
  image1_y_top = image1.y_top
  image2_x_left = image2.x_left
  image2_y_top = image2.y_top
  
  N_col1 = image1.N_col
  N_row1 = image1.N_row
  N_col2 = image2.N_col
  N_row2 = image2.N_row
  
  pixel_size = image1.pixel_size
  image1_x_right  = float(image1_x_left + N_col1* pixel_size)
  image1_y_down   = float(image1_y_top - N_row1* pixel_size)
  image2_x_right  = float(image2_x_left + N_col2 * pixel_size)
  image2_y_down    = float(image2_y_top - N_row2 * pixel_size)
  
  intersect_x_left  = double(max([image1_x_left, image2_x_left]))
  intersect_y_top   = double(min([image1_y_top, image2_y_top]))
  intersect_x_right = double(min([image1_x_right, image2_x_right]))
  intersect_y_down  = double(max([image1_y_down, image2_y_down]))
  
  ; if the two images have no intersect region, then return
  if (intersect_x_left ge intersect_x_right) or (intersect_y_top le intersect_y_down) then begin
    return, -1
  endif else begin
    ; get number of colums rows of the intersect region
    intersect_N_col = ceil((intersect_x_right - intersect_x_left) / float(pixel_size))
    intersect_N_row = ceil((intersect_y_top - intersect_y_down) / float(pixel_size))
    
    ; get the col and row number of the intersect region
    col_tmp_left = floor((intersect_x_left - image1_x_left) / pixel_size)
    row_tmp_top  = floor((image1_y_top - intersect_y_top) / pixel_size)
    
    ;image1.value must be a pointer or a 2-dimension array
    
    if size(image1.value,/type) eq 10 then begin
      intersect_image = (*(image1.value))[col_tmp_left:(col_tmp_left + intersect_N_col - 1),$
        row_tmp_top:(row_tmp_top + intersect_N_row - 1),*]
    endif else begin
      intersect_image = image1.value[col_tmp_left:(col_tmp_left + intersect_N_col - 1),$
        row_tmp_top:(row_tmp_top + intersect_N_row - 1),*]
    endelse
    
    rst_struc = {value: intersect_image,$
      x_left: intersect_x_left, $
      y_top: intersect_y_top, $
      N_col: intersect_N_col, $
      N_row: intersect_N_row, $
      pixel_size: pixel_size}
      
  endelse
  
  return, rst_struc
  
end