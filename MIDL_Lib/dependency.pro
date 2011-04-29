Function Dependency, rname, global = glob, dirpath = dirp, nfound = num

;+
; NAME:
;		DEPENDENCY
; VERSION:
;		4.2
; PURPOSE:
;		Locating routines dependent on a given routine.
; CATEGORY:
;		Programming utility.
; CALLING SEQUENCE:
;		Result = DEPENDENCY( RNAME [, keywords])
; INPUTS:
;	RNAME
;		Character value resolving to a routine name (no extension).
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/GLOBAL
;		Switch.  If set, the search is global, default is search in current
;		directory.
;	DIRPATH
;		Directory path, for internal use only (recursive calls).
;	NFOUND
;		Optional output, see below.
; OUTPUTS:
;		Returns a list of addresses for all the routines which are calling
;		RNAME.  If none are found, returns null string.
; OPTIONAL OUTPUT PARAMETERS:
;	NFOUND
;		Returns the number of files satisfying the search criterion.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calls itself recursively.  Also calls DEFAULT, SDEP,
;		STREQ, STRPARSE_MM and STRVALID_MM, from MIDL.
; MODIFICATION HISTORY:
;		Created 10-AUG-2001 by Mati Meron.
;-

	on_error, 1

	rdir = 'MIDL'
	gfil = '*.pro'
	dirp = Default(dirp,'',/dtyp)
	res = ''
	num = 0
	sname = strupcase(rname)
	ds = sdep(/ds)
	ps = sdep(/ps)

	if keyword_set(glob) then begin
		ldir = Strparse_mm(!path,ps,gloc)
		for i = 0l, ldir do $
		if strpos(strupcase(gloc[i]),rdir) lt 0 then gloc[i] = ''
		cd, cur = cur
		dum = where(Streq(cur,gloc),ndum)
		if ndum eq 0 then gloc = [cur,gloc]
		dum = where(gloc ne '')
		gloc = gloc[dum]
		for i = 0l, n_elements(gloc)-1 do begin
			pres = Dependency(rname,nfound=pnum,dirpath=gloc[i])
			if pnum gt 0 then begin
				res = [res,pres]
				num = num + pnum
			endif
		endfor
		if num gt 0 then res = res[where(res ne '',num)]
	endif else begin
		if dirp ne '' then gfil = dirp + ds + gfil
		list = findfile(gfil)
		if (size(list))[0] gt 0 then begin
			nl = n_elements(list)
			locs = lonarr(nl)
			line = ''
			for i = 0l, nl - 1 do begin
				openr, filun, list[i], /get_lun
				hfl = 0
				while not (hfl or eof(filun)) do begin
					readf, filun, line
					line = strupcase(line)
					cmpos = strpos(line,';')
					fppos = strpos(line,'FUNCTION ') > strpos(line,'PRO ')
					hfl= fppos ge 0 and (cmpos eq -1 or cmpos gt fppos)
				endwhile
				while not eof(filun) do begin
					readf, filun, line
					line = strupcase(line)
					snpos = Strvalid_mm(line,sname,/text)
					if snpos ge 0 then begin
						cmpos = strpos(line,';')
						if cmpos eq -1 or cmpos gt snpos then begin
							locs[i] = 1
							break
						endif
					endif
				endwhile
				free_lun, filun
			endfor
			dum = where(locs,num)
			if num gt 0 then res = list[dum]
		endif
	endelse

	return, res
end