function shape_attribute_set, fn_shape, fld_NAME, fld_VALUES, sub_Recs = sub_Recs
  ; testing the existence of shape file
  fi = FILE_INFO(fn_Shape)
  if ~fi.EXISTS then begin
    print, 'shape file not exists: ', fn_Shape
    return, 0
  endif
  
  oShape = OBJ_NEW('IDLffShape', fn_Shape, /UPDATE)
  oShape-> GetProperty, ATTRIBUTE_NAMES = ATTRIBUTE_NAMES, N_RECORDS = N_RECORDS
  
  if ~keyword_set(sub_Recs) then begin
    if n_elements(fld_VALUES) NE N_RECORDS then begin
      print, 'elements of fld_VALUES incorrect'
      oShape->Close
      OBJ_DESTROY, oShape
      return, 0
    endif
  endif
  
  subscript_tmp = where (STRUPCASE(strtrim(ATTRIBUTE_NAMES,2)) $
    eq STRUPCASE(strtrim(fld_name,2)), count_tmp)
    
  if count_tmp EQ 1 then begin
    attribute_num = subscript_tmp [0]
  endif  else begin
    print, 'field not exists: ', fld_name
    return, 0
  endelse
  
  if keyword_set(sub_Recs) then begin
    for int_rec = 0, n_elements(sub_Recs)-1 do begin
      index = sub_Recs[int_rec]
      oShape->SetAttributes, index, attribute_num, fld_VALUES[int_rec]
    endfor
  endif else begin
    for int_attr = 0, n_elements(fld_VALUES)-1 do begin
      index = int_attr
      oShape->SetAttributes, index, attribute_num, fld_VALUES[int_attr]
    endfor
  endelse
  
  oShape->Close
  OBJ_DESTROY, oShape
  
  
  return , 1
  
end