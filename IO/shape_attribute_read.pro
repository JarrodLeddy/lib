function shape_attribute_read, fn_shape, fld_NAME
  fld_NAME =  STRUPCASE(fld_Name)
  
  if keyword_set (fn_Shape) then begin
    if n_elements(fn_shape) GT 1 then begin
      print, 'can only read attribute from a single shape file'
      RETALL
    endif
    
    ; testing the existence of shape file
    fi = FILE_INFO(fn_Shape)
    if ~fi.EXISTS then begin
      print, 'shape file not exists: ', fn_Shape
      RETALL
    endif
  endif
  
  oShape = OBJ_NEW('IDLffShape', fn_Shape, DBF_ONLY =1 )
  oShape-> GetProperty, ATTRIBUTE_NAMES = ATTRIBUTE_NAMES
  dbf_recs = oShape->GetAttributes(/ALL)
  OBJ_DESTROY, oShape
  
  if keyword_set (fld_name) then begin
    if n_elements(fld_name) NE 1 then begin
      print, 'can only read attribute for a single field or all fields'
      RETALL
    endif
    
    subscript_tmp = where (STRUPCASE(strtrim(ATTRIBUTE_NAMES,2)) eq STRUPCASE(fld_name), count_tmp)
    if count_tmp NE 1 then begin
      print, 'can not find field ' + fld_name + ' in file ' + fn_shape
      RETALL
    endif
    return, dbf_recs.(subscript_tmp[0])
  endif else begin
    return, dbf_recs
  endelse
end