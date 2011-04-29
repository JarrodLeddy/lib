Function SVD_invert, arr, thresh, square = squ, nozero = noz, scale = scl, $
	refine = ref, values = val, status = stat

;+
; NAME:
;		SVD_INVERT
; VERSION:
;		4.3
; PURPOSE:
;		Matrix invertion.
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = SVD_INVERT( ARR [, keywords])
; INPUTS:
;	ARR
;		Two dimensional array (a scalar or a one-element array is accepted as an
;		1x1 array), doesn'thave to be square unless the keyword SQUARE is set.
; OPTIONAL INPUT PARAMETERS:
;	THRESH
;		Determines the threshold for setting singular values to 0.  The internal
;		threshold is THRESH*TOLER(ARR)*Maximal_singular_value (see TOLER for
;		details).  Default value for THRESH is the dimensionality of ARR.
;		Minimal value is 1.
; KEYWORD PARAMETERS:
;	/SQUARE
;		Switch.  If set, only square matrices are accepted.
;	/NOZERO
;		Switch.  If set, below threshold singular values are set to threshold.
;		To be used with great care as instabilities may result.
;	/SCALE
;		Switch.  If set, the input array is preprocessed through differential
;		scaling of its rows and columns (the scaling is reversed followint the
;		inversion.  Improves results for cases where there is great spread of
;		values for the singular values.
;	/REFINE
;		Switch.  If set, the result is refined through an extra calculation
;		step.  Not needed in general, but may reduce errors for arrays very
;		close to singular.
;	VALUES
;		Optional output, see below.
;	STATUS
;		Optional output, see below.
; OUTPUTS:
;		Returns the inverse of ARR, if it exists.  If not, returns a
;		quasi-inverse, such that for all non-null vectors of ARR the product
;		SVD_INVERSE(ARR)#ARR is equivalent to the identity operators.  In other
;		words, in all cases (whether ARR is regular or not) we've
;
;			ARR#SVD_INVERSE(ARR)#ARR = ARR
;
; OPTIONAL OUTPUT PARAMETERS:
;	STATUS
;		Returns a calculation status value (type BYTE).  Possible values are:
;			0	:	Error, ARR is not a matrix, or not square matrix if
;					/SQUARE is set.
;			1	:	Proper inverse returned.
;			2	:	Quasi-inverse returned.
;	VALUES
;		Returns the diagonal "singular values" from the SVD decomposition.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		ARR must be a 2D array (or scalar).  If /SQUARE is set, ARR must be a
;		square matrix.
; PROCEDURE:
;		Uses SVD decomposition.  Slightly slower than the IDL INVERT function
;		but allows for calculation of quasi-inverse when a proper inverse does
;		not exist, even for non-square matrices.
;		Calls CALCTYPE, CAST, DEFAULT, DIAGOARR, ISNUM and TOLER from MIDL.
; MODIFICATION HISTORY:
;		Created 20-MAY-2003 by Mati Meron.
;		Modified 30-MAY-2003 by Mati Meron.  Added keyword VALUES.
;		Modified 15-DEC-2003 by Mati Meron.  Added keyword SCALE.
;		Modified 15-JAN-2004 by Mati Meron.  Added keyword NOZERO.
;-

	on_error, 1

	stat = 0b
	if n_elements(arr) eq 1 then warr = reform([arr],1,1) else warr = arr
	siz = size(warr)

	if Isnum(warr) and (siz[0] eq 2) then begin
		estat = 2b - (siz[1] eq siz[2])
		if estat or not keyword_set(squ) then begin
			stat = estat
			typ = Calctype(0.,warr)
			svdc, warr, w, u, v,/double
			val = Cast(w,typ,typ,/fix)
			nw = n_elements(w)
			eps = (Default(thresh,nw) > 1)*Toler(warr)
			abw = abs(w)
			mabw = max(abw)
			if keyword_set(scl) and (mabw gt 0) then begin
				scafl = 1
				awar = abs(warr) > eps^2*mabw/nw
				rgt = Diagoarr(1/sqrt(total(awar,1)))
				lft = Diagoarr(1/sqrt(total(awar,2)))
				warr = lft#warr#rgt
				if n_elements(warr) eq 1 then warr = reform([warr],1,1)
				svdc, warr, w, u, v,/double
				abw = abs(w)
				mabw = max(abw)
			endif else scafl = 0
			dum = where(abw gt eps*mabw, ndum)
			if stat and ndum lt nw then stat = 2b
			inw = 0*w
			if keyword_set(noz) then inw = inw + 1./(eps*mabw)
			if ndum gt 0 then inw[dum] = 1./w[dum]
			inw = Diagoarr(inw)
			res = matrix_multiply(u,matrix_multiply(inw,v),/atran)
			if keyword_set(ref) then res = res + (res - res#warr#res)
			if scafl then res = rgt#res#lft
		endif else message, 'Not a square matrix'
	endif else message, 'Not a matrix!'

	return, Cast(res,typ,typ,/fix)
end