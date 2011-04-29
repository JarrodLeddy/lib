function IO_ENVI_write, array_in, str_file_out=str_file_out, str_file_hdr= str_file_hdr

  if keyword_set(str_file_out) then begin
    openw,  int_file_unit, str_file_out, /get_lun
    writeu, int_file_unit, array_in
    close,  int_file_unit
    free_lun, int_file_unit
  endif
  
  if keyword_set(str_file_hdr) then begin
  
    strct_size    = size(array_in,/structure)
    
    if strct_size.N_DIMENSIONS eq 2 then begin
      samples = n_elements(array_in [*,0])
      lines = n_elements(array_in [0,*])
      bands = 1
    endif
    if strct_size.N_DIMENSIONS eq 3 then begin
      samples = n_elements(array_in [*,0,0])
      lines = n_elements(array_in [0,*,0])
      bands = n_elements(array_in [0,0,*])
    endif
    
    openw,  int_file_unit, strtrim(str_file_hdr,2), /get_lun
    
    printf, int_file_unit, 'ENVI'
    printf, int_file_unit, 'description = {File Imported into ENVI.}'
    printf, int_file_unit, 'samples = '+ strtrim(string(samples),2)
    printf, int_file_unit, 'lines   = '+ strtrim(string(lines),2)
    printf, int_file_unit, 'bands   = '+ strtrim(string(bands),2)
    printf, int_file_unit, 'header offset = 0'
    printf, int_file_unit, 'file type = ENVI Standard'
    printf, int_file_unit, 'data type = ' + strtrim(string(strct_size.type),2)
    printf, int_file_unit, 'interleave = bsq'
    printf, int_file_unit, 'sensor type = Unknown'
    printf, int_file_unit, 'byte order = 0'
    printf, int_file_unit, 'wavelength units = Unknown'
    close,  int_file_unit
    free_lun, int_file_unit
    
  endif
  
  return, 1
  
end