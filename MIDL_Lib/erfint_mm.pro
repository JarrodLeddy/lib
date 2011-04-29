Function Erfint_mm, y, x

;+
; NAME:
;		ERFINT_MM
; VERSION:
;		4.3
; PURPOSE:
;		Calculates a definite integral of the error function.
; CATEGORY:
;		Mathematical function (general).
; CALLING SEQUENCE:
;		Result = ERFINT_MM (Y [,X])
; INPUTS:
;	Y
;		Numeric, otherwise arbitrary.  Upper integration limit.
; OPTIONAL INPUT PARAMETERS:
;	X
;		Numeric, otherwise arbitrary.  Lower integration limit.  Defaults to 0.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns an integral of the error function between X and Y.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		If both X and Y are arrays, they need to have same number of elements.
;		Scalar-scalar and scalar-array combinations are permitted.
; PROCEDURE:
;		Straightforward.  Uses CALCTYPE, CAST, DEFAULT and ERRORF_MM from MIDL.
; MODIFICATION HISTORY:
;		Created 10-MAY-2002 by Mati Meron.
;-

	on_error, 1

	x = Default(x,0.)
	nxy = [n_elements(x),n_elements(y)]
	nlo = min(nxy,max=nhi)
	if nlo gt 1 and nlo lt nhi then message, 'Dimensional mismatch!'
	typ = Calctype(0.,x,y)

	res = y*Errorf_mm(y) - x*Errorf_mm(x) + (exp(-y^2) - exp(-x^2))/sqrt(!dpi)

	return, Cast(res,typ,typ,/fix)
end