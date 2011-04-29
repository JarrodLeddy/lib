Function ODE_relax, x, y, eps, lo_bound= lob, hi_bound= hib, sym_ybound= ysb,$
	ffun = ffun, gfun= gfun, hfun = hfun, fpar= fpar, gpar= gpar, hpar= hpar, $
	nonlinear = nol, corr_coef = corf, try = try, show_progress = shop, $
	change_only = chon, cond_f = cnf, cond_g = cng, last_inc = pdif, iter= count

;+
; NAME:
;		ODE_RELAX
; VERSION:
;		4.3
; PURPOSE:
;		Solving differential equations of the form
;
;			Y'' + F(X)*Y' + G(X)*Y = H(X)
;
;		or the more general (nonlinear)
;
;			Y'' + F(X)*Y' + G(X,Y) = H(X)
;
; CATEGORY:
;		Mathematical.
; CALLING SEQUENCE:
;		Result = ODE_RELAX( X [, Y], LO_BOUND = LOB, HI_BOUND = HIB [,keywords])
; INPUTS:
;	X
;		Numeric vector, at least 3 elements long.  The X coordinates for which
;		the result is calculated.
; OPTIONAL INPUT PARAMETERS:
;	Y
;		Numerical vector, same length as X, serves as an initial guess at the
;		solution.  Ignored for the case of linear equation.  Optional for non-
;		linear equation (if not given, it is generated internally).
;	EPS
;		Smallness parameter, establishing convergence criterion in the
;		nonlinear mode.  Default value is square root of machine DOUBLE
;		precision.
; KEYWORD PARAMETERS:
;	LO_BOUND
;		Numeric vector providing the boundary condition at the lower endpoint of
;		the X interval.  The general boundary condition is of the form
;
;			a*Y' + b*Y = c  (where Y', Y are evaluated at the endpoint).
;
;		and LO_BOUND is provided as the 3-element vector [a,b,c] (optionally,
;		it can be given as a 2-element vector [a,b] in which case c defaults
;		to zero.  This input is mandatory.
;	HI_BOUND
;		Same as LO_BOUND, for the upper endpoint of the X interval.
;	/SYM_YBOUND
;		Switch.  If set, the symmetrized value (Y[0] + Y[1])/2 is used to
;		represent Y in the lower boundary condition (instead of plain Y[0])
;		and, similarly, a symmetrized combination is used at the upper end.
;	FFUN
;		Character value representing an existing IDL function, corresponding
;		to F(X) in the expression above.  The function must comply with the IDL
;		standard of being able to accept an array input and return an array
;		output.  The calling sequence for the function must be either
;
;			Result = FFUN(X)
;		or
;			Result = FFUN(X, extra)
;
;		where X is the variable and EXTRA may be any single entity (scalar,
;		array, structure etc.) used to pass additional parameters to the
;		function (see FPAR, below)
;
;		If no argument is provided to FFUN, it defaults to the MIDL function
;		POLEVAL, amounting to polynomial evaluation using FPAR to provide the
;		coefficients.  Specifically (in this case) if FPAR is a scalar constant
;		the action of FFUN amounts to multiplication by same constant.
;	GFUN
;		Character value representing an existing IDL function, complying with
;		same standards as FFUN.  Corresponds to G(X) or G(X,Y) in the
;		expression above.  The calling sequence for the function depends on
;		the setting of the NON_LINEAR switch (see below).
;
;		If NON_LINEAR is *not* set then the calling sequence is same as for
;		FFUN (see above).  Also, same as in the case of FFUN, GFUN defaults to
;		POLEVAL if not provided.
;
;		If NON_LINEAR is set, then GFUN is a function of both X and Y and the
;		calling sequence is either
;
;			Result = GFUN(X, Y)
;		or
;			Result = GFUN(Y, Y, extra)
;
;		where EXTRA has same meaning as for FFUN and is provided through GPAR
;		(see below).  There is no default setting for GFUM in the non-linear
;		case and, if not provided, an error results.
;	HFUN
;		Character value representing an existing IDL function, complying with
;		same standards as FFUN.  Corresponds to H(X) in the expression above.
;		The calling sequence for the function is same as for FFUN.  In the
;		linear case HFUN defaults to POLEVAL if not provided, same as FFUN.
;		In the non-linear case, if HFUN is not provided, it is ignored.
;	FPAR
;		An arbitrary value or variable which is passed to the function FFUN.
;		May be an array or structure.
;	GPAR
;		Same as FPAR, for GFUN.
;	HPAR
;		Same as FPAR, for HFUN.
;	/NONLINEAR
;		Switch.  If set, indicates that the equation is non linear and that the
;		iterative mode needs to be used.
;	CORR_COEF
;		Value of a parameter which is used in the nonlinear mode to hasten
;		convergence.  Any value will be accepted but values <0 or >=1 tend to
;		destabilize the procedure and should be avoided.  Default value is 1/2.
;		This parameter is ignored in the case of a linear equation.
;	TRY
;		Integer parameter, specifying number of "tries" in the nonlinear mode.
;		A successful "try" in this mode occurs when the new rms sum of
;		increments is larger then the EPS (see above) plus the previous such
;		sum.  Calculation terminates when the number of *consecutive* successful
;		tries equals TRY.  Default value is 1.
;	SHOW_PROGRESS
;		Accepts a numerical value determining how much progress info will be
;		displayed during the iteration process, in the nonlinear mode.  For
;		value N, information is printed every N-th iteration.  The info
;		displayed consists of 3 numbers, in order:  number of steps so far,
;		length of the most recent vector of Y corrections and the scalar
;		product of the most recent and the previous vector of Y corrections,
;		divided by the product of their lengths.  In the case of linear
;		equation, this parameter is ignored.
;	/CHANGE_ONLY
;		Switch.  Modifies the keyword SHOW_PROGRESS, so that only info for
;		iterations where the TRY counter changed is displayed, in the format of:
;		number of steps so far, value of the TRY counter, length of the most
;		recent vector of Y corrections and the scalar product of the most recent
;		and the previous vector of Y corrections, divided by the product of
;		their lengths.
;	COND_F
;		Optional output, see below.
;	COND_G
;		Optional output, see below.
;	LAST_INC
;		Optional output, see below.
;	ITER
;		Optional output, see below.
; OUTPUTS:
;		Returns a vector of Y values, of the same length as the original X
;		vector.  These Y values are an approximation to the solution of the
;		differential equation.
; OPTIONAL OUTPUT PARAMETERS:
;	COND_F
;		Returns the maximal (over the grid provided) value of F(X)*dX/2.  This
;		provides an indirect measure of the quality of the approximation.
;	COND_G
;		Returns the maximal (over the grid provided) value of G(X)*dX^2/4 or
;		G(X,Y)*dX^2/4.  This also provides an indirect measure of the quality
;		of the approximation.
;	LAST_INC
;		In the case of a nonlinear equation returns the length of the last
;		Y-increment vector, providing a measure of the convergence of the
;		iteration.  Not active in the case of a linear equation.
;
;		Note:  small or zero value of LAST_INC indicates that the iteration
;		has converged but provides no information regarding the quality of the
;		result.
;	ITER
;		In the case of a nonlinear equation, returns the number of iterations
;		performed.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Based on minimalization of the *action* corresponding to the 2nd order
;		ODE.  For a linear differential equation the minimalization over a
;		finite mesh yields a triagonal equation which is solved in a single
;		step.  In the case of a non-linear equation the minimalization
;		generates a vector of Y corrections which is added to the original
;		values and the process is repeated, iteratively, till it converges.
;
;		Calls ARREQ, CAST, DEFAULT, FPU_FIX, ISNUM, TOLER and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 10-DEC-2001 by Mati Meron.
;		Modified 10-MAY-2006 by Mati Meron.  Added keywords CHANGE_ONLY, ITER
;		and TRY.
;-

	on_error, 1

	n = n_elements(x)
	if n lt 3 then message, 'At least 3 points required!
	dtyp = Type(x)
	sor = sort(x)
	wx = double(x[sor])
	dx = wx[1:*] - wx
	xc = 0.5d*(wx[1:*] + wx)
	if n_elements(lob) le 1 then message, 'Insufficient bound info!' $
	else if n_elements(lob) eq 2 then wlob = [lob,0] else wlob = lob
	wlob = wlob*[1,dx[[0,0]]]
	if n_elements(hib) le 1 then message, 'Insufficient bound info!' $
	else if n_elements(hib) eq 2 then whib = [hib,0] else whib = hib
	whib = whib*[1,dx[[n-2,n-2]]]
	if keyword_set(ysb) then nsb = 0 else nsb = 1
	pco = (1 + nsb)/2d
	mco = (1 - nsb)/2d

	ttyp = Type(ffun)
	if ttyp eq 0 then ffun = 'Poleval' else $
	if ttyp ne 7 then message, 'Invalid f_function!'
	if n_elements(fpar) eq 0 then fc = FPU_fix(call_function(ffun,xc)) $
	else fc = FPU_fix(call_function(ffun,xc,fpar))
	fcd = fc*dx/2
	cnf = max(abs(fcd))
	kcm = (1 - fcd)/dx
	kcp = (1 + fcd)/dx

	ttyp = Type(hfun)
	if ttyp eq 0 then hfun = 'Poleval' else $
	if ttyp ne 7 then message, 'Invalid h_function!'
	if n_elements(hpar) eq 0 then hc=FPU_fix(call_function(hfun,xc)) $
	else hc = FPU_fix(call_function(hfun,xc,hpar))

	if keyword_set(nol) then begin
		if n_elements(y) eq 0 then y = 0*wx else $
		if n_elements(y) ne n then message, 'Y length mismatch!'
		wy = double(y(sor))
		wy[0]  = ((wlob[0]+mco*wlob[1])*wy[1]  - wlob[2])/(wlob[0]-pco*wlob[1])
		wy[n-1]= ((whib[0]-mco*whib[1])*wy[n-2]+ whib[2])/(whib[0]+pco*whib[1])

		hfl = not Arreq(hc,0*hc)

		if Type(gfun) ne 7 then message, 'Invalid g_function!'
		gpfl = (n_elements(gpar) ne 0)

		shocon = Default(shop,0l,/dtyp) > 0
		shofl = (shocon gt 0)
		chofl = keyword_set(chon)
		try = Default(try,1,/dtyp) > 1
		ctry = (pctry = 0l)

		denom = kcm[0:n-3] + kcp[1:n-2]
		ninc = dblarr(n)
		ndif = sqrt(Toler(/double))
		weps = Default(eps,ndif,/dtyp)
		corf = Default(corf,.5d,/dtyp)
		init = 1
		done = 0
		count = (trcount = 0l)
		repeat begin
			pdif = ndif
			pinc = ninc
			dy = wy[1:*] - wy
			yc = 0.5d*(wy[1:*] + wy)
			if gpfl then gc = FPU_fix(call_function(gfun,xc,yc,gpar)) $
			else gc = FPU_fix(call_function(gfun,xc,yc))
			if hfl then gc = gc - hc
			gc = gc*dx^2/2
			ninc[1:n-2] = (((kcp*dy)[1:n-2] - (kcm*dy)[0:n-3]) + $
			((kcp*gc)[1:n-2] + (kcm*gc)[0:n-3]))/denom
			ninc[0] =   (wlob[0]+ mco*wlob[1])*ninc[1]  /(wlob[0]- pco*wlob[1])
			ninc[n-1] = (whib[0]- mco*whib[1])*ninc[n-2]/(whib[0]+ pco*whib[1])
			ndif = sqrt(total(ninc^2))
			corr = total(pinc*ninc)/(pdif*ndif)
			if init then begin
				wy = wy + (1 + corf*corr)*ninc
				if ndif lt pdif then init = 0
			endif else begin
				pctry = ctry
				if (ndif + weps) gt pdif then ctry = ctry + 1 $
				else ctry = (ctry - 1) > 0
				if ctry lt try then wy = wy + (1 + corf*corr)*ninc $
				else done = 1
			endelse
			if shofl then begin
				if chofl then begin
					if pctry ne ctry then begin
						print, count, ctry, ndif, corr
						if ((trcount mod 10*shocon) eq 0) or done then wait,0.01
						trcount = trcount + 1
					endif
				endif else begin
					if (count mod shocon) eq 0 then print, count, ndif, corr
					if ((count mod 10*shocon) eq 0) or done then wait, 0.01
				endelse
			endif
			count = count + 1
		endrep until done
		res = wy
		cng = max(abs(gc))/2
	endif else begin
		ttyp = Type(gfun)
		if ttyp eq 0 then gfun = 'Poleval' else $
		if ttyp ne 7 then message, 'Invalid g_function!'
		if n_elements(gpar) eq 0 then gc=FPU_fix(call_function(gfun,xc)) $
		else gc = FPU_fix(call_function(gfun,xc,gpar))
		gc = gc*dx^2/4
		cng = max(abs(gc))
		lcm = 1 - gc
		lcp = 1 + gc

		hc = hc*dx^2

		rvec = dblarr(n)
		lvec = rvec
		mvec = rvec
		uvec = rvec

		lvec[1:n-2] = (kcm*lcp)[0:n-3]
		mvec[1:n-2] = -((kcm*lcm)[0:n-3] + (kcp*lcm)[1:n-2])
		uvec[1:n-2] = (kcp*lcp)[1:n-2]
		rvec[1:n-2] = ((kcm*hc)[0:n-3] + (kcp*hc)[1:n-2])/2

		lvec[n-1] = whib[0] - mco*whib[1]
		mvec[0] = -wlob[0] + pco*wlob[1]
		mvec[n-1] = -whib[0] - pco*whib[1]
		uvec[0] = wlob[0] + mco*wlob[1]
		rvec[0] = wlob[2]
		rvec[n-1] = -whib[2]

		res = trisol(lvec,mvec,uvec,rvec,/double)
	endelse

	return, Cast(res,4,dtyp,/fix)
end