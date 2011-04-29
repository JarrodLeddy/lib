Pro Plot_ver2, x, y0, y1, $
	xmargin = xmar, ymargin = ymar, ratio = rat, gap = gp, $
	xtype = xtyp, ytype = ytyp, ynozero = ynz, xtitle = xtit, ytitle = ytit, $
	title = tit, psym = psm, linestyle = linst, color = col, _extra = _e

;+
; NAME:
;		PLOT_VER2
; VERSION:
;		4.0
; PURPOSE:
;		Draws 2 plots, vertically spaced, with a possibility of multiple curves
;		on each plot.
; CATEGORY:
;		Plotting.
; CALLING SEQUENCE:
;		PLOT_VER2, [X,] Y0, Y1 [, optional keywords]
; INPUTS:
;	Y0
;		A numeric vector or 2 dimensional array containing the Y coordinates of
;		the data for the top plot.  If Y is a 2-dim.array, each row is ploted
;		separately.  It is assumed that the number of points per plot is larger
;		than the number of plots so that if Y is an (M*N) array with N > M, it
;		will be transposed prior to plotting.
;	Y1
;		Same as Y0 for the bottom plot.
; OPTIONAL INPUT PARAMETERS:
;	X
;		A numeric vector containing the X coordinates of the data.  If absent
;		it is replaced by the vector [0, 1, 2 ...].
; KEYWORD PARAMETERS:
;	RATIO
;		Size ratio between top and bottom plot.  Default is 1.
;	GAP
;		Width of the gap between the plots in character units.  Default is 0.1
;	XMARGIN
;		Standard IDL plotting interpretation.
;	YMARGIN
;		Ditto.
;	XTYPE
;		Ditto.
;	YTYPE
;		Ditto.  If given as 2-element vector, elements 0 and 1 apply to top and
;		bottom plots, respectively.
;	YNOZERO
;		Ditto.  If given as 2-element vector, elements 0 and 1 apply to top and
;		bottom plots, respectively.
;	TITLE
;		Ditto.
;	XTITLE
;		Ditto.
;	YTITLE
;		Ditto.  If given as 2-element vector, elements 0 and 1 apply to top and
;		bottom plots, respectively.
;	PSYM
;		Ditto.  If given as a vector consecutive elements are applied to
;		consecutive curves on each plot.
;	LINESTYLE
;		Ditto.  If given as a vector consecutive elements are applied to
;		consecutive curves on each plot.
;	COLOR
;		Ditto.  If given as a vector consecutive elements are applied to
;		consecutive curves on each plot.
;	_EXTRA
;		A formal keyword used to pass all plotting keywords.  Not to be used
;		directly.
; OUTPUTS:
;		None.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Uses calls to DEFAULT, PLOTOT and PLVAR_KEEP, from
;		MIDL.
; MODIFICATION HISTORY:
;		Created 30-JUL-1991 by Mati Meron.
;		Modified 15-JAN-1994 by Mati Meron.  Now PLOT_VER2 takes advantage of
;		the keyword inheritance property and accepts all IDL plotting keywords.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	if n_elements(y1) eq 0 then begin
		py1 = y0
		py0 = x
		sdum = size(x)
		case sdum[0] of
			1	:	len = sdum[1]
			2	:	len = max(sdum[1:2])
			else:	message, 'Bad data!'
		endcase
		px = indgen(len)
	endif else begin
		py1 = y1
		py0 = y0
		px = x
	endelse

	xtyp = Default(xtyp,!x.type)
	ytyp = Default(ytyp,!y.type)
	if n_elements(ytyp) eq 1 then ytyp = [ytyp,ytyp]
	xex = Default(xex,0)
	ynz = Default(ynz,0)
	if n_elements(ynz) eq 1 then ynz = [ynz,ynz]
	tit = Default(tit,!p.title)
	xtit = Default(xtit,!x.title)
	ytit = Default(ytit,!y.title)
	if n_elements(ytit) eq 1 then ytit = [ytit,ytit]
	psm = Default(psm,0)
	linst = Default(linst,0)
	col = Default(col,!p.color)

	scaf = float(!d.y_ch_size)/!d.y_size
	ymar = Default(ymar,!y.margin)
	rat = float(Default(rat,1))
	gp = Default(gp,0.1)*scaf
	bm = ymar[0]*scaf
	tm = ymar[1]*scaf
	pp = (1 - tm - bm - gp)/(1 + rat)
	botop = bm + pp
	tobot = botop + gp

	Plvar_keep, action = 'save'
	!p.multi = [0,1,2]
	!x.margin = Default(xmar,!x.margin)
	!x.thick = 2
	!y.thick = 2

	tlen = !p.ticklen
	!p.region = [0,tobot,1,1]
	!y.margin = [0,ymar[1]]
	!x.tickname = ' '
	Plotot, px, py0, xtype = xtyp, ytype = ytyp[0], ynozero = ynz[0], $
	title = tit, ytitle = ytit[0], psym = psm, linestyle = linst, color = col,$
	_extra = _e
	!p.ticklen = tlen*(1 - 6*scaf)/(1 - tobot - tm)
	axis, xaxis = 1

	!p.ticklen = tlen
	!p.region = [0,0,1,botop]
	!y.margin = [ymar[0],0]
	!x.tickname = ''
	Plotot, px, py1, xtype = xtyp, ytype = ytyp[1], ynozero = ynz[1], $
	xtitle = xtit, ytitle = ytit[1], psym = psm,linestyle = linst,color = col,$
	_extra = _e
	!p.ticklen = tlen*(1 - 6*scaf)/(botop - bm)
	!x.tickname = ' '
	axis, xaxis = 0

	Plvar_keep, action = 'restore'

	return
end
