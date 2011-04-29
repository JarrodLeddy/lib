Function Voup, u, v

;+
; NAME:
;		VOUP
; VERSION:
;		4.0
; PURPOSE:
;		Finds the outer product of two vectors.
; CATEGORY:
;		Geometry, General.
; CALLING SEQUENCE:
;		Result = VOUP ( U, V)
; INPUTS:
;	U, V
;		Vectors, numeric, otherwise arbitrary.  Scalars accepted as vectors of
;		length 1.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the outer product in Type FLOAT or higher.  for U of length M
;		and V of length N, the outer product is an array of dimension (M,N).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Uses CAST, FPU_FIX and ISNUM from MIDL.
;		Works also with complex vectors.
; MODIFICATION HISTORY:
;		Created 10-NOV-1997 by Mati Meron.
;		Modified 10-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	if not (Isnum(u) and Isnum(v)) then message, 'Not numeric vectors!'

	ru = Cast(reform([u]),4)
	rv = Cast(reform([v]),4)
	siu = size(ru)
	siv = size(rv)

	if siu[0] ne 1 or siv[0] ne 1 then message, 'Inputs must be vectors' $
	else if Isnum(ru,/com) or Isnum(rv,/com) then rv = conj(rv)

	return, FPU_fix(ru#transpose(rv))
end
