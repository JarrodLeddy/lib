Function Vinp, u, v

;+
; NAME:
;		VINP
; VERSION:
;		4.0
; PURPOSE:
;		Finds the scalar product of two vectors.
; CATEGORY:
;		Geometry, General.
; CALLING SEQUENCE:
;		Result = VINP ( U, V)
; INPUTS:
;	U, V
;		Vectors, numeric, of same length, otherwise arbitrary.  Scalars
;		accepted as vectors of length 1.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the value of the scalar product, in Type FLOAT or higher.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		Vectors must have same length.
; PROCEDURE:
;		Straightforward.  Uses CAST, FPU_FIX and ISNUM from MIDL.
;		Works also with complex vectors.
; MODIFICATION HISTORY:
;		Created 30-JUN-1992 by Mati Meron.
;		Modified and added to MIDL on 5-NOV-1997, by Mati Meron.
;		Modified on 10-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	if not (Isnum(u) and Isnum(v)) then message, 'Not numeric vectors!'

	ru = Cast(reform([u]),4)
	rv = Cast(reform([v]),4)
	siu = size(ru)
	siv = size(rv)

	if siu(0) eq 1 and siv(0) eq 1 then begin
		if n_elements(ru) ne n_elements(rv) then message, 'Unequal lengths!' $
		else if Isnum(ru,/com) or Isnum(rv,/com) then ru = conj(ru)
	endif else message, 'Inputs must be vectors'

	return, FPU_fix((transpose(ru)#rv)(0))
end
