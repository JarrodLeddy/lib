pro testtime
;
;  time_start = SYSTIME(/SECONDS )
;  for a = 0l, 990000L do begin
;    b =  map_2points(100,30, 40, 30)
;  endfor
;  print, SYSTIME(/SECONDS ) - time_start

  time_start = SYSTIME(/SECONDS )
  for a = 0l, 990000L do begin
    b =  mlib_map2points_1(100,30, 40, 30)
  endfor
  print, SYSTIME(/SECONDS ) - time_start
  
  time_start = SYSTIME(/SECONDS )
  for a = 0l, 990000L do begin
    b =  mlib_map2points_2 (100,30, 40, 30)
  endfor
  print, SYSTIME(/SECONDS ) - time_start
  
  time_start = SYSTIME(/SECONDS )
  for a = 0l, 990000L do begin
    b =  mlib_map2points_3 (100,30, 40, 30)
  endfor
  print, SYSTIME(/SECONDS ) - time_start
  
  time_start = SYSTIME(/SECONDS )
  lon = fltarr(90000L)
  lat = fltarr(90000L)
  for i = 0,9999 do begin
    lon[i] = 40
    lat[i] = 30
  endfor
  b =  mlib_map2points_1(100,30, lon, lat)
  print, SYSTIME(/SECONDS ) - time_start
  
  time_start = SYSTIME(/SECONDS )
  lon = fltarr(90000L)
  lat = fltarr(90000L)
  for i = 0,9999 do begin
    lon[i] = 40
    lat[i] = 30
  endfor
  b =  mlib_map2points_2(100,30, lon, lat)
  print, SYSTIME(/SECONDS ) - time_start

  time_start = SYSTIME(/SECONDS )
  lon = fltarr(90000L)
  lat = fltarr(90000L)
  for i = 0,9999 do begin
    lon[i] = 40
    lat[i] = 30
  endfor
  b =  mlib_map2points_3(100,30, lon, lat)
  print, SYSTIME(/SECONDS ) - time_start
  
end

Function mlib_Map2points_1, lon0, lat0, lon1, lat1
  k = !dpi/180.0
  cosc = sin(k*lat0) * sin(k*lat1) + cos(k*lat0) * cos(k*lat1) * cos(k*(lon1-lon0))
  cosc = -1 > cosc < 1
  return, acos(cosc) * 6378206.4d0
end

Function mlib_Map2points_2, lon0, lat0, lon1, lat1
  k =0.017453293
  cosc = sin(k*lat0) * sin(k*lat1) + cos(k*lat0) * cos(k*lat1) * cos(k*(lon1-lon0))
  cosc = -1 > cosc < 1
  return, acos(cosc) * 6378206.4d0
end

Function mlib_Map2points_3, lon0, lat0, lon1, lat1
  cosc = sin( 0.017453293*lat0) * sin( 0.017453293*lat1) + cos( 0.017453293*lat0) * cos( 0.017453293*lat1) * cos( 0.017453293*(lon1-lon0))
  cosc = -1 > cosc < 1
  return, acos(cosc) * 6378206.4d0
end
