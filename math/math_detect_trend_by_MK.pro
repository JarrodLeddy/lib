;*******************************************************************
;+
; NAME:
;       math_detect_trend_by_MK
;
; PURPOSE:
;
;       The purpose of this function is to provide trend test
;       with mann-kendall method.
;
; AUTHOR:
;
;       Weihua, FANG,    weihua.fang@bnu.edu.cn
;       Ying LI     ,    ying.li@mail.bnu.edu.cn  
;
; ARGUMENTS:
;
;       x: vector of time series
;
; KEYWORDS:
;
;       Uf: Set this keyword to get the value of Uf
;       Ub: Set this keyword to get the value of Ub
;
;
; Sample:
;
;
;pro math_detect_trend_by_MK_example
;
;  n = 91
;  x = fltarr(n)
;  x [0:9]   = [15.4,14.6,15.8,14.8,15.0,15.1,15.1,15.0,15.2,15.4]
;  x [10:19] = [14.8,15.0,15.1,14.7,16.0,15.7,15.4,14.5,15.1,15.3]
;  x [20:29] = [15.5,15.1,15.6,15.1,15.1,14.9,15.5,15.3,15.3,15.4]
;  x [30:39] = [15.7,15.2,15.5,15.5,15.6,16.1,15.1,16.0,16.0,15.8]
;  x [40:49] = [16.2,16.2,16.0,15.6,15.9,16.2,16.7,15.8,16.2,15.9]
;  x [50:59] = [15.8,15.5,15.9,16.8,15.5,15.8,15.0,14.9,15.3,16.0]
;  x [60:69] = [16.1,16.5,15.5,15.6,16.1,15.6,16.0,15.4,15.5,15.2]
;  x [70:79] = [15.4,15.6,15.1,15.8,15.5,16.0,15.2,15.8,16.2,16.2]
;  x [80:89] = [15.2,15.7,16.0,16.0,15.7,15.9,15.7,16.7,15.3,16.1]
;  x [90]    = 16.2
;  dummy = MK_test (x, Uf=Uf, Ub=Ub)
;  iplot, Uf, yrange = [min([Uf,Ub,-1.96])-0.5, max([Uf,Ub,1.96]) + 0.5]
;  iplot, Ub
;  Ub[*] = -1.96
;  iplot, Ub
;  Ub[*] = 1.96
;  iplot, Ub
;
;end
;

; REFERENCE
;
;- 魏凤英．现代气候统计诊断预测技术．北京：气象出版社，1999.
;
; MODIFICATION_HISTORY:
;  
;
;*******************************************************************


function MK_rank, x
  n    = n_elements(x)
  u    = dblarr(n)
  
  r  = fltarr(n-1)
  sk = fltarr(n-1)
  
  for i = 2, n do begin
    dummy = where ( x[0:i-1] LT x[i-1], r_tmp)
    r [i-2] = r_tmp
  endfor
  
  Sk[0] = r[0]
  for i =3, n do begin
    Sk[i-2] = Sk[i-3] + r [i-2]
  endfor
  
  i = findgen(n-1) + 2
  e        = i * (i-1.)*0.25
  var      = i * (i-1.)*(2*i+5.)/72.
  u[1:n-1] = (Sk-e) / sqrt(var)
  
  return, u
end

function math_detect_trend_by_MK, x, Uf = Uf, Ub = Ub
  Uf = MK_rank(x)
  Ub = -reverse(MK_rank(reverse (x,1)),1)
  return, 1
end


