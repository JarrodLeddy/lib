Function StrValid_mm, expr, str, pos, $
	prefix = pref, postfix = post, text = tex, _extra = _e

;+
; NAME:
;		STRVALID_MM
; VERSION:
;		4.2
; PURPOSE:
;		Locating a substring within a string, subject to "boundary conditions".
; CATEGORY:
;		String processing.
; CALLING SEQUENCE:
;		Result = STRVALID_MM( EXPR, STR [keywords])
; INPUTS:
;	EXPR
;		The expression in which to search for the substring (see STRPOS).
;	STR
;		The substring to be searched for within EXPR (see STRPOS).
; OPTIONAL INPUT PARAMETERS:
;	POS
;		The character position at which the search is begun (see STRPOS).
;		Default value is 0.
; KEYWORD PARAMETERS:
;	PREFIX
;		Character string, including all the characters which can legitimately
;		preceed STR within EXPR.  Default is "any character".
;	POSTFIX
;		Character string, including all the characters which can legitimately
;		follow STR within EXPR.  Default is "any character".
;	/TEXT
;		Switch.  If set then both PREFIX and POSTFIX default to "puctuation
;		and operation characters" i.e. all characters which are neither a
;		letter nor a number.
; OUTPUTS:
;		Returns the position of STR within EXPR, same as STRPOS.  However, if
;		PREFIX and/or POSTFIX are set (directly or through TEXT), and STR
;		appears within EXPR while being preceded by a character *not* in
;		PREFIX, or followed by a character not in POSTFIX, this occurence
;		won't count.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses IDL STRPOS, followed by checking of the preceding and following
;		character, if such exist.  Calls DEFAULT from MIDL.
; MODIFICATION HISTORY:
;		Created 15-SEP-2001 by Mati Meron.
;-

	on_error, 1
	punc = '	 !$&*()-+=[]{}\;:",<.>/?' + "'"

	elen = strlen(expr)
	slen = strlen(str)

	if keyword_set(tex) then begin
		pref = Default(pref,punc,/dtyp)
		post = Default(post,punc,/dtyp)
		prefl = 1
		posfl = 1
	endif else begin
		if keyword_set(pref) then prefl = 1 else prefl = 0
		if keyword_set(post) then posfl = 1 else posfl = 0
	endelse

	res = strpos(expr,str,Default(pos,0l,/dtyp),_extra=_e)
	if res gt 0 and prefl $
	then preres = strpos(pref,strmid(expr,res-1,1)) else preres = 1l
	if (res + slen) lt elen and posfl $
	then posres = strpos(post,strmid(expr,res+slen,1)) else posres = 1l
	if preres lt 0 or posres lt 0 then res = -1l

	return, res
end