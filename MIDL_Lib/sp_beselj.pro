Function Sp_Beselj, x, n

;+
; NAME:
;		SP_BESELJ
; VERSION:
;		4.0
; PURPOSE:
;		Calculates spherical Bessel functions of the first kind, j_n(x).
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = SP_BESELJ( X, N)
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
;		Returns the values of the spherical Bessel function j_n(x), which is
;		related to the standard Bessel function J by
;			j_n(x) = sqrt(pi/(2*x))*J_(n+1/2) (x)
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
;		Uses a combination of modified series expansion (for small values of X
;		and recursion for large X.  The transition between the two regions
;		occurs in the vicinity of |X| ~ N.
;		Warning:  for large values of N small inaccuracies may occur in the
;		vicinity of the transition region.  These are usually to small to be
;		noticed, though.
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
	dum = machar(/double)
	eps = sqrt(dum.xmin)

	zetem = where(abs(z) le eps, zenum)
	nztem = where(abs(z) gt eps, nznum)
	if nznum gt 0 then zz = z[nztem]
	res = 0*z

	case nn of
		0	:	begin
					if zenum gt 0 then res[zetem] = Cast(1,ztyp)
					if nznum gt 0 then res[nztem] = sin(zz)/zz
				end
		1	:	begin
					if zenum gt 0 then res[zetem] = Cast(0,ztyp)
					if nznum gt 0 then res[nztem] = (sin(zz) - zz*cos(zz))/zz^2
				end
		else:	begin
					eps = 0.895*nn*(4*sqrt(dum.eps)/nn)^(1./(nn+2))
					zetem = where(abs(z) le eps, zenum)
					nztem = where(abs(z) gt eps, nznum)
					if zenum gt 0 then begin
						zz = z[zetem]
						res[zetem] = 1d
						for i = 1l, nn do res[zetem] = res[zetem]*zz/(2*i + 1)
						zzs = zz^2/(4*nn + 6)
						res[zetem] = res[zetem]*exp(-zzs*(1d + zzs/(2*nn +5)))
					endif
					if nznum gt 0 then begin
						zz = z[nztem]
						w2 = 0d*zz
						w1 = w2 + 1
						for i = nn-1, 1, -1 do begin
							w0 = ((2*i + 1)*w1 - zz*w2)/zz
							w2 = w1
				 			w1 = w0
						endfor
						j0 = sin(zz)/zz
						j1 = (sin(zz) - zz*cos(zz))/zz^2
						res[nztem] = w1*j1 - w2*j0
					endif
				end
    endcase

	return, Cast(res,4,xtyp,/fix)
end
