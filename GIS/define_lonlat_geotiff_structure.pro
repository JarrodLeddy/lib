;+
; NAME:
;
;    define_lonlat_geotiff_structure
;
; AUTHOR:
;
;    Weihua Fang
;    weihua.fang@bnu.edu.cn
;
; PURPOSE:
;
;    define geotiff for lon/lat projection to store data
;
; CALLING SEQUENCE:
;
;    result = define_lonlat_geotiff_structure(x_left, y_top, pixel_size)
;
; ARGUMENTS:
;
;    x_left: x coordinate of left-top point in tiff file, unit: degree
;    y_top: y coordinate of left-top point in tiff file, unit: degree
;    pixel_size: pixel size of tiff file, unit: degree
;
; KEYWORDS:
;
; OUTPUTS:
;
;    A structure describing geotiff, which contains lon/lat projection and other infomation
;
; KNOWN BUGS:
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
function define_lonlat_geotiff_structure, x_left, y_top, pixel_size

  MODELPIXELSCALETAG      = dblarr(3)
  MODELTRANSFORMATIONTAG  = dblarr(4,4)
  MODELTIEPOINTTAG        = dblarr(6,1)
  
  MODELPIXELSCALETAG      = [double(pixel_size), double(pixel_size), 0d]
  MODELTIEPOINTTAG[0:2,0] = 0d
  MODELTIEPOINTTAG[3:5,0] = [double(x_left), double(y_top), 0d]

  GTMODELTYPEGEOKEY       = 2 
  GTRASTERTYPEGEOKEY      = 1 
  GTCITATIONGEOKEY        = 'Beijing Normal University'
  GEOGRAPHICTYPEGEOKEY    = 4326
  GEOGCITATIONGEOKEY      = 'www.OpenCyclone.com'
  GEOGANGULARUNITSGEOKEY  = 9102 
  PCSCITATIONGEOKEY       = 'SWAN'
  
  geotiff_structure = CREATE_STRUCT( $
    'MODELPIXELSCALETAG'      ,  MODELPIXELSCALETAG       , $
    'MODELTIEPOINTTAG'        ,  MODELTIEPOINTTAG         , $
    'GTMODELTYPEGEOKEY'       ,  GTMODELTYPEGEOKEY        , $
    'GTRASTERTYPEGEOKEY'      ,  GTRASTERTYPEGEOKEY       , $
    'GTCITATIONGEOKEY'        ,  GTCITATIONGEOKEY         , $
    'GEOGRAPHICTYPEGEOKEY'    ,  GEOGRAPHICTYPEGEOKEY     , $
    'GEOGCITATIONGEOKEY'      ,  GEOGCITATIONGEOKEY       , $
    'GEOGANGULARUNITSGEOKEY'  ,  GEOGANGULARUNITSGEOKEY   , $
    'PCSCITATIONGEOKEY'       ,  PCSCITATIONGEOKEY        )
    
  return, geotiff_structure
  
end