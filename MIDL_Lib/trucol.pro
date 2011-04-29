Function Trucol, r, g, b, scale = sca, max_scale = mxs, load = loa, start = sta
;+
; NAME:
;		TRUCOL
; VERSION:
;		4.8
; PURPOSE:
;		Generates True Color values for display purposes.
; CATEGORY:
;		Graphics utility.
; CALLING SEQUENCE:
;		Result = TRUCOL( R [,G, B] [keywords]
; INPUTS:
;	R
;		Numeric.  A scalar, vector or a 2D array.
;	G
;		Numeric.  A scalar or vector.
;	B
;		Numeric.  A scalar or vector.
;
;	Note:	1)	Either only R or all three of R, G, B must be given.
;			2)	If only R is given, it must be a [3,N] array or, optionally, a
;				vector of length 3 which is treated as a [3,1] array.
;			3)	If all three inputs are given, they must all be scalars or
;				vectors of same length.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	SCALE
;		Numeric (integer) parameter, determines the division of color ranges
;		into parts.  Default value is 4.
;	/MAX_SCALE
;		Switch.  If set, the default value of SCALE is set at the maximum, i.e.
;		!D.TABLE_SIZE.
;
;		Note:	If an actual value is provided, through SCALE, it overrides the
;				defaults even if MAX_SCALE is set.
;	/LOAD
;		Switch.  If set, the colors defined by R, G, B are also loaded into the
;		current color table.
;	START
;		Provides the value for the starting loading location (default is zero).
;		If /LOAD is not set, START has no effect.
; OUTPUTS:
;		Returns one or more True color values.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Converts each triple present in input(s) (i.e. either a row of R if
;		given as array or a triple of values one each from R, G and B) into
;		a proper True color index.  The input values are scaled by
;		(!D.TABLE_SIZE-1)/SCALE.  Thus, in the default situation where
;		!D.TABLE_SIZE = 256 and SCALE = 4, an input value of, say, 2, yields
;		127, etc.
;		Calls DEFAULT, JOIN_XY, and TYPE, from MIDL.
; MODIFICATION HISTORY:
;		Created 5-MAR-2004 by Mati Meron.
;		Modified 25-DEC-2004 by Mati Meron.  Added keywords LOAD and START.
;-

	on_error, 1
	bas = !d.table_size
	if keyword_set(mxs) then defsca = bas else defsca = 4l
	wsca = Default(sca,defsca,/dtyp) < bas

	case fix(total([Type(r),Type(g),Type(b)] gt 0)) of
		1	:	begin
					siz = size(r)
					if (siz[0] eq 1 or siz[0] eq 2) and siz[1] eq 3 then begin
						if siz[0] eq 1 then rgb = reform(r,3,1) else rgb = r
					endif else message, 'Bad input format!'
				end
		3	:	rgb = Join_xy(r,g,b)
		else:	message, 'Band or missing input!'
	endcase

	n = (size(rgb))[2]
	rgb = long((bas - 1.)/wsca*(0 > long(rgb) < wsca))
	res = reform(rgb[0,*] + bas*(rgb[1,*] + bas*rgb[2,*]))

	if keyword_set(loa) then tvlct, rgb[0,*],rgb[1,*],rgb[2,*],Default(sta,0)

	if n eq 1 then return, res[0] else return, res
end