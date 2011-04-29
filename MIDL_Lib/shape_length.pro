Function Shape_length, shape, close = clo

;+
; NAME:
;		SHAPE_LENGTH
; VERSION:
;		4.3
; PURPOSE:
;		Calculates the length of a 2-dimensional shape.
; CATEGORY:
;		Mathematical Array function.
; CALLING SEQUENCE:
;		Result = SHAPE_LENGTH( SHAPE [ /CLOSE])
; INPUTS:
;	SHAPE
;		A [2,*] numeric array.  3D shapes are not supported.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/CLOSED
;		Switch.  If set, the shape is closed prior to calculation.
; OUTPUTS:
;		Returns the length of the shape (if the shape is closed, the length is
;		the perimeter of the shape).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		Limited to 2 dimensional shapes.
; PROCEDURE:
;		Straightforward.  Calls FPU_FIX, SHAPE_CLOSE and SHAPE_VER from MIDL.
; MODIFICATION HISTORY:
;		Created 25-MAR-2003 by Mati Meron.
;-

	on_error, 1
	ndim = Shape_ver(shape, length = len)
	if ndim ne 2 then begin
		if ndim eq 3 then message, 'Only 2-D shapes accepted!' $
		else message, 'Improper or missing shape!'
	endif else begin
		if keyword_set(clo) then wsh = Shape_close(shape) else wsh = shape
		x = reform(wsh[0,*])
		y = reform(wsh[1,*])
		len = total(sqrt((x[1:*] - x)^2 + (y[1:*] - y)^2))
	endelse

	return, FPU_fix(len)
end