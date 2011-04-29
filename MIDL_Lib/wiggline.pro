Pro Wiggline, from = tail, to = head, $
	periods = per, amplitude = amp, phase = pha, exact = exc, $
	device = dev, normal = nor, no_show = nsh, shapeout = shap, _extra = _e

;+
; NAME:
;		WIGGLINE
; VERSION:
;		4.0
; PURPOSE:
;		Draws a "wiggly line" (a sinusoid, to be exact) in the current plot
;		area, from the FROM to the TO location (with a possible modification
;		due to PHASE .  DATA coordinates are used, unless one of the keywords
;		/DEVICE or /NORMAL is set.  Alternatively, a *SHAPE* representation
;		(see SHAPE_VER) for definition) of the wiggly line may be returned
;		through the SHAPEOUT keyword.  DATA coordinates are used unless one
;		of the keywords /DEVICE or /NORMAL is set.
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		WIGGLINE, FROM = tail, TO = head [, keywords]
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	FROM
;		Two dimensional vector, start location, mandatory.
;	TO
;		Two dimensional vector, end location, mandatory.
;	PERIODS
;		Scalar, specifies number of wiggle periods.  Default value is 1.  Note
;		that if PERIODS isn't integer or half integer, the curve may miss the
;		point provided by TO.
;	AMPLITUDE
;		Scalar, specifies amplitude of oscillation, relative to
;		period_length/2*pi.  Default value is 1.
;	PHASE
;		Scalar, provides a phase offset, in fractions of a cycle. Default is 0.
;		Note that when the phase is not 0, the curve may be offset from the
;		points provided by FROM and TO.
;	/EXACT
;		Switch.  If set, PERIODS and PHASE are rounded to the nearest half-
;		integer, assuring that the curve will pass through both FROM and TO.
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
;		contains the *SHAPE* representation of the wiggly line.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The keywords passed through _EXTRA are transferred to the PLOTS
;		routine.  No keyword verification is performed by WIGGLINE.
; PROCEDURE:
;		Uses DEFAULT, MAKE_GRID, ONE_OF, SHAPE_COCON and VNORM from MIDL.
;		All the coordinates are converted to DEVICE coordinates for shape
;		generation and plotting purposes.
; MODIFICATION HISTORY:
;		Created 1-SEP-1999 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	per = Default(per,1.,/dtyp)
	amp = Default(amp,1.,/dtyp)
	wph = Default(pha,0.,/dtyp) mod 1
	if keyword_set(exc) then begin
		per = round(2*per)/2.
		wph = round(2*wph)/2.
	endif

	posib = ['DATA', 'DEVICE', 'NORMAL']
	sor = posib(1 + One_of(dev,nor))

	tem = Shape_cocon([[tail],[head]], from = sor, to = 'DEVICE')
	fro = tem(*,0)
	seg = tem(*,1) - tem(*,0)
	npo = 1 + 4*ceil(per*(sqrt(!pi*amp*Vnorm(seg)/(4*per)) > 1))

	s = Make_grid([0,1],npo)
	ss = amp/(2*!pi*per)*sin(2*!pi*(per*s + wph))

	wigl = transpose([[fro[0]+seg[0]*s-seg[1]*ss],[fro[1]+seg[1]*s+seg[0]*ss]])

	if not keyword_set(nsh) then plots, wigl, /device, _extra = _e
	shap = Shape_cocon(temporary(wigl), from = 'DEVICE', to = sor)

	return
end
