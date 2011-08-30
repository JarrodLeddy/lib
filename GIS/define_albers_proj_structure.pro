;+
; NAME:
;       define_Albers_proj_structure
;
; PURPOSE:
;
;       This program aims to define an Albers Projected system(Krasovsky ellipse(1940))
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
;       sMap_Albers = define_Albers_proj_structure()
;
; OPTIONAL INPUTS:
;
;
; OUTPUTS:
;       sMap_Albers - a map projection structure, 
;                    Albers projected system 
;                    Krasovsky ellipse(1940)
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
function define_Albers_proj_structure

  SEMIMAJOR_AXIS   = 6378245.0 ; Meter
  SEMIMINOR_AXIS   = 6356863.0
  STANDARD_PAR1    = 25.0      ; degree
  STANDARD_PAR2    = 47.0      ; degree
  CENTER_LONGITUDE = 105.0     ; degree
  FALSE_EASTING    = 0.0       ; Meter
  FALSE_NORTHING   = 0.0       ; Meter
  
  sMap_Albers = MAP_PROJ_INIT(103, $
    SEMIMAJOR_AXIS= SEMIMAJOR_AXIS, $
    SEMIMINOR_AXIS= SEMIMINOR_AXIS, $
    STANDARD_PAR1 = STANDARD_PAR1, $
    STANDARD_PAR2 = STANDARD_PAR2, $
    CENTER_LONGITUDE = CENTER_LONGITUDE)
    
  return,sMap_Albers
  
end