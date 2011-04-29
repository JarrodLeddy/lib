Function StrParse_mm, line, delim, list

;+
; NAME:
;		STRPARSE_MM
; VERSION:
;		4.0
; PURPOSE:
;		Parses the string LINE using the characters in DELIM as delimiters.
;		Puts individual pieces into consecutive locations in LIST.
; CATEGORY:
;		String Processing.
; CALLING SEQUENCE:
;		Result = STRPARSE_MM( LINE, DELIM [, LIST])
; INPUTS:
;	LINE
;		Character string.
;	DELIM
;		Character string.  Each Character of DELIM is used as a delimiter.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the number of pieces found minus one i.e. the index of the last
;		element of LIST if LIST is provided.  If LINE is a null string or not a
;		string, the function returns -1l.
; OPTIONAL OUTPUT PARAMETERS:
;	LIST
;		Character array.  If name is provided, the pieces of LINE resulting
;		from the parsing process are returned in consecutive locations in LIST.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Using the function TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron as STRPARSE.
;		Renamed 25-SEP-1999 to STRPARSE_MM in order to avoid naming conflicts
;		with RSI routines.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1

	if Type(line) ne 7 then return, -1l
	index = -1l
	list = ''
	len = strlen(line)
	for i = 0l, len - 1 do begin
		if strpos(delim,strmid(line,i,1)) ne -1 then index = [index,i]
	endfor
	index = [index,len]
	for i = 0l, n_elements(index) - 2 do begin
		list = [list,strmid(line,index[i] + 1,index[i+1] - index[i] -1)]
	endfor
	inlist = where(list ne '',items)
	if items ne 0 then list = list[inlist] else list = list[0]

	return, long(items - 1)
end
