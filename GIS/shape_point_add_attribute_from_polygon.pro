;+
; NAME:
;     shape_point_add_attribute_from_polygon
;
; AUTHOR:
;     ShiXianwu
;     xianwu.shi@gmail.com
;
; PURPOSE:
;     Identify which polygon entity contain the point from the point shape file,and add the identyfied
;     result as a field to the point shape file
;
; CALLING SEQUENCE:
;     result =  shape_point_add_attribute_from_polygon(fn_shape_polygon, fn_shape_point,fn_new_shape_point, $
;     field_name_in_shape_point,field_name_in_shape_polygon = field_name_in_shape_polygon)
;
; ARGUMENTS:
;
;     fn_shape_polygon: the path of the polygon file
;     fn_shape_point:  the path of the source point shape file
;     fn_new_shape_point: the path of the outputs point shape file
;     field_name_in_shape_point: the field name to be added in the outputs point shape file
;
; KEYWORDS:
;     field_name_in_shape_polygon: a filed name in the polygon file
;
; OUTPUTS:
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
function shape_point_add_attribute_from_polygon,fn_shape_polygon, fn_shape_point,fn_new_shape_point, $
    field_name_in_shape_point,field_name_in_shape_polygon = field_name_in_shape_polygon
    
  point_Shape = OBJ_NEW('IDLffShape',fn_shape_point)
  point_Shape->GetProperty, N_ENTITIES=N_ENTITIES,ATTRIBUTE_INFO = point_INFO
  
  has_field = 0
  point_tmp = where (STRTRIM(point_INFO.name,2) EQ STRTRIM(field_name_in_shape_point,2), count_point)
  if count_point gt 0 then has_field = 1
  
  polygon_Shape = OBJ_NEW('IDLffShape',fn_shape_polygon)
  polygon_Shape-> GetProperty, ATTRIBUTE_INFO = ATTRIBUTE_INFO
  IF KEYWORD_SET(field_name_in_shape_polygon) THEN BEGIN
    subscript_tmp = where (STRTRIM(ATTRIBUTE_INFO.name,2) EQ STRTRIM(field_name_in_shape_polygon,2), count_tmp)
    IF count_tmp LE 0 THEN BEGIN
      fld_type = 3
    ENDIF ELSE BEGIN
      fld_type = ATTRIBUTE_INFO[subscript_tmp].type
    ENDELSE
  ENDIF ELSE BEGIN
    fld_type = 3
  ENDELSE
  
  fld_arr  = MAKE_ARRAY(N_ENTITIES, TYPE=fld_type)
  
  for int_ent = 0,N_ENTITIES-1 do begin
    oENTITY  = point_Shape -> IDLffShape::GetEntity(int_ent)
    IF KEYWORD_SET(field_name_in_shape_polygon) THEN BEGIN
      flag = shape_point_in_polygon(fn_shape_polygon,oENTITY.BOUNDS(0:1),str_fldname = field_name_in_shape_polygon)
      fld_arr[int_ent] = flag
    endif else begin
      flag = shape_point_in_polygon(fn_shape_polygon,oENTITY.BOUNDS(0:1))
      fld_arr[int_ent] = flag
    endelse
  endfor
  
  OBJ_DESTROY, point_Shape
  OBJ_DESTROY, polygon_Shape
  
  if has_field eq 0 then begin
    dummy1 = shape_attribute_add(fn_shape_point,fn_new_shape_point,fld_NAME = $
      field_name_in_shape_point, fld_TYPE = fld_type, fld_WIDTH = 20 )
    dummy2 = shape_attribute_set(fn_new_shape_point,field_name_in_shape_point,fld_arr)
  endif else begin
    dummy =  shape_attribute_set(fn_new_shape_point,field_name_in_shape_point,fld_arr)
  endelse
  
  return,1
  
end