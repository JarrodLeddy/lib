Function Smooth_mm, arr, wid, deriv = nder, edge_truncate = edt

;+
; NAME:
;		SMOOTH_MM
; VERSION:
;		4.0
; PURPOSE:
;		Non broadening data smoothing.
; CATEGORY:
;		Array function.
; CALLING SEQUENCE:
;		Result = SMOOTH_MM( ARR, WID [keywords])
; INPUTS:
;	ARR
;		Array, numeric, no more than six dimensions.
;	WID
;		The width of the smoothing window.  Can be given either as a scalar (in
;		which case it is applied to all the dimensions of the array, or as a
;		vector (in which case each entry applies to one dimension).  The WIDTH
;		entry(s) should be an odd number(s), if it is even the next higher odd
;		number(s) will be used.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	DERIV
;		Causes the smoothed derivative (first or second) of the data to be
;		returned instead of the data itself.  Currently valid only for 1D
;		arrays.
;	/EDGE_TRUNCATE
;		Switch.  Same as in the IDL version of SMOOTH.
; OUTPUTS:
;		Returns the smoothed array or (optionally) its first or second
;		derivative.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses a variation of the Savitzky-Golay procedure.  Superior to the IDL
;		provided SMOOTH routine in the sense that it doesn't introduce peak
;		broadening.  Note that:
;
;		1)  The width needed obtain a given degree of smoothing is about twice
;			as big as with SMOOTH (which isn't a problem since this extra width
;			doesn't cause broadening.
;		2)  Since the averaging kernel isn't positive definite, in some rare
;			cases (high and very narrow peaks with little or no background)
;			SMOOTH_MM may generate artifacts.
;
;		Calls CAST, CONVOL_MM, DEFAULT, DIAGOARR, MAKE_GRID, SOLVE_LINSYS and
;		TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 25-JAN-1997 by Mati Meron as M_SMOOTH.
;		Renamed 25-SEP-1999 by Mati Meron, to SMOOTH_MM.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	ndmx = 6

	siz = size(reform([arr]))
	ndm = siz[0]
	if ndm gt ndmx then message, 'At most six dimensions are allowed'
	nder = Default(nder,0,/dtype) > 0
	dwid = (nder + 1)/2*2 + 1l
	wwid = Default(wid,dwid,/dtype) > dwid

	if nder eq 0 then begin
		if n_elements(wwid) eq 1 then wwid = replicate(wwid,ndm) else $
		if n_elements(wwid) ne ndm then message, 'Improper width dimension!'
	endif else if ndm gt 1 then message,'Derivatives allowed only with 1D data'

	typ = Type(arr) > 4
	m = Cast(floor(wwid/2.),5,Typ)
	if nder gt 0 then k = dindgen(2*m+1) - m
	if min(siz[1:ndm] - 2*m - 1) lt 0 then message, 'Width exceeds array size'

	case nder of
		0	:	begin
					ks = (Make_grid(transpose([[-m],[m]]),2*m+1,fun=ker))^2

					s2 = [1.,m*(m+1)/3]
					s4 = s2*[1.,(3*m^2 + 3*m - 1)/5]
					sar = s2#transpose(s2) + Diagoarr(s4 - s2^2)
					rhs = [1.*ndm/n_elements(ks),fltarr(ndm)]
					lam = Solve_linsys(sar,rhs,/svd)

					ker = ker + lam[0]
					if ndm eq 1 then ker = ker + lam[1]*ks else $
					for i = 0, ndm-1 do ker = ker + lam[i+1]*ks[i,*,*,*,*,*]
					ker = reform(ker,2*m+1)
				end
		1	:	ker = -3.*k/(m*(2*m+1)*(m+1))
		2	:	ker = 30.*(3*k^2 - m*(m+1))/((2*m-1)*m*(2*m+1)*(m+1)*(2*m+3))
		3	:	ker = 210.*k*(3*m*(m+1) - 1 - 5*k^2)/ $
						((m-1)*(2*m-1)*m*(2*m+1)*(m+1)*(2*m+3)*(m+2))
		else:	message, 'Derivative of order'+ string(nder)+ ' not supported!'
	endcase

	if not keyword_set(edt) then begin
		l = lonarr(ndmx)
		l[0:ndm-1] = m
 		h = lonarr(ndmx)
		h[0:ndm-1] = siz[1:ndm] - m - 1
		res = Cast(arr,4)
		tres = Convol_mm(arr,ker)
		res(l[0]:h[0],l[1]:h[1],l[2]:h[2],l[3]:h[3],l[4]:h[4],l[5]:h[5]) = $
		tres(l[0]:h[0],l[1]:h[1],l[2]:h[2],l[3]:h[3],l[4]:h[4],l[5]:h[5])
	endif else res = Convol_mm(arr,ker,/edge_trun)

	return, Cast(res,typ,typ,/fix)
end
