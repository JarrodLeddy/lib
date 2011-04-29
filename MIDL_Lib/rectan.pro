Pro Rectan, xlims = xls, ylims = yls, radius = rad, relative = rel, $
	xwiggle = xwg, ywiggle = ywg, rotate = rot, rotation_center = rocent, $
	degrees = deg, fill = fil, device = dev, normal = nor, $
	no_show = nsh, shapeout = rect, _extra = _e

;+
; NAME:
;		RECTAN
; VERSION:
;		4.0
; PURPOSE:
;		Draws a rectangle between the limits specified by XLIMS and YLIMS,
;		possibly rotated and/or rounded  The drawing is done in the currently
;		defined plot area.  Alternatively, a *SHAPE* representation (see
;		SHAPE_VER for definition) of the rectangle may be returned through the
;		SHAPEOUT keyword.  DATA coordinate system is assumed unless specified
;		otherwise by one of the keywords /DEVICE or /NORMAL.
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		RECTAN, XLIMS = XLS, YLIMS = YLS [, optional keywords]
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	XLIMS
;		2 dimensional vector, format [xmin,xmax], mandatory.
;	YLIMS
;		2 dimensional vector, format [xmin,xmax], mandatory.
;	RADIUS
;		Value of radius for rounded corners.
;	/RELATIVE
;		Switch.  Specifies that the radius value is relative to the shorter
;		side of the rectangle.
;	XWIGGLE
;		Optional.  Allows to change the two sides parallel to the X-axis
;		(before rotation, if any) into sinusoidal lines.  Can be given as
;		scalar, 2D or 3D vector.  The first parameter is number of periods,
;		the second is amplitude and the third phase (see the routine WIGGLINE
;		for explanation).  Number of periods is always rounded to nearest
;		integer or half integer and the phase is rounded to 0 or half period.
;		Default for amplitude is 1, for phase is 0.
;
;		Note:  If RADIUS (see above) is given, XWIGGLE is ignored.
;	YWIGGLE
;		Same as XWIGGLE, for the Y sides.
;	ROTATE
;		Optional.  Angle of rotation in the mathematical positive direction.
;		Assumed in radians, unless DEGREES is set.  Rotation center is the
;		center of the rectangle unless specified otherwise by the keyword
;		ROTATION_CENTER (see below).
;	ROTATION_CENTER
;		Optional.  Accepts a two element vector specifying the center of
;		rotation.  Ignored if ROTATE is not given.  Defaults to center of shape.
;	/DEGREES
;		Switch.  Specifies that the rotation angle is given in degrees.
;	/FILL
;		Switch.  Causes the rectangle to be filled with a solid pattern.
;	/DEVICE
;		Standard IDL plotting interpretation.
;	/NORMAL
;		Ditto.
;	/NO_SHOW
;		Switch.  If set, no plotting is done, but the shape is generated and
;		may be returned through SHAPEOUT.
;	SHAPEOUT
;		Optional output, see below.
;	_EXTRA
;		A formal keyword used to pass all plotting keywords.  Not to be used
;		directly.
; OUTPUTS:
;		None.
; OPTIONAL OUTPUT PARAMETERS:
;	SHAPEOUT
;		When provided with the name of a variable, on return the variable
;		contains the *SHAPE* representation of the rectangle.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		RECTAN calls either PLOTS or (when /FILL is used) POLYFILL.  Since
;		some graphics keywords work only with PLOTS, or only with POLYFILL,
;		some care must be exercised.
; PROCEDURE:
;		Uses calls to DEFAULT, HOW_MANY, ONE_OF, SHAPE_CLOSE, SHAPE_COCON,
;		SHAPE_TRANS and WIGGLINE from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Modified 15-OCT-1991 by Mati Meron.  Added keyword COLOR.
;		Modified 15-OCT-1992 by Mati Meron.  Added rotation capability.
;		Modified 30-OCT-1992 by Mati Meron.  Added corner rounding capability.
;		Modified 15-DEC-1993 by Mati Meron.  Now RECTAN takes advantage of the
;		keyword inheritance property and accepts all IDL graphics keywords.
;		Modified 25-JUL-1999 by Mati Meron.  Added keywords NO_SHOW and
;		SHAPEOUT.
;		Modified 20-SEP-1999 by Mati Meron.  Added possibility of wiggly
;		borders through the keywords XWIGGLE and YWIGGLE.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	posib = ['DATA', 'DEVICE', 'NORMAL']
	sor = posib(1 + One_of(dev,nor))

	rls = transpose([[min(xls, max = sec), sec],[min(yls, max = sec), sec]])
	corn = rls([[2,3],[0,3],[0,1],[2,1]])
	dxy = rls[*,1] - rls[*,0]
	rad = Default(rad,0.,/dtype)

	if rad gt 0 then begin
		radx = 0.5*min(dxy)
		if keyword_set(rel) then rad = radx*rad
		rad = rad < radx
		cent = corn - rad*[[1,1],[-1,1],[-1,-1],[1,-1]]
		rect = [0,0]
		for i = 0, 3 do begin
			rsor = [[corn[*,i]],[cent[*,i]]]
			rdev = Shape_cocon(rsor, from = sor, to = 'dev')
			npoints = 1 + fix(!pi/4*sqrt(max(abs(rdev[*,1] - rdev[*,0]))))
			tem = !pi/(2*npoints)*(indgen(npoints + 1) + i*npoints)
			arc = transpose([[cent[0,i]+rad*cos(tem)],[cent[1,i]+rad*sin(tem)]])
			rect = [[rect],[arc]]
		endfor
		rect = Shape_close(rect[*,1:*])
    endif else begin
		rect = Shape_close(corn)
		nwig = How_many(fir=xwg,sec=ywg,which=whig)
		if nwig gt 0 then begin
			ar = rect[*,0:1]
			br = rect[*,1:2]
			cr = rect[*,2:3]
			dr = rect[*,3:4]
			if (whig and 1) ne 0 then begin
				wpar = [xwg,1,1]
				Wiggline, from = ar[*,0], to = ar[*,1], /exact, /no_show, $
				shap= ar, per = wpar[0], amp = wpar[1], pha = wpar[2]
				cr = reverse(ar,2)
				cr[1,*] = cr[1,*] - dxy[1]
			endif
			if (whig and 2) ne 0 then begin
				wpar = [ywg,1,1]
				Wiggline, from = br[*,0], to = br[*,1], /exact, /no_show, $
				shap= br, per = wpar[0],amp = wpar[1], pha = wpar[2]
				dr = reverse(br,2)
				dr[0,*] = dr[0,*] + dxy[0]
			endif
			rect = [[ar],[br[*,1:*]],[cr[*,1:*]],[dr[*,1:*]]]
		endif
    endelse

	if n_elements(rot) ne 0 then begin
		rocent = Default(rocent,0.25*total(corn,2),low=4)
		rect = Shape_trans(rect,0,1,-rocent)
		rect = Shape_trans(rect,rot,1,rocent,degrees= deg)
	endif

	if not keyword_set(nsh) then if keyword_set(fil) then $
	polyfill, rect, device=dev, normal=nor, _extra = _e $
	else plots, rect, device = dev, normal = nor, _extra = _e

	return
end
