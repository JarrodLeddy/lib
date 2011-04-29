Function Sp_Besely, x, n

;+
; NAME:
;		SP_BESELY
; VERSION:
;		4.0
; PURPOSE:
;		Calculates spherical Bessel functions of the first kind, y_n(x).
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = SP_BESELY( X, N)
; INPUTS:
;	X
;		Numeric, otherwise arbitrary.
;	N
;		Nonnegative scalar.  Should be integer (if not then rounded downwards
;		to an integer on input.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the values of the spherical Bessel function y_n(x), which is
;		related to the standard Bessel function Y by
;			y_n(x) = sqrt(pi/(2*x))*Y_(n+1/2) (x)
;		The result is of the same form and type as the input (but no lower then
;		FLOAT.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None other than the restriction on N mentioned above.
; PROCEDURE:
;		Recursion, using calculated values of y_0 and y_1.
;		Calls CAST and ISNUM from MIDL.
; MODIFICATION HISTORY:
;		Created 5-SEP-1995 by Mati Meron.
;		Modified 20-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	if n_elements(n) eq 0 then message, 'missing N!'
	if n lt 0 then message, 'N must be nonnegative!'
	nn = floor(n)

	if Isnum(x,/complex,typ=xtyp) then ztyp = 9 $
	else if Isnum(x) then ztyp = 5 $
	else message, 'Non numeric input!'
	z = Cast(x,ztyp)

	case nn of
		0	:	res = -cos(z)/z
		1	:	res = -(cos(z) + z*sin(z))/z^2
		else:	begin
					w2 = 0d*z
					w1 = w2 + 1
					for i = nn-1, 1, -1 do begin
						w0 = ((2*i + 1)*w1 - z*w2)/z
						w2 = w1
						w1 = w0
					endfor
					y0 = -cos(z)/z
					y1 = -(cos(z) + z*sin(z))/z^2
					res = w1*y1 - w2*y0
				end
	endcase

	return, Cast(res,4,xtyp,/fix)
end
