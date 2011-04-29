Function Sign, x, nozero = noz

;+
; NAME:
;		SIGN
; VERSION:
;		4.1
; PURPOSE:
;		Gives the sign of X, i.e. 1 for positive, -1 for negative, 0 for 0.
; CATEGORY:
;		Mathematical Function (General).
; CALLING SEQUENCE:
;		Result = SIGN(X)
; INPUTS:
;	X
;		Numerical, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/NOZERO
;		Switch.  If set, 0 is considered positive, i.e. Sign(0) = 1
; OUTPUTS:
;		Returns the value of SIGN(X), see above, as an long integer.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		For complex X the result is SIGN(REAL(X)), the imaginary part is ignored
; PROCEDURE:
;		Straightforward.  Using CAST from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Modified 25-DEC-1991 by Mati Meron.
;		Modified 5-DEC-1993 by Mati Meron.  Output type changed to LONG.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;		Modified 1-MAY-2002 by Mati Meron.  Added keyword NOZERO.
;-

	temx = Cast(x,1,5)
	if keyword_set(noz) then res = long((temx ge 0)) - (temx lt 0) $
	else res = long((temx gt 0)) - (temx lt 0)

	return, res
end
