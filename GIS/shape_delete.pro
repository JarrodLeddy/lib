FUNCTION shape_delete, fn_shape, noconfirm = noconfirm

  file_basename = FILE_BASENAME(fn_shape, '.shp')
  file_dirname = FILE_DIRNAME(fn_shape)
  suffix = ['.dbf', '.prj', '.sbn', '.sbx', '.shp', '.shx']

  fn_list_delete = FILEPATH( file_basename + suffix, ROOT_DIR=file_dirname)
  N_suffix = n_elements(suffix)
  
  if keyword_set(noconfirm) then begin
    FILE_DELETE, fn_list_delete, /ALLOW_NONEXISTENT, /QUIET
    return, 1
  endif else begin
    Message_Text = strarr(N_suffix + 1)
    Message_Text[0] = 'Do you want to delete file?'
    Message_Text[1:N_suffix] = fn_list_delete [*]
    
    YES = DIALOG_MESSAGE(Message_Text, TITLE= 'Delete Shape file?', /Question)
    if strtrim(strupcase(YES),2) eq strtrim('YES') then begin
      FILE_DELETE, fn_list_delete, /ALLOW_NONEXISTENT, /QUIET
      return, 1
    endif else begin
      return, 0
    endelse
  endelse
  
  return, 1
  
END
