Pro Labels, x, y, labs, align = aln, _extra = _e

;+
; NAME:
;		LABELS
; VERSION:
;		4.0
; PURPOSE:
;		Multiple XYOUTS interface.
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		LABELS, X, Y, LABS [ ,ALIGN = ALN] [, optional keywords]
; INPUTS:
;	X
;		The X coordinates of the labels.  Can be given either as a scalar (in
;		which case all the labels will have the same x coordinate) or as a
;		vector of the same length as the LABS vector.
;	Y
;		Same as above for the Y coordinates.
;	LABS
;		A character vector containing the labels to be drawn.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	ALIGN
;		The allignment parameter for LABS (see ALIGN graphics keyword in the
;		IDL manual.  Can be given as a vector, thus providing individual
;		allignment parameter to each string in LABS.
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
;		If any of X, Y or ALIGN is given as a scalar variable, it is converted
;		to a vector of the same length as LABS.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straigtforward.  Calls DEFAULT from MIDL.
; MODIFICATION HISTORY:
;		Created 10-DEC-1991 by Mati Meron.
;		Modified 15-DEC-1993.  Incorporated keyword inheritance, allowing for
;		using all the XYOUTS keywords.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	nlab = n_elements(labs)
	if n_elements(x) eq 1 then x = replicate(float(x),nlab)
	if n_elements(y) eq 1 then y = replicate(float(y),nlab)
	aln = Default(aln,fltarr(nlab))
	if n_elements(aln) eq 1 then aln = replicate(float(aln),nlab)

	for i = 0l, nlab-1 do xyouts, x[i], y[i], labs[i], align= aln[i], _extra= _e

	return
end
