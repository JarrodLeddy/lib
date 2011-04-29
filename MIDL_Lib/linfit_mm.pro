Function Linfit_mm, x, y, w, order = nord, residual = resid, error = erf, $
	base = bas, params = pars, parmask = pmsk, $
	factor = fact, fpower = fpow, fparam = fpar

;+
; NAME:
;		LINFIT_MM
; VERSION:
;		4.3
; PURPOSE:
;		Linear fitting with an arbitrary number of parameters.
; CATEGORY:
;		Mathematical Function.
; CALLING SEQUENCE:
;		Result = LINFIT_MM( X, Y [,W] [, keywords])
; INPUTS:
;	X
;		Numeric vector.  X coordinates of the data.
;	Y
;		Numeric vector.  Y coordinates of the data.  Same length as X.
; OPTIONAL INPUT PARAMETERS:
;	W
;		Numeric scalar or vector.  Weight parameter(s).  If given as scalar,
;		the scalar weight is applied to all the points.  If given as vector,
;		must be same length as X.  Default is constant weight (1).
;
;		Note:	The standard statistical weight is 1/sigma, not 1/sigma^2.
; KEYWORD PARAMETERS:
;	ORDER
;		Specifies the order of the fit, i.e. one less than the number of free
;		parameters (or base functions).  If not given, the order will be read
;		from the number of entries in the BASE variable (see below).  If both
;		ORDER and BASE are specified, the higher one will determine the order.
;		Finally, if neither is specified, ORDER is set to 1 (meaning linear fit)
;	RESIDUAL
;		Optional output, see below.
;	ERROR
;		Optional output, see below.
;	BASE
;		Character array containing names of base functions.  Any blank entry
;		will be replaced by a power of X.  For example, if the third entry
;		(i = 2) is blank (or null string) the third base function will be X^2.
;	PARAMS
;		Array containing optional parameters (one per function) to be used in
;		the function calls.
;	PARMASK
;		Parameter mask, specifies which of the parameters are to be used.  A
;		nonzero entry means USE, zero means DON'T USE.  Default is USE for all
;		existing parameters.
;	FACTOR
;		Optional factor function, i.e. a function multiplying all the base
;		functions.  If given as a character value, the value is taken to
;		represent the function name.  If given as a number, the common factor
;		used is X^FACTOR.
;	FPOWER
;		If given as a numeric value and a function name is provided in FACTOR,
;		the function is raised to the power of FPOWER.
;	FPARAM
;		Used to pass an optional parameter to a function specified in FACTOR,
;		in the same way that PARAMS passes parameters to the base functions.
; OUTPUTS:
;		Returns a vector containing the fit coefficients.
; OPTIONAL OUTPUT PARAMETERS:
;	RESIDUAL
;		The name of the variable to receive the residual Chi-Square value,
;		normalized to the number of degrees of freedom.  If the number of
;		points is <= the number of parameters, such calculation is impossible,
;		of course, and RESIDUAL returns machine maximum.
;	ERROR
;		The name of the variable to receive the statistical errors of the fit
;		cofficients.  Returns a vector of same length as the output vector.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Standard linear optimization, using a Singular Value Decomposition
;		procedure to solve the linear system.  Uses DEFAULT, FPU_FIX, ISNUM,
;		SOLVE_LINSYS and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 1-JUN-93 by Mati Meron.
;		Renamed from LINFIT to M_LINFIT to avoid clashes with an IDL library
;		routine bearing the same name.
;		Modified 20-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Renamed 25-SEP-1999 by Mati Meron, to LINFIT_MM.
;		Modified 30-MAY-2000, to enable handling the case of
;		N_points = N_parameters (i.e. Degrees_of_freedom = 0).
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;		Modified 25-OCT-2001 by Mati Meron.  Added keyword ERROR.
;		Modified 20-NOV-2001 by Mati Meron.  Added keywords FACTOR, FPOWER
;		and FPARAM.
;-

	on_error, 1
	nv = n_elements(x)
	if n_elements(y) ne nv then message, 'X ,Y lengths must be equal!'
	wei = Default(w,1.,/dtype)
	if n_elements(wei) eq 1 then wei = replicate(wei,nv) else $
	if n_elements(wei) ne nv then message, 'X ,W lengths must be equal!'
	sinf = machar(double = (Isnum(x,/dou,typ=xtyp) or Isnum(y,/dou,type=ytyp)))

	nord = Default(nord,1)
	bas = Default(bas, strarr(nord + 1))
	if Type(bas) ne 7 then message, 'Function names must be strings!'
	nbas = n_elements(bas)
	if nord gt (nbas-1) then begin
		bas = [bas,strarr(nord-nbas+1)]
		nbas = nord + 1
	endif else nord = nbas - 1
	bmsk = strtrim(bas) ne ''

	npars = n_elements(pars) < nbas
	if npars gt 0 then begin
		pmsk = Default(pmsk,replicate(1,npars)) ne 0
		npmsk = n_elements(pmsk) < npars
		if npmsk lt nbas then pmsk = [pmsk,replicate(0,nbas-npmsk)]
	endif else pmsk = replicate(0,nbas)

	if n_elements(fact) ne 0 then begin
		if not Isnum(fact) then begin
			if n_elements(fpar) ne 0 then mfac = call_function(fact,x,fpar) $
			else mfac = call_function(fact,x)
			if Isnum(fpow) then mfac = mfac^fpow
		endif else mfac = x^fact
		fafl = 1
	endif else fafl = 0

	farr = make_array(nv, nord + 1, type = Calctype(x,y,1.,/strict))
	for i = 0l, nord do begin
		if bmsk[i] then begin
			if pmsk[i] then farr(*,i) = call_function(bas[i],x,pars[i]) $
			else farr[*,i] = call_function(bas[i],x)
		endif else farr[*,i] = x^i
		if fafl then farr[*,i] = farr[*,i]*mfac
		farr[*,i] = FPU_fix(farr[*,i]*wei)
	endfor
	yw = FPU_fix(y*wei)

	if nord eq 0 then res = [total(farr*yw)/total(farr^2)] $
	else res = Solve_linsys(farr,yw,/svd)
	if nv le nbas then begin
		resid = sinf.xmax
		erf = replicate(resid,nbas)
	endif else begin
		resid = FPU_fix(total((yw - farr#res)^2)/(nv - nbas))
		erf = sqrt(resid/Diagovec(farr##transpose(farr)))
	endelse

	return, res
end