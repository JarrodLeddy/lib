Function Fnamparse, fnam, path = path, extension = ext, present = pres

;+
; NAME:
;		FNAMPARSE
; VERSION:
;		4.9
; PURPOSE:
;		Parsing file names.
; CATEGORY:
;		Utility.
; CALLING SEQUENCE:
;		Result = FNAMPARSE( FNAM [, keywords])
; INPUTS:
;	FNAM
;		String scalar, representing a valid (full or partial) file name.  If
;		given, must be of character type.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	PATH
;		Optional output, see below.
;	EXTENSION
;		Optional output, see below.
;	PRESENT
;		Optional output, see below.
; OUTPUTS:
;		Returns the "net" filename (i.e. the filename without path and
;		extension) if present in the input, else returns null string.
; OPTIONAL OUTPUT PARAMETERS:
;	PATH
;		Returns the path part of the filename if present in the input, else
;		returns null string.  The path returned is terminated with the
;		directory separator ('\' for Windows).
;	EXTENSION
;		Returns the filename extension if present in the input, else returns
;		null string.  The extension returned is preceded by '.'.
;	PRESENT
;		Returns a 3 element BYTE vector, with each entry set to 1 if the
;		corresponding filename part (in order, [PATH,NAME,EXTENSION]) is
;		present, 0 otherwise.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The input, if present, must be of type STRING and follow the rules for
;		legitimate filename.  Missing input is taken as null string.
; PROCEDURE:
;		Straightforward.  Calls STREQ, STRPARSE_MM and TYPE from MIDL.  Also
;		calls SDEP from imports.
; MODIFICATION HISTORY:
;		Created 25-DEC-2004 by Mati Meron.
;-

	on_error, 1
	ds = sdep(/ds)
	ts = '.'
	path = ''
	nam = ''
	ext = ''

	if Type(fnam) eq 0 then gnam = '' else gnam = fnam
	if Type(gnam) eq 7 then begin
		flen = strlen(gnam)
		if flen gt 0 then begin
			if strpos(gnam,ts) eq 0 then message, 'Invalid file name!'
			dum = Strparse_mm(gnam,ts,lis)
			if dum gt 0 then begin
				gnam = strjoin(lis[0:dum-1],ts)
				ext = ts + lis[dum]
			endif
			dum = strpos(gnam,ds,/reverse_search)
			if dum ge 0 then begin
				path = strmid(gnam,0,dum+1)
				if (dum+1) lt flen then nam = strmid(gnam,dum+1)
			endif else nam = gnam
		endif
		pres = 1b - Streq([path,nam,ext],'')
	endif else message, 'No file name present!'

	return, nam
end