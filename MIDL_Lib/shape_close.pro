Function Shape_close, shape

;+
; NAME:
;		SHAPE_CLOSE
; VERSION:
;		4.0
; PURPOSE:
;		Closes the shape, i.e. appends the first point to the end of the shape,
;		unless the shape is already closed in which case nothing happens.
; CATEGORY:
;		Array Manipulation / General Graphics.
; CALLING SEQUENCE:
;		Result = SHAPE_CLOSE( SHAPE)
; INPUTS:
;	SHAPE
;		A [2,*] or [3,*] numeric array.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		0 for failure, i.e. a missing or invalid shape, otherwise returns the
;		closed shape.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Uses calls to ARREQ and SHAPE_VER in MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	if (Shape_ver(shape, len = shlen)) eq 0 then begin
		message, 'Missing or invalid shape!', /continue
		return, 0b
	endif else begin
		if Arreq(shape[*,0],shape[*,shlen-1]) then return, shape $
		else return, [[shape],[shape[*,0]]]
	endelse
end
