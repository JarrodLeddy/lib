Pro Square, base = bas, height = hei, side = sid, $
	ll_corner = llc, lr_corner = lrc, ur_corner = urc, ul_corner = ulc, $
	wiggle = wig, fill = fil, device = dev, normal = nor, $
	no_show = nsh, shapeout = shap, _extra = _e

;+
; NAME:
;		SQUARE
; VERSION:
;		4.0
; PURPOSE:
; 		Draws a SQUARE, based on a length of a side and a given location of a
;		corner.  The square is drawn so as to appear visually as a square, even
;		if the lengths of the sides in DATA coordinates differ.  The drawing is
;		done in the currently defined plot area.  Alternatively, a *SHAPE*
;		representation (see SHAPE_VER for definition) of the square may be
;		returned through the SHAPEOUT keyword. DATA coordinates are used unless
;		one of the keywords /DEVICE or /NORMAL is set.
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		Square, {BASE = BAS, HEIGHT = HEI, SIDE = SID}, $
;		{LL_CORNER = LLC, LR_CORNER = LRC, UR_CORNER = URC, UL_CORNER = ULC}, $
;		[optional keywords]
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None
; KEYWORD PARAMETERS:
;	BASE												|
;		Length of side, measured in the X-direction.	| One
;	SIDE												| and only one
;		Same as BASE.									| must be
;	HEIGHT												| provided
;		Length of side, measured in the Y-direction.	|
;
;	LL_CORNER												|
;		2dim vector, coordinates of the lower left corner.	|
;	LR_CORNER												| One
;		2dim vector, coordinates of the lower right corner.	| and only one
;	UR_CORNER												| must be
;		2dim vector, coordinates of the upper right corner.	| provided
;	UL_CORNER												|
;		2dim vector, coordinates of the upper left corner.	|
;
;	WIGGLE
;		Optional.  Allows to change the sides of the square from straight to
;		sinusoidal lines.  Can be given as scalar, 2D or 3D vector.  The first
;		parameter (mandatory) is number of periods, the second and third
;		(optional) are amplitude and phase, respectively (see the routine
;		WIGGLINE for explanation).  Number of periods is always rounded to
;		nearest integer or half integer and the phase is rounded to 0 or half
;		period.  Default for amplitude is 1, for phase is 0.
;	/FILL
;		Switch.  Causes the square to be filled with a solid pattern.
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
;		contains the *SHAPE* representation of the square.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		SQUARE passes the extra keywords through _EXTRA, without checking.
;		Therefore, some care must be exercised.
; PROCEDURE:
;		Uses calls to COO_CONV, ONE_OF and SHAPE_COCON from MIDL.  Converts all
;		parameters to device coordinates and calls RECTAN (also from MIDL) to
;		do the actual plotting.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Modified 15-DEC-1993 by Mati Meron.  Now SQUARE takes advantage of the
;		keyword inheritance property and accepts all IDL plotting keywords.
;		Modified 25-JUL-1999 by Mati Meron.  Added keywords NO_SHOW and
;		SHAPEOUT.
;		Modified 20-SEP-1999 by Mati Meron.  Added possibility of wiggly
;		borders, through the keyword WIGGLE.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	dnum = One_of(bas,hei,sid,  value = psid) mod 2
	if dnum eq -1 then message, 'Either base or height must be provided!'
	cnum = One_of(llc,lrc,urc, ulc, value = corner)
	if cnum eq -1 then message, 'One corner must be provided!'

	posib = ['DATA', 'DEVICE', 'NORMAL']
	sor = posib(1 + One_of(dev,nor))

	tem = [corner[dnum],corner[dnum] + psid]
	if (cnum - dnum) eq 1 or (cnum - dnum) eq 2 then tem = tem - psid
	tem = Coo_conv(tem, axis = dnum, from = sor, to = 'DEVICE')
	psid = tem[1] - tem[0]

	x = Coo_conv(corner[0], axis = 'X', from = sor, to = 'DEVICE')
	y = Coo_conv(corner[1], axis = 'Y', from = sor, to = 'DEVICE')
	xlims = [x, x + psid]
	ylims = [y, y + psid]
	if cnum eq 1 or cnum eq 2 then xlims = xlims - psid
	if cnum eq 2 or cnum eq 3 then ylims = ylims - psid

	Rectan, xlims = xlims, ylims = ylims, xwiggle = wig, ywiggle = wig, $
	/device, fill = fil, no_show = nsh, shapeout = shap, _extra = _e

	shap = Shape_cocon(temporary(shap),from = 'DEVICE', to = sor)

	return
end
