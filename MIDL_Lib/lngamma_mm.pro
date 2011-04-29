Function Lngamma_mm, x, integer = int

;+
; NAME:
;		LNGAMMA_MM
; VERSION:
;		5.2
; PURPOSE:
;		Calculates the natural log of the gamma function.  Replacement for the
;		IDL LNGAMMA function which accepts only real input.
; CATEGORY:
;		Mathematical function (general).
; CALLING SEQUENCE:
;		Result = LNGAMMA_MM (X, [,/INTEGER ])
; INPUTS:
;	X
;		Numeric, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/INTEGER
;		Switch.  If set, the calculation is performed in an "integer mode".
;		This is limited to integer X (non integer X is converted to integer on
;		input) but the calculation is much faster.
; OUTPUTS:
;		Returns the natural logarithm of the gamma function of X.  Output type
;		and form are identical to those of the input (but output type is never
;		lower than FLOAT).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The real part of X should be positive.
; PROCEDURE:
;		Uses a continued fraction expansion.  Calls CAST, CONFRAC, DEFAULT,
;		TOLER and TYPE, from MIDL.
; MODIFICATION HISTORY:
;		Created 30-MAR-1996 by Mati Meron as M_LNGAMMA.
;		Renamed 25-SEP-1999 by Mati Meron, to LNGAMMA_MM.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;		Modified 10-NOV-2005 by Mati Meron.  Added keyword /INTEGER.
;-

	on_error, 1

	a = [1d/12d, 1d/30d, 53d/210d, 195d/371d, 22999d/22737d, $
		29944523d/19733142d, 109535241009d/48264275462d, $
		2.95520928d,3.34489801d,2.40361667d,1.19320621d,0.40123515d,0.07143468d]

	b = dblarr(n_elements(a),2)
	b[*,1] = 1d
	xpo = x + 1d

	if keyword_set(int) then res = (total(alog(dindgen(max(x))>1),/cum))[x-1] $
	else res = 0.5d*alog(2d*!dpi) + (xpo - 0.5d)*alog(xpo) - xpo - alog(x) + $
		Confrac(a,b,xpo,eps = Toler(x), /rel)

	return, Cast(res,4,Type(x))
end
