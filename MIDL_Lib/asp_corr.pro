Function Asp_Corr, shape, reference = reflin

;+
; NAME:
;		ASP_CORR
; VERSION:
;		4.0
; PURPOSE:
;		Corrects the aspect ratio of a 2-dimensional shape, in order to make up
;		for for different scaling in the x and y dimensions.
; CATEGORY:
;		Array Manipulation /General Graphics.
; CALLING SEQUENCE:
;		Result = ASP_CORR( SHAPE, REFERENCE = reflin)
; INPUTS:
;	SHAPE
;		(2,*) numeric array, mandatory.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	REFERENCE
;		Defines the scaling procedure, according to the provided character
;		value.  Accepts one of the following six values (only the first two
;		characters matter):
;			'XLO' :  Scale x, keeping lowest x-value constant.
;			'XCEN':  Scale x, keeping center x-value constant.
;			'XHI' :  Scale x, keeping highest x-value constant.
;			'YLO' :  Scale y, keeping lowest y-value constant.
;			'YCEN':  Scale y, keeping center y-value constant.
;			'YHI' :  Scale y, keeping highest y-value constant.
; OUTPUTS:
;		0 in case of failure (bad or missing shape or keyword value), otherwise
;		the transformed shape is returned as a floating array (double if the
;		input is of type double).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		Three dimensional shapes aren't currently accepted.
; PROCEDURE:
;		Uses calls to CAST, DEFAULT, SHAPE_VER and STRMATCH_MM from MIDL.  The
;		scaling is done using the sizes of the plotting area in device
;		coordinates, provided by the system variables !d.x_vsize and
;		!d.y_vsize.  Therefore the scaling is always proper for the current
;		output device.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	if Shape_ver(shape) ne 2 then begin
		message, 'Missing or invalid shape!', /continue
		return, 0
	endif

	posib = ['XLO','XCEN','XHI','YLO','YCEN','YHI']
	numop = StrMatch_mm(reflin,posib,2)
	if numop ge 0 then begin
		res = Cast(shape,4,5)
		ic = numop/3
		fac = (float(!d.y_vsize)/!d.x_vsize)^(1 - 2*ic)
		top = max(res[ic,*], min = bot)
		case (numop - 3*ic) of
			0	:	ref = bot
			1	:	ref = (top + bot)/2
			2	:	ref = top
		endcase
		res[ic,*] = (res[ic,*] - ref)*fac + ref
	endif else begin
		show = strupcase(Default(reflin,'___',/strict))
		message, show + ' is not a valid reference line!',/continue
		return, 0
	endelse

	return, res
end
