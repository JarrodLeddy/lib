Function Shape_cocon, shape, from = sor, to = des

;+
; NAME:
;		SHAPE_COCON
; VERSION:
;		4.0
; PURPOSE:
;		Converts 2 or 3 dimensional shapes from the FROM to the TO coordinate
;		system.  Allowed systems are DATA, DEVICE (only for 2-dim shapes) and
;		NORMAL.  In principle identical to the system routine CONVERT_COORD,
;		SHAPE_COCON is maintained for historical reasons.
; CATEGORY:
;		Plotting / General Graphics.
; CALLING SEQUENCE:
;		Result = SHAPE_COCON( SHAPE [,keywords])
; INPUTS:
;	SHAPE
;		A [2,*] or [3,*] array.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	FROM
;		Specifies input coordinate system.  Possible values are 'DATA',
;		'DEVICE' and 'NORMAL' (Only the first 3 characters matter).  Default
;		is 'DATA'.
;	TO
;		Same as FROM for the output coordinate system.
; OUTPUTS:
;		0 for failure (improper shape or bad keyword value) else returns the
;		transformed shape.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses calls to CAST, COO_CONV, DEFAULT and SHAPE_VER, from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Modified 30-JUL-1999 by Mati Meron.  Type conversion bug fixed.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	ndim = Shape_ver(shape)
	if not ndim then begin
		message, 'Missing or invalid shape!', /continue
		return, 0
	endif else res = Cast(shape,4)

	sor = Default(sor,'DATA')
	des = Default(des,'DATA')

	if sor ne des then begin
		for i = 0, ndim - 1 do begin
			res[i,*] = Coo_conv(res[i,*], axis = i, from = sor, to = des)
		endfor
	endif

	return, res
end
