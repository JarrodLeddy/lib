function shape_attribute_remove, fn_shape_src, fn_shape_rst, names_remove
  ; testing the existence of shape file
  fi = FILE_INFO(fn_shape_src)
  if ~fi.EXISTS then begin
    print, 'shape file not exists: ', fn_shape_src
    return, 0
  endif
  
  names_remove =  STRUPCASE(names_remove)
  
  ; read the property of src shape file
  oShape_src = OBJ_NEW('IDLffShape', fn_shape_src)
  oShape_src-> GetProperty, ATTRIBUTE_INFO = ATTRIBUTE_INFO, $
    ENTITY_TYPE = ENTITY_TYPE, N_ENTITIES = N_ENTITIES, N_ATTRIBUTES = N_ATTRIBUTES
  fld_NAMEs = STRUPCASE(ATTRIBUTE_INFO.Name)
  fld_TYPEs = ATTRIBUTE_INFO.Type
  fld_WIDTHs = ATTRIBUTE_INFO.Width
  fld_PRECISION = ATTRIBUTE_INFO.PRECISION
  
  ; create new result shape file
  oShape_rst = OBJ_NEW('IDLffShape', fn_shape_rst, /UPDATE, ENTITY_TYPE = ENTITY_TYPE)
  ; create attribute structure for result shape file
  for int_attr = 0, N_ATTRIBUTES - 1 do begin
    fld_Name_tmp = fld_NAMEs[int_attr]
    sub_tmp = where (names_remove[*] EQ fld_NAMEs[int_attr], count_tmp )
    if count_tmp NE 1 then begin
      if fld_TYPEs[int_attr] EQ 5 then begin
        oShape_rst->AddAttribute, fld_Name_tmp, fld_TYPEs[int_attr], $
          fld_WIDTHs[int_attr], PRECISION = fld_PRECISION[int_attr]
      endif else begin
        oShape_rst->AddAttribute, fld_Name_tmp, fld_TYPEs[int_attr], $
          fld_WIDTHs[int_attr]
      endelse
    endif
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
  int_fld_tmp = 0
  for int_attr = 0, N_ATTRIBUTES - 1 do begin
    fld_Name_tmp = fld_NAMEs[int_attr]
    sub_tmp = where (names_remove[*] EQ fld_NAMEs[int_attr], count_tmp )
    if count_tmp NE 1 then begin
      oShape_rst->SetAttributes, index, int_fld_tmp, attr_src.(int_attr)[*]
      int_fld_tmp = int_fld_tmp + 1
    endif
  endfor
  OBJ_DESTROY, oShape_src
  OBJ_DESTROY, oShape_rst
  
  return, 1
end