Function Diagoarr, vec

;+
; NAME:
;		DIAGOARR
; VERSION
;		4.0
; PURPOSE:
;		Creates a diagonal square matrix with the elements of a given vector on
;		the diagonal.
; CATEGORY:
;		Array Manipulation.
; CALLING SEQUENCE:
;		Result = DIAGOARR(VEC)
; INPUTS:
;	VEC
;		Vector.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Return a square N*N (N is the vector's dimension) matrix, with the
;		elements of VEC on the diagonal and zeroes elsewhere.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calls TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 20-MAY-1993 by Mati Meron.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	n = n_elements(vec)
	arr = make_array(n, n, type = Type(vec))
	arr((n+1)*indgen(n)) = vec
	return, arr
end
