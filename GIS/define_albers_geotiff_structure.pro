function define_albers_geotiff_structure, x_left, y_top, pixel_size

  MODELPIXELSCALETAG      = dblarr(3)
  MODELTRANSFORMATIONTAG  = dblarr(4,4)
  MODELTIEPOINTTAG        = dblarr(6,1)
  
  MODELPIXELSCALETAG      = [double(pixel_size), double(pixel_size), 0d]
  MODELTIEPOINTTAG[0:2,0] = 0d
  MODELTIEPOINTTAG[3:5,0] = [double(x_left), double(y_top), 0d]
  
  ;MODELTRANSFORMATIONTAG [*,0] = [1, 1, 0, 23]
  ;MODELTRANSFORMATIONTAG [*,1] = [1024, 0, 1, 1]
  ;MODELTRANSFORMATIONTAG [*,2] = [1025, 0, 1, 1]
  ;MODELTRANSFORMATIONTAG [*,3] = [1026, 34737, 275, 0]
  GTMODELTYPEGEOKEY       = 1
  GTRASTERTYPEGEOKEY      = 1
  GTCITATIONGEOKEY        = ''
  GEOGRAPHICTYPEGEOKEY    = 32767
  GEOGCITATIONGEOKEY      = ''
  GEOGGEODETICDATUMGEOKEY = 32767
  GEOGPRIMEMERIDIANGEOKEY = 8901
  GEOGLINEARUNITSGEOKEY   = 9001
  GEOGANGULARUNITSGEOKEY  = 9102
  GEOGELLIPSOIDGEOKEY     = 32767
  GEOGSEMIMAJORAXISGEOKEY = 6378245.0
  GEOGSEMIMINORAXISGEOKEY = 6356863.0
  PROJECTEDCSTYPEGEOKEY   = 32767
  PCSCITATIONGEOKEY       = ''
  PROJECTIONGEOKEY        = 32767
  PROJCOORDTRANSGEOKEY    = 11
  PROJLINEARUNITSGEOKEY   = 9001
  PROJSTDPARALLEL1GEOKEY  = 25.000000
  PROJSTDPARALLEL2GEOKEY  = 47.000000
  PROJNATORIGINLATGEOKEY  = 0.00000000
  PROJFALSEEASTINGGEOKEY  = 0.00000000
  PROJFALSENORTHINGGEOKEY = 0.00000000
  PROJCENTERLONGGEOKEY    = 105.00000
  
  
  geotiff_structure = CREATE_STRUCT( $
    'MODELPIXELSCALETAG'      ,  MODELPIXELSCALETAG       , $
   ; 'MODELTRANSFORMATIONTAG'  ,  MODELTRANSFORMATIONTAG   , $
    'MODELTIEPOINTTAG'        ,  MODELTIEPOINTTAG         , $
    'GTMODELTYPEGEOKEY'       ,  GTMODELTYPEGEOKEY        , $
    'GTRASTERTYPEGEOKEY'      ,  GTRASTERTYPEGEOKEY       , $
    'GTCITATIONGEOKEY'        ,  GTCITATIONGEOKEY         , $
    'GEOGRAPHICTYPEGEOKEY'    ,  GEOGRAPHICTYPEGEOKEY     , $
    'GEOGCITATIONGEOKEY'      ,  GEOGCITATIONGEOKEY       , $
    'GEOGGEODETICDATUMGEOKEY' ,  GEOGGEODETICDATUMGEOKEY  , $
    'GEOGPRIMEMERIDIANGEOKEY' ,  GEOGPRIMEMERIDIANGEOKEY  , $
    'GEOGLINEARUNITSGEOKEY'   ,  GEOGLINEARUNITSGEOKEY    , $
    'GEOGANGULARUNITSGEOKEY'  ,  GEOGANGULARUNITSGEOKEY   , $
    'GEOGELLIPSOIDGEOKEY'     ,  GEOGELLIPSOIDGEOKEY      , $
    'GEOGSEMIMAJORAXISGEOKEY' ,  GEOGSEMIMAJORAXISGEOKEY  , $
    'GEOGSEMIMINORAXISGEOKEY' ,  GEOGSEMIMINORAXISGEOKEY  , $
    'PROJECTEDCSTYPEGEOKEY'   ,  PROJECTEDCSTYPEGEOKEY    , $
    'PCSCITATIONGEOKEY'       ,  PCSCITATIONGEOKEY        , $
    'PROJECTIONGEOKEY'        ,  PROJECTIONGEOKEY         , $
    'PROJCOORDTRANSGEOKEY'    ,  PROJCOORDTRANSGEOKEY     , $
    'PROJLINEARUNITSGEOKEY'   ,  PROJLINEARUNITSGEOKEY    , $
    'PROJSTDPARALLEL1GEOKEY'  ,  PROJSTDPARALLEL1GEOKEY   , $
    'PROJSTDPARALLEL2GEOKEY'  ,  PROJSTDPARALLEL2GEOKEY   , $
    'PROJNATORIGINLATGEOKEY'  ,  PROJNATORIGINLATGEOKEY   , $
    'PROJFALSEEASTINGGEOKEY'  ,  PROJFALSEEASTINGGEOKEY   , $
    'PROJFALSENORTHINGGEOKEY' ,  PROJFALSENORTHINGGEOKEY  , $
    'PROJCENTERLONGGEOKEY'    ,  PROJCENTERLONGGEOKEY        )
    
  return, geotiff_structure
  
end