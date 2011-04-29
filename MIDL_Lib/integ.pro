Function Integ, x, y, delta = dex, value_only = val

;+
; NAME:
;		INTEG
; VERSION:
;		4.0
; PURPOSE:
;		Integrates a function provided as an array of points.
; CATEGORY:
;		Mathematical Function (array).
; CALLING SEQUENCE:
;		Result = INTEG([X,] Y [, keywords])
; INPUTS:
;	Y
;		A vector containing the Y coordinates of the data.
; OPTIONAL INPUT PARAMETERS:
;	X
;		A vector containing the X coordinates of the data.  If not provided,
;		it is assumed that the X coordinates are equally spaced, with a default
;		default spacing of 1. (unless changed by the DELTA keyword).
; KEYWORD PARAMETERS:
;	DELTA
;		Sets the spacing of the X coordinates of the data.  If the X coord.
;		are explicitly provided (see X input above) DELTA is ignored.
;	/VALUE_ONLY
;		Switch.  Normally INTEG returns the integral function of Y, as a vector
;		(see OUTPUTS below).  If VALUE_ONLY is set, only the full value of the
;		integral is returned as scalar.  This makes the execution faster.
; OUTPUTS:
;		Normally returns the integral function of Y, i.e. a vector whose i-th
;		entry is the integral of Y from X(0) to X(i) (and therefore the last
;		entry is the full integral of Y.  If the optional keyword VALUE_ONLY is
;		set, only the full integral is returned, as a scalar.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The Y vector (and the X vector, if provided) must be of length >= 3.
; PROCEDURE:
;		Simpson integration, where the mid-interval points are obtained from
;		cubic interpolation using Neville's algorithm.
;		Uses CALCTYPE, DEFAULT, FPU_FIX and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 20-FEB-1992 by Mati Meron.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	nv = n_elements(x)
	if nv lt 3 then message, 'Insufficient data!'
	dtyp = Calctype(x,1.,/strict)

	if n_elements(y) eq 0 then begin
		dex = Default(dex,1.,low = dtyp)
		xw = dex*(findgen(nv+2) - 1)
		yw = [0., x, 0.]
	endif else begin
		dtyp = Calctype(dtyp,Type(y),/typ,/strict)
		if n_elements(y) ne nv then message, 'Incompatible array lenghts!'
		xw = [2*x[0] - x[1], x, 2*x[nv-1] - x[nv-2]]
		yw = [0., y, 0.]
	endelse

	p = make_array(4, type = dtyp)
	q = p
	nw = nv + 1
	for i = 1, 3 do begin
		k = nw - i
		p[i] = yw[i]
		q[i] = yw[k]
		for j = i - 1, 1, - 1 do begin
			l = nw - j
			p[j] = ((xw[0]-xw[i])*p[j] + (xw[j]-xw[0])*p(j+1))/(xw[j]-xw[i])
			q[j] = ((xw[nw] - xw[k])*q[j] + (xw[l]-xw[nw])*q[j+1])/(xw[l]-xw[k])
		endfor
	endfor
	yw[0] = p[1]
	yw[nw] = q[1]

	xc = .5*(xw[2:nv] + xw[1:nv-1])
	q = make_array(nv - 1, 4, type = dtyp)
	for i = 0, 3 do begin
		k = nv - 2 + i
		q[*,i] = yw[i:k]
		for j = i - 1, 0, -1 do begin
			l = nv - 2 + j
			q[*,j] = ((xc - xw[i:k])*q[*,j] + (xw[j:l] - xc)*q[*,j+1]) $
				/(xw[j:l] - xw[i:k])
		endfor
	endfor

	res = [0,(yw[1:nv-1] + yw[2:nv] + 4*q[*,0])*(xw[2:nv] - xw[1:nv-1])/6.]
	if keyword_set(val) then res = total(res) else $
	for i = 2l, nv - 1 do res[i] = res[i] + res[i-1]

	return, FPU_fix(res)
end
