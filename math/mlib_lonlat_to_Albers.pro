;+
; NAME:
;       mlib_lonlat_to_Albers
;
; PURPOSE:
;
;       This program transform the Geographic Coordinate System(longitude and latitude) to 
;       Projected Coordinate System(Albers Projected Coordinate System).
;
; AUTHOR:
;      Shixianwu
;      xianwu.shi@gmail.com
;
; CATEGORY:
;
;       Geography, math.
;
; CALLING SEQUENCE:
;
;       albers_xy = mlib_lonlat_to_Albers(lon_lat_array)
;
; OPTIONAL INPUTS:
;       lon_lat_array - A 2-by-npoints array of the longitude and latitude in the Geographic Coordinate System
;
; OUTPUTS:
;       albers_xy - A 2-by-npoints array of the X and Y location in the Projected Coordinate System
;
; INPUT KEYWORDS:
;  
;
; OUTPUT KEYWORDS:
;
;
;  EXAMPLE:
;
;
function mlib_lonlat_to_Albers,lon_lat_array

  lon =float(lon_lat_array(0,*))
  lat =float(lon_lat_array(1,*))
  SEMIMAJOR_AXIS   = 6378137.0 ;METER  
  SEMIMINOR_AXIS   = 6356752.3  
  STANDARD_PAR1    = 25.0      ; degree
  STANDARD_PAR2    = 47.0      ; degree
  CENTER_LONGITUDE = 105.0     ; degree
  
  ;create map structure for alber_equal_area_conic project
  sMap_Albers = MAP_PROJ_INIT(103, $
    SEMIMAJOR_AXIS=SEMIMAJOR_AXIS,$
    SEMIMINOR_AXIS=SEMIMINOR_AXIS,$
    STANDARD_PAR1 = STANDARD_PAR1, $
    STANDARD_PAR2 = STANDARD_PAR2, $
    CENTER_LONGITUDE = CENTER_LONGITUDE)
  albers_xy = MAP_PROJ_FORWARD(lon,lat,MAP_STRUCTURE  = sMap_Albers)
  
  return,albers_xy 
  
end