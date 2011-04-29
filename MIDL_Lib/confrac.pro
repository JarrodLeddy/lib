Function Confrac, a, b, x, afunction = afun, bfunction = bfun, $
    epsilon = eps, relative = rel, error = erv, status = stat

;+
; NAME:
;		CONFRAC
; VERSION:
;		4.0
; PURPOSE:
;		Performs continued fraction evaluation.
; CATEGORY:
;		Mathematical function (general).
; CALLING SEQUENCE:
;		Result = CONFRAC( A, B [,X [, keywords]])
; INPUTS:
;	A
;		A numeric scalar, vector or a 2-D array.  A(i,*) contains the i-th
;		A coefficient(s) of the continued fraction.
;	B
;		Same as A for the B coefficient(s).  A and B must agree in their first
;		dimension, i.e. if A is an (N,M) array (including the possibility of
;		M = 1) then B must be an (N,M') array, with an arbitrary M'.
; OPTIONAL INPUT PARAMETERS:
;	X
;		Numeric, otherwise arbitrary.  When provided, X is used together with
;		A and B to determine the continued fraction coefficients.
; KEYWORD PARAMETERS:
;	AFUNCTION
;		Name of a function to be used (with the CALL_FUNCTION routine) to
;		determine the A coefficients.  Optional.
;	BFUNCTION
;		Same as AFUNCTION for the B coefficients.  Optional.
;	EPSILON
;		Smallness parameter, determining the allowed evaluation error.
;		Optional.  Default values are machine dependent, established through
;		TOLER which calls MACHAR().
;	/RELATIVE
;		Switch.  If set, EPS represent the allowed relative evaluation error.
;	ERROR
;		Optional output, see below.
;	STATUS
;		Optional output, see below.
; OUTPUTS:
;		Returns the value(s) of the continued fraction.  The result is of the
;		same format as X (a scalar if X is not given).  The type of the result
;		is the highest of the types of A, B, and X, but no lower than 4 (float).
; OPTIONAL OUTPUT PARAMETERS:
;	ERROR
;		The name of the variable to receive the estimated evaluation error.
;		Given in the same format as X (scalar if X isn't provided).  If
;		RELATIVE is set the error returned is relative.
;	STATUS
;		The name of the variable to receive evaluation status information.
;		Same format as ERROR.  Possible values are:
;			0 - evaluation didn't converge.
;			1 - OK.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None other then the restrictions on A, B, as mentioned above.
; PROCEDURE:
;		CONFRAC evaluates continued fractions of the form
;
;			res = a(0)/(b(0) + a(1)/(b(1) + a(2)/(b(2) + ......
;
;		Using the recurrence relation from Numerical Recipies, Sec 5.2.  The
;		designation of the coefficients a(i), b(i) depends on the data
;		provided, as follows:
;
;		1)  If X isn't provided then a(i) = A(i) (or A(i,0) if A is a 2-dim
;			array) and same is true for b(i) (using B)
;		2)  If X is provided then a(i) = Sum_j(A(i,j)*X^j) and the same for b(i)
;			using B.  In other words the fraction coefficients are polynomials
;			in X, using columns of A, B, as polynomial coefficients.  Note that
;			if A and/or B are one dimensional arrays then only X^0 is used i.e.
;			we are back to case 1.
;		3)  If AFUN and/or BFUN are provided then a(i) = afun(x,A(i,*),i) and
;			same for b(i) with BFUN and B.  The functions can be arbitrary but
;			they must accept at least three parameters.
;
;		CONFRAC uses CALCTYPE, CAST, DEFAULT, FPU_FIX, POLEVAL, TOLER and TYPE
;		from MIDL.
; MODIFICATION HISTORY:
;		Created 20-DEC-1994 by Mati Meron.
;		Modified 10-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1

	if n_params() lt 2 then message, 'both A and B are needed!'
	sia = size(a)
	sib = size(b)
	flen = (sia)(sia[0]<1)
	if (sib)(sib[0]<1) ne flen then message, "Unequal arrays' lengths!"
	afl = n_elements(afun) gt 0
	bfl = n_elements(bfun) gt 0

	dtyp = Calctype(Type(a),Type(b),Type(x),4,/types,/strict)
	weps = Default(eps,Toler(type=dtyp))
	relfl = keyword_set(rel)

	wx = Default(x,1.,low = dtyp)
	nox = 1. + 0.*wx
	erv = (machar(double = dtyp eq 5 or dtyp eq 9)).xmax*Cast(nox,4,5)
	stat = 0*fix(nox)
	norfl = 0

	ap = 1.
	bp = 0.
	al = 0.
	bl = 1.
	i = 0l

	repeat begin
		if norfl then begin
			ap = ap*norm
			bp = bp*norm
			norfl = 0
		endif

		if afl then ai = call_function(afun,wx,i,a[i,*]) $
		else ai = Poleval(wx,a[i,*])
		if bfl then bi = call_function(bfun,wx,i,b[i,*]) $
		else bi = Poleval(wx,b[i,*])

		an = al*bi + ap*ai
		bn = bl*bi + bp*ai
		ap = al
		bp = bl
		al = an
		bl = bn

		binz = where(bn ne 0, noz)
		if noz gt 0 then begin
			norfl = 1
			norm = nox
			norm[binz] = 1./bn[binz]
			al = al*norm
			bl = bl*norm
			erv[binz] = (abs(al - ap))[binz]
			if relfl then erv[binz] = erv[binz]/(abs(al) > weps)[binz]
			stat[binz] = fix(erv[binz] le weps)
		endif
		i = i + 1l
	endrep until i eq flen or min(stat) eq 1

	return, FPU_fix(al)
end
