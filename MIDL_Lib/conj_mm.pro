Function Conj_mm, x

;+
; NAME:
;		CONJ_MM
; VERSION:
;		4.0
; PURPOSE:
;		Returns complex conjugate values.
; CATEGORY:
;		Mathematical, general.
; CALLING SEQUENCE:
;		Result = CONJ_MM (X)
; INPUTS:
;	X
;		Numerical, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the complex conjugate of the input, if the input is complex,
;		else returns the input.  The only difference from the RSI function CONJ
;		is that the output of CONJ_MM is always of the same numerical type as
;		the input.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calling CAST and ISNUM from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUL-2000 by Mati Meron.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	if not Isnum(x, type = typ) then message, 'Not numeric!"

	return, Cast(conj(x),typ,typ,/fix)
end
