Function Angle_inc, x, y, absolute= abs, closed= clo, pad= pad, total_only= tot
;+
; NAME:
;		ANGLE_INC
; VERSION:
;		5.0
; PURPOSE:
;		Calculates the angle increments between segments of a polygonal line.
; CATEGORY:
;		Mathematical.
; CALLING SEQUENCE:
;		Result = ANGLE_INC( X [, Y] [, keywords])
; INPUTS:
;	X
;		Numeric vector or [2,N] array.  In the first case:
;			1)	If Y is given, X represents the X coordinates of the vertices.
;			2)	If Y is not given, X represents the Y coordinates and the X
;				coordinates are generated internally as [1, 2, ...N-1]
;		In the second case X represents both X and Y coordinates and Y should
;		not be given.
; OPTIONAL INPUT PARAMETERS:
;	Y
;		Numeric vector, optional when X given as vector, forbidden when X is a
;		[2,N] array.  Represents the Y coordinates.
; KEYWORD PARAMETERS:
;	/ABSOLUTE
;		Switch.  If set the absolute values of the angles are calculated.
;	/CLOSED
;		Switch.  If set, the shape is closed prior to calculation (unless it
;		is already closed.
;	/PAD
;		Switch.  If set and the shape is neither closed nor is /CLOSED invoked,
;		the result is padded with a leading and trailing zero to bring it to
;		length N.
;	/TOTAL_ONLY
;		Switch.  If set, only the sum of the angles is returned.
; OUTPUTS:
;		Returns the N-2 (or N, for a closed curve) external angles generated
;		by the vertices.  Note, the external angles are the angles by which
;		each segment deviates from the previous one.
;
;		If the shape isn't closed but /PAD is set, the result is of length N,
;		with the first and last term being zeroes.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The value of N (the vector length) must be >=3.  Also, if both X and Y
;		are given, they must be of same length.
; PROCEDURE:
;		Straightforward from the geometric definitions.  Calls CAST, DIF,
;		SIGN, SPLIT_XY and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 15-MAY-2001 by Mati Meron.
;		Modified 25-AUG-2005 by Mati Meron.  Added keyword PAD.
;-

	on_error, 1

	n = Split_xy(x,y,x=wx,y=wy,mint=5)
	if n ge 3 then begin
		clofl = wx[0] eq wx[n-1] and wy[0] eq wy[n-1]
		if clofl or keyword_set(clo) then begin
			wx = [wx,wx[clofl:1]]
			wy = [wy,wy[clofl:1]]
			padfl = 0
		endif else padfl = keyword_set(pad)
		dx = (Dif(wx,/cli))[1:*]
		dy = (Dif(wy,/cli))[1:*]
		norm = sqrt(dx^2 + dy^2)
		dx = dx/norm
		dy = dy/norm
		cosv = -1 > (shift(dx,1)*dx + dy*shift(dy,1))[1:*] < 1
		sinv = -1 > (shift(dx,1)*dy - dx*shift(dy,1))[1:*] < 1
		res = asin(sinv)
		dum = where(cosv lt 0, ndum)
		if ndum gt 0 then res[dum] = !dpi*Sign(res[dum]) - res[dum]
		if padfl then res = [0d,res,0d]
		if keyword_set (abs) then res = abs(res)
		if keyword_set(tot) then res = total(res)
	endif else message, 'At least 3 points are required!'

	return, Cast(res,4,Type(x))
end