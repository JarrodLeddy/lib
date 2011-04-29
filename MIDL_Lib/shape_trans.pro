Function Shape_trans, shape, ang, mag, roff, $
	degrees = deg, flip = ax, center = cen

;+
; NAME:
;		SHAPE_TRANS
; VERSION:
;		4.0
; PURPOSE:
;		Performs a geometrical transformation of an arbitrary 2_dim shape.
;		The transformation may include (in order):
;			1)	Magnification by MAG.  If MAG is a 2-dim vector, X and Y
;				coordinates are magnified by MAG[0] and MAG[1] respectively.
;				If FLIP is set, the magnification will include inversion in
;				the X or Y axis, according to the value of FLIP.
;			2)	Rotation by the angle ANG.
;			3)	Translation by ROFF.
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		Result = SHAPE_TRANS( SHAPE [,parameters] [,keywords])
; INPUTS:
;	SHAPE
;		A [2,*] numeric array.  Future support for 3D shapes is planned.
; OPTIONAL INPUT PARAMETERS:
;	ANG
;		Rotation angle, assumed to be measured in radians, unless /DEGREES is
;		set.  Default value is 0, i.e. no rotation.
;	MAG
;		Magnification factor, can be given as a scalar (in which case both
;		dimensions are multiplied by this scalar) or a 2 dimensional vector (in
;		which case the X and Y dimensions are multiplied by MAG[0] and MAG[1]
;		respectively.  Default value is 1, i.e. no magnification.
;	ROFF
;		Translation vector.  Can be given as a scalar (in which case same
;		translation is applied to both dimensions) or as a 2 dimensional
;		vector.  Default is [0,0], i.e. no translation.
; KEYWORD PARAMETERS:
;	/DEGREES
;		Switch.  If set, the angle value is given in degrees.
;	FLIP
;		Accepts a char value ('X' or 'Y').  Causes inversion in the
;		appropriate axis.
;	/CENTER
;		Switch.  If set, the transformations are performed relative to the
;		center of the shape, given by the average of the minimal and maximal
;		value in each dimension.  By default the transformation center is [0,0].
; OUTPUTS:
;		0 for failure (improper or 3D shape) else returns the transformed shape.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		Currently limited to 2 dimensional shapes.
; PROCEDURE:
;		Uses calls to DEFAULT, FPU_FIX, SHAPE_VER, STRMATCH_MM and TYPE from
;		MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Modified 10-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	ndim = Shape_ver(shape)
	if not ndim then begin
		message, 'Improper or missing shape!', /continue
		return, 0
	endif else begin
		if ndim eq 3 then begin
			message, 'Only 2-dimensional shapes accepted!', /continue
			return, 0
		endif
	endelse

	dang = Default(ang,0.,low = 4)
	if keyword_set(deg) then dang = !dtor*dang
	srot = [[cos(dang),sin(dang)],[-sin(dang),cos(dang)]]
	dmag = Default(mag,1.,low = 4)
	if n_elements(dmag) eq 1 then dmag = replicate(dmag,ndim)
	if Type(ax) eq 7 then begin
		iflip = StrMatch_mm(ax,['X','Y','Z'],1)
		dmag[iflip] = -dmag[iflip]
	endif
	droff = Default(roff,0.,low = 4)
	if n_elements(droff) eq 1 then droff = replicate(droff,ndim)

	res = float(shape)
	if keyword_set(cen) then begin
		for i = 0, ndim - 1 do begin
			top = max(res[i,*], min = bot)
			pcen = (top + bot)/2
			droff[i] = droff[i] + pcen
			res[i,*] = res[i,*] - pcen
		endfor
	endif
	for i = 0, ndim - 1 do begin
		if dmag[i] ne 1 then res[i,*] = dmag[i]*res[i,*]
	endfor
	if dang ne 0 then res = srot#res
	for i = 0, ndim - 1 do begin
		if droff[i] ne 0 then res[i,*] = droff[i] + res[i,*]
	endfor

	return, FPU_fix(res)
end
