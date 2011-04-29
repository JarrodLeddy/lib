Function Current, caller = call, path = path

;+
; NAME:
;		CURRENT
; VERSION:
;		5.2
; PURPOSE:
;		Finding current location in traceback stack, i.e. the name of the
;		caller of CURRENT.
; CATEGORY:
;		Programing utility.
; CALLING SEQUENCE:
;		Result = CURRENT()
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	CALLER
;		Integer value, modifies the output to the name of a higher order caller.
;		Default value is zero.  For non-zero value caller of order CALLER+1 is
;		identified.
;	PATH
;		Optional output, see below.
; OUTPUTS:
;		Returns the name of the caller of CURRENT, or the name of a higher order
;		caller.  For example, setting CALLER = 2 causes the name of the
;		caller of the caller of the caller of CURRENT to be returned.
; OPTIONAL OUTPUT PARAMETERS:
;	PATH
;		Returns the full path for the returned routine.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		If CALL points beyond the highest ($MAIN$) level, CURRENT can only
;		return: "There ain't no caller # ...".
; PROCEDURE:
;		Straightforward.  Calls DEFAULT and STRPARSE_MM from MIDL and SDEP from
;		IMPORTS.
; MODIFICATION HISTORY:
;		Created 30-JUL-2003 by Mati Meron.
;		Modified 5-DEC-2004 by Mati Meron.  Added keywords /CALLER and PATH.
;		Modified 20-NOV-2005 by Mati Meron.  Added higher level caller capacity.
;-

	on_error, 1
	ds = sdep(/ds)

	help, /traceback, out = trac
	ntr = n_elements(trac)
	ind = 1 + Default(call,0,/dtyp) > 0
;	if ind ge ntr then message, "There ain't no caller!'

	if ind lt ntr then begin
		dum = Strparse_mm(trac[ind],'%	 ',lis)
		if arg_present(path) then begin
			if dum eq 0 then begin
				cd, cur = path
				path = path + ds
			endif else begin
				path = lis[dum]
				path = strmid(path,0,strpos(path,ds,/reverse_search)+1)
			endelse
		endif
	endif else begin
		lis = "There ain't no caller #" + string(ind,form='(i2)')
		path = ''
	endelse

	return, lis[0]
end