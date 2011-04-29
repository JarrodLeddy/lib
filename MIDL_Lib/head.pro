Pro Head, a, b, c, d, e, f, g, h, nr = nr, nc = nc, row = ro, column = co, $
	full = ful, transpose = trn, show_index = shin, nowrap = now, format= efor,$
	_extra = _e

;+
; NAME:
;		HEAD
; VERSION:
;		5.0
; PURPOSE:
;		Displays the beginning ("head") or, optionally, a selected part of an
;		1-2D array.
; CATEGORY:
;		Input/Output.
; CALLING SEQUENCE:
;		HEAD, A [,B ...H] [,keywords]
; INPUTS:
;	A [,B ...H]
;		One or more arrays, of arbitrary type.  If more than one array is
;		provided, all the arrays have to be 1D.  A single array can have 1 or
;		2 dimensions, but no more than 2.
; OPTIONAL INPUT PARAMETERS:
;		All but the first input are optional.
; KEYWORD PARAMETERS:
;	NR
;		The number of rows to be displayed.  Default value is 10 (except for
;		the case of a single 1D array in wrapping mode (see keyword NO_WRAP,
;		below), when it is 12).  If explicit values for the starting and ending
;		row numbers are provided through the keyword ROW (see below), NR is
;		ignored.
;	NC
;		Same as NR, for columns.  Default value is 6, maximal value is 8.
;		In the case of a single 1D array in wrapping mode, NC is
;		interchangeable with NR and, if both are provided, NC is ignored.
;	ROW
;		Specifies the first (and possibly last) row of the displayed array
;		part.  For an array with N rows, the possibilities are as follows:
;
;			1)	No value provided: display area is from row #0 through row
;				#(NR - 1) or last row, whichever comes first.
;			2)	Scalar value r0:  display area is from row #r0 through row
;				#(r0 + NR - 1) or last row, whichever comes first.
;			3)  Single vector value r0 (for example, ROW = [4]):  this is
;				interpreted as a vector input, ROW = [r0,r0] (see case 4 below)
;				and a single row (#r0) is output.
;			4)	Two element vector of the form ROW = [r0,r1]:  In this case
;				display area is from row #r0 through row #r1.
;
;		In the case of a single 1D array in the default wrapping mode (see
;		keyword NO_WRAP, below), ROW is interchangeble with COLUMN and
;		specifies the first (and, possibly, last) element to be displayed).
;	COLUMN
;		Same as ROW, for columns of the display area.  For a 2D array the
;		default number of displayed columns is the smaller of 6 and the actual
;		number of columns in the data.  For 1D arrays COLUMN is ignored,
;		except for the case of a single 1D array in wrapping mode.  In this
;		case COLUMN is interchangeable with ROW (see above) and ignored if ROW
;		is provided.
;		Maximal possible number of displayed columns is 8.
;	/FULL
;		Switch.  If set, the whole array is displayed.  Note that /FULL
;		overrides the settings of ROW, if provided.
;	/TRANSPOSE
;		Switch.  If set and the input array is 2D, the transpose of the array
;		is used.  Thus HEAD, A, /TRANSPOSE is equivalent to HEAD, TRANSPOSE(A).
;		Ignored for multiple 1D inputs.
;	/SHOW_INDEX
;		Switch.  If set, the indices of the rows and columns shown are
;		displayed, on the right (for rows) and top (for columns).
;	/NO_WRAP
;		Switch.  Turns off wrapping mode which is on, by default for single 1D
;		arrays.  In the wrapping mode the array is displayed over as many lines
;		as needed, same as when being displayed using the PRINT statement.  In
;		a non-wrapping mode only a portion of a 1D array that fits on a single
;		line may be displayed.  If the input consists of a 2D array or multiple
;		1D arrays, the wrapping mode is off.
;	FORMAT
;		Character array, containing format specifications for the columns.
;		If not provided, default TABULATE formats are used.  If only a single
;		entry provided, it'll be used for all columns.  For more details see
;		TABULATE.
;		If multiple entries are provided in the wrapping mode, only the first
;		one is used.
;	_EXTRA
;		A formal keyword used to pass keywords to TABULATE.  Not to be used
;		directly.  All TABULATE keywords are available.
; OUTPUTS:
;		None, other then the printed output.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		As mentioned above:
;			1)	Arrays with more then 2 dimensions not accepted.
;			2)	For 2D, only a single array is allowed.
;			3)	For 1D, up to 8 arrays allowed.  They can be of different
;				types but must have same length.
;			4)  Wrapping is only possible with a single 1D array.
; PROCEDURE:
;		HEAD serves as a front end to TABULATE.  It selects a part of the
;		input, based on the row and column settings, and passes it to TABULATE
;		which displays it.  In addition to TABULATE, HEAD calls DEFAULT,
;		HOW_MANY, STRPARSE_MM and TYPE from MIDL.
;		In the wrap mode, HEAD bypasses TABULATE and uses PRINT, directly.
; MODIFICATION HISTORY:
;		Created 1-NOV-1997 by Mati Meron.
;		Modified 5-OCT-1998 by Mati Meron.  Added wrap mode for 1D arrays.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;		Modified 20-JUL-2005 by Mati Meron.  Added keyword FULL.
;-

	on_error, 1
	nwadef = 12l
	nrodef = 10l
	ncodef = 6l
	ncomax = 8l
	wrafl = 0
	cnams = [ 'A',  'B',  'C',  'D',  'E',  'F',  'G',  'H']
	wnams = ['WA', 'WB', 'WC', 'WD', 'WE', 'WF', 'WG', 'WH']

	wnr = Default(nr,nrodef,/dtype)
	wnc = Default(nc,ncodef,/dtype) < ncomax
	shofl = keyword_set(shin)

	nco = (n_params() < ncomax)
	if nco gt 0 then begin
		if nco eq 1 then begin
			tem = [a]
			if keyword_set(trn) then tem = transpose(tem)
			siz = size(tem)
			if siz[0] gt 2 then begin
				tem = reform(tem)
				siz = size(tem)
				if siz[0] gt 2 then message, 'Dims > 2 not supported!'
			endif
			if siz[0] eq 1 then begin
				if keyword_set(now) then begin
					tem = reform(tem,siz[1],1)
					siz = size(tem)
				endif else wrafl = 1
			endif
			if wrafl then begin
				nro = siz[1]
				ndum = How_many(fir = nr,sec = nc)
				if ndum eq 0 then wnr = nwadef else wnr = Default(nr,nc) > 0l
				ndum = How_many(fir = ro, sec = co)
				if ndum eq 0 then wro = 0l else wro = Default(ro,co) > 0l
			endif else begin
				wco = Default(co,0l,/dtype) > 0
				if (size(wco))[0] eq 0 then wco = [wco,wco+wnc-1] else $
				if n_elements(wco) eq 1 then wco = [wco,wco]
				wco = wco[0] > wco < (((wco[0] + ncomax) < siz[1]) - 1)
				nco = wco[1] - wco[0] + 1
				nro = siz[2]
				for i = wco[0], wco[1] do id = $
				execute(wnams(i-wco[0]) + ' = reform(tem(' + string(i) + ',*))')
				if shofl then begin
					lfor = floor(alog10(wco[1] > 1)) + 1
					hfor = strcompress('(I' + string(lfor) + ')', /remove_all)
					head = string(wco[0] + lindgen(nco), form = hfor)
				endif
			endelse
		endif else begin
			idim = lonarr(nco)
			nro = idim
			for i = 0, nco - 1 do begin
				id = execute('typ = Type(' + cnams[i] + ')')
				if typ gt 0 then begin
					id = execute(wnams[i] + ' = reform([' + cnams[i] + '])')
					id = execute('siz = size(' + wnams[i] + ')')
					idim[i] = siz[0]
					nro[i] = siz[1]
				endif else nco = nco < i
			endfor
			if max(idim) gt 1 then message, 'multiple arrays must be 1D!'
			nro = min(nro[0:nco-1], max = nrox)
			if nro ne nrox then message, 'Unequal column lengths!'
		endelse
	endif else message, 'No data!'

	if not keyword_set(ful) then begin
		if not wrafl then wro = Default(ro,0l,/dtype) > 0l
		if (size(wro))[0] eq 0 then wro = [wro,wro+wnr-1] else $
		if n_elements(wro) eq 1 then wro = [wro,wro]
		wro = wro[0] > wro < (nro - 1)
	endif else wro = [0l,nro-1]

	if n_elements(efor) ne 0 then begin
		wefor = efor
		if wrafl then begin
			dum = Strparse_mm(wefor[0],'()',lis)
			wefor = lis[0]
			dum = Strparse_mm(wefor,'.0123456789',lis)
			fpos = strpos(wefor,lis[0])
			if fpos eq 0 then wefor = strcompress(string(nro),/remove) + wefor
			wefor = '(' + wefor +')'
		endif else if n_elements(wefor) eq 1 then wefor = replicate(wefor,nco)
	endif

	if wrafl then print, a(wro[0]:wro[1]), form = wefor else $
	Tabulate, wa, wb, wc, wd, we, wf, wg, wh, from = wro[0], to = wro[1], $
	index = shofl, head = head, nohead = 1 - shofl, format = wefor, _extra = _e

	return
end
