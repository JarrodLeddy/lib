;+
; NAME:
;
;    image_union
;
; AUTHOR:
;
;    Yuguo Wu
;    irisksys@gmail.com
;
; PURPOSE:
;
;    calculate specified value of 2 images
;
; CALLING SEQUENCE:
;
;    result = image_union(image1, image2, union_option = union_option)
;
; ARGUMENTS:
;
;    image1: a struct which has been calculated for some images, the elements are:
;      value: calculating index
;      x: x coordinates of start point of image
;      y: y coordinates of start point of image
;      N_col: number of column of image
;      N_row： nubber of N_row of image
;      pixel_size: pixel size of image
;    image2: a struct which is to be added in images, the elements are:
;      value: calculating index
;      x: x coordinates of start point of image
;      y: y coordinates of start point of image
;      N_col: number of column of image
;      N_row： nubber of N_row of image
;      pixel_size: pixel size of image
;
; KEYWORDS:
;    union_option: option of image union in images' public region:
;      1. choose maximum value
;      2. choose minimum value
;      3. choose mean value
;      4. choose sum value
;    background_value: initial value of union image. default value is 0
;
; OUTPUTS:
;
;    A struct after combine image1 and image2, the elements is the same as image1
;
; KNOWN BUGS:
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;

function image_union, image1, image2, union_option = union_option, $
    background_value = background_value
    
  image1_x_left = image1.x_left
  image1_y_top = image1.y_top
  image2_x_left = image2.x_left
  image2_y_top = image2.y_top
  
  ; get N_col and N_row of image1(rectangle) and N_col of image2(square)
  N_col1 = image1.N_col
  N_row1 = image1.N_row
  N_col2 = image2.N_col
  N_row2 = image2.N_row
  
  ; get pixel size, in this case, pixel size of image1 is eqaul to image2's
  pixel_size = image1.pixel_size
  
  ; get end points of 2 images
  image1_x_right = float(image1_x_left + (N_col1 - 1)* pixel_size)
  image1_y_down = float(image1_y_top - (N_row1 - 1)* pixel_size)
  image2_x_right = float(image2_x_left + (N_col2 - 1)* pixel_size)
  image2_y_down = float(image2_y_top - (N_row2 - 1)* pixel_size)
  
  ; get a start point of image which combine image1 and image2
  x_left = min([image1_x_left, image2_x_left])
  y_top = max([image1_y_top, image2_y_top])
  x_end = max([image1_x_right, image2_x_right])
  y_end = min([image1_y_down, image2_y_down])
  ; get N_col and N_row of the image
  N_image_col = round((x_end - x_left) / pixel_size) + 1
  N_image_row = round((y_top - y_end) / pixel_size) + 1
  
  ; define image to combine 2 image
  union_image = fltarr(N_image_col, N_image_row)
  if keyword_set(background_value) then begin
    union_image[*] = background_value
  endif else begin
    background_value = 0
  endelse
  
  ; get the index of start points in union image
  image1_col_tmp_left = round((image1_x_left - x_left) / pixel_size)
  image1_row_tmp_top  = round((y_top - image1_y_top) / pixel_size)
  image2_col_tmp_left = round((image2_x_left - x_left) / pixel_size)
  image2_row_tmp_top  = round((y_top - image2_y_top) / pixel_size)
  
  ; fill the image with 2 images
  i_y_end = image1_row_tmp_top + N_row1
  if i_y_end gt N_image_row then begin
    i_y_end = N_image_row
  endif
  
  union_image[image1_col_tmp_left: image1_col_tmp_left + N_col1 - 1,$
    image1_row_tmp_top:i_y_end - 1] = image1.value[*, 0 : i_y_end - image1_row_tmp_top - 1]
    
  union_image[image2_col_tmp_left: image2_col_tmp_left + N_col2 - 1,$
    image2_row_tmp_top:image2_row_tmp_top + N_row2 - 1 ] = image2.value[*, 0 : N_row2 - 1]
        
  ; define a return structure
  return_image = {value: union_image, $
    x_left: x_left, $
    y_top: y_top, $
    N_col: N_image_col, $
    N_row: N_image_row, $
    pixel_size: pixel_size}
    
  ; specify the public region of the 2 images(start/end points)
  public_x_left = max([image1_x_left, image2_x_left])
  public_y_top  = min([image1_y_top, image2_y_top])
  public_x_end  = min([image1_x_right, image2_x_right])
  public_y_end  = max([image1_y_down, image2_y_down])
  
  ; 2 images has no public region, return
  if public_x_left gt public_x_end or public_y_top lt public_y_end then begin
    return, return_image
  endif else begin
    ; get N_col and N_row for public region
    public_N_col = round((public_x_end - public_x_left) / pixel_size) + 1
    public_N_row = round((public_y_top - public_y_end) / pixel_size) + 1
       
    ; get the start point index of images for 2 images just defined
    public_x1 = round((public_x_left - image1_x_left) / pixel_size)
    public_y1 = round((image1_y_top - public_y_top) / pixel_size)
    public_x2 = round((public_x_left - image2_x_left) / pixel_size)
    public_y2 = round((image2_y_top - public_y_top) / pixel_size)
    ; get the start point index of union image in public region
    public_x_union = round((public_x_left - x_left) / pixel_size)
    public_y_union = round((y_top - public_y_top) / pixel_size)
        
    public_image1 = image1.value[public_x1:public_x1+public_N_col-1,$
      public_y1:public_y1 + public_N_row - 1]
          
    public_image2 = image2.value[public_x2:public_x2+public_N_col-1,$
      public_y2:public_y2 + public_N_row - 1]
      
    ; compare 2 images in public region, choose the union option of value
    if ~keyword_set(union_option) then union_option = 1
    case union_option of
      1: begin
        union_image[public_x_union:public_x_union+public_N_col-1,$
          public_y_union: public_y_union + public_N_row - 1] = public_image1 > public_image2        
      end
      2: begin
        for i_y_union = public_y_union, public_y_union + public_N_row - 1 do begin
          subscript_tmp = where(public_image1[*, i_y_union - public_y_union] eq background_value, count)
          if count gt 0 then begin
            public_image1[subscript_tmp, i_y_union - public_y_union] = 10000.0
          endif
          union_image[public_x_union + indgen(public_N_col), i_y_union] = $
            public_image1[*, i_y_union - public_y_union] < public_image2[*, i_y_union - public_y_union]
        endfor
      end
      3: begin
        for i_y_union = public_y_union, public_y_union + public_N_row - 1 do begin
          union_image[public_x_union + indgen(public_N_col), i_y_union] = $
            0.5 * (public_image1[*, i_y_union - public_y_union] + public_image2[*, i_y_union - $
            public_y_union])
        endfor
      end
      4: begin
        for i_y_union = public_y_union, public_y_union + public_N_row - 1 do begin
          union_image[public_x_union + indgen(public_N_col), i_y_union] = $
            public_image1[*, i_y_union - public_y_union] + public_image2[*, i_y_union - public_y_union]
        endfor
      end
    endcase
  endelse
  
  ;temp = check_math()
  ;  if temp NE 0 then stop
  
  return_image.value = union_image
  
  return, return_image
  
end