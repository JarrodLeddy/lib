Function Shape_ver, shape, length = len

;+
; NAME:
;		SHAPE_VER
; VERSION:
;		4.0
; PURPOSE:
;		Checks whether SHAPE is a proper shape, i.e. a [2,*] or [3,*] , numeric
;		non-complex array.
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		Result = SHAPE_VER( SHAPE [, LENGTH = LEN])
; INPUTS:
;	SHAPE
;		Arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	LENGTH
;		Provides an optional output.  See below.
; OUTPUTS:
;		If SHAPE fits the definition of a proper shape (see above), returns the
;		number of dimensions (2 or 3) as floating, otherwise returns 0.
; OPTIONAL OUTPUT PARAMETERS:
;	LENGTH
;		The name of a variable to receive the length (number of points) of the
;		shape.  If the shape isn't defined or isn't proper, the value is 0.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses information provided by the system function SIZE.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron under the name IS_SHAPE.
;		Renamed SHAPE_VER, 25-NOV-1993 for consistency with other shape routines
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	siz = size(shape)
	if siz[0] eq 2 then begin
		proper = (siz[1] eq 2 or siz[1] eq 3) and siz[3] lt 6
		len = siz[2]*proper
		return, float(siz[1])*proper
	endif else begin
		len = 0
		return, 0.
	endelse
end
