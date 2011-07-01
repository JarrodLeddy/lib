;+
; NAME:
;
;    shape_attribute_set
;
; AUTHOR:
;
;    Weihua Fang
;    weihua.fang@bnu.edu.cn
;
; PURPOSE:
;
;    Set attribute value for shape file.

;
; CALLING SEQUENCE:
;
;    result = shape_attribute_set(fn_shape, fld_NAME, fld_VALUES, sub_Recs = sub_Recs)
;
; ARGUMENTS:
;
;    fn_shape: A string of shape file name with full path. Program can only read 
;    attribute from a single shape file
;    fld_NAME: A string of field name to be set.
;    fld_VALUES: A string vector of field's value. The number of this vector must be equal
;    to the number of records to be set.
;
; KEYWORDS:
;
;    sub_Recs: A string vector of record to be set. If it's given, program will set values
;              for it; otherwise, program will set all the record.
;
; OUTPUTS:
;
;    0: Set failed for such reasons:
;       a. Shape file doesn't exit.
;       b. The number of fld_VALUES is not equal to the number of record to be set.
;       c. field doesn't exit.
;    1：  Set successfully.
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
;    Code written by Weihua Fang.
;    Comments written by Yuguo Wu.
;
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