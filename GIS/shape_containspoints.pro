;+
; NAME:
;  shape_containspoints
;
; AUTHOR:
;
;  Weihua.fang
;  ShiXianwu
;  xianwu.shi@gmail.com
;
; PURPOSE:
;   Judge the position relationship between a point and ROI
;
; CALLING SEQUENCE:
;  result =  shape_point_in_polygon(fn_shape_polygon,point,str_fldname = str_fldname)
;
; ARGUMENTS:
;
;    fn_shape_polygon: a string of shape file name, which is used for position judgement
;    x: A vector of x coordinates
;    y: A vector of y coordinates
;
; KEYWORDS:
;  str_fldname: the string of field name in the polygon entity
;
; OUTPUTS:
;  stru_fig : a stucture, contains two members, stru_fig.fld_val and stru_fig.ShpCntnPts
;   1) stru_fig.ShpCntnPts stores the flag to judge the position relationship between a point and ROI
;      0 = Exterior. The point lies strictly out of bounds of the ROI
;      1 = Interior. The point lies strictly inside the bounds of the ROI
;      2 = On edge. The point lies on an edge of the ROI boundary
;      3 = On vertex. The point matches a vertex of the ROI
;   2) if keyword fld_NAME is set
;      the value of each entity's (FID + 1) is  stored in stru_fig.fld_val
;      if stru_fig.ShpCntnPts eq 0, stru_fig.fld_val will be 0
;   3) if keyword fld_NAME is not set
;      the value of each entity's fld_NAME are stored in stru_fig.fld_val
;      if stru_fig.ShpCntnPts eq 0, stru_fig.fld_val will be null
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
function shape_containspoints,fn_shape_polygon, x, y, str_fldname = str_fldname, $
    value_outside_polygon = value_outside_polygon
    
  oShape = OBJ_NEW('IDLffShape',fn_shape_polygon)
  oShape-> GetProperty, N_ENTITIES=N_ENTITIES,ATTRIBUTE_INFO = ATTRIBUTE_INFO
  
  IF KEYWORD_SET(str_fldname) THEN BEGIN
    subscript_tmp = where (STRTRIM(ATTRIBUTE_INFO.name,2) EQ STRTRIM(str_fldname,2), count_tmp)
    IF count_tmp NE 1 THEN BEGIN
      PRINT, 'field ' + str_fldname + 'not exists'
    ENDIF ELSE BEGIN
      fld_no  = subscript_tmp[0]
      fld_type= ATTRIBUTE_INFO[fld_no].type
    ENDELSE
  END ELSE BEGIN
    fld_type = 5
  ENDELSE
  
  N_pts   = n_elements(x)
  fld_val = make_array(N_pts, TYPE =  fld_type)
  if keyword_set (value_outside_polygon) then begin
    fld_val[*] = value_outside_polygon
  endif
  
  ShpCntnPts = intarr(N_pts)
  
  
  
  for int_ENT =  0L , N_ENTITIES -1 do begin
  
    oENTITY  = oShape -> IDLffShape::GetEntity(int_ENT,/ATTRIBUTES)
    
    x_min = min(oENTITY.BOUNDS[0])
    y_min = min(oENTITY.BOUNDS[1])
    x_max = max(oENTITY.BOUNDS[4])
    y_max = max(oENTITY.BOUNDS[5])
    
    sub_xy = where(x lt x_max and x gt x_min and y lt y_max and y gt y_min, cnt_sub)
    
    if cnt_sub le 1 then continue
    
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
      
      for int_pts = 0L, cnt_sub - 1 do begin
        flag = oROI->ContainsPoints(x[sub_xy(int_pts)],y[sub_xy(int_pts)])
        if flag gt 0 then begin
          if KEYWORD_SET(str_fldname) then begin
            fld_val[sub_xy(int_pts)] = (*oENTITY.ATTRIBUTES).(fld_no)
          endif else begin
            fld_val[sub_xy(int_pts)] = int_ENT + 1
          endelse
        endif
        ShpCntnPts[sub_xy(int_pts)] = ShpCntnPts[sub_xy(int_pts)]> flag
      endfor
      
      OBJ_DESTROY,oROI
    endfor
    
    oShape->Idlffshape::destroyentity, oENTITY
  endfor
  
  oShape->IDLffShape::Close
  OBJ_DESTROY, oShape
  
  return,{stru_fig, fld_val:fld_val, ShpCntnPts:ShpCntnPts}
  
end