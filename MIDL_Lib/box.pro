Pro Box, xlims, ylims, border = brd, over = ov, truasp = traxy, $
	update_lims = upl, _extra = _e

;+
; NAME:
;		BOX
; VERSION:
;		4.0
; PURPOSE:
;		Creates an empty plot area, with boundaries defined by XLIMS and YLIMS.
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		BOX, XLIMS, YLIMS [, keywords]
; INPUTS:
;	XLIMS, YLIMS
;		2 dimensional vectors, format: [xmin,xmax] and [ymin,ymax] respectively.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/BORDER
;		Switch.  Draws a border around the plot area.  Default - no border.
;	/OVER
;		Switch.  Creates the plot area over an existing plot.  Default - new
;		plot area.
;	TRUASP
;		Corrects the XLIMS or YLIMS values to yield a 1:1 aspect ratio.
;		Accepts six possible character values (only first 2 characters matter):
;			'XLO' :  Scale x, keeping lowest x-value constant.
;			'XCEN':  Scale x, keeping center x-value constant.
;			'XHI' :  Scale x, keeping highest x-value constant.
;			'YLO' :  Scale y, keeping lowest y-value constant.
;			'YCEN':  Scale y, keeping center y-value constant.
;			'YHI' :  Scale y, keeping highest y-value constant.
;	/UPDATE_LIMS
;		Switch.  If set, XLIMS and YLIMS are updated to the values used in
;		plotting.
;	_EXTRA
;		A formal keyword used to pass all plotting keywords.  Not to be used
;		directly.  See comment in RESTRICTIONS.
; OUTPUTS:
;		None.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		If UPDATE_LIMS is set, the values of XLIMS, YLIMS may change.
; RESTRICTIONS:
;		The keywords passed through _EXTRA are transferred to the PLOTS
;		routine.  No keyword verification is performed by BOX.
; PROCEDURE:
;		Uses calls to CAST, and STRMATCH_MM from MIDL.  The scaling is done
;		using the sizes of the plotting area in device coordinates, provided by
;		the  system variables !d.x_vsize and !d.y_vsize.  Therefore the scaling
;		is always proper for the current output device.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Modified 15-DEC-1991 by Mati Meron.  Added keyword COLOR.
;		Modified 15-DEC-1993 by Mati Meron.  Now BOX takes advantage of the
;		keyword inheritance property and accepts all IDL plotting keywords.
;		Modified 1-MAY-1995 by Mati Meron.  Improved aspect ratio correction.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	blims = Cast(transpose([[xlims],[ylims]]),4,5)
	if keyword_set(brd) then sty = 16 else sty = 20

	if n_elements(traxy) ne 0 then begin
		posib = ['XLO','XCEN','XHI','YLO','YCEN','YHI']
		numop = StrMatch_mm(traxy,posib,2)
		if numop ge 0 then begin
			ic = numop/3
			horp = !p.multi[1] > 1.
			verp = !p.multi[2] > 1.
			if !p.charsize eq 0 then chas = 1. else chas = !p.charsize
			if (horp > verp) gt 2 then chas = 0.5*chas
			facx = float(round((!d.x_vsize - $
				horp*chas*!d.x_ch_size*total(!x.margin))/horp>$
				(-chas*!d.x_ch_size*!x.margin[0])))
			facy = float(round((!d.y_vsize - $
				verp*chas*!d.y_ch_size*total(!y.margin))/verp>$
				(-chas*!d.y_ch_size*!y.margin[1])))
			fac = abs(facy/facx)
			span = (blims[1-ic,1] - blims[1-ic,0])*fac^(2*ic - 1)
			case numop mod 3 of
			0	:	blims[ic,1] = blims[ic,0] + span
			1	:	blims[ic,*] = 0.5*(total(blims[ic,*]) + span*[-1,1])
			2	:	blims[ic,0] = blims[ic,1] - span
			endcase
		endif else message, 'Illegal reference line entry!'
		sty = sty + 1
		if keyword_set(upl) then begin
			xlims = transpose(blims[0,*])
			ylims = transpose(blims[1,*])
		endif
	endif

	plot, blims[0,*], blims[1,*], /nodata, xstyle = sty, ystyle = sty, $
	noerase = keyword_set(ov), ticklen = 0, _extra = _e

	return
end
