Function StrMatch_mm, str, list, len, caseon = cas, reverse = rev, $
	all = all, exclude = exl, nosub = nsb, number = nmatch

;+
; NAME:
;		STRMATCH_MM
; VERSION:
;		4.1
; PURPOSE:
;		Compares the string STR with the strings in the array LIST.  Comparison
;		is done for the first LEN characters, or all of them if LEN is 0.  If a
;		match is found, STR is replaced by the full string from the list (or
;		if the keyword /ALL is set, by an array containing all the matching
;		strings), unless /NOSUB is set.
; CATEGORY:
;		String Processing.
; CALLING SEQUENCE:
;		Result = STRMATCH_MM( STR, LIST [, LEN] [, keywords])
; INPUTS:
;	STR
;		Character string.
;	LIST
;		Character array.
; OPTIONAL INPUT PARAMETERS:
;	LEN
;		The number of characters to compare.  Default is full comparison.
; KEYWORD PARAMETERS:
;	/CASEON
;		Switch. If set the comparison is case sensitive. Default is ignore case.
;	/REVERSE
;		Switch.  If set and LEN provided and non-zero, the comparison is done
;		for the last LEN characters.
;	/ALL
;		Switch.  If set, returns the indices of all the matching elements.
;	/EXCLUDE
;		Switch.  If set returns the indices of all the non-matching elements.
;	/NOSUB
;		Switch.  If set, prevents the substitution of the matching element(s)
;		in STR.
;	NUMBER
;		Optional output, see below.
; OUTPUTS:
;		Returns the index of the first match, or -1l if no match is found.
;		Optionally (see keyword ALL above) returns all the matching indices,
;		or non-matching indices when the keyword EXCLUDE is set.
; OPTIONAL OUTPUT PARAMETERS:
;	NUMBER
;		The name of a variable to receive the number of matches found.  Note
;		that unless the keyword ALL is set, NUMBER can only yield 0 or 1.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None other then the substitution in STR.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses the function STREQ from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron, as STRMATCH.
;		Modified 20-NOV-1993 by Mati Meron.  Added keyword ALL.
;		Modified 11-OCT-1997 by Roger J. Dejus.  Added keyword EXCLUDE.
;		Renamed 25-SEP-1999 to STRMATCH_MM in order to avoid naming conflicts
;		with RSI routines.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;		Modified 25-AUG-2001, added keyword NUMBER.
;		Modified 10-SEP-2001, added keyword REVERSE.
;		Modified 10-OCT-2002, added keyword NOSUB.
;-

;	on_error, 1

	if keyword_set(exl) then $
		match = where(Streq(str,list,len,caseon= cas,rev= rev) eq 0, nmatch) $
		else match = where(Streq(str,list,len,caseon= cas,rev= rev), nmatch)
	if not keyword_set(all) then begin
		match = match(0)
		nmatch = nmatch < 1
	endif
	if nmatch gt 0 and not keyword_set(nsb) then str = list(match)

	return, match
end
