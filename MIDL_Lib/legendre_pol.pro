Function Legendre_pol, x, l, m

;+
; NAME:
;		LEGENDRE_POL
; VERSION:
;		4.0
; PURPOSE:
;		Calculates Legendre polynomials Pl and associated polynomials Plm.
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = LEGENDRE_POL( X, L [, M])
; INPUTS:
;	X
;		Numeric, absolute values must be <= 1, otherwise arbitrary.
;	L
;		Nonnegative scalar, rounded to integer on input.  Defaults to 0
; OPTIONAL INPUT PARAMETERS:
;	M
;		Nonnegative scalar, rounded to integer on input.  Defaults to 0.  Must
;		be <= L.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the values of the Legendre polynomial P(l,x) or (when M is not
;		zero) of the associated Legendre polynomial P(l,m,x).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None other then the restrictions on X, L and M as mentioned above.
; PROCEDURE:
;		Using the recurrence relation from Numerical Recipies, Sec. 6.6.
;		Calling CAST, DEFAULT, and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 20-DEC-1994 by Mati Meron.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	wl = Default(l,0l,/dtype)
	wm = Default(m,0l,/dtype)

	if wl lt 0 or wm lt 0 then message, 'L and M must be nonnegative!'
	if wm gt l then message, 'Must have M <= L !'
	if max(abs(x)) gt 1 then message, 'Absolute value of X must be <=1 !'

	res = (-1d)^wm*(1d - x^2)^(0.5d*wm)
	for i = 1l, wm - 1 do res = (2*i + 1)*res

	if wl gt wm then begin
		lm1 = 0*res
		for i = wm + 1, wl do begin
			lm2 = lm1
			lm1 = res
			res = (2d*i - 1d)/(i - wm)*(x*lm1 - lm2) + lm2
		endfor
	endif

	return, Cast(res,4,Type(x),/fix)
end
