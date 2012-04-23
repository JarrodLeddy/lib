;+
; NAME:
;  math_detect_period_by_power_spectrum
;
; AUTHOR:
;  LI Ying   ying.li@mail.bnu.edu.cn
;
; PURPOSE:
;  1. To calculate raw power spectral density;
;  2. To smooth power spectra;
;  3. To examinate the prosess using red/white noice progress;
;  4. To calculate the number of wave, the period and  frequency.
;
; CALLING SEQUENcE:
;
;    result = math_detect_period_by_power_spectrum(str_data, mlag)
;
; ARGUMENTS:
;    str_data: the time series to be analyzed.
;    mlag : max lag length.
;
; KEYWORDS:
;
;
; OUTPUTS:
;   [5,n] = [power spectrum, num_wave, period, frequency, examination]
;
; KNOWN BUGS:
;
;
; EXAMPLE:
;
;pro math_detect_period_by_power_spectrum_example
;
;  x= [1726.1358,3302.8028,4140.9908 ,2761.3602 ,2071.3745 ,4825.4665 ,$
;    2665.7876 ,3767.1083 ,2710.6649 ,5523.5285 ,4583.6087 ,4490.3340 ,$
;    3837.4038 ,4583.7727 ,2758.0455 ,2212.5422 ,3677.5950 ,1419.8101 ,$
;    3350.1951 ,3045.4534 ,3277.5885 ,2268.8492 ,4380.6510 ,3849.6587 ,$
;    3627.6386 ,2547.0059 ,2546.4989 ,3308.6674 ,2345.6471 ,3011.2875 ,$
;    3196.5279 ,2293.8466 ,1746.1963 ,4170.1172 ,6283.2484 ,3630.9421 ,$
;    1476.3130 ,2255.9939 ,3136.0930 ,4376.2476 ,2819.5159 ,2980.9760 ,$
;    2064.9224 ,5882.4859 ,2394.1387 ,2681.9345 ,2150.2728 ,1155.8223 ,$
;    2960.8238 ,2581.2251 ,3693.8305 ,2762.2905 ,1983.7255 ,1509.7555 ,$
;    3208.3046 ,3823.3174 ,3251.8912 ,4437.8722 ]
;    
;  result = math_detect_period_by_power_spectrum(x,19)
;  for int = 0, 19 do begin
;    print,result[*,int]
;  endfor
;end
;
; MODIFIcATION_HISTORY:

function math_detect_period_by_power_spectrum, str_data, mlag

  n_data = n_elements(str_data)
  mlagwk = mlag
  
  ;calculating auto-covariance coefficient
  str_anomaly = str_data - mean(str_data)
  c = mean(str_anomaly^2)
   cc = dblarr(mlag)
  for L=0,mlag-1 do begin
    CC(L)=0.0
    for I= 0,n_data-L-2 do begin
      CC(L)=CC(L)+str_anomaly(I)*str_anomaly(I+L+1)
    endfor
    CC(L)=CC(L)/(n_data-L-1)
    CC(L)=CC(L)/C
  endfor
  
  ;  estimating raw power spectra
  c = 1.0
  spe = fltarr(mlag + 1)
  spe[0] = total(cc[0:mlag-2])/mlag+(c + cc[mlag-1])/(2*mlag)

  for L = 0,mlag-2 do begin
    spe[L+1] = 0.
    for I= 0,mlag-2 do begin
      spe[L+1] = spe(L+1)+ cc[I]*cos(!pi*(L+1)*(I+1)/mlag)
    endfor
    spe[L+1] = 2*spe[L+1]/mlag + c/mlag + (-1)^(L+1)* cc[mlag-1]/mlag
  endfor
  spe[mlag] = 0.0;
  for I = 0,mlag-2 do begin
    spe[mlag] = spe[mlag] + (-1)^I * cc[mlag-1]
  endfor
  spe[mlag] = spe[mlag]/mlag + (c + (-1)^mlag * cc[mlag-1])/(2*mlag)

  ;smoothing power spectra
  ps = fltarr(mlag + 1)
  ps[0] = 0.54 * spe[0] + 0.46 * spe[1]
  for L = 1,mlag-1 do begin
    ps[L] = 0.23 * spe[L-1] + 0.54 * spe[L] + 0.23 * spe[L+1]
  endfor
  ps[mlag] = 0.46 * spe[mlag-1] + 0.54 * spe[mlag]
  
  ;  statistical significence of ps
  W = total(spe[1:(mlag-1)])
  W = W/mlag + (spe[0] + spe[mlag])/(2 * mlag)
  if (mlag gt fix(n_data/2)) then W = 2.57*W
  if (mlag eq fix(n_data/2)) then W = 2.49*W
  if (mlag lt fix(n_data/2) and mlag gt fix(n_data/3)) then W = 2.323 * W
  if (mlag eq fix(n_data/3)) then W = 2.157*W
  if (mlag lt fix(n_data/3)) then W = 1.979*W
  
  ;the red noice examination
  sk = fltarr(mlag + 1)
  for L = 0, mlag do begin
    sk[L] = W * (1 - cc[0]^2)/(1 + cc[0]^2 - 2 * cc[0] * cos(3.14159*L/mlag))
  endfor
  if (cc[0] gt 0 and cc[0] ge cc[1]) then begin
  ;the white noice examination
  endif else begin
    sk[0:mlag] = W
  endelse
  
  ;calculating the length of cycle
  period =  fltarr(mlag + 1)
  for L = 1,mlag do begin
    period[L] = (2.0 * mlag)/((L+1) * 1.0 - 1.0)
  endfor
  period[0] = 1.0/0
  frequency = 1.0/period
  num_wave  = indgen(mlag+1) 
  ;  CL95      = sk
  return,[transpose(ps),transpose(num_wave),$
    transpose(period),transpose(frequency),transpose(sk)]
    
end




