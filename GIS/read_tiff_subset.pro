function read_tiff_subset, subset_lon = subset_lon, subset_lat = subset_lat, $
    sImage = sImage, fn_image = fn_image
    
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
    geotiff = sImage.geotiff
    
    dimension    = SIZE(image, /DIMENSIONS)
    type         = SIZE(image, /Type)
    image_subset = MAKE_ARRAY(DIMENSION = dimension , type = type )

    if geotiff.GTModelTypeGeoKey eq 2 then begin ; geographic longitude/latitude
      subset_x = subset_lon
      subset_y = subset_lat
    endif else begin
      mapCoord = GeoCoord(image, geotiff)
      sMap     = mapCoord -> GetMapStructure()
      subset_xy = Map_Proj_Forward(subset_lon, subset_lat, Map_Structure = mapStruct)
      subset_x = subset_xy[0]
      subset_y = subset_xy[1]
    endelse
; to improve coding here

    
  endelse
end