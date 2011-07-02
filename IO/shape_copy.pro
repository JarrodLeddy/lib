;+
; NAME:
;
;    shape_copy
;
; AUTHOR:
;
;    Weihua Fang
;    weihua.fang@bnu.edu.cn
;
; PURPOSE:
;
;    Copy a shape file.
;
;
; CALLING SEQUENCE:
;
;    result = shape_copy(fn_shape_src, fn_shape_rst, names_replace = name_replace)
;
; ARGUMENTS:
;
;    fn_shape_src: A string of shape file name to be copied with full path.
;    fn_shape_rst: A string of shape file name, which is the copied file.
;
; KEYWORDS:
;
;    name_replace: A string of file name. If it's given, copied file name is replaced
;    with it; otherwise, copied file name is the same as source file.
;
; OUTPUTS:
;
;    0: Add failed for the reason that the shape file doesn't exit
;    1：  Add successfully.
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
;    Code written by Weihua Fang.
;    Comments written by Yuguo Wu.
;
function shape_copy, fn_shape_src, fn_shape_rst, names_replace = name_replace
  
  ; testing the existence of shape file
  fi = FILE_INFO(fn_shape_src)
  if ~fi.EXISTS then begin
    print, 'shape file not exists: ', fn_shape_src
    return, 0
  endif
  
  names_replace = strupcase(names_replace)
  
  ; read the property of src shape file
  oShape_src = OBJ_NEW('IDLffShape', fn_shape_src)
  oShape_src-> GetProperty, ATTRIBUTE_INFO = ATTRIBUTE_INFO, $
    ENTITY_TYPE = ENTITY_TYPE, N_ENTITIES = N_ENTITIES, N_ATTRIBUTES = N_ATTRIBUTES
  fld_NAMEs = strupcase(ATTRIBUTE_INFO.Name)
  fld_TYPEs = ATTRIBUTE_INFO.Type
  fld_WIDTHs = ATTRIBUTE_INFO.Width
  fld_PRECISION = ATTRIBUTE_INFO.PRECISION
  
  ; create new result shape file
  oShape_rst = OBJ_NEW('IDLffShape', fn_shape_rst, /UPDATE, ENTITY_TYPE = ENTITY_TYPE)
  
  ; create attribute structure for result shape file
  for int_attr = 0, N_ATTRIBUTES - 1 do begin
    fld_Name_tmp = fld_NAMEs[int_attr]
    if keyword_set(names_replace) then begin
      sub_tmp = where (names_replace[0,*] EQ fld_NAMEs[int_attr], count_tmp )
      if count_tmp EQ 1 then begin
        fld_Name_tmp = names_replace[1, sub_tmp[0]]
      endif
    endif
    
    if fld_TYPEs[int_attr] EQ 5 then begin
      oShape_rst->AddAttribute, fld_Name_tmp, fld_TYPEs[int_attr], $
        fld_WIDTHs[int_attr], PRECISION = fld_PRECISION[int_attr]
    endif else begin
      oShape_rst->AddAttribute, fld_Name_tmp, fld_TYPEs[int_attr], $
        fld_WIDTHs[int_attr]
    endelse
  endfor
  
  ; put entity of src shape to result shape
  for int_ent = 0, N_ENTITIES -1 do begin
    oENT_tmp = oShape_src->GetEntity(int_ent);,/ATTRIBUTES)
    oShape_rst->PutEntity, oENT_tmp
    oShape_src->DestroyEntity, oENT_tmp
  endfor
  
  ; set attribute of result shape with that of src shape
  attr_src = oShape_src-> GetAttributes(/ALL)
  index = indgen(N_ENTITIES)
  for int_attr = 0, N_ATTRIBUTES - 1 do begin
    oShape_rst->SetAttributes, index, int_attr, attr_src.(int_attr)[*]
  endfor
  
  OBJ_DESTROY, oShape_src
  OBJ_DESTROY, oShape_rst
  
  return, 1
  
end