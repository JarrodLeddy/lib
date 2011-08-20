;+
; NAME:
;  shape_point_in_polygon
;
; AUTHOR:
;  ShiXianwu
;  xianwu.shi@gmail.com
;
; PURPOSE:
;   determines whether the given point is contained within the polygon region
;
; CALLING SEQUENCE:
;  result =  shape_point_in_polygon(fn_shape_polygon,point,str_fldname = str_fldname)
;
; ARGUMENTS:
;
;  fn_shape_polygon: the path of the file
;  point:  a two elements vector, indicating the point coordinate
;
; KEYWORDS:
;  str_fldname: the string of field name in the polygon entity
;
; OUTPUTS:
;  IF the given point is out of the polygon region, this function return -1.otherwise,if the given 
;  point is contained within the polygon region,two situations:
;      if keyword is seted: return the string of field name of the entity which contains the given point
;      if keyword is not seted: return the FID of the entity which contains the given point
; 
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
function shape_point_in_polygon,fn_shape_polygon,point,str_fldname = str_fldname

  oShape = OBJ_NEW('IDLffShape',fn_shape_polygon)
  oShape-> GetProperty, N_ENTITIES=N_ENTITIES,ATTRIBUTE_INFO = ATTRIBUTE_INFO
  
  IF KEYWORD_SET(str_fldname) THEN BEGIN
    subscript_tmp = where (STRTRIM(ATTRIBUTE_INFO.name,2) EQ STRTRIM(str_fldname,2), count_tmp)
    IF count_tmp NE 1 THEN BEGIN
      PRINT, 'field ' + str_fldname + 'not exists'
    ENDIF ELSE BEGIN
      fld_no  = subscript_tmp[0]
    ENDELSE
  ENDIF
  
  for int_ENT =  0L , N_ENTITIES -1 do begin
  
    oENTITY  = oShape -> IDLffShape::GetEntity(int_ENT,/ATTRIBUTES)
    for int_part = 1L, oENTITY.N_PARTS do begin
      if oENTITY.N_PARTS LE 1 then begin
        start_vertic = 0
        end_vertic   = oENTITY.N_VERTICES -1
      endif else begin
        start_vertic = (*oENTITY.Parts)[int_part -1]
        if int_part LT oENTITY.N_PARTS then begin
          end_vertic   = (*oENTITY.Parts)[int_part] -1
        endif else begin
          end_vertic   =  oENTITY.N_VERTICES -1
        endelse
      endelse
      
      VERTICES_Polygon = (*oENTITY.vertices)[0:1,start_vertic:end_vertic]
      oROI = OBJ_NEW( 'IDLanROI')
      oROI -> SetProperty, data = VERTICES_Polygon[0:1,*]
      flag = oROI->ContainsPoints(point)
      if flag gt 0 then begin
        if KEYWORD_SET(str_fldname) then begin
          return,(*oENTITY.ATTRIBUTES).(fld_no)
        endif else begin
          return,int_ENT
        endelse
      endif
      OBJ_DESTROY,oROI
    endfor
    
    oShape->Idlffshape::destroyentity, oENTITY
  endfor
  
  oShape->IDLffShape::Close
  OBJ_DESTROY, oShape
  
  return,-1
  
end