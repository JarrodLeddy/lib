Function map_2points_meters_batch, lon0, lat0, lon1, lat1

  k = !dpi / 180
  
  cosc = sin( k*lat0) * sin( k*lat1) + cos( k*lat0) * cos( k*lat1) * cos( k*(lon1-lon0))
  cosc = -1 > cosc < 1
  
  coslt1 = cos(k*lat1)
  sinlt1 = sin(k*lat1)
  coslt0 = cos(k*lat0)
  sinlt0 = sin(k*lat0)
  
  cosl0l1 = cos(k*(lon1-lon0))
  sinl0l1 = sin(k*(lon1-lon0))
  
  cosc = sinlt0 * sinlt1 + coslt0 * coslt1 * cosl0l1 ;Cos of angle between pnts
  ; Avoid roundoff problems by clamping cosine range to [-1,1].
  cosc = -1 > cosc < 1
  sinc = sqrt(1.0 - cosc^2)
  
  subscript_tmp = where(sinc ne 1.0e-7, count)
  if count ne 0 then begin
    cosaz = (coslt0 * sinlt1 - sinlt0*coslt1*cosl0l1) / sinc ;Azmuith
    sinaz = sinl0l1*coslt1/sinc
  endif
  subscript_tmp = where(sinc le 1.0e-7, count)
  if count ne 0 then begin
    cosaz[subscript_tmp] = 1.0
    sinaz[subscript_tmp] = 0.0
  endif
  
  max_size = max([n_elements(lon0), n_elements(lon1)])
  output = dblarr(2, max_size)
  output(0, *) = acos(cosc) * 6378206.4d0
  output(1, *) = atan(sinaz, cosaz) / k
  return, output
  
end