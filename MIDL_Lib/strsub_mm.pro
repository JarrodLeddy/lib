Function StrSub_mm, str, v_0, v_1, v_2, v_3, v_4, v_5, v_6, v_7, $
	wildcard = wld, recycle = rec

;+
; NAME:
;		STRSUB_MM
; VERSION:
;		5.5
; PURPOSE:
;		Substitutes strings for wildcards in an input character string.
; CATEGORY:
;		String Processing.
; CALLING SEQUENCE:
;		Result = STRSUB_MM( STR [,V_0 [.... ,V_7]], [keywords])
; INPUTS:
;	STR
;		Scalar character string
; OPTIONAL INPUT PARAMETERS:
;	V_0 through V_7
;		Scalars, of arbitrary type (except for structure) serving as
;		substitution variables.  All optional, however see details below.
; KEYWORD PARAMETERS:
;	WILDCARD
;		The character or combination of characters serving as wildcard.
;		Default is "?".
;	/RECYCLE
;		Switch.  If set, the substitution variables are recycled as needed.
;		Details below.
; OUTPUTS:
;		Returns the input STR, with the first instance of the wildcard being
;		replaced by the (atring) value of V_0, the second with V_1 and so on.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None other than those listed above (i.e. all inputs must be scalars).
; PROCEDURE:
;		Identifies all locations where the wildcard is present within STR and
;		replaces the wildcards, in order, by the string value of V_0, V_1 ...
;		etc.  (if any of the V_i inputs is not a string, it is converted into
;		a string internally).  If /RECYCLE is not set, the number of the V_i
;		inputs provided must be equal or greater than the number of wildcards
;		present.  If /RECYCLE is set, the V_i values are reused (going back to
;		the beginning upon reaching the end.  In this case even a single V_0 is
;		sufficient.  If no wildcards are present in STR, it is returned
;		unchanged.
;		Calls DEFAULT and STRPARSE_MM from MIDL.
; MODIFICATION HISTORY:
;		Created 15-OCT-2006 by Mati Meron.
;-

	on_error, 1
	nmax = 8

	nv = n_params() - 1
	if nv ge 0 then begin
		wwld = Default(wld,'?',/dtyp)
		vnam =  strcompress('v_' + sindgen(nmax),/remove)
		vsub =  strarr(nmax)
		for i = 0, nv-1 do begin
			dum = execute('siz = size(' + vnam[i] + ')')
			if siz[0] eq 0 then begin
				case siz[1] of
					7	:	dum = execute('vsub[i] =' + vnam[i])
					8	:	message, 'Structure substitutions not allowed!'
					else:	dum = execute('vsub[i] = strtrim(string(' + $
								vnam[i] + '),2)')
				endcase
			endif else message, 'Only scalar substitutions allowed!'
		endfor
		ns = Strparse_mm(' ' + str + ' ',wwld,lis)
		if ns le nv or keyword_set(rec) then begin
			for j = 0, ns - 1 do lis[j] = lis[j] + vsub[j mod nv]
			res = strtrim(strjoin(lis),2)
		endif else message, 'Insufficient number of substitution variables!'
	endif else message, 'Missing input(s)!'

	return, res
end