Pro Display_mm, img, x, y, ind= ind, image= imag, contour= cont, surface= surf,$
	xrev= xrv, yrev= yrv, bin= bin, aver= ave, zoom= zom, auzoom= auz, pix=pix,$
	rot= rot, min= imn, max= imx, block= blk, log= log, intype= itp, fine= fin,$
	clean = cln, order = ord, window= win, wnew= new, restore= rst, poff= pof, $
	_extra = _e

;+
; NAME:
;		DISPLAY_MM
; VERSION:
;		5.2
; PURPOSE:
;		Image display.
; CATEGORY:
;		Display.
; CALLING SEQUENCE:
;		DISPLAY_MM, IMG [, X, Y] [keywords]
; INPUTS:
;	IMG
;		A two dimensional numeric array.  Mandatory.
;		Optionally, a 3D array may be used.  In such case, IMG[2,*,*] is taken
;		to be the actual image, while IMG[0,*,*] and IMG[1,*,*] are taken to be
;		X and Y (see below), respectively.  However, see /IND below.
; OPTIONAL INPUT PARAMETERS:
;	X
;		An optional vector or 2D array of X values for the image.  If not
;		provided, an internal vector (containing consecutive pixel numbers)
;		is generated.
;
;		Optionally, X may be given as a [2,*,*] array.  In such case, X[0,*,*]
;		is used as X and X[1,*,*] as Y, internally.
;	Y
;		An optional vector or 2D array of Y values for the image.  If not
;		provided, an internal vector (containing consecutive pixel numbers) is
;		generated.
; KEYWORD PARAMETERS:
;	IND
;		Integer scalar.  If IMG is a 3D array, IND specifies the index of the
;		image within the array.  In other words, IMG[IND,*,*] is the actual
;		image.  The default value for IND is 2.
;	/IMAGE
;		Switch.  Specifies an Image (TV) display using IDL TVSCL.  This is also
;		the default in the absence of any specification.
;	/CONTOUR
;		Switch.  Specifies contour display using IDL CONTOUR.
;	/SURFACE
;		Switch.  Specifies surface display using IDL SHADE_SURF.
;	/XREV
;		Switch.  If set, the X vector is reversed.
;	/YREV
;		Switch.  If set, the Y vector is reversed.
;	BIN
;		An integer scalar or a vector of length 2, specifies binning of the
;		image.  If given as a vector, first entry applies to the X dimension and
;		second to Y.  If given as a scalar, it applies to both dimensions.
;	/AVER
;		Switch.  Specifies that the binnedchannels are to be averaged, instead
;		of scaled by the bin ratio (which is the default).  If BIN is not used,
;		/AVER has no effect.
;	ZOOM
;		Same as bin, but specifies zooming, i.e. scaling up of the image.  ZOOM
;		is only active in the IMAGE mode.
;	AUZOOM
;		Specifies automatic zooming to a size nearer to AUZOOMxAUZOOM if the
;		value of AUZOOM is >1, or to 512x512 otherwise.  Active only in IMAGE
;		mode.  Overriden by ZOOM if the later is provided.
;	/PIX
;		Switch.  Specifies keeping the pixels as is (no interpolation) while
;		zooming.  Equivalent to the REBIN keyword /SAMPLE.  If no zooming is
;		performed, /PIX has no effect.
;	ROT
;		An integer scalar specifying image rotation.  See IDL function ROTATE
;		for details.
;	MIN
;		A scalar entry in the range (0,1) specifying minimal relative value to
;		be displayed.  The minimum is set at MIN*maximum(IMG) and all image
;		values less than the minimum are set to the minimum.
;	MAX
;		Same as minimum, for the maximal value to be displayed.  All image
;		values greater than the maximum are set to the maximum.
;	/BLOCK
;		Switch.  If set and MAX is provided, all the values greater than the
;		maximum are set to the minimum (i.e. effectively zero).
;	/LOG
;		Switch.  If set, LOG(IMG) is displayed.  However, see /INTYPE.
;	/INTYPE
;		Switch.  If set and /LOG is set, log(IMG + 1) is displayed.  This is
;		also true without setting /INTYPE if IMG is of one of the integer types.
;	/FINE
;		Switch.  Results in finer mesh when diplaying in CONTOUR mode with /LOG
;		set.  No effect in other modes.
;	/CLEAN
;		Switch. If set, only the image is displayed, without axes and scales.
;		Active only in the IMAGE mode.
;	ORDER
;		Scalar integer, overrides the setting of !ORDER.  All even values
;		translate to 0, all odd to 1.  The external value of !ORDER is
;		unaffected.  Note that !order only inluences IMAGE, not the other modes.
;	WINDOW
;		The number of the graphics window to use.  Optional, if not given TV_MM
;		will pick a window by itself.
;	/WNEW
;		Switch.  Forces the creation of new graphics window.
;
;		Note:	If /WNEW is not set, TV_MM will attempt to use the window
;				with number given by WINDOW or, if none was given, the window
;				corresponding to !D.WINDOW.  In the IMAGE mode, however, if this
;				is not large enough to accomodate the image, a new window will
;				still be created.
;	/RESTORE
;		Switch.  If set, !D.WINDOW is reset to its original value (prior to the
;		call to DISPLAY_MM, on exit.
;	POFF
;		An offset of the image into the graphics window (active only in IMAGE
;		mode).  Can be given as a 2-element vector, in a [x_off,y_off] format,
;		or as a scalar (in which case same offset applies to both dimensions).
;
;		Note:	The offset is applied after the graphics window has already been
;				established and it may be reduced (even to zero) if the window
;				is not large enough for the full offset.
;	_EXTRA
;		A formal keyword used to pass all keywords acceptable by PLOT, CONTOUR
;		or SHADE_SURF, as the case arises.  Not to be used directly.
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
;		Straightforward.  Calls ARREQ, DEFAULT, ISNUM, ONE_OF, PLVAR_KEEP, TOLER
;		 and WHERINSTRUCT, from MIDL.
; MODIFICATION HISTORY:
;		Created 30-NOV-2005 by Mati Meron as upgrade from the earlier TV_MM.
;		Modified 15-DEC-2005 by Mati Meron.  Changed keyword NEW to WNEW.
;		Modified 15-FEB-2006 by Mati Meron.  Added keyword POFF and some
;		internal changes.
;		Modified 1-MAR-2006 by Mati Meron.  Added keyword RESTORE.
;		Modified 15-JUN-2006 by Mati Meron.  Adeed keyword IND.
;-

	on_error, 1

	whi = One_of(imag,cont,surf) > 0
	if Isnum(ord,/int) then word = abs(ord mod 2) else word = !order

	wimg = reform(img)
	siz = size(wimg)
	case siz[0] of
		2	:	begin
					if (size(x))[0] eq 3 then begin
						wx = reform(x[0,*,*])
						wy = reform(x[1,*,*])
					endif else begin
						if n_elements(x) lt 2 then wx = lindgen(siz[1]) $
						else wx = reform(x)
						if n_elements(y) lt 2 then wy = lindgen(siz[2]) $
						else wy = reform(y)
					endelse
				end
		3	:	begin
					imind = 2 > Default(ind,2) < (siz[1] - 1)
					wx = reform(wimg[0,*,*])
					wy = reform(wimg[1,*,*])
					wimg = reform(wimg[imind,*,*])
					siz = size(wimg)
				end
		else:	message, 'Not an image!'
	endcase
	if (size(wx))[0] eq 2 then wx = reform(wx[*,0])
	if (size(wy))[0] eq 2 then wy = reform(wy[0,*])
	if keyword_set(xrv) then wx = reverse(wx)
	if keyword_set(yrv) xor word then wy = reverse(wy)
	if not Arreq([n_elements(wx),n_elements(wy)],siz[1:2]) $
	then message, 'Data sizes discrepancy!'

	if Isnum(bin,/int) then begin
		wbin = ([bin,bin[0]])[0:1]
		dims = siz[1:2]/wbin
		if Arreq(dims*wbin,siz[1:2]) then begin
			wimg = rebin(wbin[0]*wbin[1]*wimg,dims)
			if keyword_set(ave) then wimg = wimg/(wbin[0]*wbin[1])
			wx = rebin(wx,dims[0])
			wy = rebin(wy,dims[1])
			siz = size(wimg)
		endif else message, 'Unacceptable bin sizes!'
	endif

	pixfl = keyword_set(pix)
	if keyword_set(auz) and not Isnum(zom) then begin
		auzfl = 1
		if auz gt 1 then ddim = auz else ddim = 512l
		zom = ((ddim + pixfl - 1)/(siz[1:2] + pixfl - 1) > 1)
	endif else auzfl = 0
	if Isnum(zom,/int) and whi eq 0 then begin
		wzom = ([zom,zom[0]])[0:1]
		dims = siz[1:2]*wzom
		lims = dims - wzom
		wimg = rebin(wimg,dims,sample=pixfl)
		wx = rebin(wx,dims[0])
		wy = rebin(wy,dims[1])
		if not pixfl then begin
			wimg = (wimg)[0:lims[0],0:lims[1]]
			wx = (wx)[0:lims[0]]
			wy = (wy)[0:lims[1]]
		endif
		siz = size(wimg)
	endif

	if Isnum(rot,/int) then begin
		wrot = rot mod 8
		if wrot lt 0 then wrot = wrot + 8
		wimg = rotate(wimg,wrot)
		wx = reform(rotate(wx,wrot))
		wy = reform(rotate(transpose(wy),wrot))
		if ((wrot + (wrot ge 4)) mod 2) then begin
			tem = wx
			wx = wy
			wy = tem
			exi = Wherinstruct('xti',_e)
			eyi = Wherinstruct('yti',_e)
			if exi ge 0 and eyi ge 0 then begin
				tem = _e.(exi)
				_e.(exi) = _e.(eyi)
				_e.(eyi) = tem
			endif
			if word and whi eq 0 then begin
				wx = reverse(wx)
				wy = reverse(wy)
			endif
		endif
		siz = size(wimg)
	endif

	imax = max(wimg,min=imin)
	wmin = ((0 > Default(imn,0.,/dtyp) < 1)*imax) > imin
	wmax = ((0 > Default(imx,1.,/dtyp) < 1)*imax) > wmin
	wimg = wimg > wmin
	if keyword_set(blk) then begin
		dum = where(wimg gt wmax, ndum)
		if ndum gt 0 then wimg[dum] = wmin
	endif else wimg = wimg < wmax

	lfl = keyword_set(log)
	if lfl then begin
		if keyword_set(itp) or Isnum(wimg,/int) then wimg = long(wimg) + 1 $
		else wimg = wimg > Toler(wimg)*abs(wmax)
		if whi ne 2 then wimg = alog10(wimg)
		wmax = max(wimg,min=wmin)
	endif

	owin = !d.window
	if Isnum(win,/int) then wset, win
	if keyword_set(new) and whi gt 0 then window, /free
	case whi of
		0:	begin
				xrn = [wx[0],wx[siz[1]-1]]
				yrn = [wy[0],wy[siz[2]-1]]
				if lfl then zrn = 10^[wmin,wmax] else zrn = [wmin,wmax]

				fulfl = 1 - keyword_set(cln)
				lpad = 64l*fulfl
				rpad = 24l*fulfl
				ssiz = siz
				if auzfl then ssiz[1:2] = [ddim,ddim]
				xsiz = ssiz[1] + 2*(lpad + rpad)
				ysiz = ssiz[2] + lpad + rpad

				if keyword_set(new) or !d.x_size lt xsiz or !d.y_size lt ysiz $
				then window, /free, xsiz = xsiz, ysiz = ysiz
				mpof = [!d.x_size - xsiz, !d.y_size - ysiz]
				if Isnum(pof) then wpof = 0 > ([pof,pof[0]])[0:1] < mpof $
				else wpof = [0,0]
				wpad = lpad + wpof

				plvar_keep, act = 'sav'
				erase
				device, deco = 0
				tvscl, wimg, wpad[0], wpad[1], order = word

				if fulfl then begin
					plot, wx, wy, xran=xrn, yran=yrn,/nodata,/noerase,/device,$
					xstyle = 9, ystyle = 9, ticklen = -0.01, $
					position = [wpad,wpad + siz[1:2] - 1], _extra = _e
					cwid = 2*rpad/3
					carr = bytarr(cwid,siz[2])
					fill = 256l*lindgen(siz[2])/siz[2]
					if word then fill = reverse(fill)
					for i = 0l, cwid - 1 do carr[i,*] = fill
					tvscl, carr, wpad[0]+ siz[1]+ rpad/3, wpad[1], order = word
					plot, zrn, zrn, yran = zrn, /nodata, /noerase, /device, $
					posit= [wpad +[siz[1]+rpad/3,0],wpad+siz[1:2]+[rpad,0]-1], $
					xstyle = 5, ystyle = 5, ylog = lfl
					axis, yax=1, ticklen=-0.01*siz[1]/cwid, ystyle=9
				endif
				plvar_keep, act = 'res'
			end
		1:	begin
				if lfl then begin
					top = floor(wmax)
					bot = floor(wmin) < 0
					dtp = top - bot
					finfl = keyword_set(fin)
					if finfl then row = [1,2,5] else row = [1,3]
					tem = findgen(2+finfl,dtp+1)
					for i = 0, dtp do tem[*,i] = row*10.^(i+bot)
					tem = tem[*]
					lev = alog10(tem)
					ntem = n_elements(tem)
					annot= string(tem)
					ftem = floor(lev)
					form = strcompress($
					'(f'+ string(abs(ftem)+3)+ '.'+ string(-ftem>1)+')',/rem)
					annot = strarr(ntem)
					for i = 0l, ntem-1 do annot[i] = string(tem[i],form=form[i])
				endif else begin
					lmax = 10.^floor(alog10(wmax))
					hmax = lmax*ceil(wmax/lmax)
					inlev = Wherinstruct('nlev',_e)
					if inlev ge 0 then nlev = _e.(inlev) else nlev = 11
					lev = hmax/10.*findgen(nlev)
				endelse
				contour, wimg, wx, wy, /fol, lev = lev, c_annot = annot, $
				xstyle=1, ystyle=1, _extra = _e
			end
		2:	begin
				shade_surf, wimg, wx, wy, zlog = lfl, charsiz= 2, _extra = _e
			end
	endcase
	if keyword_set(rst) then wset, owin

	return
end