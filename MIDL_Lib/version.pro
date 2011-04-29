Function Version, fname, number = num, location = loc, all = all

;+
; NAME:
;		VERSION
; VERSION:
;		5.2
; PURPOSE:
;		Finding the version number of a routine.
; CATEGORY:
;		Programing utility.
; CALLING SEQUENCE:
;		Result = VERSION ( [FNAME [, keywords]])
; INPUTS:
;	FNAME
;		Character scalar, representing a file name.  A .pro extension is
;		assumed and appended if missing.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	NUMBER
;		Optional output, see below.
;	LOCATION
;		Optional output, see below.
;	/ALL
;		Switch.  If set and multiple files with the same name are detected,
;		the results for all are given.
; OUTPUTS:
;		Returns the version number(s) (as it appears in the informational block
;		as float.  If the routine exists but no version number is found,
;		returns 0.  If the file is not found, returns -1.
; OPTIONAL OUTPUT PARAMETERS:
;	NUMBER
;		Returns the number of fitting files found.
;	LOCATION
;		Character array, returns the locations of all fitting files found.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Three possibilities:
;			1)	If routine name alone is given, like in
;				res = Version('my_rout'), VERSION scans the whole IDL path (as
;				given by !PATH) as well as current directory (if not on path),
;				locating all instances of MY_ROUT.
;			2)	If a name with a directory path is given, like in
;				res = version('c:\midl\_midl\my_rout') then VERSION finds the
;				file if it exists, at the provided address.  No attempt to find
;				additional files with same name is made in this case.
;			3)	If a name is not provided, VERSION provides the user with
;				a graphic interface to FINDFILE and allows to specify the file
;				interactively.
;
;		In all three cases the file(s) found (note that only in the first case
;		there can be more than one file) are scanned and the version number (if
;		present) is extracted from the info block (if present) into the result.
;		If no version number is found, VERSION returns 0. and if the file
;		itself isn't found, it returns -1.
;
;		VERSION calls FILE_GET, STREQ and STRPARSE_MM, from MIDL, and SDEP
;		from the ROger Dejus library.
; MODIFICATION HISTORY:
;		Created 10-AUG-2001 by Mati Meron.
;-

	on_error, 1
	ds = sdep(/ds)
	ps = sdep(/ps)
	ext = '.pro'
	num = 0

	if n_elements(fname) eq 0 then begin
		loc = [File_get(filt = '*' + ext,/read)]
		if not Streq(loc[0],'') then num = 1
	endif else begin
		if Streq(strmid(fname,3,4,/rev),ext) then wname = fname $
		else wname = fname + ext
		dum = Strparse_mm(wname,ds)
		if dum eq 0 then begin
			ldir = Strparse_mm(!path,ps,loc)
			cd, cur = cur
			dum = where(Streq(cur,loc),ndum)
			if ndum eq 0 then begin
				loc = [cur,loc]
				ldir = ldir + 1
			endif

			errs = lonarr(ldir+1)
			loc = loc + ds + wname
			for i = 0l, ldir do begin
				openr, checkun, loc[i], /get_lun, error = err
				errs[i] = err
				if err eq 0 then free_lun, checkun
			endfor
			dum = where(errs eq 0, num)
			if num gt 0 then loc = loc[dum] else loc = ['']
		endif else begin
			dum = findfile(wname,count=num)
			if num gt 0 then loc = [wname] else loc = ['']
		endelse
	endelse

	if num gt 0 then begin
		line = ''
		vers = ''
		comp = '-+.0123456789'
		if keyword_set(all) then numl = num else numl = 1
		res = fltarr(numl)
		for i = 0l, numl - 1 do begin
			openr, filun, loc[i], /get_lun
			while not eof(filun) and not Streq(line,';+',2) do readf,filun,line
			while not eof(filun) and not Streq(line,';-',2) do begin
				readf, filun, line
				if strpos(line,'VERSION:') ge 0 then begin
					readf, filun, vers
					break
				endif
			endwhile
			free_lun, filun
			if vers ne '' then begin
				val = 0
				ndum = Strparse_mm(vers,' 	',vlis)
				vers = vlis[ndum]
				for j=0,strlen(vers)-1 do val=val<strpos(comp,strmid(vers,j,1))
				if val eq 0 then res[i] = float(vers)
			endif
		endfor
	endif else res = [-1.]

	return, res
end
