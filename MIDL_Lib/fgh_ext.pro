Function FGH_ext, fun, eps, x_ini = xin, params = par, scale = scl, try = try,$
	min = mno, max = mxo, mask = msk, vec_con = cvc, val_con = cvl, $
	sumsq = ssq, yvals = yvl, weights = wei, progress = prg, alternate = alt, $
	extval = evl, chi = chi, covmat = cvm, error= err, status= stat, _extra = _e

;+
; NAME:
;		FGH_EXT
; VERSION:
;		4.8
; PURPOSE:
;		Finds extrema (possibly constrained), max or min, of functions.
; CATEGORY:
;		Mathematical, general.
; CALLING SEQUENCE:
;		Result = FGH_EXT( FUN [, EPS] [keywords])
; INPUTS:
;;	FUN
;		Character value representing an existing IDL function.  The function
;		must satisfy the following requirements:
;
;		1)	Accept vector input X and return scalar value.
;		2)	Provide two optional outputs , through keywords, as follows:
;			a)	Keyword GRAD, returning the gradient of FUN as a vector of
;				same dimensionality as the input.
;			b)	Keyword HESS, returning the Hessian matrix of FUN, as a square
;				matrix, dimensionality same as input along each dimension.
;
;		In addition FUN may accept one additional input (beyond X) of
;		arbitrary form, and an unlimited number of keywords (beyond GRAD and
;		HESS).  Thus the general from of the FUN defining line should be
;
;		Function FUN, X [, PAR], GRAD = GRD, HESS = HES [, extra keywords]
; OPTIONAL INPUT PARAMETERS:
;	EPS
;		Smallness parameter, used to determine convergence.  Default is machine
;		precision, according to data type, as given by TOLER.  Rougly speaking,
;		the error of the result (assuming the procedure converged) is of the
;		order of SQRT(EPS).
; KEYWORD PARAMETERS:
;	X_INI
;		Initial X vector, to start the iteration.  Optional in the case of
;		constrained extremum (where an initial vector can be generated
;		internally), mandatory otherwise.
;	PARAMS
;		An arbitrary optional value or variable which is passed to the function
;		FUN.  No restrictions on type and form and no checking is done.
;	/SCALE
;		Switch.  If set, modifies the operation of SVD_INVERT (see there).
;		Improves robustness in the case of functions with widely different
;		rates of change in different directions, at the price of slowing down
;		the calculation.
;	TRY
;		Specifies how many times to ignore evidence of divergence (meaning,
;		instances where the new function increment is larger than the previous
;		one.  Default is 10.
;	/MIN
;		Switch.  If set, only minima are sought.
;	/MAX
;		Switch.  If set, only maxima are sought.
;	MASK
;		Numeric vector (scalar also acceptable) specifying which variables to
;		keep fixed during the iteration.  Can be used *only* when X_INI is
;		provided.  If MASK is used, VEC_CON (see below) is ignored.
;		MASK can be given in two formats:
;			1)  A vector of same length as the length of X_INI.  In this case
;				any zero entry causes the corresponding variable to be kept
;				constant.  For example, if the length of X_INI is 6, then the
;				MASK of [1,0,1,1,1,0] means "keep  X[1] and X[5] constant".
;			2)	A vector (or scalar) *shorter* than X_INI.  In this case the
;				entries in MASK are taken as the actual indices of the variables
;				to be kept constant.  In this notation, the MASK from example
;				(1) above will be written as [2,5].
;	VEC_CON
;		A vector or 2-dim array (representing a set of vectors), used (together
;		with VAL_CON, see below) to define the constraints.  If a vector, must
;		be of same length as X_INI (if provided), if a 2-dim array, the larger
;		of the two dimensions must be same as this of X_INI.  See notes below.
;	VAL_CON
;		A value or vector used (together with VEC_CON, see above) to define the
;		constraints.  If provided, VAL_CON must include one scalar value for
;		each vector in VEC_CON.  For example, if VEC_CON is a vector (of any
;		length), VAL_CON must have one element only, and if VEC_CON is an array
;		of dimensions [6,4] then it is taken as a set of 4 vectors of length 6
;		and VAL_CON should have 4 elements.
;
;		However, it is also possible to provide VAL_CON as a single value
;		(regardless of the size of VEC_CON), in which case it'll be expanded
;		into a vector of the required length, with all the elements equal to
;		the provided value.  Or, VAL_CON can be omitted all together in which
;		case it is replaced internally by zero(s).
;
;		Note 1:	VEC_CON and VAL_CON are used to establish a set of linear
;				constraints of the form
;
;				X /dot V_i = C_i	|	i = 0,...(k-1)
;
;				Where V_i is the i-th vector in VEC_CON, C_i is the i-th value
;				in VAL_CON and k is the number of constraint vectors (which
;				number cannot exceed the length of X).  When such constraint is
;				provided, only the subspace of X satisfying the constaint is
;				used in the calculation.
;
;		Note 2:	If MASK is used, VEC_CON is generated internally.  For example,
;				setting MASK to [2,5] is equivalent to providing VEC_CON
;				containing the vectors [0,0,1,...] and [0,0,0,0,0,1,...].
;
;		Note 3:	If MASK is used and VAL_CON is provided, the length of VAL_CON
;				*must* be either 1 or the length of MASK.
;		Note 4:	If MASK is used and VAL_CON is *not* provided, then the entries
;				of X_INI corresponding to the masked values serve as the
;				values of VAL_CON.
;
;	/SUMSQ
;		Switch.  If set, "sum squared" evaluation of the function is performed.
;		See details in FGH_FUN.
;	YVALS
;		Comparison vector for "sum squared" purposes, used within FGH_FUN when
;		SUMSQ is set. See details in FGH_FUN.
;	WEIGHTS
;		Numeric weights vector, used within FGH_FUN when SUMSQ is set. See
;		details in FGH_FUN.
;	/PROGRESS
;		Switch.  If set, best function value obtained in each iteration is
;		printed to the screen.
;	/ALTERNATE
;		Switch.  If set, the error is calculated in an alternative fashion, as
;		the inverse of the square root of the diagonal values of the inverse of
;		the covariance matrix, instead of the square root of the diagonal value
;		of the covariance matrix.  Active only when /SUMSQ is set.
;	EXTVAL
;		Optional output, see below.
;	CHI
;		Optional output, see below.
;	COVMAT
;		Optional output, see below.
;	ERROR
;		Optional output, see below.
;	STATUS
;		Optional output, see below.
;	_EXTRA
;		A formal keyword used to additional keywords to FUN.  Not to be used
;		directly.
; OUTPUTS:
;		Returns the extremum location, as vector, if found, else returns the
;		last location evaluated.
; OPTIONAL OUTPUT PARAMETERS:
;	EXTVAL
;		Returns the value of the function at the extremum or (if not
;		converging), the last value calculated.
;	CHI												|
;		Returns the Chi squared of the result.  Note|
;		that this is the true Chi squared only when	|	These two keywords only
;		the WEIGHTS are the inverses of the squared	|	active if /SUMSQ is set,
;		statistical errors of YVALS.				|	else they return nothing
;	COVMAT											|
;		Returns the covariance matrix of the result.|
;	ERROR
;		Returns the estimated iteration error.  If /SUMSQ is set, the error is
;		determined from the diagonal elements of COVMAT, else it is estimated
;		by the last iteration step.
;	STATUS
;		Returns iteration status information.  Possible values are:
;			0	:	Not converging and/or Hessian indicates no extremum.
;			1	:	Converged to minimum.
;			2	:	Converged to maximum.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Alternating gradient-hessian steps and 1-dim optimization along the
;		gradient direction from the previous step.
;		Calls ARREQ, CALCTYPE, CAST, DEFAULT, DIAGOARR, DIAGOVEC, FGH_FUN,
;		ISNUM, ONE_OF, SIGN, SORPURGE, SVD_INVERT, TOLER and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 25-OCT-2003 by Mati Meron.
;		Modified 10-DEC-2003 by Mati Meron.  Added keywords SUMSQ, WEIGHTS and
;		YVALS, to streamline "sum-squared" operations.
;		Modified 10-JAN-2004 by Mati Meron.  Added keywords /MIN, /MAX, and
;		COVMAT and introduced covariance matrix based error calculation.
;		Modified 20-JAN-2004 by Mati Meron.  Added keyword MASK.
;-

	on_error, 1

	ncv = n_elements(cvl)
	if ncv gt 0 then wcvl = cvl
	nms = n_elements(msk)
	if nms gt 0 then begin
		n = n_elements(xin)
		if n gt 0 then begin
			if n ge nms then begin
				if ncv le 1 or ncv eq nms then begin
					if n gt nms then begin
						s = Sorpurge(msk,net=nzms)
						zmsk = msk[s]
					endif else zmsk = where(msk eq 0,nzms)
					if nzms gt 0 then begin
						cvc = (identity(n))[*,zmsk]
						if ncv eq 0 then wcvl = xin[zmsk]
						if ncv eq nms then $
						if n eq nms then wcvl = cvl[zmsk] else wcvl = cvl[s]
						if ((ncv eq nms) or (ncv eq 0)) then ncv = nzms
					endif
				endif else message, 'Mask - constraint_values discrepancy!'
			endif else message, 'MASK too big!'
		endif else message, 'Cannot use MASK without X_INI!'
	endif

	cfl = Isnum(cvc)
	if cfl then begin
		siz = size(cvc)
		case siz[0] of
			0	:	aar = reform([cvc],1,1)
			1	:	aar = reform(cvc,siz[1],1)
			2	:	if siz[2] gt siz[1] then aar= transpose(cvc) else aar = cvc
			else:	message, 'Wrong constraints array size!'
		endcase
		siz = size(aar)
		n = siz[1]
		nc = siz[2]
		if ncv eq 0 then wcv = replicate(0.,nc) $
		else if ncv eq 1 then wcv = replicate(wcvl,nc) $
		else if ncv eq nc then wcv = wcvl $
		else message, 'Wrong number of constraint values!'
		rar = aar# SVD_invert(transpose(aar)# aar)
		x = rar#wcv
		aqr = Diagoarr(replicate(1.,n)) - rar#transpose(aar)
		if Isnum(xin) then if n_elements(xin) eq n then x = x + aqr#xin $
		else message, 'Constraints - X size discrepancy!'
	endif else begin
		if Isnum(xin) then begin
			x = Cast(xin,4)
			n = n_elements(x)
			nc = 0
		endif else message, 'Missing inputs!
	endelse

	extyp = ([0,-1,1])[One_of(mno,mxo) + 1]
	typ = Calctype(x,0.)
	deps = Toler(x)
	big = (machar(double=Isnum(x,/double))).xmax
	weps = Default(eps,deps,/dtyp) > deps
	try = Default(try,10) > 0
	ntry = 0
	stat = 0
	comp = big
	finch = replicate(1b,3)
	fval = make_array(3,typ=typ)
	fval[0] = $
	FGH_fun(fun,x,par=par,sum=ssq,yva=yvl,wei=wei,grad=grd,hess=hes,_extra=_e)
	repeat begin
		ihs = SVD_invert(hes,val=hdi,scale=scl)
		thdi = total(hdi)
		if cfl then begin
			bar = ihs#aar
			bat = transpose(bar)
			jhs = SVD_invert(bat#hes#bar,scale=scl)
			ihs = aqr#(ihs - bar#jhs#bat)#aqr
		endif
		dx = -ihs#grd
		if extyp then dx = extyp*Sign(total(grd*dx))*dx
		doval = [0,1,1]
		repeat begin
			repeat begin
				if not Arreq(finch,finite(fval)) then message, 'Overflow!!!'
				if doval[1] then fval[1] = $
				FGH_fun(fun,x+dx,par=par,sum=ssq,yva=yvl,wei=wei,_extra=_e)
				if doval[2] then fval[2] = $
				FGH_fun(fun,x+2*dx,par=par,sum=ssq,yva=yvl,wei=wei,_extra=_e)
				fir = total(fval*[1,0,-1])/2.
				sec = total(fval*[1,-2,1])
				if sec ne 0 then $
				if extyp*Sign(sec) le 0 then cor = fir/sec else cor = 0 $
				else cor = 0
				if abs(cor) ge 1 then begin
					if cor ge 1 then begin
						dx = 2*dx
					 	fval[1] = fval[2]
					 	doval = [0,0,1]
					endif else begin
						dx = dx/2
						fval[2] = fval[1]
						doval = [0,1,0]
					endelse
				endif
				if thdi*total((dx/n)^2) lt weps then cor = 0
			endrep until abs(cor) lt 1
			err = (1 + cor)*dx
			evl = FGH_fun($
			fun,x+err,par=par,sum=ssq,yva=yvl,wei=wei,gra=grd,hes=hes,_extra=_e)
			if extyp then begin
				okfl = extyp*(evl - fval[0]) ge 0
				if not okfl then begin
					dx = err/2
					fval[2] = evl
					doval = [0,1,0]
				endif else x = x + err
			endif else begin
				x = x + err
				okfl = 1
			endelse
		endrep until okfl
		ncomp = abs(evl - fval[0])/((abs(evl) + abs(fval[0]))> deps)
		done = (ncomp < thdi*total((err/n)^2)) lt weps
		if not done then begin
			ntry = ntry + (ncomp gt comp)
			comp = ncomp
			fval[0] = evl
		endif else err = abs(err)
		if keyword_set(prg) then print, evl, '	', ncomp
	endrep until (done or ntry gt try)

	if done then begin
		if cfl then thes = double(aqr#hes#aqr) else thes = double(hes)
		trired, thes, diag, ofdiag, /double
		triql, diag, ofdiag, thes, /double
		adiag = abs(diag)
		zer = where(adiag lt n*deps*max(adiag),nzer,comp=nozer,ncomp=nnozer)
		if nzer le nc then if min(diag[nozer],max=meig)*meig gt 0 $
		then stat = -Sign(meig)
	endif

	if keyword_set(ssq) then begin
		ihs = SVD_invert(Cast(hes,5),val=hdi,scale=scl)
		if cfl then begin
			bar = ihs#aar
			bat = transpose(bar)
			jhs = SVD_invert(bat#hes#bar,scale=scl)
			ihs = aqr#(ihs - bar#jhs#bat)#aqr
		endif
		ns = n_elements(wei)
		twei = total(wei)
		chi = Cast(2*evl*twei/((ns - n + nc) > deps),typ,typ)
		cvm = Cast(chi/twei*ihs,typ,typ)
		afl = keyword_set(alt)
		if afl then esq=Diagovec(SVD_invert(cvm,sca=scl)) else esq=Diagovec(cvm)
		dum = where(esq lt 0,ndum)
		if afl then err= 1/sqrt(abs(esq)) else err= sqrt(abs(esq))
		if ndum gt 0 then err[dum] = big
	endif

	return, Cast(x,typ,typ,/fix)
end