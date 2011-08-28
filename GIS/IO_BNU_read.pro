function IO_BNU_read,filename

    openr,file_unit_in,filename,/get_lun
    
    nbr=file_lines(filename)-1
    
    first_line = ''
    readf,file_unit_in,first_line

    table_tmp=strarr(19,nbr)
    readf,file_unit_in,table_tmp,$
        FORMAT = '(i6,1x,i6.1,1x,a15,1x,i2,1x,i2,1x,i2,1x,i2,1x,i2,1x,i10,1x,i4,1x,i2.2,1x,i2.2,1x,i2,1x,f6.2,1x,f5.2,1x,f6.1,1x,f5.1,1x,f6.1,1x,f6.1)'

    close, file_unit_in
    Free_lun, file_unit_in
    
    return,table_tmp    

end