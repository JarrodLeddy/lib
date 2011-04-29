Pro Plotot, x, y, xtype = xtyp, ytype = ytyp, ynozero = ynz, $
	psym = psm, linestyle = linst, color = col, _extra = _e

;+
; NAME:
;		PLOTOT
; VERSION:
;		4.0
; PURPOSE:
;		Plots multiple data sets on a single plot.
; CATEGORY:
;		Plotting.
; CALLING SEQUENCE:
;		PLOTOT, [X,] Y [, optional keywords]
; INPUTS:
;	Y
;		A numeric vector or 2 dimensional array containing the Y coordinates of
;		the data.  If Y is a vector PLOTOT operates same as PLOT.  If it is
;		a 2-dim.array, each row is ploted separately.  It is assumed that the
;		number of points per plot is larger than the number of plots so that if
;		 is an (M*N) array with N > M, it will be transposed prior to plotting.
; OPTIONAL INPUT PARAMETERS:
;	X
;		A numeric vector containing the X coordinates of the data.  If absent
;		it is replaced by the vector [0, 1, 2 ...].
; KEYWORD PARAMETERS:
;	XTYPE
;		Standard IDL plotting interpretation.
;	YTYPE
;		Ditto.
;	/YNOZERO
;		Ditto.
;	PSYM
;		Ditto.  If given as a vector consecutive elements are applied to
;		consecutive plots.
;	LINESTYLE
;		Ditto.  If given as a vector consecutive elements are applied to
;		consecutive plots.
;	COLOR
;		Ditto.  If given as a vector consecutive elements are applied to
;		consecutive plots.
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
;		Straightforward.  Uses calls to DEFAULT, PLVAR_KEEP, SIGN and
;		WHERINSTRUCT in MIDL.
; MODIFICATION HISTORY:
;		Created 30-JUL-1991 by Mati Meron.
;		Modified 15-JAN-1994 by Mati Meron.  Now PLOTOT takes advantage of the
;		keyword inheritance property and accepts all IDL plotting keywords.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;		Modified 5-JAN-2003 by Mati Meron.  Internal change, using PLVAR_KEEP
;		to assure restoration of plot paramaters to initial state before exit.
;		Modified 10-APR-2004 by Mati Meron.  Internal changes only.
;-

	on_error, 1
	if n_elements(x) eq 0 then message, 'Missing data!'

	sdum = size(x)
	if n_elements(y) eq 0 then begin
		py = x
		case sdum[0] of
			1	:	len = sdum[1]
			2	:	len = max(sdum[1:2])
			else:	message, 'Bad data!'
		endcase
		px = indgen(len)
	endif else begin
		len = sdum[1]
		px = x
		py = y
	endelse

	sdum = size(py)
	case sdum[0] of
		1	:	plnum = 1
		2	:	if sdum[2] eq len then begin
					plnum = sdum[1]
					py = transpose(py)
				endif else plnum = sdum[2]
		else:	message, 'Bad data!'
	endcase

	xtyp = Default(xtyp,!x.type)
	ytyp = Default(ytyp,!y.type)
	xlfl = xtyp or (Wherinstruct('xlo',_e) ge 0)
	ylfl = ytyp or (Wherinstruct('ylo',_e) ge 0)
	xmin = min(px, max = xmax)
	ymin = min(py, max = ymax)
	ynz = Default(ynz,0)
	if ynz eq 0 and not ylfl then ymin = 0 < ymin
	if xlfl then xmin = xmin > (machar()).xmin
	if ylfl then ymin = ymin > (machar()).xmin
	nth = Wherinstruct('thi',_e,thcon)
	if thcon eq 1 then thi = _e.(nth[0]) else thi = !p.thick
	psm = Default(psm,0)
	if n_elements(psm) eq 1 then psm = (psm + Sign(psm)*indgen(plnum)) mod 7
	linst = Default(linst,0)
	if n_elements(linst) eq 1 then linst = (linst + indgen(plnum)) mod 6
	col = Default(col,!p.color)
	if n_elements(col) eq 1 then col = (col + intarr(plnum))

	plvar_keep, act = 'sav'
	plot, px, py[*,0], xrange = [xmin,xmax], yrange = [ymin,ymax], $
		xtype = xtyp, ytype = ytyp, ynozero = ynz, psym = psm[0], $
		linestyle = linst[0], color = col[0], _extra = _e
	for i = 1, plnum - 1 do begin
		oplot, px, py[*,i], thick = thi, psym = psm[i], $
		linestyle = linst[i], color = col[i]
	endfor
	plvar_keep, act = 'res'

	return
end
