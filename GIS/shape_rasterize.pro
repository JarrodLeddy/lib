;+
; NAME:
;  shape_rasterize
;
; AUTHOR:
;  FANG Weihua
;
; PURPOSE:
;  Change vector data into raster data
;
; CALLING SEQUENCE:
;  result = shape_rasterize (str_shape_File, pixel_size)
;
; ARGUMENTS:
;
; str_shape_File: the path of the file
; pixel_size: the pixel size(we can also say resolution of the latitude and longitude )
;
; KEYWORDS:
;
;    str_fldname: Certain attribute field of the shp file,default: str_fldname = FID
;    origin: Origin coordinate,default: x_min and y_min in shp file
;    n_col_row: the values of col and row
;    sMap_Target:Projection Conversion(input data is in Geographic latitude/longitude)
;
; OUTPUTS:
;
;   a mask file (the region the vector file contains)
;
; EXAMPLE:
;
;   File=dialog_pickfile()
;   a = shape_rasterize(file,0.1)
;
; MODIFICATION_HISTORY:

FUNCTION Shape_rasterize, str_shape_File,  $
    pixel_size, $
    str_fldname   = str_fldname, $
    origin        = origin, $
    return_origin = return_origin, $
    n_col_row     = n_col_row, $
    sMap_Target   = sMap_Target
    
  oShape = OBJ_NEW('IDLffShape',str_shape_File)
  oShape-> GetProperty, ENTITY_TYPE  = ENTITY_TYPE, ATTRIBUTE_INFO = ATTRIBUTE_INFO
  
  has_valid_fld = 0
  IF KEYWORD_SET(str_fldname) THEN BEGIN
    subscript_tmp = where (STRTRIM(ATTRIBUTE_INFO.name,2) EQ STRTRIM(str_fldname,2), count_tmp)
    IF count_tmp NE 1 THEN BEGIN
      PRINT, 'field ' + str_fldname + 'not exists'
    ENDIF ELSE BEGIN
      fld_type = ATTRIBUTE_INFO[subscript_tmp].type
      IF fld_type NE 7 THEN BEGIN
        fld_no  = subscript_tmp[0]
        has_valid_fld = 1
      ENDIF
    ENDELSE
  ENDIF
  
  ;point
  IF ENTITY_TYPE EQ 1 THEN BEGIN
    oShape-> GetProperty, N_ENTITIES=N_ENTITIES
    roi_arr   = OBJARR(N_ENTITIES)
    fld_vals  = MAKE_ARRAY( N_ENTITIES, TYPE=fld_type)
    
    FOR int_ENT = 0 , N_ENTITIES -1 DO BEGIN
      ent_tmp  = Shape_obj -> IDLffShape::GetEntity(i)
      fld_vals[int_ENT]  = (*ent_tmp.ATTRIBUTES).(fld_no)
      
      roi_arr[i] = OBJ_NEW('IDLanROI')
      
      IF KEYWORD_SET(sMap_Target) THEN BEGIN
        roi_arr[i] -> IDLanROI::Setproperty, $
          data = MAP_PROJ_FORWARD ([ent_tmp.bounds[0],ent_tmp.bounds[1]], $
          MAP_STRUCTURE = sMap_Target)
      ENDIF ELSE BEGIN
        roi_arr[i] -> IDLanROI::Setproperty, $
          data = [ent_tmp.bounds[0],ent_tmp.bounds[1]]
      ENDELSE
      Shape_obj->Idlffshape::destroyentity, ent_tmp ;clean up pointers
      
      roi_arr[i] -> IDLanROI::Getproperty,ROI_XRANGE = x_range_albers
      roi_arr[i] -> IDLanROI::Getproperty,ROI_YRANGE = y_range_albers
      
      IF int_ENT EQ 0 THEN BEGIN
        x_min_shp = x_range_albers[0]
        x_max_shp = x_range_albers[1]
        y_min_shp = y_range_albers[0]
        y_max_shp = y_range_albers[1]
      ENDIF ELSE BEGIN
        x_min_shp  = x_min_shp  < x_range_albers[0]
        x_max_shp  = x_max_shp  > x_range_albers[1]
        y_min_shp  = y_min_shp  < y_range_albers[0]
        y_max_shp  = y_max_shp  > y_range_albers[1]
      ENDELSE
      
    ENDFOR ;int_ENT
    
    IF ~KEYWORD_SET(origin) THEN BEGIN
      origin    = FLTARR(2)
      origin[0] = x_min_shp
      origin[1] = y_min_shp
    ENDIF
    
    IF ~KEYWORD_SET(n_col_row) THEN BEGIN
      n_col_row = LONARR(2)
      n_col_row [0] = CEIL( (x_max_shp - origin[0])/pixel_size)
      n_col_row [1] = CEIL( (y_max_shp - origin[1])/pixel_size)
    ENDIF
    upper_bounds    = DBLARR(2)
    upper_bounds[0] = x_min_shp + pixel_size * n_col_row[0]
    upper_bounds[1] = y_min_shp + pixel_size * n_col_row[1]
    
    mask = MAKE_ARRAY( n_col_row[0], n_col_row[1], TYPE =fld_type)
    ;    print,n_col_row
    
    FOR i = 0,N_ELEMENTS(roi_arr)-1 DO BEGIN
    
      roi_arr[i] -> IDLanROI::Getproperty,ROI_XRANGE = x_range_albers
      roi_arr[i] -> IDLanROI::Getproperty,ROI_YRANGE = y_range_albers
      s_tmp = ROUND( double (x_range_albers[0] - origin[0]        ) / pixel_size, /L64)
      l_tmp = ROUND( double (upper_bounds[1]   - y_range_albers[0]) / pixel_size, /L64)
      
      IF has_valid_fld THEN BEGIN
        mask[s_tmp,l_tmp] = fld_vals [i]
      ENDIF ELSE BEGIN
        mask[s_tmp,l_tmp] = i + 1
      ENDELSE
    ENDFOR
    
  ENDIF
  
  ;polygon or polyline
  IF ENTITY_TYPE EQ 5 OR ENTITY_TYPE EQ 3 THEN BEGIN
    ;get the bounds of shapefile
    oShape-> GetProperty, N_ENTITIES=N_ENTITIES
    fld_vals  = MAKE_ARRAY( N_ENTITIES, TYPE=fld_type)
    
    ;n_ent = N_ENTITIES
    FOR int_ENT = 0 , N_ENTITIES -1 DO BEGIN
      oENTITY  = oShape -> IDLffShape::GetEntity(int_ENT,/ATTRIBUTES)
      
      IF has_valid_fld EQ 1 THEN BEGIN
        fld_vals[int_ENT] = (*oENTITY.ATTRIBUTES).(fld_no)
      ENDIF ELSE BEGIN
        fld_vals[int_ENT] = int_ENT + 1
      ENDELSE
      
      
      IF KEYWORD_SET(sMap_Target) THEN BEGIN
        VERTICES_Polygon_Proj = MAP_PROJ_FORWARD ($
          (*(oENTITY.VERTICES))[0:1,*],$
          MAP_STRUCTURE = sMap_Target)
      ENDIF ELSE BEGIN
        VERTICES_Polygon_Proj = (*(oENTITY.VERTICES))[0:1,*]
      ENDELSE
      PTR_FREE, oENTITY.VERTICES
      oShape->Idlffshape::destroyentity, oENTITY
      
      IF int_ENT EQ 0 THEN BEGIN
        x_min_shp = MIN(VERTICES_Polygon_Proj[0,*])
        x_max_shp = MAX(VERTICES_Polygon_Proj[0,*])
        
        y_min_shp = MIN(VERTICES_Polygon_Proj[1,*])
        y_max_shp = MAX(VERTICES_Polygon_Proj[1,*])
      ENDIF ELSE BEGIN
        x_min_shp  = x_min_shp  < MIN(VERTICES_Polygon_Proj[0,*])
        x_max_shp  = x_max_shp  > MAX(VERTICES_Polygon_Proj[0,*])
        
        y_min_shp  = y_min_shp  < MIN(VERTICES_Polygon_Proj[1,*])
        y_max_shp  = y_max_shp  > MAX(VERTICES_Polygon_Proj[1,*])
      ENDELSE
    ENDFOR
    
    IF KEYWORD_SET(origin) THEN BEGIN
      x_min_shp = origin  [0]
      y_min_shp = origin  [1]
    ENDIF
    
    IF ~KEYWORD_SET(n_col_row) THEN BEGIN
      n_col_row = LONARR(2)
      n_col_row [0] = CEIL( (x_max_shp - x_min_shp)/pixel_size)
      n_col_row [1] = CEIL( (y_max_shp - y_min_shp)/pixel_size)
    ENDIF
    
    x_max_shp = x_min_shp + pixel_size * n_col_row[0]
    y_max_shp = y_min_shp + pixel_size * n_col_row[1]
    
    IF ~KEYWORD_SET(origin) THEN BEGIN
      origin    = FLTARR(2)
      origin[0] = x_min_shp
      origin[1] = y_min_shp
    ENDIF
    
    
    mask = intarr (n_col_row[0],n_col_row[1])
    
    ;    print,n_col_row
    
    IF ENTITY_TYPE EQ 3 THEN BEGIN
      oROI = OBJ_NEW( 'IDLanROI',type=1)
    ENDIF ELSE BEGIN
      oROI = OBJ_NEW( 'IDLanROI')
    ENDELSE
    
    FOR int_ENT =  0L , N_ENTITIES -1 DO BEGIN
    
      oENTITY  = oShape -> IDLffShape::GetEntity(int_ENT)
      
      FOR int_part = 1L, oENTITY.N_PARTS DO BEGIN
      
        IF oENTITY.N_PARTS LE 1 THEN BEGIN
          start_vertic = 0
          end_vertic   = oENTITY.N_VERTICES -1
        ENDIF ELSE BEGIN
          start_vertic = (*oENTITY.Parts)[int_part -1]
          IF int_part LT oENTITY.N_PARTS THEN BEGIN
            end_vertic   = (*oENTITY.Parts)[int_part] -1
          ENDIF ELSE BEGIN
            end_vertic   =  oENTITY.N_VERTICES -1
          ENDELSE
        ENDELSE
        
        
        VERTICES_Polygon_LL = (*oENTITY.vertices)[0:1,start_vertic:end_vertic]
        
        IF KEYWORD_SET(sMap_Target) THEN BEGIN
          VERTICES_Polygon_Proj = MAP_PROJ_FORWARD (VERTICES_Polygon_LL[0:1,*], $
            MAP_STRUCTURE = sMap_Target)
        ENDIF ELSE BEGIN
          VERTICES_Polygon_Proj = VERTICES_Polygon_LL[0:1,*]
        ENDELSE
        
        
        ;Compute the columns and rows of the rectangle
        
        ;------------------- revised part 1
        col_left  = FLOOR((MIN(VERTICES_Polygon_Proj[0,*]) - x_min_shp)$
          /pixel_size,/L64); + 1
        row_down  = FLOOR((MIN(VERTICES_Polygon_Proj[1,*]) - y_min_shp)$
          /pixel_size,/L64); + 1
          
        x_col_left  = x_min_shp + col_left *pixel_size
        y_row_down  = y_min_shp + row_down *pixel_size
        
        samples_polygon   = CEIL((MAX(VERTICES_Polygon_Proj[0,*]) - $
          x_col_left)/pixel_size,/L64)
        lines_polygon     = CEIL((MAX(VERTICES_Polygon_Proj[1,*]) - $
          y_row_down)/pixel_size,/L64)
        samples_polygon = samples_polygon > 1
        lines_polygon = lines_polygon > 1
        
        VERTICES_Polygon_Proj_aoi = VERTICES_Polygon_Proj / FLOAT(pixel_size)
        x_col_left_roi  = x_col_left/FLOAT(pixel_size)
        y_row_down_roi  = y_row_down/FLOAT(pixel_size)
        
        oROI -> SetProperty, data = VERTICES_Polygon_Proj_aoi [0:1, *]
        
        mask_tmp = oROI->Computemask(Dimensions =[samples_polygon,lines_polygon], $
          ;          origin = [x_col_left_roi, y_row_down_roi], $
          LOCATION = [x_col_left_roi, y_row_down_roi], $
          mask_rule = 2, $
          PIXEL_CENTER = [0.5,0.5])
          
        CASE SIZE(mask_tmp, /N_DIMENSIONS) OF
          0: ; do nothing
          1: mask_tmp = REVERSE( mask_tmp /BYTE(255) )
          2: BEGIN
            mask_tmp = REVERSE( mask_tmp /BYTE(255) ,2)
          END
          ELSE: ; never happens
        ENDCASE
        
        col_start = col_left
        col_end   = col_start + samples_polygon - 1
        row_end   = n_col_row[1] - row_down - 1
        row_start = row_end   - lines_polygon + 1
        mask_tmp_col_start = 0
        mask_tmp_col_end = samples_polygon-1
        mask_tmp_row_start = 0
        mask_tmp_row_end = lines_polygon-1
        
        IF col_start LT 0 THEN BEGIN
          mask_tmp_col_start = - col_start
          col_start = 0
        ENDIF
        IF col_end GE n_col_row[0] THEN BEGIN
          mask_tmp_col_end = mask_tmp_col_end - col_end + n_col_row[0]-1
          col_end = n_col_row[0]-1
        ENDIF
        IF row_start LT 0 THEN BEGIN
          mask_tmp_row_start = - row_start
          row_start = 0
        ENDIF
        IF row_end GE n_col_row[1] THEN BEGIN
          mask_tmp_row_end = mask_tmp_row_end - row_end + n_col_row[1]-1
          row_end = n_col_row[1]-1
        ENDIF
        
        mask_tmp = mask_tmp[mask_tmp_col_start:mask_tmp_col_end,mask_tmp_row_start:mask_tmp_row_end]
        
        mask_rst = mask[col_start:col_end,row_start:row_end]
        subscript_tmp = where (mask_rst EQ 0, count_tmp)
        IF count_tmp GT 0 THEN BEGIN
          IF KEYWORD_SET(str_fldname) THEN BEGIN
            mask_tmp  = mask_tmp * (fld_vals(int_ENT))
          ENDIF ELSE BEGIN
            mask_tmp  = mask_tmp * (int_ENT+1)
          ENDELSE
          mask_rst [subscript_tmp] = mask_tmp [subscript_tmp]
          mask[col_start:col_end,row_start:row_end] = mask_rst [*,*]
        ENDIF
        
      ENDFOR ; of int_part
      
      PTR_FREE, oENTITY.PARTS
      PTR_FREE, oENTITY.VERTICES
      oShape->Idlffshape::destroyentity, oENTITY
      
    ENDFOR ; of int_ENT
    OBJ_DESTROY, oROI
  ENDIF
  
  oShape->Idlffshape::close
  OBJ_DESTROY, oShape
  
  PRINT, 'end of rasterize_shape_polygon'
  
  if keyword_set(return_origin) then begin
    return_origin = origin
  endif
  
  RETURN, mask
  
END
