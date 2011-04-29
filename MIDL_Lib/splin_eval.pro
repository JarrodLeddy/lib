Function Splin_eval, x, spc, deriv = nder

;+
; NAME:
;		SPLIN_EVAL
; VERSION:
;		4.0
; PURPOSE:
;		Cubic spline evaluation using spline coefficients supplied by the
;		supplementary function SPLIN_COEFFS.  The combination of SPLIN_COEFFS
;		and SPLIN_EVAL is more efficient than the library function SPLINE when
;		repeated interpolations based on the same data set are performed.
; CATEGORY:
;		Mathematical Function (General).
; CALLING SEQUENCE:
;		Result = SPLIN_EVAL( X, SPC [, DERIV = NDER)
; INPUTS:
;	X
;		Numeric, otherwise arbitrary.  The X value (or values) for which the
;		spline interpolation is to be performed.
;	SPC
;		An (n,3) array of spline coefficients, created by the function
;		SPLIN_COEEFS.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	DERIV
;		Integer.  If provided and nonzero, an interpolated derivative of the
;		order DERIV is returned.  Default value is 0.
; OUTPUTS:
;		Returns the result of the interpolation, in the same form as X.  The
;		type of the result is floating or higher, depending on X.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Standard Cubic spline evaluation (see Numerical Recipies, chapt. 3.3)
;		with the boundary condition of 0 THIRD derivative (constant end
;		curvature).  Uses DEFAULT and FPU_FIX from MIDL.
; MODIFICATION HISTORY:
;		Created 15-APR-1992 by Mati Meron.
;		Modified 15-MAY-1992 by Mati Meron.  Added derivative option.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	siz = size(spc)
	if siz[0] ne 2 or siz[2] ne 3 then message, 'Bad coefficient array!'
	nv = siz[1]

	nev = n_elements(x)
	if nev eq 1 then begin
		loc = where(x[0] lt spc[1:nv-2,0], num)
		if num ne 0 then l = loc[0] else l = nv - 2
		m = 0l
	endif else begin
		l = indgen(nv - 1)
		m = make_array(nev, type = 3)
		loc = where(x lt spc[1,0], num)
		if num gt 0 then m[loc] = 0l
		for i = 1l, nv - 3 do begin
			loc = where (x ge spc[i,0] and x lt spc[i+1,0], num)
			if num gt 0 then m[loc] = i
		endfor
		loc = where (x ge spc[nv-2,0], num)
		if num gt 0 then m[loc] = nv - 2
	endelse

	dex = spc[l+1,0] - spc[l,0]
	dey = spc[l+1,1] - spc[l,1]
	dexsq = dex*dex
	spa = (spc[l+1,2] - spc[l,2])*dexsq
	spb = (spc[l+1,2] + 2*spc[l,2])*dexsq
	if nev gt 1 then l = m
	p = (x - spc[l,0])/dex[m]

	nder = Default(nder,0)
	case nder of
		0	:	res = spc[l,1] + p*(dey[m] - spb[m] + p*(spb[m] + spa[m]*(p-1)))
		1	:	res = (dey[m] - spb[m] + p*(2*spb[m] + spa[m]*(3*p - 2)))/dex[m]
		2	:	res = 2*(spb[m] + spa[m]*(3*p-1))/dexsq[m]
		else:	message, 'Derivative of order ' + string(nder) +' not allowed!'
	endcase

	return, FPU_fix(res)
end
