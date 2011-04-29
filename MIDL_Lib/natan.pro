Function Natan, x, n, hyper = hyp

;+
; NAME:
;		NATAN
; VERSION:
;		4.0
; PURPOSE:
;		Calculates the function /int{(1 + x^2)^(-n-1)}, or, optionally,
;		/int{(1 - x^2)^(-n-1)}
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = NATAN( X [, N [, /HYPER]])
; INPUTS:
;	X
;		Numerical, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;	N
;		Integer scalar, defaults to 0.
; KEYWORD PARAMETERS:
;	/HYPER
;		Switch, turns on the "hyperbolic" option.
; OUTPUTS:
;		Returns /int{(1 + x^2)^(-n-1)} (for N = 0 it amounts to ATAN(X)), or,
;		if /HYPER is set, /int{(1 - x^2)^(-n-1)} (for N = 0 this is the
;		hyperbolic ATAN).  The result is of the same form as X, of type FLOAT
;		or higher (if X is of a higher type).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		N must be >= 0, otherwise it is taken to be 0.
; PROCEDURE:
;		Exact evaluation in powers of 1/(1 + x^2).  Uses CAST, DEFAULT, FPU_FIX
;		and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 30-MARCH-1994 by Mati Meron.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	n = Default(n,0,/dtype)
	if keyword_set(hyp) then begin
		sgn = -1.
		res = 0.5*alog((1. + x)/(1. - x))
	endif else begin
		sgn = 1.
		res = atan(x)
	endelse

	if n gt 0 then begin
		xsiz = size(x)
		xtyp = 4 > Type(x) < 9
		ndim = xsiz[0]
		nelm = xsiz(ndim+2)
		xtem = Cast(reform([x],nelm),xtyp)
		ytem = reform(make_array(nelm*n,type=xtyp),nelm,n)
		ytem[*,0] = 1./(1. + sgn*xtem^2)
		coef = 0.5
		for i = 1l, n - 1 do begin
			ytem[*,i] =  2.*i/(2.*i + 1.)*ytem[*,0]*ytem[*,i-1]
			coef = (2.*i + 1.)/(2.*i + 2)*coef
		endfor
		ytem = xtem*total(ytem,2)
		if ndim eq 0 then ytem = ytem[0] else ytem = reform(ytem,xsiz[1:ndim])
		res = coef*(res + ytem)
	endif

	return, FPU_fix(res)
end
