;+
; NAME:
;
;    shape_containspoints
;
; AUTHOR:
;
;    Weihua Fang
;    weihua.fang@bnu.edu.cn
;
; PURPOSE:
;
;    Judge the position relationship between a point and ROI
;
;
; CALLING SEQUENCE:
;
;    result = shape_containsPoints(ShapeFile, x, y)
;
; ARGUMENTS:
;
;    ShapeFile: a string of shape file name, which is used for position judgement
;
; KEYWORDS:
;
; OUTPUTS:
;
;    -1: The shape file type is not polygon
;    ShpCntnPts: An integer vector of the judgement result.
;      0 = Exterior. The point lies strictly out of bounds of the ROI
;      1 = Interior. The point lies strictly inside the bounds of the ROI
;      2 = On edge. The point lies on an edge of the ROI boundary
;      3 = On vertex. The point matches a vertex of the ROI
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
;    Code written by Weihua Fang.
;    Comments written by Yuguo Wu.
;
function shape_containsPoints, ShapeFile, x, y

  N_pts = n_elements(x)
  ShpCntnPts = intarr(N_pts)
  
  oShape = obj_new('IDLffShape',ShapeFile)
  oShape-> GetProperty, ENTITY_TYPE  = ENTITY_TYPE
  print, ENTITY_TYPE
  
  if ENTITY_TYPE ne 5 then begin
    obj_destroy,oShape
    return,-1
  endif else begin
  
    oROIGROUP = OBJ_NEW( 'IDLanROIGroup')
    oROI = OBJ_NEW('IDLanROI')
    
    oShape-> GetProperty, N_ENTITIES = N_ENTITIES
    for int_ENT = 0 , N_ENTITIES -1 do begin
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
        
        VERTICES_Polygon_LL = (*oENTITY.vertices)[0:1,start_vertic:end_vertic]
        oROI -> SetProperty, data = VERTICES_Polygon_LL [0:1, *]
        
        for int_pts = 0L, N_pts - 1 do begin
          ShpCntnPts[int_pts] = oROI->ContainsPoints(x[int_pts],y[int_pts])
        endfor
        
      endfor ;int_part
      
      oShape->IDLffShape::DestroyEntity, oENTITY
    endfor ;int_ent
    
  endelse
  obj_destroy,oROI
  obj_destroy,oROIGROUP
  obj_destroy,oshape
  
  return,ShpCntnPts
  
end
