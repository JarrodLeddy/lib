Function Squnexp, x, n

;+
; NAME:
;		SQUNEXP
; VERSION:
;		4.0
; PURPOSE:
;		Calculates a "flattened" exponent.  See definition below.
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = SQUNEXP( X, N)
; INPUTS:
;	X
;		Numeric, otherwise arbitrary.  However, negative inputs may create
;		overflows and/or divergences.
;	N
;		Nonnegative scalar.  Should be integer (if not then rounded downwards
;		to an integer on input.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the values of a "flattened negative exponent, defined by
;
;			SQUNEXP(X,N) = exp(-X)*sum_(0 to N)(X^K)/K!
;
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
;		Clenshaw recursion with renormalization.
;		Calls CAST and ISNUM from MIDL.
; MODIFICATION HISTORY:
;		Created 25-OCT-1995 by Mati Meron.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	if n_elements(n) eq 0 then message, 'missing N!'
	if n lt 0 then message, 'N must be nonnegative!'
	nn = floor(n)

	if Isnum(x, /complex, type = xtyp) then ztyp = 9 else ztyp = 5
	z = Cast(x,ztyp)

	case nn of
		0	:	res = exp(-z)
		1	:	res = exp(-z + alog(1 + z))
		else:	begin
					lf = -z + alog(1 + z)
					w2 = 0
					for i = nn-1, 1, -1 do begin
						w0 = 1 + z/(i + 1) - z/(i + 2)*w2
						lf = lf + alog(w0)
						w2 = 1/w0
					endfor
					res = (1 - 0.5*w2*z/(1 + z))*exp(lf)
				end
	endcase

	return, Cast(res,4,xtyp,/fix)
end
