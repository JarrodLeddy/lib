Function Streq, str1, str2, len, caseon = cas, reverse = rev, warn = wn

;+
; NAME:
;		STREQ
; VERSION:
;		4.0
; PURPOSE:
;		Compares for equality the first LEN characters of STR1, STR2.
;		If LEN is 0, or absent, the whole strings are compared.
; CATEGORY:
;		String Processing.
; CALLING SEQUENCE:
;		Result = STREQ( STR1, STR2 [,LEN] [, keywords])
; INPUTS:
;	STR1, STR2
;		character strings, mandatory.
; OPTIONAL INPUT PARAMETERS:
;	LEN
;		Number of characters to compare.  Default is 0, translating to a full
;		comparison.
; KEYWORD PARAMETERS:
;	/CASEON
;		Switch. If set the comparison is case sensitive. Default is ignore case.
;	/REVERSE
;		Switch.  If set, and LEN provided and non-zero, the comparison is done
;		for the last LEN characters of STR1, STR2.
;	/WARN
;		Switch.  If set, a warning is issued whenever STR1 or STR2 is not a
;		character variable.  Default is no warning.
; OUTPUTS:
;		1b for equal, 0b for nonequal.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Using DEFAULT and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;		Modified 10-SEP-2001 by Mati Meron.  Added the keyword REVERSE and
;		fixed a bug (providing LEN as a vector of length 1 instead of scalar
;		caused errors).
;-

	on_error, 1

	if Type(str1) ne 7 or Type(str2) ne 7 then begin
		if keyword_set(wn) then message, 'Not a string!', /continue
		return, 0b
	endif

	dlen = Default(len,0l,/dtype)
	if dlen[0] eq 0 then dlen = max([strlen(str1),strlen(str2)])
	if not keyword_set(cas) then begin
		dum1 = strupcase(str1)
		dum2 = strupcase(str2)
	endif else begin
		dum1 = str1
		dum2 = str2
	endelse

	if keyword_set(rev) then fir = dlen-1 else fir = 0l
	return, strmid(dum1,fir,dlen,rev=rev) eq strmid(dum2,fir,dlen,rev=rev)
end
