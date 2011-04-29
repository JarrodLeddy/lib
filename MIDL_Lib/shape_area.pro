Function Shape_area, shape

;+
; NAME:
;		SHAPE_AREA
; VERSION:
;		4.0
; PURPOSE:
;		Calculates the area enclosed by a 2-dimensional shape.
; CATEGORY:
;		Mathematical Array function.
; CALLING SEQUENCE:
;		Result = SHAPE_AREA( SHAPE)
; INPUTS:
;	SHAPE
;		A [2,*] numeric array.  3D shapes are not supported.
; OPTIONAL INPUT PARAMETERS:
;		None.
; OUTPUTS:
;		0 for failure (improper or 3D shape) else returns the area of the shape.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		Limited to 2 dimensional shapes.
; PROCEDURE:
;		Straightforward.  Calls FPU_FIX and SHAPE_VER from MIDL.
; MODIFICATION HISTORY:
;		Created 10-NOV-1992 by Mati Meron.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	ndim = Shape_ver(shape, length = len)
	if ndim ne 2 then begin
		if ndim eq 3 then message, 'Only 2-D shapes accepted!' $
		else message, 'Improper or missing shape!'
	endif else begin
		offs = shift(lindgen(len),-1)
		area = 0.5*total(shape[0,*]*shape[1,offs] - shape[0,offs]*shape[1,*])
	endelse

	return, FPU_fix(area)
end
