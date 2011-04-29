Function Diagovec, arr

;+
; NAME:
;		DIAGOVEC
; VERSION:
;		4.0
; PURPOSE:
;		Extracts the diagonal of a square matrix as a vector.
; CATEGORY:
;		Array Manipulation.
; CALLING SEQUENCE:
;		Result = DIAGOVEC(ARR)
; INPUTS:
;	ARR
;		Array, 2-dimensional, square (a scalar is considered a 1*1 matrix).
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		If ARR is a square matrix, returns the diagonal as a vector, else
;		generates an error message.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.
; MODIFICATION HISTORY:
;		Created 20-DEC-1991 by Mati Meron.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;		Modified 25-NOV-2001 by Mati Meron.  Added scalar handling capability.
;-

	on_error, 1
	if n_elements(arr) gt 1 then begin
		siz = size(arr)
		if siz[0] ne 2 then message, 'Not a matrix!' else $
		if siz[1] ne siz[2] then message, 'Not a square matrix!' else $
		res = arr((siz[1] + 1)*indgen(siz[1]))
	endif else res = reform([arr])

	return, res
end
