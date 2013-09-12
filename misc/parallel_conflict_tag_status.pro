function parallel_conflict_tag_status, filename, read = read, write = write, tag = tag

  if keyword_set(read) then begin
    flag = file_test(filename,/read)
    while flag ne 1 do begin
      wait,2
      flag = file_test(filename,/read)
    endwhile
    openr,lun,filename,/get_lun
    readf,lun,TC_ID
    free_lun,lun
  endif
  
  if keyword_set(write) then begin
    flag = file_test(filename,/write)
    while flag ne 1 do begin
      wait,2
      flag = file_test(filename,/read)
    endwhile
    openw,lun,filename,/get_lun
    printf,lun,tag
    free_lun,lun
  endif
  
  return,1
  
end