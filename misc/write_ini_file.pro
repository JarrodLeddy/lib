;+
; NAME:
;
; write_ini_file
;
; AUTHOR:
;
; Wei Lin
; wei.lin@mail.bnu.edu.cn
;
; PURPOSE:
;
; This function can be used to write a variable initialization file in standard format.
;
; CALLING SEQUENCE:
;
; result = write_ini_file(str_ini_file, var_name, var_value, var_comments, $
;   comment_character = comment_character)
;
; ARGUMENTS:
;
; str_file_ini : file name of the initial file to be written
; var_name     : string array of variable names
; var_value    : string array of variable values 
; var_comments : string array of variable comments 
;
; KEYWORDS:
;
;    comment_character: a char of specific comment symbol used in the initial file, default: ';'
;
; OUTPUTS:
;
;    an initial file
;
; EXAMPLE:
;
;  str_ini_file = 'wind.ini'
;  var_name     = ['Vg_type','PBL_type']
;  var_value    = [7,1,10]
;  var_comments = ['type of gradient wind field model',$
;    'type of planetary boundary layer model',$
;    'type of model for calculating Holland B']
;  write_ini = write_ini_file(str_ini_file, var_name, var_value, var_comments)
;
;
; MODIFICATION_HISTORY:
;
  
function write_ini_file, str_ini_file, var_name, var_value, var_comments, $
    comment_character = comment_character
    
  if ~keyword_set(comment_character) then comment_character = ';'
  n_var_name     = n_elements(var_name)
  n_var_value    = n_elements(var_value)
  n_var_comments = n_elements(var_comments)
  
  if n_var_name ne n_var_value or n_var_value ne n_var_comments then begin
    print,'The elements of var_name, var_value and var_comments must be the same!'
    return, -1
  endif else begin
    openw,lun,str_ini_file,/get_lun, width = 60000
    for var_i = 0, n_var_name - 1 do begin
      printf,lun,string(var_name[var_i]) + ' = ' + string(var_value[var_i])
      printf,lun,comment_character + ' ' + var_comments[var_i]
    endfor
    free_lun,lun
    return,1
  endelse
end