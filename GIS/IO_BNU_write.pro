function IO_BNU_write,filename,bundata

    openw,file_unit_out,filename,/get_lun
    printf,file_unit_out,'SNBR,CardNo,Name,Type_SS,Intensisty_SS,Type_cn,Intensity_cn,DurationDay,LandfallorNot,Year,Month,Day,Hour_UTC,Lon,Lat,Pres,MWS,TranslationSpeed,Heading'
    ; the time is UTC.——Ying LI 
    printf,file_unit_out,bundata, $ 
        FORMAT = '(i6,1x,i6.1,1x,a15,1x,i2,1x,i2,1x,i2,1x,i2,1x,i2,1x,i10,1x,i4,1x,i2.2,1x,i2.2,1x,i2,1x,f6.2,1x,f5.2,1x,f6.1,1x,f5.1,1x,f6.1,1x,f6.1)'
    close, file_unit_out
    Free_lun, file_unit_out
    return,1
 
end
