Function Matrix_fun, arr, fun, eps, params = pars

;+
; NAME:
;		MATRIX_FUN
; VERSION:
;		4.2
; PURPOSE:
;		Calculating an arbitrary function of a symmetric matrix.
; CATEGORY:
;		Matrix function.
; CALLING SEQUENCE:
;	Result = MATRIX_FUN( ARR, FUN [, EPS, PARAMS = PARS])
; INPUTS:
;	ARR
;		A numeric, real, symmetric matrix (i.e. a square array).
;	FUN
;		Character value representing an existing IDL function.  The function
;		must comply with the IDL standard of being able to accept an array
;		input and return an array output.  The calling sequence for the
;		function must be either
;			Result = FUN(x)
;		or
;			Result = FUN(x, extra)
;		where X is the variable and EXTRA may be any single entity (scalar,
;		array, structure etc.) used to pass additional parameters to the
;		function.
; OPTIONAL INPUT PARAMETERS:
;	EPS
;		Smallness parameter, defining maximal allowed relative deviation of ARR
;		from symmetricity.  Default value provided by the EPS field in IDL's
;		MACHAR
; KEYWORD PARAMETERS:
;	PARAMS
;		An arbitrary value or variable which is passed to the function FUN.
; OUTPUTS:
;		Returns FUN(ARR) where FUN is the provided function.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None other than possible restriction of the specific FUN used.
; PROCEDURE:
;		Diagonalizes ARR, performs the operation implied by FUN on the
;		diagonal elements, then transforms back to the original base.  Calls
;		CAST, DEFAULT, FPU_FIX, ISNUM, TOLER and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 20-OCT-2001 by Mati Meron.
;-

	on_error, 1

	siz = size(arr)
	if siz[0] ne 2 or siz[1] ne siz[2] then message, $
	'Not a matrix or not a square matrix!'
	if (not Isnum(arr,type=dtyp)) or Isnum(arr,/complex) then message, $
	'Input must be a REAL array'
	weps = Default(eps,2*Toler(type=dtyp))
	if max(abs(arr-transpose(arr))) gt weps*max(abs(arr)) then message, $
	'Not a symmetric array!'
	if Type(fun) ne 7 then message, 'Mising FUNCTION name!'

	tarr = double(arr)
	trired, tarr, diag, ofdiag, /double
	triql, diag, ofdiag, tarr, /double
	if n_elements(pars) eq 0 then fdiag = FPU_fix(call_function(fun,diag)) $
	else fdiag = FPU_fix(call_function(fun,diag,pars))

	return, Cast(transpose(tarr)##Diagoarr(fdiag)##tarr,4,dtyp,/fix)
end