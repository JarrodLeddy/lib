FUNCTION shape_select_by_attribute, fn_shape_src, fn_shape_rst, $
    fld_NAME, operater, fld_value, $
    noconfirm = noconfirm
    
  ; testing the existence of shape file
  fi = FILE_INFO(fn_shape_src)
  if ~fi.EXISTS then begin
    print, 'shape file not exists: ', fn_shape_src
    return, 0
  endif
  
  fi = FILE_INFO(fn_shape_rst)
  if fi.EXISTS then begin
    dummy = shape_delete(fn_shape_rst, noconfirm = noconfirm)
    if dummy eq 0 then return, 0
  endif
  
  rst_attr = shape_attribute_read(fn_shape_src, fld_NAME = fld_NAME)
  case operater of
    0: rec_range = where(rst_attr eq fld_value, count_tmp)
    1: rec_range = where(rst_attr eq fld_value, count_tmp)
    2: rec_range = where(rst_attr GT fld_value, count_tmp)
    3: rec_range = where(rst_attr GE fld_value, count_tmp)
    4: rec_range = where(rst_attr LT fld_value, count_tmp)
    5: rec_range = where(rst_attr LE fld_value, count_tmp)
    6: rec_range = where(rst_attr NE fld_value, count_tmp)
    else: begin
      print, 'wrong operater'
      return, 0
    end
  endcase
  if count_tmp EQ 0 then begin
    return, -1
  endif
  ;  rec_range = rec_range + 1 ; be careful here, the range number of first row is 1
  
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
    valid_ent = where(rec_range EQ int_ent, count_tmp)
    if count_tmp EQ 1 then begin
      oENT_tmp = oShape_src->GetEntity(int_ent);,/ATTRIBUTES)
      oShape_rst->PutEntity, oENT_tmp
      oShape_src->DestroyEntity, oENT_tmp
    endif
  endfor
  
  ; set attribute of result shape with that of src shape
  attr_src = oShape_src-> GetAttributes(rec_range)
  index = indgen(n_elements(rec_range))
  for int_attr = 0, N_ATTRIBUTES - 1 do begin
    oShape_rst->SetAttributes, index, int_attr, attr_src.(int_attr)[*]
  endfor
  
  OBJ_DESTROY, oShape_src
  OBJ_DESTROY, oShape_rst
  
  return, 1
  
end