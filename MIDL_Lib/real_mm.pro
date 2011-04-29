Function Real_mm, x

;+
; NAME:
;		REAL_MM
; VERSION:
;		4.0
; PURPOSE:
;		Returns real values.
; CATEGORY:
;		Mathematical, general.
; CALLING SEQUENCE:
;		Result = REAL_MM (X)
; INPUTS:
;	X
;		Numerical, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the real value of the input, i.e. the input itself if its real
;		the real part in FLOAT format for COMPLEX and the real part in DOUBLE
;		format for DCOMPLEX.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calling CAST, FPU_FIX and ISNUM from MIDL.
; MODIFICATION HISTORY:
;		Created 5-MAY-1996 by Mati Meron as M_REAL.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Renamed 25-SEP-1999 by Mati Meron, to REAL_MM.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	if not Isnum(x) then message, 'Not numeric!"

	if Isnum(x, /complex, typ= xtyp) then return, FPU_fix(Cast(x,4,xtyp/2+ 1)) $
	else return, FPU_fix(x)
end
