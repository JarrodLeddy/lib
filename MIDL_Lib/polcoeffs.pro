Function Polcoeffs, x, y, svd = svd

;+
; NAME:
;		POL_COEFFS
; VERSION:
;		4.3
; PURPOSE:
;		Finding the coefficient of a polynomial.
; CATEGORY:
;		Mathematical, general.
; CALLING SEQUENCE:
;		Result = POL_COEFFS( X [, Y] [,/SVD])
; INPUTS:
;	X
;		Numeric, Either a vector (scalar is considered to be a vector of
;		length 1) or an [2,*] array.
; OPTIONAL INPUT PARAMETERS:
;	Y
;		Numeric, acceptable only when X is a vector, in which case Y has to be
;		a vector of same length.
;
;		Note:	Processing of the X and Y variables follows the same rules as
;				in the SPLIT_XY routine.  See there.
; KEYWORD PARAMETERS:
;	/SVD
;		Switch.  Specifies solution using the Singular Value Decomposition
;		method.  Default is LU decomposition.
; OUTPUTS:
;		Returns a vector of length N (where N is the length of the X and Y
;		inputs), containing the coefficients of the unique polynomial of order
;		N-1 passing through all the points.  The coefficients are in order from
;		lowest to highest.  If no input is given, returns zero.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Uses SPLIT_XY from MIDL to process the input and
;		SOLVE_LINSYS (also from MIDL) to find the coefficients.  ALSO calls
;		TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 10-AUG-2002 by Mati Meron.
;-

	on_error, 1

	n = Split_xy(x,y,x=wx,y=wy)
	if n gt 0 then begin
		tem = make_array(n,n,type=Type(wx))
		for i = 0l, n-1 do tem[*,i] = wx^i
		res = Solve_linsys(tem,wy,svd=svd)
	endif else res = 0.

	return, res
end