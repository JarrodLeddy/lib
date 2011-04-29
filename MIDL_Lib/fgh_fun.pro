Function FGH_fun, fun, x, params= par, sumsq= ssq, yvals= yvl, weights= wei,$
	grad = grd, hess = hes, _extra = _e

;+
; NAME:
;		FGH_FUN
; VERSION:
;		4.5
; PURPOSE:
;		Function evaluation in support of FGH_EXT.
; CATEGORY:
;		Mathematical, utility function, not to be used directly.
; CALLING SEQUENCE:
;		Result = FGH_FUN( FUN, X [keywords])
; INPUTS:
;;	FUN
;		Character value representing an existing IDL function.  Depending on
;		the setting of the keyword SUMSQ (see below), the function must satisfy
;		the following requirements:
;
;		SUMSQ not set:
;
;		1)	Accept vector input X and return scalar value.
;		2)	Provide two optional outputs , through keywords, as follows:
;			a)	Keyword GRAD, returning the gradient of FUN as a vector of
;				same dimensionality as the input.
;			b)	Keyword HESS, returning the Hessian matrix of FUN, as a square
;				matrix, dimensionality same is input along each dimension.
;
;		SUMSQ set:
;
;		1)	Accept vector input X (size N) and return a vector output (size M).
;			M and N can be 1 as special case.
;		2)	Provide two optional outputs , through keywords, as follows:
;			a)	Keyword GRAD, returning the gradient of FUN as an array of size
;				[M,N].
;			b)	Keyword HESS, returning the Hessian matrix of FUN, as an array
;				of size [M,N,N].
;
;		In addition FUN may accept one additional input (beyond X) of
;		arbitrary form, and an unlimited number of keywords (beyond GRAD and
;		HESS).  Thus the general from of the FUN defining line should be
;
;		Function FUN, X [, PAR], GRAD = GRD, HESS = HES [, extra keywords]
;
;	X
;		Numeric vector, function input.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	PARAMS
;		An arbitrary optional value or variable which is passed to the function
;		FUN.  No restrictions on type and form and no checking is done.
;	/SUMSQ
;		Switch.  Determines operating mode.  See in PROCEDURE, below.
;	YVL
;		Numeric vector, used only when SUMSQ is set.  Details in PROCEDURE,
;		below.  If provided, must be of same dimensionality as the output of
;		FUN.  Defaults to 0.
;	WEIGHTS
;		Numeric vector, used only when SUMSQ is set.  Details in PROCEDURE,
;		below.  If provided, must be of same dimensionality as the output of
;		FUN.  Defaults to 1.
;	GRAD
;		Optional output, see below.
;	HESS
;		Optional output, see below.
;	_EXTRA
;		A formal keyword used to additional keywords to FUN.  Not to be used
;		directly.
; OUTPUTS:
;		Returns the calculated value as scalar (always).  Details in PROCEDURE,
;		below.
; OPTIONAL OUTPUT PARAMETERS:
;	GRAD
;		Returns the gradient of the result, with respect to X, as a vector of
;		length N = N_ELEMENTS(X)
;	HESS
;		Returns the Hessian matrix of the result (with respect to X) as a
;		square [N,N] matrix.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Depending on the setting of the keyword SUMSQ.
;
;		SUMSQ set:
;
;		In this case F, the output of FUN is expected to be a vector of length
;		M (which in general has nothing to do with the length of X, i.e. N).
;		G, the gradient of FUN, is an [M,N] array and H, the Hessian of FUN is
;		an [M,N,N] array.  The output of FGH_FUN is then generated from F as
;
;			Result = SUM{i=0,M-1} (W[i]*(F[i] - YVL[i])^2)/2
;
;		where W[i] = WEIGHTS[i].  The GRAD output (if required) is generated
;		from F and G as
;
;			GRAD = SUM{i=0,M-1} (W[i]*(F[i] - YVL[i])*G[i,*])
;
;		Finally, the HESS output, (if required) is generated FROM F, G and H as
;
;			HESS= SUM{i=0,M-1}(W[i]*((F[i] - YVL[i])*H[i,*,*] + G[i,*]^T*G[i,*])
;
;		where G[i,*]^T is the transpose of G[i,*]
;
;		SUMSQ not set:
;
;		In this case FGH_FUN simply executes CALL_FUNCTION with FUN and returns
;		the result F (and, if required, G and H) with no further processing.
;		gradient direction from the previous step.
;		Calls FPU_FIX and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 10-DEC-2003 by Mati Meron.
;-

	on_error, 1

	pfl = Type(par) ne 0
	ffl = arg_present(grd) or arg_present(hes)
	case pfl + 2*ffl of
		0	:	f = call_function(fun,x,_extra=_e)
		1	:	f = call_function(fun,x,par,_extra=_e)
		2	:	f = call_function(fun,x,grad=g,hess=h,_extra=_e)
		3	:	f = call_function(fun,x,par,grad=g,hess=h,_extra=_e)
	endcase

	if keyword_set(ssq) then begin
		nf = n_elements(f)
		if n_elements(yvl) eq 0 then yvl = replicate(0.,nf) $
		else if n_elements(yvl) ne nf then message, 'Yvals number mismatch!'
		if n_elements(wei) eq 0 then wei = replicate(1.,nf) $
		else if n_elements(wei) ne nf then message, 'Weights number mismatch!'
		wein = wei/total(wei)

		df = f - yvl
		wdf = [wein*df]
		fnc = (transpose(wdf)#df)/2
		if ffl then begin
			nx = n_elements(x)
			grd = reform(transpose(wdf)#g)
			hes = make_array(nx,nx,type=Type(h))
			for i = 0l, nf-1 do $
			hes = hes + wdf[i]*h[i,*,*] + wein[i]*transpose(g[i,*])#g[i,*]
		endif
	endif else begin
		if n_elements(f) ne 1 then message, 'The function must be scalar!'
		fnc = f
		if ffl then begin
			grd = g
			hes = h
		endif
	endelse

	return, FPU_fix(fnc[0])
end