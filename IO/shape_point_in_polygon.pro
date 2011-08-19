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
;  result =  shape_point_in_polygon(fn_shape_polygon,point)
;
; ARGUMENTS:
;
;  fn_shape_polygon: the path of the file
;  point:  a two elements vector, indicating the point coordinate
;
; KEYWORDS:
;
;
; OUTPUTS:
;
;   flag: 0 stands for the point lies strictly out of bounds of the region
;         1 stands for the point lies strictly inside the bounds of the region
;         2 stands for the point lies on an edge of the region boundary(maybe interior boundary)
;         3 stands for the point matches a vertex of the region(including interior vertex)
;
; EXAMPLE:
;
; MODIFICATION_HISTORY:
;
function shape_point_in_polygon,fn_shape_polygon,point

  flag = 0
  oShape = OBJ_NEW('IDLffShape',fn_shape_polygon)
  oShape-> GetProperty, N_ENTITIES=N_ENTITIES
  
  for int_ENT =  0L , N_ENTITIES -1 do begin
  
    oENTITY  = oShape -> IDLffShape::GetEntity(int_ENT)
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
      if flag gt 0 then return,flag
    endfor
    
    oShape->Idlffshape::destroyentity, oENTITY
  endfor
  
  oShape->IDLffShape::Close
  OBJ_DESTROY, oShape
  
  return,flag
  
end