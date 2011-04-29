Function Splin_coeffs, x, y, segmented = seg

;+
; NAME:
;		SPLIN_COEFFS
; VERSION:
;		4.0
; PURPOSE:
;		Calculates cubic splines coefficients which are intended to be used by
;		the supplementary function SPLIN_EVAL.  The combination of SPLIN_COEFFS
;		and SPLIN_EVAL is more efficient than the library function SPLINE when
;		repeated interpolations based on the same data set are performed.
; CATEGORY:
;		Mathemetical Function (General).
; CALLING SEQUENCE:
;		Result = SPLIN_COEFFS( X, Y [, /SEGMENTED] )
; INPUTS:
;	X
;		Vector, numeric, at least 2 elements.  Contains the X coordinates of
;		the data, in arbitrary order.
;	Y
;		Vector, numeric, same length as X.  Contains the Y values corresponding
;		to the values in X.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/SEGMENTED
;		Switch.  If set the input data is treated as segmented, where segment
;		boundary is defined as two consecutive points with the same X
;		coordinate.  Spline fitting is performed on each segment separately.
;		In default operation, whenever multiple points with the same X
;		coordinate are encountered, all but the first one are deleted.
; OUTPUTS:
;		Returns an (n,3) array where n is the number of data points.  The
;		columns of the result are:
;			0 -	X values, sorted in increasing order.
;			1 - Corresponding Y values.
;			2 - Calculated corresponding spline coefficients.
;		This array is intended to be used as an input to the function SPLIN_EVAL
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		As mentioned above, the X and Y arrays must have at least 2 elements.
;		Also, if the keyword SEGMENTED is used, the arrays must be presorted in
;		ascending order.  In normal (not SEGMENTED) evaluation the order
;		doesn't matter.
; PROCEDURE:
;		Standard Cubic spline evaluation (see Numerical Recipies, chapt. 3.3)
;		with the boundary condition of 0 THIRD derivative (constant end
;		curvature).  Calls itself recursively.  Also uses calls to CAST,
;		FPU_FIX and SORPURGE in MIDL.  If X and Y have only 2 elements, the
;		spline is a plain linear fit.
; MODIFICATION HISTORY:
;		Created 15-APR-1992 by Mati Meron.
;		Modified 15-AUG-1992 by Mati Meron.  Replaced SORT with SORPURGE in
;		order to protect against a possible repetition of x values.
;		Modified 10-FEB-1993 by Mati Meron.  Added SEGMENTED option.
;		Modified 10-APR-1993 by Mati Meron.  Added acceptance of 2-point data.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	nv = n_elements(x)
	if nv lt 2 then message, 'Insufficient data!'
	if n_elements(y) ne nv then message, 'X & Y lengths must be equal!'

	if keyword_set(seg) then begin
		wx = x
		wy = y
		dum = where(wx[1:nv-1] - wx[0:nv-2] eq 0, ndum)
		if ndum eq 0 then dum = [nv-1] else dum = [dum, nv-1]
		res = Splin_coeffs(wx[0:dum[0]], wy[0:dum[0]])
		for i = 0l, ndum - 1 do res = $
		[res,Splin_coeffs(wx[dum[i]+1:dum[i+1]],wy[dum[i]+1:dum[i+1]])]
	endif else begin
		sox = Sorpurge(x, netlen = nv)
		if nv lt 2 then message, 'Insufficient useful data!'
		wx = Cast(x[sox],4)
		wy = Cast(y[sox],4)

		if nv gt 2 then begin
			dex = wx[1:nv-1] - wx[0:nv-2]
			dey = wy[1:nv-1] - wy[0:nv-2]
			cdex = 2*(dex[0:nv-3] + dex[1:nv-2])
			deydex = dey/dex
			ddey = deydex[1:nv-2] - deydex[0:nv-3]
			spc = trisol([0,dex],[-dex[0],cdex,-dex[nv-2]],[dex,0],[0,ddey,0])
		endif else spc = 0.*wy

		res = [[wx],[wy],[spc]]
	endelse

	return, FPU_fix(res)
end
