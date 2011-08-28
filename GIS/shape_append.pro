;+
; NAME:
;
;    shape_append
;
; AUTHOR:
;
;    Weihua Fang
;    weihua.fang@bnu.edu.cn
;
; PURPOSE:
;
;    Append a shape file to another shape file
;
;
; CALLING SEQUENCE:
;
;    result = shape_copy(fn_shape_src, fn_shape_append, fn_shape_rst)
;
; ARGUMENTS:
;
;    fn_shape_src: A string of source shape file name to be appended.
;    fn_shape_append: A string of appending shape file name
;    fn_shape_rst:  A string of shape file name, which is the output file after appending.
;
; KEYWORDS:
;
; OUTPUTS:
;
;    0: Append failed for such reason
;      a. source shape file doesn't exit
;      b. appending shape file doesn't exit
;      c. appending shape file is not the same type with the source file.
;      d. field name(s) of appending shape file is not the same as the source file
;      e. field type of appending shape file is not the same as the source file
;    1：  Add successfully.
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
;    Code written by Weihua Fang.
;    Comments written by Yuguo Wu.
;
function shape_append, fn_shape_src, fn_shape_append, fn_shape_rst
  ; testing the existence of shape file
  fi = FILE_INFO(fn_shape_src)
  if ~fi.EXISTS then begin
    print, 'shape file not exists: ', fn_shape_src
    return, 0
  endif
  for int_shp = 0, n_elements(fn_shape_append)-1 do begin
    fi = FILE_INFO(fn_shape_append[int_shp])
    if ~fi.EXISTS then begin
      print, 'shape file not exists: ', fn_shape_append[int_shp]
      return, 0
    endif
  endfor
  
  same_name_type = shape_compare(fn_shape_src, fn_shape_append)
  
  sub_tmp = where (same_name_type eq 0, count_tmp)
  if count_tmp GT 0 then begin
    for int_tmp = 0, n_elements(same_name_type[0,*]) - 1 do begin
      if same_name_type[0, int_tmp] NE 1 then begin
        print, 'not same shape type: ', fn_shape_append[int_tmp]
      endif
      if same_name_type[1, int_tmp] NE 1 then begin
        print, 'not same field name: ', fn_shape_append[int_tmp]
      endif
      if same_name_type[2, int_tmp] NE 1 then begin
        print, 'not same field type: ', fn_shape_append[int_tmp]
      endif
    endfor
  ;  return, 0
  endif
  
  ; read the property of main shape file
  oShape_main = OBJ_NEW('IDLffShape', fn_shape_src)
  oShape_main-> GetProperty, ATTRIBUTE_INFO = ATTRIBUTE_INFO, $
    ENTITY_TYPE = ENTITY_TYPE, N_ENTITIES = N_ENTITIES, N_ATTRIBUTES = N_ATTRIBUTES
  fld_NAMEs = ATTRIBUTE_INFO.Name
  fld_TYPEs = ATTRIBUTE_INFO.Type
  fld_WIDTHs = ATTRIBUTE_INFO.Width
  fld_PRECISION = ATTRIBUTE_INFO.PRECISION
  
  ; create new result shape file
  oShape_rst = OBJ_NEW('IDLffShape', fn_shape_rst, /UPDATE, ENTITY_TYPE = ENTITY_TYPE)
  
  ; create attribute structure for result shape file
  for int_attr = 0, N_ATTRIBUTES - 1 do begin
    if fld_TYPEs[int_attr] EQ 5 then begin
      oShape_rst->AddAttribute, fld_NAMEs[int_attr], fld_TYPEs[int_attr], $
        fld_WIDTHs[int_attr], PRECISION = fld_PRECISION[int_attr]
    endif else begin
      oShape_rst->AddAttribute, fld_NAMEs[int_attr], fld_TYPEs[int_attr], $
        fld_WIDTHs[int_attr]
    endelse
  endfor
  
  ; put entity of main shape to result shape
  for int_ent = 0, N_ENTITIES -1 do begin
    oENT_tmp = oShape_main->GetEntity(int_ent);,/ATTRIBUTES)
    oShape_rst->PutEntity, oENT_tmp
    oShape_main->DestroyEntity, oENT_tmp
  endfor
  
  ; set attribute of result shape with that of main shape
  attr_main = oShape_main-> GetAttributes(/ALL)
  index = indgen(N_ENTITIES)
  for int_attr = 0, N_ATTRIBUTES - 1 do begin
    oShape_rst->SetAttributes, index, int_attr, attr_main.(int_attr)[*]
  endfor
  OBJ_DESTROY, oShape_main
  records_appended = N_ENTITIES
  
  ; add entity and set attribute of all append shapes to result shape
  for int_shp = 0, n_elements(fn_shape_append) - 1 do begin
    oShape_append_tmp = OBJ_NEW('IDLffShape', fn_shape_append[int_shp])
    ; put entity
    oShape_append_tmp-> GetProperty, N_ENTITIES = N_ENTITIES, $
      N_ATTRIBUTES =  N_ATTRIBUTES, ATTRIBUTE_NAMES = NAMEs_tmp
    for int_ent = 0, N_ENTITIES -1 do begin
      oENT_tmp = oShape_append_tmp->GetEntity(int_ent);,/ATTRIBUTES)
      oShape_rst->PutEntity, oENT_tmp
      oShape_append_tmp->DestroyEntity, oENT_tmp
    endfor
    
    ; set attribute
    attr_append_tmp = oShape_append_tmp-> GetAttributes(/ALL)
    
    
    index = indgen(N_ENTITIES)
    index = index + records_appended
    records_appended =  records_appended + N_ENTITIES
    
    for int_attr = 0, N_ATTRIBUTES - 1 do begin
      sub_tmp = where (fld_NAMEs EQ NAMEs_tmp[int_attr], count_tmp)
      if count_tmp EQ 1 then begin
        ;oShape_rst->SetAttributes, index, int_attr, attr_append_tmp.(int_attr)[*]
        oShape_rst->SetAttributes, index, sub_tmp[0], attr_append_tmp.(int_attr)[*]
      endif
    endfor
    OBJ_DESTROY, oShape_append_tmp
  endfor
  
  OBJ_DESTROY, oShape_rst
  
  return, 1
  
end