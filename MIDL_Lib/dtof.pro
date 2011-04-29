Function DtoF, x, ignore = ign

;+
; NAME:
;		DTOF
; VERSION:
;		4.5
; PURPOSE:
;		Scales down magnitude of DOUBLE type numbers to fit within the size
;		limit for FLOAT type.
; CATEGORY:
;		Utility function.
; CALLING SEQUENCE:
;		Result = DTOF(X)
; INPUTS:
;	X
;		Numerical, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/IGNORE
;		Switch.  When set, DTOF returns the input doing nothing.
; OUTPUTS:
;		For an input of type DOUBLE (including DCOMPLEX) DTOF eturns the input,
;		with all entries whose magnitude is larger than the machine maximum (for
;		FLOAT type) replaced by the machine maximum (with the appropriate sign.
;		If the input is DCOMPLEX, the operation is performed separately on the
;		real and imaginary parts.
;		Any other numeric input is returned unchanged.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None, other than the input has to be numeric.
; PROCEDURE:
;		Straightforward.  Calls IMAGINARY_MM, ISNUM, REAL_MM and SIGN from MIDL.
;		Also calls itself recursively.
; MODIFICATION HISTORY:
;		Created 25-JAN-2004 by Mati Meron.
;-

	on_error, 1

	if Isnum(x) then begin
		res = x
		if Isnum(x,/double) and not keyword_set(ign) then begin
			if not Isnum(x,/complex) then begin
				xmax = (machar()).xmax
				dum = where(abs(res) gt xmax, ndum)
				if ndum gt 0 then res[dum] = xmax*Sign(res[dum])
			endif else res = dcomplex(DtoF(Real_mm(x)),DtoF(Imaginary_mm(x)))
		endif
	endif else message, 'Not numeric!'

	return, res
end