;+
; NAME:
;
;    shape_create_line_single
;
; AUTHOR:
;
;    Weihua Fang
;    weihua.fang@bnu.edu.cn
;
; PURPOSE:
;
;    Create a line by points
;
;
; CALLING SEQUENCE:
;
;    shape_create_line_single(fn_shape, longitude, latitude, lon_PRECISION =lon_PRECISION, $
;    lat_PRECISION = lat_PRECISION, fld_NAME = fld_NAME, fld_TYPE = fld_TYPE, $
;    fld_WIDTH = fld_WIDTH, fld_PRECISION = fld_PRECISION, pts_VALUES = pts_VALUES)
;
; ARGUMENTS:
;
;    fn_shape: A string of shape file name, which is the creating line. Program can only create a
;    single shape file for once.
;    longitude: A float vector of longitude
;    latitude:  A float vector of latitude
;
; KEYWORDS:
;
;    lon_PRECISION: A integer vector of the precision of longitude
;    lat_PRECISION: A integer vector of The precision of latitude
;    fld_NAME: A stirng vector of field name for the creating points
;    fld_TYPE: A integer vector of field type for the creating points
;    fld_WIDTH: A integer vector of field width
;    fld_PRECISION: A integer vector of field precision for the creating points
;    pts_VALUES: A float vector of creating points' value
;
; OUTPUTS:
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
;    Code written by Weihua Fang.
;    Comments written by Yuguo Wu.
;
function shape_create_line_single, fn_shape, longitude, latitude, $
    fld_NAME = fld_NAME, fld_TYPE = fld_TYPE, fld_WIDTH = fld_WIDTH, $
    fld_PRECISION = fld_PRECISION, fld_VALUE_0 = fld_VALUE_0
    
  ;print, 'start of shape_create_polyline'
  if keyword_set (fn_Shape) then begin
    if n_elements(fn_shape) GT 1 then begin
      print, 'can only create a single shape file once'
      RETALL
    endif
    ; testing the existence of shape file
    fi = FILE_INFO(fn_Shape)
    if fi.EXISTS then begin
      print, 'shape file already exists: ', fn_Shape
      RETALL
    endif
  endif else begin
    print, 'no input shape file. Please specify your shape file path'
    RETALL
  endelse
  
  oShape = OBJ_NEW('IDLffShape', fn_Shape, ENTITY_TYPE = 3)
  
  ;Set the attribute definitions for the new Shapefile
  if keyword_set(fld_NAME) then begin
    for i_tmp = 0, n_elements(fld_NAME)-1 do begin
      if fld_TYPE [i_tmp] EQ 5 then begin
        oShape->AddAttribute, fld_name[i_tmp] , fld_TYPE[i_tmp], $
          fld_WIDTH[i_tmp], PRECISION=fld_PRECISION[i_tmp]
      endif else begin
        oShape->AddAttribute, fld_name[i_tmp] , fld_TYPE[i_tmp], $
          fld_WIDTH[i_tmp]
      endelse
    endfor
  endif
  
  ; Create structure for new entity.
  oENTITY = {IDL_SHAPE_ENTITY}
  oENTITY.SHAPE_TYPE = 3
  
  oENTITY.BOUNDS[0] = min(longitude)
  oENTITY.BOUNDS[1] = min(latitude)
  ;  oENTITY.BOUNDS[2] = 0.00000000
  ;  oENTITY.BOUNDS[3] = 0.00000000
  oENTITY.BOUNDS[4] = max(longitude)
  oENTITY.BOUNDS[5] = max(latitude)
  ;  oENTITY.BOUNDS[6] = 0.00000000
  ;  oENTITY.BOUNDS[7] = 0.00000000
  
  oENTITY.N_VERTICES = n_elements(longitude)
  VERTICES = fltarr(2,n_elements(longitude))
  VERTICES[0,*] = longitude[*]
  VERTICES[1,*] = latitude[*]
  oENTITY.VERTICES = PTR_NEW(VERTICES)
  oShape -> PutEntity, oENTITY
  PTR_FREE, oENTITY.VERTICES, oENTITY.MEASURE,oENTITY.PARTS,$
    oENTITY.PART_TYPES, oENTITY.ATTRIBUTES
    
  ; Set attributes
  oShape->SetAttributes, 0, [0],fld_VALUE_0
  
  oShape->Close
  OBJ_DESTROY, oShape
  
;  print, 'end of shape_create_polyline_single'
  
end