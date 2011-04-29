Function Chebyshev_pol, x, n, associated = aso

;+
; NAME:
;		CHEBYSHEV_POL
; VERSION:
;		4.0
; PURPOSE:
;		Calculates Chebyshev polynomials Tn and associated functions.
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = CHEBYSHEV_POL( X, N, [ /ASSOCIATED])
; INPUTS:
;	X
;		Numeric, absolute values must be <= 1, otherwise arbitrary.
;	N
;		Nonnegative scalar, rounded to integer on input.  Defaults to 0.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/ASSOCIATED
;		Switch.  When set, an associated function, SIN(N*ARCCOS(X)) is returned.
; OUTPUTS:
;		Returns the values of the Chebyshev polynomial T(n,x), defined as
;		COS(N*ARCCOS(X)) or (when ASSOCIATED is set), the values of the
;		associated Chebyshev function, SIN(N*ARCCOS(X)).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None other then the restrictions on X, and N as mentioned above.
; PROCEDURE:
;		Using the mathematical definition.  Calling DEFAULT and FPU_FIX from
;		MIDL.
; MODIFICATION HISTORY:
;		Created 20-DEC-1994 by Mati Meron.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	wn = Default(n,0l,/dtype)

	if wn lt 0 then message, 'N must be nonnegative!'
	if max(abs(x)) gt 1 then message, 'Absolute value of X must be <=1 !'

	if keyword_set(aso) then return, FPU_fix(sin(wn*acos(x))) $
	else return, FPU_fix(cos(wn*acos(x)))
end
