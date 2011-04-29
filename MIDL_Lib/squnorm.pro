Function Squnorm, x, n

;+
; NAME:
;		SQUNORM
; VERSION:
;		4.0
; PURPOSE:
;		Calculates a "flattened" Gaussian.  See definition below.
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = SQUNORM( X, N)
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
;		Returns the values of a "flattened" Gaussian, defined by
;
;		SQUNORM(X,N) = C*exp(-X^2/(2*D^2))*sum_(0 to N)((X^2/(2*D^2))^K)/K!
;
;		Where the constants C, D, given by:
;
;			C = sqrt((2*N+3)/(6*PI))*2^(2*N)*(N!)^2/(2*N+1)!
;
;			D = sqrt(3/(2*N+3))
;
;		are chosen so as to make the integral and the variance of the function
;		equal 1 (especially for N=0 the standard Normal distribution is
;		obtained).
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
;		Calculates the mormalization constants and calls SQUNEXP.  Also calls
;		CAST, DEFAULT and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 25-OCT-1995 by Mati Meron.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	typ = Type(x)
	n = Default(n,0l,/dtype)
	ecoef = n/3d + 0.5d
	coef = sqrt(ecoef/!dpi)
	for i = 1l, n do coef = coef/(1d + 0.5d/i)

	return, FPU_fix(Cast(coef*Squnexp(ecoef*x^2,n),4,typ,/fix))
end
