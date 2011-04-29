Pro Obstat, reset = res

;+
; NAME:
;		OBSTAT
; VERSION:
;		5.2
; PURPOSE:
;		Providing informational messages about obsolete routines.
; CATEGORY:
;		Utility.
; CALLING SEQUENCE:
;		OBSTAT [,/RESET]
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/RESET
;		Switch.  Normally OBSTAT issues a warning message only once per session
;		for each called obsolete routine.  Calling OBSTAT with RESET set,
;		resets the message counter.
; OUTPUTS:
;		None other than screen output.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		MERON_OBSOLETE_ROUTINES
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		OBSTAT maintains a list of obsolete routines and their replacements.
;		When called from MAIN, OBSTAT diplays the full list.  When called from
;		within a specific routine, OBSTAT checks whether this routine is on the
;		obsolete list.  If yes, the action taken is one of the following:
;
;		If the routine, though obsolete, is still maintained, a warning message
;		to the effect is issued, together with the name of the replacement
;		routine.  Program execution then proceeds normally.  The message is
;		issued only once per IDL section (on the first call to the routine).
;
;		If the routine is no longer maintained, an error message is issued,
;		together with the name of the replacement routine.  The program then
;		quits and returns to the calling routine.  The message is issued on
;		every call to the obsolete routine.
;
;		OBSTAT Calls STRMATCH_MM, STRPARSE_MM and TABULATE from MIDL.
; MODIFICATION HISTORY:
;		Created 30-SEP-1999 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;		Slightly upgraded 30-NOV-2001 by Mati Meron.
;-

	common meron_obsolete_routines, exs, mor_inf

	on_error, 2

	blank = {routstat, old_name: '', new_name: '', stat: 0, checked: 0}

	old = ['BESELK', 'M_ABS', 'M_CONVOL', 'M_ERRORF', $
		'M_GAMMA', 'M_IGAMMA', 'M_IMAGINARY', 'M_LINFIT', $
		'M_LNGAMMA', 'M_NERFC', 'M_REAL', 'M_SMOOTH', $
		'STRMATCH', 'STRPARSE', 'TV_MM', 'WPNG_MM']

	new = ['BESELK_MM', 'ABS_MM', 'CONVOL_MM', 'ERRORF_MM', $
		'GAMMA_MM', 'IGAMMA_MM', 'IMAGINARY_MM', 'LINFIT_MM', $
		'LNGAMMA_MM', 'NERFC_MM', 'REAL_MM', 'SMOOTH_MM', $
		'STRMATCH_MM', 'STRPARSE_MM', 'DISPLAY_MM', 'WIMG_MM']

	stat = [0,1,1,1, 1,1,1,1, 1,1,1,1, 0,1,1,1]

	stmesg = ['		Old routine is no longer supported', $
		'		Old routine is still temporarily supported']
	shmesg = ['not supported','still supported']

	if N_elements(exs) eq 0 or keyword_set(res) then begin
		nr = n_elements(stat)
		if n_elements(old) ne nr or n_elements(new) ne nr then $
		message, 'Lists are screwed up!'
		mor_inf = replicate(blank,nr)
		for i = 0, nr - 1 do begin
			mor_inf[i].old_name = old[i]
			mor_inf[i].new_name = new[i]
			mor_inf[i].stat = stat[i]
		endfor
		exs = 1
	endif

	help, /traceback, output = out
	snum = Strparse_mm(out[1],' 	',list)
	rname = list[1]
	kr = Strmatch_mm(rname,mor_inf.old_name)

	if kr ge 0 then begin
		if not mor_inf[kr].checked then begin
			print, string(7b)
			mesg = '	The routine ' + rname + ' has been replaced by ' + $
			mor_inf[kr].new_name + string([10b,13b]) + stmesg(mor_inf[kr].stat)
			message, mesg, continue = mor_inf[kr].stat
			mor_inf[kr].checked = mor_inf[kr].stat
		endif
	endif else begin
		if strpos(rname,'MAIN') ge 0 then Tabulate, $
		mor_inf.old_name, mor_inf.new_name, shmesg[mor_inf.stat], $
		tit= 'MIDL Routine replacements', $
		head = ['Old routine', 'New routine','Status of Old']
	endelse

	return
end
