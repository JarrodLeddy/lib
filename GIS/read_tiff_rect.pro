;+
; NAME:
;
; read_tiff_rect
;
; AUTHOR:
;
; Wei Lin
; wei.lin@mail.bnu.edu.cn
;
; PURPOSE:
;
; This function can be used to read the pixel values of input GeoTIFF file within defined rectangle.
;
; CALLING SEQUENCE:
;
; result = read_tiff_rect(filename_arr,  rect_LL = rect_LL)
;
; ARGUMENTS:
;
; filename_arr : string array of GeoTIFF file names with the same info
;
; KEYWORDS:
;
;    rect_LL: 4 elements scalar array
;       rect_LL[0] : left longitude of rectangle
;       rect_LL[1] : right longitude of rectangle
;       rect_LL[2] : top latitude of rectangle
;       rect_LL[3] : down latitude of rectangle
;
; OUTPUTS:
;
;    A 5 elements stucture: 
;      return_stuc = {value: rst_value, $
;        x_left: rect_left, $
;        y_top: rect_top, $
;        N_col: N_col, $
;        N_row: N_row, $
;        pixel_size: pixel_size}
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
  
function read_tiff_rect, filename_arr,  rect_LL = rect_LL

  n_file = n_elements(filename_arr)
  tiff_info  = Query_tiff(filename_arr[0],info, geotiff = geotiff)
  
  if ~keyword_set(rect_LL) then begin
    rst_value = make_array(info.dimensions[0],info.dimensions[1],n_file,type = info.PIXEL_TYPE)
    for file_i = 0, n_file - 1 do begin
      rst_value[*,*,file_i] = read_TIFF( filename_arr[file_i], geotiff= geotiff)
    endfor
    rst_image = {value: rst_value, $
      x_left: geotiff.MODELTIEPOINTTAG[3], $
      y_top: geotiff.MODELTIEPOINTTAG[4], $
      N_col: info.dimensions[0], $
      N_row: info.dimensions[1], $
      pixel_size: geotiff.MODELPIXELSCALETAG[0]}
    return,rst_image
  endif
  
  if geotiff.GTModelTypeGeoKey ne 2 then begin ; with projection
    mapCoord  = GeoCoord(filename_arr[0])
    mapStruct = mapCoord -> GetMapStructure()
    rect_region = Map_Proj_Forward(rect_LL[0:1], rect_LL[2:3], Map_Structure = mapStruct)
    rect_left  = rect_region[0,0]
    rect_right = rect_region[0,1]
    rect_top   = rect_region[1,0]
    rect_down  = rect_region[1,1]
  endif else begin
    rect_left  = rect_LL[0]
    rect_right = rect_LL[1]
    rect_top   = rect_LL[2]
    rect_down  = rect_LL[3]
  endelse
  
  pixel_size   = geotiff.MODELPIXELSCALETAG[0]
  tiff_x_left  = geotiff.MODELTIEPOINTTAG[3]
  tiff_x_right = tiff_x_left + pixel_size * (info.dimensions[0] + 1)
  tiff_y_top   = geotiff.MODELTIEPOINTTAG[4]
  tiff_y_down  = tiff_y_top - pixel_size * (info.dimensions[1] + 1)

  if (rect_left lt tiff_x_left) or (rect_right gt tiff_x_right) $
    or (rect_top gt tiff_y_top) or (rect_down lt tiff_y_down) then begin
    ;print,'The rectangle must be within the region of tiff file!'
    return, -1
  endif else begin
  
    col_tmp_left = floor((rect_left - tiff_x_left) / pixel_size)
    row_tmp_top  = floor((tiff_y_top - rect_top) / pixel_size)
    
    N_col = ceil((rect_right - rect_left) / pixel_size)
    N_row = ceil((rect_top - rect_down) / pixel_size)

    rst_value = make_array(N_col,N_row,n_file,type = info.PIXEL_TYPE)
    for file_i = 0, n_file - 1 do begin
      rst_value[*,*,file_i] = read_TIFF( filename_arr[file_i], geotiff= geotiff, $
        sub_rect=[col_tmp_left,row_tmp_top,N_col,N_row])
    endfor
    
    rst_image = {value: rst_value, $
      x_left: rect_left, $
      y_top: rect_top, $
      N_col: N_col, $
      N_row: N_row, $
      pixel_size: pixel_size}
    return,rst_image
  endelse
end