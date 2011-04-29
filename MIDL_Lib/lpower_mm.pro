Function Lpower_mm, x, n

;+
; NAME:
;		POWER_MM
; VERSION:
;		5.4
; PURPOSE:
;		Calculating the power of whatever, multiplied by its logarithm..
; CATEGORY:
;		Mathematical
; CALLING SEQUENCE:
;		Result = POWER_MM( X, N)
; INPUTS:
;	X
;		The argument.  Numeric, otherwise arbitrary.
;	N
;		The exponent.  Numeric, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns ALOG(X)*X^N
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Serves for fitting purposes.  Calls FPU_FIX from MIDL.
; MODIFICATION HISTORY:
;		Created 20-MAY-2006 by Mati Meron.
;-

	on_error, 1
	return, FPU_fix(alog(x)*x^n)
end