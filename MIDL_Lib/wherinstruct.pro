Function Wherinstruct, tagnam, structnam, count, tags = tnam

;+
; NAME:
;		WHERINSTRUCT
; VERSION:
;		4.0
; PURPOSE:
;		Finding fields within a structure.
; CATEGORY:
;		Programming.
; CALLING SEQUENCE:
;		Result = WHERINSTRUCT( TAGNAM, STRUCTNUM [, COUNT] [,TAGS = TNAM])
; INPUTS:
;	TAGNAM
;		Character variable or constant.
;	STRUCTNUM
;		Name of a structure variable.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	TAGS
;		Optional output, see below.
; OUTPUTS:
;		If STRUCTNAM exists, is a structure, and has one or more tag names
;		which match with TAGNAM, The return is a numeric (long integer) array
;		which includes the indices of the matching fields (similar to the
;		output of WHERE.  In all other cases the output is -1.
; OPTIONAL OUTPUT PARAMETERS:
;	COUNT
;		Same as in WHERE, returns the number of matches found.
;	TAGS
;		Accepts the name of the variable in which the names of the matching
;		fields are returned as a string array.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses the system routine TAG_NAMES to find all the tag names of the
;		structure, and then uses STRMATCH_MM from MIDL to match these names
;		with the input TAGNAM.  The number of characters in TAGNAM determines
;		the number of characters used in the match.  For example, if
;		TAGNAM = 't' then all the names starting with 't' will be picked but if
;		TAGNAM = 'thor' then only those starting with 'thor' will be noticed.
;		Calls STRMATCH_MM and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUN-1995 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1

	res = -1l
	if Type(structnam) eq 8 then begin
		tnam = tagnam
		res = StrMatch_mm(tnam,tag_names(structnam),strlen(tagnam),/all)
	endif
	if res[0] eq -1 then begin
		tnam = ''
		count = 0
	endif else count = n_elements(res)

	return, res
end
