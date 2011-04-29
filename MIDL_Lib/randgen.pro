Function Randgen, seed, len, distribution = dfun, params = par, compars = cpar,$
	integer = int, inform = inf

;+
; NAME:
;		RANDGEN
; VERSION:
;		4.3
; PURPOSE:
;		Generating arbitrary random distributions.
; CATEGORY:
;		Mathematical, general.
; CALLING SEQUENCE:
;		Result = RANDGEN (SEED [, LEN], DISTRIBUTION = DFUN [, keywords])
; INPUTS:
;	SEED
;		A named variable containing the seed value for random number generation.
;		Does not need to be defined prior to call.  For details see IDL
;		routines RANDOMN and RANDOMU.
; OPTIONAL INPUT PARAMETERS:
;	LEN
;		The length of the random vector to be generated.  Default value is 1.
; KEYWORD PARAMETERS:
;	DISTRIBUTION
;		Character value, name of an existing IDL function, representing the
;		desired distribution.  The function must comply with the IDL standard
;		of being able to accept an array input and return an array output.  The
;		calling sequence for the function must be either
;
;			Result = DISTRIBUTION( X)
;		or
;			Result = DISTRIBUTION( X, extra)
;
;		where X is the variable and EXTRA may be any single entity (scalar,
;		array, structure etc.) used to pass additional parameters to the
;		function (see PARAMS, below).
;
;		The function doesn't have to be normalized but should be non-negative.
;		Negative values are treated as zero.
;	PARAMS
;		An arbitrary value or variable which is being passed to the function
;		DISTRIBUTION.  May be an array or structure.
;	COMPARS
;		Parameters for the "comparison function".  This function is of the form:
;
;			F = c/(b^2 + (x-a)^2)
;
;		and the parameters are provided as a 3-element vector, [a,b,c].  It is
;		possible to provide partial or no data.  The default values for compars
;		are
;			[0,1,1/pi]
;
;		If partial data is provided, the remainder is filled, in order, from
;		the list above.  Thus, if a call to RANDGEN includes COMPARS = [3,2]
;		the the set used internally will be [3,2,1/pi]
;	/INTEGER
;		Switch.  If set, the result is a set of randomly distributed integers.
;	/INFORM
;		Switch.  If set, teh routine prints an informational message when the
;		internal normalization parameters change.
; OUTPUTS:
;		Returns a vector (length LEN) of values, randomly distributed according
;		to DISTRIBUTION.  If the keyword /INTEGER is set, the result is of type
;		LONG, else it is of type FLOAT or DOUBLE (when either PARAMS or COMPARS
;		are DOUBLE).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses the "rejection method" as outlined in Numerical Recipes.  Calls
;		CALCTYPE, DEFAULT, FPU_FIX and TOLER from MIDL.
; MODIFICATION HISTORY:
;		Created 10-JAN-2002 by Mati Meron.
;-

	on_error, 1

	damp = 1./!pi
	wpar = Default(cpar,0.,lo=4)
	if n_elements(wpar) eq 1 then wpar = [wpar,1.,damp] else $
	if n_elements(wpar) eq 2 then wpar = [wpar,damp]
	parfl = n_elements(par) gt 0
	intfl = keyword_set(int)
	inffl = keyword_set(inf)
	if intfl then rtyp = 3 else rtyp = Calctype(par,wpar,/default) < 5

	ndo = Default(len,1l,/dtyp) >1l
	res = make_array(ndo,type=rtyp)
	repeat begin
		rlen = ceil(wpar[2]/damp*ndo/wpar[1])
		ran = randomu(seed,rlen) > Toler()
		tem = wpar[0] + wpar[1]*tan(!pi*(ran - 0.5))
		if intfl then tem = floor(tem)
		if parfl then dvals = FPU_fix(call_function(dfun,tem,par)) $
		else dvals = FPU_fix(call_function(dfun,tem))
		cvals = wpar[2]/(wpar[1]^2 + (tem-wpar[0])^2)
		rat = dvals/cvals
		mrat = max(rat)
		if mrat gt 1 then begin
			mult = mrat*(1 + 1./ndo)
			wpar[2] = wpar[2]*mult
			rat = rat/mult
			if inffl then print, 'Amplitude multiplied by ' + $
			string(mult, form = '(g12.5)')
		endif
		ran = randomu(seed,rlen)
		dum = where(ran le rat, ndum)
		if ndum gt 0 then begin
			res[(ndo-ndum)>0:ndo-1] = (tem[dum])[(ndum-ndo)>0:ndum-1]
			ndo = (ndo - ndum) > 0
		endif
	endrep until ndo eq 0

	return, FPU_fix(res)
end