Function Sincterpol, x, y, xint = xint, norm = norm

;+
; NAME:
;		SINCTERPOL
; VERSION:
;		4.3
; PURPOSE:
;		Performs sinc interpolation on data.
; CATEGORY:
;		Mathematical.
; CALLING SEQUENCE:
;		Result = SINCTERPOL( X, Y, XINT = XINT [, /NORM])
; INPUTS:
;	X
;		Numeric, Either a vector (scalar is considered to be a vector of
;		length 1) or an [2,*] array (can also be [3,*] array, the 3-rd column
;		will be ignored in such case).
; OPTIONAL INPUT PARAMETERS:
;	Y
;		Numeric, acceptable only when X is a vector, in which case Y has to be
;		a vector of same length.
; KEYWORD PARAMETERS:
;	XINT
;		A value or set of values for which the interpolation is required.
;	/NORM
;		Switch.  See SINCTRAN for description.
; OUTPUTS:
;		Returns the interpolated values corresponding to the values of XINT,
;		in the same format in which XINT is given.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calls CALCTYPE, DIF, FPU_FIX, LINFIT_MM, POLEVAL,
;		SINCTRAN, SOLVE_LINSYS, SPLIT_XY and TOLER
;		From MIDL.
; MODIFICATION HISTORY:
;		Created 15-SEP-2002 by Mati Meron.
;-

	on_error, 1

	n = Split_xy(x,y,x=wx,y=wy)
	if n le 1 then message, 'At least 2 points required!'
	typ = Calctype(wx,wy) > 4
	chk = Dif(wx,2,/clip)
	if max(abs(chk)) gt 4*Toler(typ)*max(abs(wx)) then begin
		tx = wx
		k = make_array(n,typ=typ,/ind)
		cof = Linfit_mm(k,tx)
		wx = Poleval(k,cof)
		tem = Sinctran(wx,tx,norm=norm)
		wy = Solve_linsys(tem,wy,/row)
	endif
	res = Sinctran(wx,xint,norm=norm)##wy
	xsiz = size(xint)
	if xsiz[0] ne 0 then res = reform(res,xsiz[1:xsiz[0]])
	stop

	return, FPU_fix(res)
end

