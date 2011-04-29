function shape_create_grid, fn_shape, x0, y0, n_cols, n_rows, grid_size, $
    fld_NAME = fld_NAME, fld_TYPE = fld_TYPE, fld_WIDTH = fld_WIDTH, $
    fld_PRECISION = fld_PRECISION, grid_VALUES = grid_VALUES
    
  print, 'start of shape_create_grid'
  
  if keyword_set (fn_Shape) then begin
    if n_elements(fn_shape) GT 1 then begin
      print, 'can only create a single shape file once'
      RETALL
    endif
    ; testing the existence of shape file
    fi = FILE_INFO(fn_Shape)
    if fi.EXISTS then begin
      print, 'shape file already exists: ', fn_Shape
      RETALL
    endif
  endif else begin
    print, 'no input shape file. Please specify your shape file path'
    RETALL
  endelse
  
  oShape = OBJ_NEW('IDLffShape', fn_Shape, ENTITY_TYPE=5)
  ;Set the attribute definitions for the new Shapefile
  oShape->AddAttribute, 'lon_0', 5, 8, PRECISION=5
  oShape->AddAttribute, 'lon_1', 5, 8, PRECISION=5
  oShape->AddAttribute, 'lat_0' , 5, 7, PRECISION=5
  oShape->AddAttribute, 'lat_1' , 5, 7, PRECISION=5
  
  if keyword_set(fld_NAME) then begin
    for i_tmp = 0, n_elements(fld_NAME)-1 do begin
      if fld_TYPE [i_tmp] EQ 5 then begin
        oShape->AddAttribute, fld_name[i_tmp] , fld_TYPE[i_tmp], $
          fld_WIDTH[i_tmp], PRECISION=fld_PRECISION[i_tmp]
      endif else begin
        oShape->AddAttribute, fld_name[i_tmp] , fld_TYPE[i_tmp], $
          fld_WIDTH[i_tmp]
      endelse
    endfor
  endif
   
  ; Create structure for new entity.
  oENTITY = {IDL_SHAPE_ENTITY}
  
  int_ent_index = 0
  VERTICES = fltarr(2,4)
  for int_col = 0, n_cols -1 do begin
    for int_row = 0, n_rows -1 do begin
    
      oENTITY.SHAPE_TYPE = 5
      oENTITY.N_VERTICES = 4
      lon_0 = x0    + int_col*grid_size[0]
      lon_1 = lon_0 + grid_size[0]
      lat_0 = y0    + int_row*grid_size[1]
      lat_1 = lat_0 + grid_size[1]
      
      VERTICES[0,*] = [lon_0, lon_1, lon_1, lon_0]
      VERTICES[1,*] = [lat_0, lat_0, lat_1, lat_1]
      oENTITY.VERTICES = PTR_NEW(VERTICES)
      
      oShape -> PutEntity, oENTITY
      
      sAttribute = oShape ->GetAttributes(/ATTRIBUTE_STRUCTURE)
      sAttribute.(0) = lon_0
      sAttribute.(1) = lon_1
      sAttribute.(2) = lat_0
      sAttribute.(3) = lat_1
      if keyword_set(grid_VALUES) then begin
        for i_tmp = 0, n_elements(fld_NAME)-1 do begin
          sAttribute.(4 + i_tmp) = grid_VALUES[i_tmp, int_col, int_row]
        endfor
      endif
      
      oShape -> SetAttributes, int_ent_index, sAttribute
      
      int_ent_index = int_ent_index + 1
      
      PTR_FREE, oENTITY.VERTICES, oENTITY.MEASURE,oENTITY.PARTS,$
        oENTITY.PART_TYPES, oENTITY.ATTRIBUTES
        
    endfor
  endfor
  
  oShape->Close
  OBJ_DESTROY, oShape
  print, 'end of shape_create_grid'
  
end