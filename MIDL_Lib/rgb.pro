Pro RGB, first = fir, last = las, range = rn, loop = lp, true_out = tru

;+
; NAME:
;		RGB
; PURPOSE:
;		Fills the IDL color table (or part of it).
; CATEGORY:
;		Graphics.
; CALLING SEQUENCE:
;		RGB [, keywords]
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	FIRST
;		Scalar or vector (up to three elements).  Specifies the Red, Green and
;		Blue content of the first color.  Defaults to [0,0,0] (black).  All
;		missing entries are replaced by zeroes.
;	LAST
;		Same as FIRST, for the last color.  Defaults to [255,255,255] (white).
;		All missing entries are replaced by 255 (maximal content).
;	RANGE
;		Scalar or two-element vector.  Specifies the adresses of the first and
;		last color to be replaced.  Defaults to [0,255] (full table).  If given
;		as a scalar, the second value becomes 255.
;	/LOOP
;		Switch.  Normally RGB fills the colors between FIRST and LAST with
;		linearly interpolated values.  If LOOP is set, the interpolation is
;		sinusoidal so that the range [FIRST,LAST] forms a closed loop of colors.
;	TRUE_OUT
;		Optional output, see below.
; OUTPUTS:
;		None.
; OPTIONAL OUTPUT PARAMETERS:
;	TRUE_OUT
;		A list of True_Color indices corresponding to the color table entries.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Generates the color entries and inserts them in table
;		through a call to TVLCT.  Uses DEFAULT from MIDL.
; MODIFICATION HISTORY:
;		Created 15-DEC-1991 by Mati Meron.
;		Modified 30-APR-2001 by Mati Meron.  Added keyword TRUE_OUT
;-

	max = 255
	fir = 0 > Default(fir, [0, 0, 0]) < max
	if n_elements(fir) eq 1 then fir = [fir, 0, 0] $
	else if n_elements(fir) eq 2 then fir = [fir, 0]
	las = 0 > Default(las, [max, max, max]) < max
	if n_elements(las) eq 1 then las = [las, max, max] $
	else if n_elements(las) eq 2 then las = [las, max]
	rn = 0 > fix(Default(rn, [0, max])) < max
	if n_elements(rn) eq 1 then rn = [rn, max]

	tlen = rn[1] - rn[0] + 1
	if (tlen gt 1) then begin
		if keyword_set(lp) then dum = sin(!pi/tlen*findgen(tlen)) $
		else dum = findgen(tlen)/(tlen - 1)
		tabl = intarr(3,tlen)
		for i = 0, 2 do begin
			tabl[i,*] = round(fir[i] + (las[i] - fir[i])*dum)
		endfor
	endif else tabl = round(fir)
	tru = reform(tabl[0,*] + 256l*(tabl[1,*] + 256l*tabl[2,*]))

	tvlct, tabl[0,*], tabl[1,*], tabl[2,*], rn[0]

	return
end
