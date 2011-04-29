Function Swidth, x, y, delta = dex, baseline = bas

;+
; NAME:
;		SWIDTH
; VERSION:
;		4.2
; PURPOSE:
;		Calculating peak width.
; CATEGORY:
;		Spectral analysis.
; CALLING SEQUENCE:
;		Result = SWIDTH ( X, Y [, keywords])
; INPUTS:
;	X
;		Numeric, Either a vector (scalar is considered to be a vector of
;		length 1) or an [2,*] array.
; OPTIONAL INPUT PARAMETERS:
;	Y
;		Numeric, acceptable only when X is a vector, in which case Y has to be
;		a vector of same length.
;
;		Note:	If only one input is provided then, if it is a [2,*] array, it
;				is split into X and Y vectors.  If it is a vector then it is
;				taken to be Y.  In such case X is generated internally as a
;				vector with spacing of 1, unless DELTA is explicitly provided.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	DELTA
;		Sets the spacing of the X coordinates of the data.  If the X coord.
;		are explicitly provided (see X input above) DELTA is ignored.
;	BASELINE
;		Optional baseline, to be subtracted from the Y values.  Can be given
;		either as a scalar or a vectro of same length as Y.
; OUTPUTS:
;		Returns the "square width" calculated as
;
;			(Integral(Y))^2/integral(Y^2)
;
;		For a gaussian this yields sigma*sqrt(4*pi).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Strightforward.  Calls INTEG, SPLIT_XY and FPU_FIX from MIDL.
; MODIFICATION HISTORY:
;		Created 10-JUN-2001 by Mati Meron.
;-

	on_error, 1
	nxy = Split_xy(x,y,x_ret=wx,y_ret=wy,inpx=inx)
	if nxy gt 0 then begin
		nbas = n_elements(bas)
		if nbas eq 1 or nbas eq nxy then wy = wy - bas $
		else if nbas ne 0 then message, 'Baseline size mismatch!'
		if not inx then res=Integ(wy,del=dex,/val)^2/Integ(wy^2,del=dex,/val) $
		else res = Integ(wx,wy,/val)^2/Integ(wx,wy^2,/val)
	endif else message, 'Bad or missing input!'

	return, FPU_fix(res)
end