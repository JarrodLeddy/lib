Function FPU_fix, x, no_abs = nab

;+
; NAME:
;		FPU_FIX
; VERSION:
;		4.0
; PURPOSE:
;		Clears Floating Point Underflow errors, setting the offending values to
;		zero.
; CATEGORY:
;		Programming.
; CALLING SEQUENCE:
;		Result = FPU_FIX( X)
; INPUTS:
;	X
;		Arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/NO_ABS
;		Switch.  If set, uses value instead of absolute value for comparison
;		with machine minimum.  For internal use only.
; OUTPUTS:
;		If the input is of any numeric type, returns the input, with the
;		possible substitution of 0 for all occurences of Floating Point
;		Underflow.  A non-numeric input is returned as is.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Uses the system routines CHECK_MATH and MACHAR.  Also
;		calls ABS_MM and ISNUM from MIDL.
; MODIFICATION HISTORY:
;		Created 30-AUG-1998 by Mati Meron.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1

	chem = check_math(mask=32)
	if Isnum(x,type = typ) and chem gt 0 then begin
		sinf = machar(double = Isnum(x,/double))
		if keyword_set(nab) then dum = where(x lt sinf.xmin, nuf) $
		else dum = where(Abs_mm(x) lt sinf.xmin, nuf)
		if nuf gt 0 then x[dum] = 0
	endif
	chem = check_math(mask=32)

	return, x
end
