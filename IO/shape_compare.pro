function shape_compare, fn_shape_main, fn_shape_chk

  ; testing the existence of shape file
  fi = FILE_INFO(fn_shape_main)
  if ~fi.EXISTS then begin
    print, 'shape file not exists: ', fn_shape_main
    return, 0
  endif
  for int_shp = 0, n_elements(fn_shape_chk)-1 do begin
    fi = FILE_INFO(fn_shape_chk[int_shp])
    if ~fi.EXISTS then begin
      print, 'shape file not exists: ', fn_shape_chk[int_shp]
      return, 0
    endif
  endfor
  
  feature_type_fld_name_type  = intarr(3, n_elements(fn_shape_chk))
  
  oShape = OBJ_NEW('IDLffShape', fn_shape_main, DBF_ONLY =1 )
  oShape-> GetProperty, ATTRIBUTE_INFO = attr_info_1, ENTITY_TYPE = ENT_main
  OBJ_DESTROY, oShape
  fld_Names_1 = strupcase(string(attr_info_1.Name))
  fld_types_1 = string(attr_info_1.Type)
  
  for int_shp = 0, n_elements(fn_shape_chk)-1 do begin
    oShape = OBJ_NEW('IDLffShape', fn_shape_chk[int_shp], DBF_ONLY =1)
    oShape-> GetProperty, ATTRIBUTE_INFO = attr_info_2, ENTITY_TYPE = ENT_chk
    OBJ_DESTROY, oShape
    if ENT_Main EQ ENT_chk then begin
      feature_type_fld_name_type [0,int_shp] = 1
    endif
    
    fld_Names_2 = strupcase(string(attr_info_2.Name))
    fld_types_2 = string(attr_info_2.Type)
    has_flds_tmp  = 1
    same_type_tmp = 1
    
    for int_fld = 0, n_elements(fld_Names_2) -1 do begin
      sub_tmp = where (fld_Names_1[*] EQ fld_Names_2[int_fld], count_tmp)
      if count_tmp NE 1 then begin
        has_flds_tmp  = 0
        same_type_tmp = 0
      endif else begin
        if fld_types_1[sub_tmp] NE  fld_types_2[int_fld] then begin
          same_type_tmp = 0
        endif
      endelse
    endfor
    feature_type_fld_name_type [1, int_shp] = has_flds_tmp
    feature_type_fld_name_type [2, int_shp] = same_type_tmp
  endfor
  return, feature_type_fld_name_type
  
end