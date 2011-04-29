Function Splint, x, spc, value_only = val

;+
; NAME:
;		SPLINT
; VERSION:
;		4.0
; PURPOSE:
;		Integrates a function provided as a set of spline coefficients.
; CATEGORY:
;		Mathematical Function (general).
; CALLING SEQUENCE:
;		Result = SPLINT (X, SPC [/VALUE_ONLY])
; INPUTS:
;	X
;		Numeric vector, 2 or more points.  The X coordinates of the data.
;	SPC
;		An [n,3] array of spline coefficients, created by the function
;		SPLIN_COEEFS.
; KEYWORD PARAMETERS:
;	/VALUE_ONLY
;		Switch.  Normally SPLINT returns the integral function of Y, as a vector
;		(see OUTPUTS below).  If VALUE_ONLY is set, only the full value of the
;		integral is returned as scalar.  This makes the execution faster.
; OUTPUTS:
;		Normally returns the integral function of Y, i.e. a vector whose i-th
;		entry is the integral of Y from X[0] to X[i] (and therefore the last
;		entry is the full integral of Y.  If the optional keyword VALUE_ONLY is
;		set, only the full integral is returned, as a scalar.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The X vector must be of length >= 2.
; PROCEDURE:
;		Exact integration, of the cubic-spline approximation to the function.
;		Uses FPU_FIX and SPLIN_EVAL from MIDL.
; MODIFICATION HISTORY:
;		Created 20-FEB-1993 by Mati Meron.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	nv = n_elements(x)
	if nv lt 2 then message, 'Insufficient data!'

	xw = x(sort(x))
	yw = Splin_eval(x,spc)
	zw = (1./6)*Splin_eval(x,spc, deriv = 2)
	tem = replicate(1,nv)

	dum = where(spc[*,0] gt xw[0] and spc[*,0] lt xw[nv-1], ndum)
	nw = nv + ndum
	if ndum ne 0 then begin
		xw = [xw, spc[dum,0]]
		yw = [yw, spc[dum,1]]
		zw = [zw, spc[dum,2]]
		tem = [tem,intarr(ndum)]
		sork = sort(xw)
		xw = xw[sork]
		yw = yw[sork]
		zw = zw[sork]
		tem = tem[sork]
	endif

	dxh = 0.5*(xw[1:nw-1] - xw[0:nw-2])
	res = [0, dxh*(yw[1:nw-1] + yw[0:nw-2] - 2*dxh^2*(zw[1:nw-1] + zw[0:nw-2]))]

	if not keyword_set(val) then begin
		for i = 2l, nw - 1 do res[i] = res[i] + res[i-1]
		res = res[where(tem)]
	endif else res = total(res)

	return, FPU_fix(res)
end
