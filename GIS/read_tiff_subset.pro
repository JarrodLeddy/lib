function read_tiff_subset, subset_lon = subset_lon, subset_lat = subset_lat, $
    sImage = sImage, fn_image = fn_image, tiff_val_default = tiff_val_default
    
  if ~keyword_set(sImage) then begin
    if keyword_set(fn_image) then begin
      image = read_tiff(fn_image, geotiff = geotiff)
      sImage = {image:image,geotiff:geotiff}
      return, sImage
    endif else begin
      print, 'wrong keywords!'
      return, -1
    endelse
  endif else begin
    image   = sImage.image
    
;    sub_tmp = where(image LE 0.0002, count_tmp)
;    if count_tmp GT 0 then begin
;      image[sub_tmp] = 0.0002
;    endif

    geotiff = sImage.geotiff
    
    if geotiff.GTModelTypeGeoKey eq 2 then begin ; geographic longitude/latitude
      subset_x = subset_lon
      subset_y = subset_lat
    endif else begin
      mapCoord  = GeoCoord(image, geotiff)
      mapStruct = mapCoord -> GetMapStructure()
      subset_xy = Map_Proj_Forward(subset_lon, subset_lat, Map_Structure = mapStruct)
      subset_x  = subset_xy[0, *]
      subset_y  = subset_xy[1, *]
    endelse
    
    tiff_x_left     = geotiff.MODELTIEPOINTTAG[3]
    tiff_y_top      = geotiff.MODELTIEPOINTTAG[4]
    tiff_pixel_size = geotiff.MODELPIXELSCALETAG[0]
    
    index_x = round((subset_x - tiff_x_left + 0.5 * tiff_pixel_size) / tiff_pixel_size)
    index_y = round((tiff_y_top - subset_y  - 0.5 * tiff_pixel_size) / tiff_pixel_size)
    
    dimension    = SIZE(subset_x, /DIMENSIONS)
    type         = SIZE(image, /Type)
    subset_image = MAKE_ARRAY(DIMENSION = dimension, type = type)
    
    if keyword_set(default_value) then begin
      subset_image[*] =  tiff_val_default
    endif ;else begin
;      subset_image[*] =  0.0002
;    endelse
    
    size_image    = SIZE(image, /DIMENSIONS)
    subscript_tmp = where(index_x LT size_image[0] and index_x GE 0 and $
      index_y LT size_image[1] and index_y GE 0, count_tmp)
    if count_tmp GT 0 then begin
      subset_image[subscript_tmp] = image[index_x[subscript_tmp], index_y[subscript_tmp]]
    endif
    
    return, subset_image
    
  endelse
  
end