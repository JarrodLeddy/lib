Pro Legend, location = loc, width = wid, charsize = chs, $
	text= txt, lines= lin, symbols= sym, colors= col, nowrap= now, _extra= _e
;+
; NAME:
;		LEGEND
; VERSION:
;		5.5
; PURPOSE:
;		Generates a plot legend.
; CATEGORY:
;		Graphics utility.
; CALLING SEQUENCE:
;		LEGEND, keywords
; INPUTS:
;		None
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	LOCATION
;		Character input, specifies location of legend.  Four acceptable inputs:
;			UR	:	Upper Right corner.
;			UL	:	Upper Left corner.
;			LL	:	Lower Left corner.
;			LR	:	Lower Right corner.
;
;		Default location is UR.
;	WIDTH
;		Numeric input, specifies width of legend as a fraction of the plot
;		window's size.  The width may be internally adjusted (downward only) to
;		provide a tighter wrap around the text.
;	CHARSIZE
;		Numeric input, specifies character size.  Default is 1.
;	TEXT
;		Character array, each entry provides a text item for the legend.
;	LINES
;		Numeric array, the codes of line styles corresponding to the TEXT items.
;		A code of -1 means "no line".
;	SYMBOLS
;		Numeric array, the codes of symbols corresponding to the TEXT items.
;		A code od -1 means "no symbol".
;
;		Note 1: Either LINES or SYMBOLS may be omitted altogether.  In such
;				case only lines or only symbols will be drawn.
;		Note 2:	The number of entries in LINES and/or SYMBOLS, if provided, must
;				agree with the number of entries in TEXT.
;	COLORS
;		Numeric array, the codes of colors corresponding to TEXT items.
;		Optional, but if given must be of same length as TEXT.
;	/NOWRAP
;		Switch.  If set, prevents wrapping of text to fit the legend box.
;	_EXTRA
;		A formal keyword used to pass all plotting keywords.  Not to be used
;		directly.
; OUTPUTS:
;		None other than the Graphic output.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calls DEFAULT, HOW_MANY, LABELS, RECTAN, STRMATCH_MM
;		and STRPARSE_MM from MIDL.
; MODIFICATION HISTORY:
;		Created 25-SEP-2004 by Mati Meron.
;		Modified 15-DEC-2005 by Mati Meron.  Internal changes.
;		Modified 20-SEP-2006 by Mati Meron.  Internal changes.
;-

	on_error, 1

	ffl = How_many(fir=lin,sec=sym) gt 0

	goff = 0.05
	if ffl then boff = 0.1 else boff = 0.01
	soff = boff*[.2,.5,.8]
	lspa = 1.5
	posib = ['ur','ul','ll','lr']
	mess = 'Number of ' + ['linestyles','symbols','colors'] + $
	' must agree with number of test lines!'

	whi = Strmatch_mm(loc,posib,2) > 0
	hor = whi eq 0 or whi eq 3
	ver = whi eq 0 or whi eq 1
	wchs = Default(chs,1.,/dtyp)
	psiz = [[!x.window],[!y.window]]
	off = reform(psiz[0,*])
	sca = reform(psiz[1,*]) - off
	chx = wchs*!d.x_ch_size/!d.x_size
	chy = wchs*!d.y_ch_size/!d.y_size

	wwid = 2*boff > Default(wid,.3,/dtyp) < (1-2*goff)
	mlen = floor((wwid-boff)*sca[0]/chx)
	nit = n_elements(txt)
	if nit gt 0 then begin
		wtxt = txt
		wlin = Default(lin,replicate(-1,nit),/dtyp)
		if n_elements(wlin) ne nit then message, mess[0]
		wsym = Default(sym,replicate(-1,nit),/dtyp)
		if n_elements(wsym) ne nit then message, mess[1]
		wcol = Default(col, replicate(!p.color,nit))
		if n_elements(wcol) ne nit then message, mess[2]

		if not keyword_set(now) then begin
			i = 0
			repeat begin
				len = strlen(wtxt[i])
				if len gt mlen then begin
					tem = strmid(wtxt[i],0,mlen)
					brk = strpos(tem,' ',/reverse_search)
					if brk gt 0 then begin
						fir = strmid(wtxt[i],0,brk)
						sec = strmid(wtxt[i],brk+1)
					endif else begin
						fir = strmid(wtxt[i],0,mlen-1) + '-'
						sec = strmid(wtxt[i],mlen-1)
					endelse
					if i eq (nit-1) then begin
						wtxt = [wtxt,sec]
						wlin = [wlin,-1]
						wsym = [wsym,-1]
						wcol = [wcol, 0]
					endif else begin
						wtxt = [wtxt[0:i],sec,wtxt[i+1:*]]
						wlin = [wlin[0:i], -1,wlin[i+1:*]]
						wsym = [wsym[0:i], -1,wsym[i+1:*]]
						wcol = [wcol[0:i], 0 ,wcol[i+1:*]]
					endelse
					wtxt[i] = fir
					nit = nit + 1
				endif
				i = i + 1
			endrep until i eq nit
		endif
		lfl = wlin ge 0
		sfl = wsym ge 0

		wlen = strlen(wtxt)
		for i =0l, nit-1 do wlen[i] =(wlen[i]-2*(Strparse_mm(wtxt[i],'!')>0))>0
		tlen = max(wlen)
		wwid = chx*tlen/sca[0] + boff
		whei = chy*lspa*(nit + 0.5)/sca[1]
		xli = off[0] + sca[0]*(hor + (-1)^hor*(goff + [0,wwid]))
		yli = off[1] + sca[1]*(ver + (-1)^ver*(goff + [0,whei]))
		Rectan, xli=xli, yli = yli, rad=.1, /rel, /norm

		xan = min(xli) + sca[0]*boff
		yan = max(yli) - chy*lspa*(0.9 + lindgen(nit))
		Labels, xan, yan, wtxt, /norm, charsize = wchs, _extra = _e

		if ffl then begin
			xan = min(xli) + sca[0]*soff
			yan = yan + chy/4
			j = where(lfl or sfl, nj)
			for k = 0, nj-1 do begin
				l = j[k]
				if lfl[l] then plots, xan[[0,2]], yan[[l,l]], $
				line = wlin[l], col = wcol[l], /norm, _extra = _e
				if sfl[l] then plots, xan[1], yan[l], $
				psym = wsym[l], syms = wchs, col = wcol[l], /norm, _extra = _e
			endfor
		endif
	endif else message, 'No legend text present!, /con

	return
end