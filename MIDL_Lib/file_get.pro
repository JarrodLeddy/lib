Function File_get, fname, path = path, filter = filt, pick = pic, reset = rst, $
	interactive = int, auto = aut, caller = call, status = stat, _extra = _e

;+
; NAME:
;		FILE_GET
; VERSION:
;		5.2
; PURPOSE:
;		Finding and/or checking for the existance of files.
; CATEGORY:
;		Utility
; CALLING SEQUENCE:
;		Result = FILE_GET( [FNAME] [,keywords)
; INPUTS:
;	FNAME
;		Character variable or constant, translating to a full (including path)
;		or partial file name.  If not provided, DIALOG_PICKFILE is called to
;		find the file.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	PATH
;		Character variable or constant, translating to a full or partial path.
;	FILTER
;		Character variable or constant, translating to a file-type filter.
;	/PICK
;		Switch.  Obsolete, maintained for backward compatibility purpose only.
;	/RESET
;		Switch.  Resets the PATH and FILTER saved from previous calls to their
;		original, blank values.  For testing purposes only.
;	/INTERACTIVE
;		Switch.  If set, the routine switches to interactive mode even if full
;		FNAME is provided.
;	/AUTO
;		Switch.  Active only when the keyword /WRITE is passed to
;		DIALOG_PICKFILE.  By default, FILE_GET is non-interactive in READ mode
;		unless /INTERACTIVE is set or parts of the full file name are missing.
;		In WRITE mode, on the other hand, the default operation is interactive
;		unless /AUTO is explicitly set.
;
;		Note:	If both /AUTO and /INTERACTIVE are set, the mode is interactive.
;	CALLER
;		Integer code, indicates which entry should be made in the CPFDAT
;		database.  By default, the direct caller of FILE_GET is listed but this
;		can be changed using a higher value for CALLER.
;	STATUS
;		Optional output, see below.
;	_EXTRA
;		A formal keyword, used to pass keywords to DIALOG_PICKFILE.  Not to be
;		used directly.
; OUTPUTS:
;		Returns the full file name.
; OPTIONAL OUTPUT PARAMETERS:
;	STATUS
;		Returns an operation success code, 1 if a file is found, 0 otherwise.
; COMMON BLOCKS:
;		Block FILEINF0.  Includes the a structure containing a list of calling
;		routines and the file path and filter used in the previous call for each
;		of these routines.  These will be reused unless a full file name is
;		provided or unless overridden by explicit values provided through PATH
;		and FILTER.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		If FNAME is provided, FILE_GET attempts to locate it (using the path if
;		needed) else it cals on DIALOG_PICKFILE for interactive selection.  Uses
;		ARREQ, CURRENT, DEFAULT, FNAMPARSE, STREQ, STRMATCH_MM, TYPE and
;		WHERINSTRUCT from MIDL and SDEP from imports.
; MODIFICATION HISTORY:
;		Created 15-APR-2001 by Mati Meron.
;		Modifed 30-SEP-2001 by Mati Meron.  Added keywords PICK and RESET.
;		Modified 1-APR-2002 by Mati Meron.  Modified defaults.
;		Modified 25-DEC-2004 by Mati Meron.  Introduced internal structure
;		through which defaults are maintained separately for each caller.
;		Modified 15-NOV-2005 by Mati Meron.  Added keywords AUTO and CALLER and
;		changed some internal settings.
;-

	common fileinfo, cpfdat

	on_error, 1
	nm = 32l
	ds = sdep(/ds)
	ts = '.'
	dext = '.*'

	wrifl = (Wherinstruct('wri',_e) ge 0)[0]
	intfl = byte(keyword_set(int) or (wrifl and (not keyword_set(aut))))
	ccall = Current(caller=Default(call,1)>1,_extra=_e)
	if Type(cpfdat) eq 0 or keyword_set(rst) then begin
		cpfdat = {file_get_dat, nent: 0l, dpath: '', $
		call: strarr(nm), path: strarr(nm), ext: strarr(nm)}
		cd, cur = tpath
		cpfdat.dpath = tpath + ds
	endif
	if cpfdat.nent eq 0 then cind = -1l $
	else cind = Strmatch_mm(ccall,cpfdat.call[0:cpfdat.nent-1])
	if cind lt 0 then begin
		if cpfdat.nent eq nm then begin
			cpfdat.call = shift(cpfdat.call,-1)
			cpfdat.path = shift(cpfdat.path,-1)
			cpfdat.ext = shift(cpfdat.ext,-1)
		endif else cpfdat.nent = cpfdat.nent + 1
		cind = cpfdat.nent - 1
		cpfdat.call[cind] = ccall
		cpfdat.path[cind] = cpfdat.dpath
		cpfdat.ext[cind] = dext
	endif

	if Type(path) eq 7 and (not Streq(path,'')) then begin
		if strpos(path,ds,/reverse_search) eq (strlen(path) - 1) then $
		cpfdat.path[cind] = path else cpfdat.path[cind] = path + ds
	endif

	if Type(filt) eq 7 and (not Streq(filt,'')) then fext = filt $
	else if wrifl then begin
		dfin = Wherinstruct('def',_e)
		if dfin ge 0 then fext = _e.(dfin)
	endif else fext = ''

	if Type(fext) eq 7 and (not Streq(fext,'')) then begin
		tspos = strpos(fext,ts,/reverse_search)
		fext = strmid(fext,tspos)
		if tspos lt 0 then fext = ts + fext $
		else if Arreq(fext,ts) then fext = fext + '*'
		cpfdat.ext[cind] = fext
	endif

	nname = Fnamparse(fname,path=npath,ext=ext,present=pres)
	if pres[0] then cpfdat.path[cind] = npath
	if not pres[1] then begin
		intfl = 1b
		nname = '*'
	endif
	if pres[2] or (pres[1] and Streq(fext,'')) then cpfdat.ext[cind] = ext

	if not intfl then begin
		ifil = cpfdat.path[cind] + nname + cpfdat.ext[cind]
		if not wrifl then begin
			ifil = (findfile(ifil))[0]
			if ifil ne '' then ifil = file_expand_path(ifil) $
			else ifil = dialog_pickfile(file=nname+ext, $
			path=cpfdat.path[cind], filt='*'+cpfdat.ext[cind], _extra=_e)
		endif
	endif else ifil = dialog_pickfile(file=nname+ext, $
	path=cpfdat.path[cind], filt='*'+cpfdat.ext[cind], _extra=_e)

	stat = (ifil ne '')
	if stat then begin
		dum = Fnamparse(ifil,path=npath,ext=ext)
		cpfdat.path[cind] = (cpfdat.dpath = npath)
		cpfdat.ext[cind] = ext
	endif

	return, ifil
end