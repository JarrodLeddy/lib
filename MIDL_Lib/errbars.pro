Pro Errbars, x, y, xerr = xer, yerr = yer, fancy = fnc, _extra = _e

;+
; NAME:
;		ERRBARS
; VEERSION:
;		4.0
; PURPOSE:
;		Overplots error bars over an existing plot.  More general than the
;		library routines ERRPLOT and PLOTERR, since it allows to independently
;		vary both X and Y errors, and allows for nonsymmetric error bars.
; CATEGORY:
;		Plotting.
; CALLING SEQUENCE:
;		ERRBARS, [X,] Y [, XERR = XER, YERR = YER]
; INPUTS:
;	X, Y
;		Vectors containing the data points' coordinates.  If only one is given
;		it is taken to be Y, same as in the PLOT command.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	XERR
;		Either a vector or a (2,N) array where N is the number of the data
;		points.  Contains the X-errors.  If given as a 2 dimensional array, the
;		entries XERR(0,i) and XERR(1,i) are taken as the errors of X(i) in the
;		negative and positive directions, respectively.  If given as a vector,
;		the entry XERR(i) serves as both the negative and positive error of
;		X(i) and therefore symmetric error bars are drawn.  If not provided,
;		the default is no X-errors.
;	YERR
;		Same as above, for the Y-errors.
;	/FANCY
;		Switch.  If set, orthogonal bars are added to the tips of the error
;		bars, for publication plots.
;	_EXTRA
;		A formal keyword used to pass all plotting keywords.  Not to be used
;		directly.  See comment in RESTRICTIONS.
; OUTPUTS:
;		None.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The keywords passed through _EXTRA are transferred to the PLOTS
;		routine.  No keyword verification is performed by ERRBARS.
; PROCEDURE:
;		Straightforward.  Uses DEFAULT and WHERINSTRUCT from MIDL.
; MODIFICATION HISTORY:
;		Created 10-DEC-1991 by Mati Meron.
;		Modified 15-DEC-1993 by Mati Meron.  Now ERRBARS takes advantage of the
;		keyword inheritance property and accepts most of IDL plotting keywords.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;		Modified 10-AUG-2003 by Mati Meron.  Internal adaptation for log plots.
;		Modified 5-JUN-2004 by Mati Meron.  Added keyword FANCY.
;-

	on_error, 1
	mes = 'Wrong ' + ['XERR','YERR'] + ' dimensions!'
	len = Split_xy(x,y,x=xp,y=yp)

	if Isnum(xer) then begin
		wxer = reform(xer)
		siz = size(wxer)
		case siz[0] of
			1	:	if siz[1] eq len then wxer = transpose([[wxer],[wxer]]) $
					else message, mes[0]
			2	:	if not Arreq(siz[1:2],[2,len]) then message, mes[0]
			else:	message, mes[0]
		endcase
		xfl = 1
		xlh = transpose([[xp - wxer[0,*]],[xp + wxer[1,*]]])
		if !x.type or Wherinstruct('xlo',_e) ge 0 then xlh= xlh> (machar()).xmin
	endif else xfl = 0

	if Isnum(yer) then begin
		wyer = reform(yer)
		siz = size(wyer)
		case siz[0] of
			1	:	if siz[1] eq len then wyer = transpose([[wyer],[wyer]]) $
					else message, mes[1]
			2	:	if not Arreq(siz[1:2],[2,len]) then message, mes[1]
			else:	message, mes[1]
		endcase
		yfl = 1
		ylh = transpose([[yp - wyer[0,*]],[yp + wyer[1,*]]])
		if !y.type or Wherinstruct('ylo',_e) ge 0 then ylh= ylh> (machar()).xmin
	endif else yfl = 0

	if keyword_set(fnc) then begin
		if xfl then begin
			tem = Coo_conv(xlh, ax = 'X', fro = 'DAT', to = 'DEV')
			cmp = 0.5*abs(reform(tem[1,*] - tem[0,*]))
			del = !d.y_px_cm/10 < cmp
			tem = Coo_conv(yp,ax = 'Y', fro = 'DAT', to = 'DEV')
			xtip = Coo_conv(transpose([[tem - del],[tem + del]]),ax='Y',$
					fro = 'DEV', to = 'DAT')
		endif
		if yfl then begin
			tem = Coo_conv(ylh, ax = 'Y', fro = 'DAT', to = 'DEV')
			cmp = 0.5*abs(reform(tem[1,*] - tem[0,*]))
			del = !d.x_px_cm/10 < cmp
			tem = Coo_conv(xp,ax = 'X', fro = 'DAT', to = 'DEV')
			ytip = Coo_conv(transpose([[tem - del],[tem + del]]),ax='X',$
					fro = 'DEV', to = 'DAT')
		endif
		fnfl = 1
	endif else fnfl = 0

	sloc = Wherinstruct('psym',_e)
	if sloc ge 0 then begin
		_f = _e
		_e.(sloc) = 0
	endif
	for i = 0l, len - 1 do begin
		if xfl then begin
			plots, xlh[*,i], yp[[i,i]], noclip = 0, _extra = _e
			if fnfl then begin
				plots, xlh[[0,0],i], xtip[*,i], noclip = 0, _extra = _e
				plots, xlh[[1,1],i], xtip[*,i], noclip = 0, _extra = _e
			endif
		endif
		if yfl then begin
			plots, xp[[i,i]], ylh[*,i], noclip = 0, _extra = _e
			if fnfl then begin
				plots, ytip[*,i], ylh[[0,0],i], noclip = 1, _extra = _e
				plots, ytip[*,i], ylh[[1,1],i], noclip = 1, _extra = _e
			endif
		endif
	endfor
	if sloc ge 0 then _e = _f

	return
end