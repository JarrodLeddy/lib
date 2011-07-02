;+
; NAME:
;
;    shape_attribute_add
;
; AUTHOR:
;
;    Weihua Fang
;    weihua.fang@bnu.edu.cn
;
; PURPOSE:
;
;    Add attribute for shape file.
;
; CALLING SEQUENCE:
;
;    result = shape_attribute_add(fn_shape_main, fn_shape_rst, $
;    fld_NAME = fld_NAME, fld_TYPE = fld_TYPE, fld_WIDTH = fld_WIDTH, $
;    fld_PRECISION = fld_PRECISION)
;
; ARGUMENTS:
;
;    fn_shape_main: A string of shape file name with full path. Program can only read 
;    attribute from a single shape file.
;    fld_shape_rst: A string of field name to be added attribute.
;
; KEYWORDS:
;
;    fld_NAME: A string of field name to be added.
;    fld_TYPE: An integer number of field's type code.
;    fld_WIDTH: An integer number of field's width.
;    fld_PRECISION: An integer number of field's precision
;
; OUTPUTS:
;
;    0: Add failed for the reason that the shape file doesn't exit
;    1：Add successfully.
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
;    Code written by Weihua Fang.
;    Comments written by Yuguo Wu.
;
function shape_attribute_add, fn_shape_main, fn_shape_rst, $
    fld_NAME = fld_NAME, fld_TYPE = fld_TYPE, fld_WIDTH = fld_WIDTH, $
    fld_PRECISION = fld_PRECISION
    
  ; testing the existence of shape file
  fi = FILE_INFO(fn_shape_main)
  if ~fi.EXISTS then begin
    print, 'shape file not exists: ', fn_shape_main
    return, 0
  endif
  
  ; read the property of main shape file
  oShape_main = OBJ_NEW('IDLffShape', fn_shape_main)
  oShape_main-> GetProperty, ATTRIBUTE_INFO = ATTRIBUTE_INFO, $
    ENTITY_TYPE = ENTITY_TYPE, N_ENTITIES = N_ENTITIES, N_ATTRIBUTES = N_ATTRIBUTES
  fld_NAMEs = ATTRIBUTE_INFO.Name
  fld_TYPEs = ATTRIBUTE_INFO.Type
  fld_WIDTHs = ATTRIBUTE_INFO.Width
  fld_PRECISIONs = ATTRIBUTE_INFO.PRECISION
  
  ; create new result shape file
  oShape_rst = OBJ_NEW('IDLffShape', fn_shape_rst, /UPDATE, ENTITY_TYPE = ENTITY_TYPE)
  
  ; create attribute structure for result shape file
  for int_attr = 0, N_ATTRIBUTES - 1 do begin
    if fld_TYPEs[int_attr] EQ 5 then begin
      oShape_rst->AddAttribute, fld_NAMEs[int_attr], fld_TYPEs[int_attr], $
        fld_WIDTHs[int_attr], PRECISION = fld_PRECISIONs[int_attr]
    endif else begin
      oShape_rst->AddAttribute, fld_NAMEs[int_attr], fld_TYPEs[int_attr], $
        fld_WIDTHs[int_attr]
    endelse
  endfor
  
  if keyword_set(fld_NAME) then begin
    for i_tmp = 0, n_elements(fld_NAME)-1 do begin
      if fld_TYPE [i_tmp] EQ 5 then begin
        oShape_rst->AddAttribute, fld_name[i_tmp] , fld_TYPE[i_tmp], $
          fld_WIDTH[i_tmp], PRECISION=fld_PRECISION[i_tmp]
      endif else begin
        oShape_rst->AddAttribute, fld_name[i_tmp] , fld_TYPE[i_tmp], $
          fld_WIDTH[i_tmp]
      endelse
    endfor
  endif
  
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
  
  ; newly added field will be empty
  
  OBJ_DESTROY, oShape_main
  
  OBJ_DESTROY, oShape_rst
  
  return, 1
  
end