Pro Ellipse, center = cent, radii = rd, arc = ar, degrees = deg, $
	rotate = rot, rotation_center = rocent, fill = fil, $
	device = dev, normal = nor, no_show = nsh, shapeout = elli, _extra = _e

;+
; NAME:
;		ELLIPSE
; VERSION:
;		4.0
; PURPOSE:
;		Draws an ellipse, around CENTER, with radii given by RADII, optionally
;		rotating it by angle ROT.  The drawing is done in the currently
;		defined plot area.  Alternatively, a *SHAPE* representation (see
;		SHAPE_VER for definition) of the ellipse may be returned through the
;		SHAPEOUT keyword.  DATA coordinate system is assumed unless specified
;		otherwise by one of the keywords /DEVICE or /NORMAL.
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		ELLIPSE, CENTER = CENT, RADII = RD, [, optional keywords]
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	CENTER
;		2 dimensional vector, ellipse center location, format [x,y], mandatory.
;	RADII
;		2 dimensional vector, contains the x and y radii (in order), mandatory.
;	ARC
;		Optional.  Allows to draw an elliptical arc.  Accepts a vector of
;		length 2 containing the start and end angles for the arc.  If only one
;		value is provided, the arc is drown from angle 0 to this value if it is
;		positive, or from this value to 0 if it is negative.  The angles are
;		assumed to be in radians unless DEGREES is set.
;	/DEGREES
;		Switch.  Specifies that the rotation (and arc) angles are given in
;		degrees.
;	ROTATE
;		Optional.  Angle of rotation in the mathematical positive direction.
;		Assumed in radians, unless DEGREES is set.
;	ROTATION_CENTER
;		Optional.  Accepts a two element vector specifying the center of
;		rotation.  Ignored if ROTATE is not given.  Defaults to center of shape.
;	/FILL
;		Switch.  Causes the ellipse to be filled with a solid pattern.
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
;		directly.  See comment in RESTRICTIONS.
; OUTPUTS:
;		None.
; OPTIONAL OUTPUT PARAMETERS:
;	SHAPEOUT
;		When provided with the name of a variable,on return the variable
;		contains the *SHAPE* representation of the ellipse.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		If the DATA coordinate system is used and the plot area is defined with
;		nonlinear (logarithmic) axes, the shape won't look like an ellipse.
;		ELLIPSE calls either PLOTS or (when /FILL is used) POLYFILL.  Since
;		some graphics keywords work only with PLOTS, or only with POLYFILL,
;		some care must be exercised.
; PROCEDURE:
;		Uses calls to DEFAULT, ONE_OF, SHAPE_COCON and SHAPE_TRANS from MIDL.
;		Generates a (2,N) array containing a sufficient number of ellipse
;		points to yield a smooth curve.  N is variable, depending both on the
;		ellipse size and on the pixel size of the current output device.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Modified 15-DEC-1991 by Mati Meron.  Added size and device dependence
;		of the number of plot points.
;		Modified 15-OCT-1992 by Mati Meron.  Added rotation.
;		Modified 15-DEC-1993 by Mati Meron.  Now ELLIPSE takes advantage of the
;		keyword inheritance property and accepts all IDL plotting keywords.
;		Modified 1-MAY-1995 by Mati Meron.  Added capability to draw an
;		elliptical arc.
;		Modified 25-JUL-1999 by Mati Meron.  Added keyword SHAPEOUT.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	posib = ['DATA', 'DEVICE', 'NORMAL']
	sor = posib(1 + One_of(dev,nor))

	rsor = transpose([[[0,rd[0]] + cent[0]], [[0,rd[1]] + cent[1]]])
	rdev = Shape_cocon(rsor, from = sor, to = 'dev')
	dang = !pi/(2*ceil(!pi/4*sqrt(max(abs(rdev[*,1] - rdev[*,0])))))

	war = (1+keyword_set(deg)*(!dtor-1))*Default(ar,0.,/dtype)
	war = (war/(2*!pi) mod 1)*(2*!pi)
	if n_elements(war) eq 1 then war = [war < 0., war > 0.]
	if war[1] le war[0] then war[1] = war[1] + 2*!pi
	tem = war[0] + dang*lindgen(round((war[1] - war[0])/dang) + 1l)
	elli = transpose([[cent[0] + rd[0]*cos(tem)], [cent[1] + rd[1]*sin(tem)]])
	if n_elements(rot) ne 0 then begin
		rocent = Default(rocent,cent,low=4)
		elli = Shape_trans(elli,0,1,-rocent)
		elli = Shape_trans(elli,rot,1,rocent,degrees=deg)
    endif

	if not keyword_set(nsh) then if keyword_set(fil) then $
	polyfill, elli, device = dev, normal = nor, _extra = _e $
	else plots, elli, device = dev, normal = nor, _extra = _e

	return
end
