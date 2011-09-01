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
;      col: number of column of image(a square)
;      N_row： nubber of N_row of image(a rectangle)
;      pixel_size: pixel size of image
;    image2: a struct which is to be added in images, the elements are:
;      value: calculating index
;      x: x coordinates of start point of image
;      y: y coordinates of start point of image
;      col: number of column of image(a square)
;      pixel_size: pixel size of image 
;
; KEYWORDS:
;
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

function image_union, image1, image2, union_option = union_option
  
  ; get value
  value1 = image1.value
  value2 = image2.value
  
  ; get start points of 2 images
  image1_x_start = image1.x
  image1_y_start = image1.y
  image2_x_start = image2.x
  image2_y_start = image2.y
  
  ; get N_col and N_row of image1(rectangle) and N_col of image2(square)
  N_col1 = image1.N_col
  N_row1 = image1.N_row
  N_col2 = image2.N_col
  N_row2 = image2.N_row
  
  ; get pixel size, in this case, pixel size of image1 is eqaul to image2's
  pixel_size = image1.pixel_size
  
  ; get end points of 2 images
  image1_x_end = float(image1_x_start + (N_col1 - 1)* pixel_size)
  image1_y_end = float(image1_y_start - (N_row1 - 1)* pixel_size)
  image2_x_end = float(image2_x_start + (N_col2 - 1)* pixel_size)
  image2_y_end = float(image2_y_start - (N_row2 - 1)* pixel_size)
  
  ; get a start point of image which combine image1 and image2
  x_start = min([image1_x_start, image2_x_start])
  y_start = max([image1_y_start, image2_y_start])
  x_end = max([image1_x_end, image2_x_end])
  y_end = min([image1_y_end, image2_y_end])
  ; get N_col and N_row of the image
  a = x_end - x_start
  N_image_col = round((x_end - x_start) / pixel_size) + 1
  N_image_row = round((y_start - y_end) / pixel_size) + 1
  
  ; define image to combine 2 image
  union_image = fltarr(N_image_col, N_image_row)
  
  ; get the index of start points in union image
  union_x1 = round((image1_x_start - x_start) / pixel_size)
  union_y1 = round((y_start - image1_y_start) / pixel_size)
  union_x2 = round((image2_x_start - x_start) / pixel_size)
  union_y2 = round((y_start - image2_y_start) / pixel_size)
  
  ; fill the image with 2 images
  for i_y = union_y1, union_y1 + N_row1 - 1 do begin
    union_image[union_x1 + indgen(N_col1), i_y] = value1[*, i_y - union_y1]
  endfor
  for i_y = union_y2, union_y2 + N_row2 - 1 do begin
    union_image[union_x2 + indgen(N_col2), i_y] = value2[*, i_y - union_y2]
  endfor
  
  ; define a return structure
  return_image = {value: union_image, $
                  x: x_start, $
                  y: y_start, $
                  N_col: N_image_col, $
                  N_row: N_image_row, $
                  pixel_size: pixel_size}
               
  ; specify the public region of the 2 images(start/end points)
  public_x_start = max([image1_x_start, image2_x_start])
  public_y_start = min([image1_y_start, image2_y_start])
  public_x_end   = min([image1_x_end, image2_x_end])
  public_y_end   = max([image1_y_end, image2_y_end])
  
  ; 2 images has no public region, return
  if public_x_start gt public_x_end or public_y_start lt public_y_end then begin
    return, return_image
  endif else begin
  ; get N_col and N_row for public region
    public_N_col = round((public_x_end - public_x_start) / pixel_size) + 1
    public_N_row = round((public_y_start - public_y_end) / pixel_size) + 1
    
  ; build images for the public region of 2 input image and the union image to
  ; sift the max value
  
  ; define the public image which belongs to 2 images 
    public_image1 = fltarr(public_N_col, public_N_row)
    public_image2 = fltarr(public_N_col, public_N_row)

  ; get the start point index of images for 2 images just defined
    public_x1 = round((public_x_start - image1_x_start) / pixel_size)
    public_y1 = round((image1_y_start - public_y_start) / pixel_size)
    public_x2 = round((public_x_start - image2_x_start) / pixel_size)
    public_y2 = round((image2_y_start - public_y_start) / pixel_size)
  ; get the start point index of union image in public region
    public_x_union = round((public_x_start - x_start) / pixel_size)
    public_y_union = round((y_start - public_y_start) / pixel_size)

  ; fill the public images with value for 2 images
    for i_y1 = public_y1, public_y1 + public_N_row - 1 do begin
      public_image1[indgen(public_N_col), i_y1 - public_y1] = value1[public_x1 + indgen(public_N_col), $
      i_y1]
    endfor
    for i_y2 = public_y2, public_y2 + public_N_row - 1 do begin
      public_image2[indgen(public_N_col), i_y2 - public_y2] = value2[public_x2 + indgen(public_N_col), $
      i_y2]
    endfor
  ; compare 2 images in public region, choose the union option of value
    case union_option of
    1: begin
       for i_y_union = public_y_union, public_y_union + public_N_row - 1 do begin
       union_image[public_x_union + indgen(public_N_col), i_y_union] = $
       public_image1[*, i_y_union - public_y_union] > public_image2[*, i_y_union - public_y_union]
       endfor
       end
    2: begin
       for i_y_union = public_y_union, public_y_union + public_N_row - 1 do begin
       subscript_tmp1 = where(public_image1[*, i_y_union - public_y_union] eq 0, count1)
       subscript_tmp2 = where(public_image2[*, i_y_union - public_y_union] eq 0, count2)
       if count1 gt 0 then public_image1[subscript_tmp1, i_y_union - public_y_union] = 10000
       if count2 gt 0 then public_image2[subscript_tmp1, i_y_union - public_y_union] = 10000
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

  return_image.value = union_image

  return, return_image

end 