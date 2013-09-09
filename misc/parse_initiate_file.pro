;+
; NAME:
;
; parse_initiate_file
;
; AUTHOR:
;
; Weihua Fang
; weihua.fang@bnu.edu.cn
;
; PURPOSE:
;
; To parse variables from initial file.
;
; CALLING SEQUENCE:
;
;    result = parse_initiate_file(str_file_ini, var_name, comment_character = comment_character)
;
; ARGUMENTS:
;
; str_file_ini: file name of the initial file to be parsed.
; var_name    : a string array of variable names to be parsed
;
; KEYWORDS:
;
;    comment_character: a char of specific comment symbol used in the initial file, default: ';'
;
; OUTPUTS:
;
;    a parsed  scaler string value
;
; EXAMPLE:
;
; ini_file  = 'wind.ini'
; var_name  = ['Vg_type ','PBL_type']
; n_var     = n_elements(var_name)
; var_value = strarr(n_var)
; for int = 0 ,n_var -1 do begin
;  var_value_tmp  =  parse_initiate_file(ini_file,var_name[int])
;  print, var_name[int],':',var_value_tmp
; endfor
;
; IDL prints: 
;  Vg_type: 7
;  PBL_type:1
;
; MODIFICATION_HISTORY:
;

function parse_initiate_file,  str_file_ini, var_name, comment_character = comment_character

  if ~keyword_set(comment_mark) then begin
    comment_character = ';'
  endif
  
  num_lines_of_ini_file = file_lines(str_file_ini)
  openr, int_file_unit_ini, str_file_ini, /get_lun
  str_line_buffer = strarr(1)
  for int_line = 1, num_lines_of_ini_file do begin
    readf, int_file_unit_ini,str_line_buffer
    if strmid(strtrim(str_line_buffer,2),0,1) NE comment_character then begin
      pos_of_equal_mark = STRPOS( str_line_buffer, '=' )
      if pos_of_equal_mark NE -1 then begin
        var_name_parsed   = STRCOMPRESS(strupcase(strmid(str_line_buffer,0, pos_of_equal_mark )),/remove_all)
        if var_name_parsed EQ STRCOMPRESS(strupcase(var_name), /remove_all) then begin
          return, STRCOMPRESS(strmid(str_line_buffer, pos_of_equal_mark+1), /remove_all)
        endif
      endif
    endif
  endfor
  free_lun, int_file_unit_ini
  return, ''
  
end