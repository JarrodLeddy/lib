;+
; NAME:
;
;    shape_create_points
;
; AUTHOR:
;
;    Weihua Fang
;    weihua.fang@bnu.edu.cn
;
; PURPOSE:
;
;    Create a points shape file
;
;
; CALLING SEQUENCE:
;
;    shape_create_points(fn_shape, longitude, latitude, lon_PRECISION =lon_PRECISION, $
;    lat_PRECISION = lat_PRECISION, fld_NAME = fld_NAME, fld_TYPE = fld_TYPE, $
;    fld_WIDTH = fld_WIDTH, fld_PRECISION = fld_PRECISION, pts_VALUES = pts_VALUES)
;
; ARGUMENTS:
;
;    fn_shape: A string of shape file name, which is the creating points shape file.
;    Program can only create a single shape file once, and cannot creating an existing
;    file name
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
function shape_create_points, fn_shape, longitude, latitude, $
    lon_PRECISION =lon_PRECISION, lat_PRECISION = lat_PRECISION, $
    fld_NAME = fld_NAME, fld_TYPE = fld_TYPE, fld_WIDTH = fld_WIDTH, $
    fld_PRECISION = fld_PRECISION, pts_VALUES = pts_VALUES
    
  ;  print, 'start of shape_create_points'
    
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
  
  oShape = OBJ_NEW('IDLffShape', fn_Shape, ENTITY_TYPE=1)
  
  ;Set the attribute definitions for the new Shapefile
  if ~keyword_set(lon_PRECISION) then begin
    lon_PRECISION = 5
  endif
  if ~keyword_set(lat_PRECISION) then begin
    lat_PRECISION = 5
  endif
  lon_width = 4 + lon_PRECISION
  lat_width = 3 + lat_PRECISION
  
  oShape->AddAttribute, 'lon', 5, lon_width, PRECISION = lon_PRECISION
  oShape->AddAttribute, 'lat', 5, lat_width, PRECISION = lat_PRECISION
  
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
  
  ; Add point entities.
  for int_pts = 0L, n_elements(longitude)-1 do begin
    oENTITY = {IDL_SHAPE_ENTITY}
    oENTITY.SHAPE_TYPE = 1
    oENTITY.BOUNDS[0] = longitude[int_pts]
    oENTITY.BOUNDS[1] = latitude[int_pts]
    oENTITY.BOUNDS[2] = 0.00000000
    oENTITY.BOUNDS[3] = 0.00000000
    oENTITY.BOUNDS[4] = longitude[int_pts]
    oENTITY.BOUNDS[5] = latitude[int_pts]
    oENTITY.BOUNDS[6] = 0.00000000
    oENTITY.BOUNDS[7] = 0.00000000
    oENTITY.N_VERTICES = 1
    oShape -> PutEntity, oENTITY
    
    PTR_FREE, oENTITY.VERTICES, oENTITY.MEASURE,oENTITY.PARTS,$
      oENTITY.PART_TYPES, oENTITY.ATTRIBUTES
    oShape->DestroyEntity, oENTITY
  endfor
  
  ; Set attributes
  index         = INDGEN(n_elements(longitude),/long)
  
  ;  print, longitude, latitude
  
  oShape->SetAttributes, Index, [0],longitude
  oShape->SetAttributes, Index, [1],latitude
  if keyword_set(pts_VALUES) then begin
    for int_fld = 0, n_elements(fld_NAME)-1 do begin
      oShape->SetAttributes, Index, int_fld+2, pts_VALUES[int_fld,*]
    endfor
  endif
  oShape->Close
  OBJ_DESTROY, oShape
  
;  print, 'end of shape_create_points'
end