Function Power_mm, x, n

;+
; NAME:
;		POWER_MM
; VERSION:
;		4.2
; PURPOSE:
;		Calculating the power of whatever, named replacement for ^.
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
;		Returns X^N.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Serves as replacement for the ususal X^N in cases
;		where a "named function" is needed.  Calls FPU_FIX from MIDL.
; MODIFICATION HISTORY:
;		Created 20-OCT-2001 by Mati Meron.
;-

	on_error, 1
	return, FPU_fix(x^n)
end