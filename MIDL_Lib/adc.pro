Function ADC, arr, mask = msk, binsize = bin, n_channels = nch, $
	min = min, max = max, left = lef, center = cen, right = rig, $
	round = rnd, extend = ext, top_adjust = top, normalize = norm, $
	omin = omin, omax = omax, values = val, reverse_indices = rev

;+
; NAME:
;		ADC
; VERSION:
;		4.3
; PURPOSE:
;		Interface to HISTOGRAM, simulating an Analog to Digital Converter.
; CATEGORY:
;		Mathematical.
; CALLING SEQUENCE:
;		Result = ADC( ARR [, keywords] )
; INPUTS:
;	ARR
;		Array, numeric, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	MASK
;		Provision for optional data mask.  Needs to be an array of the same
;		as ARR.  If given, only data (in ARR) corresponding to locations of
;		non-zero elements of MASK is considered.  Equivalent to replacing
;		ARR by ARR[ where(mask ne 0)].
;	BINSIZE
;		Specifies the size of the BIN, same as in HISTOGRAM.  Defaults to full
;		range (i.e. a single channel).
;	N_CHANNELS
;		Number of channels to use in the binning.  If BINSIZE is provided,
;		N_CHANNELS is ignored.
;	MIN
;		The minimal value to consider.  Same as in HISTOGRAM.  The default
;		value is min(ARR).
;	MAX
;		The maximal value to consider.  Same as in HISTOGRAM.  The default
;		value is max(ARR).
;	/LEFT
;		Switch.  If set, the elements within each bin are associated with the
;		left bin boundary (i.e. with the minimum of the interval).
;	/CENTER
;		Switch.  If set, the elements within each bin are associated with the
;		center of the bin (i.e. with the middle of the interval).  This is the
;		default.
;	/RIGHT
;		Switch.  If set, the elements within each bin are associated with the
;		right bin boundary (i.e. with the maximum of the interval).
;
;		NOTE!!!:  Only one of the switches LEFT, CENTER, RIGHT may be set.
;
;	/ROUND
;		Switch.  If set, the upper and lower boundaries are rounded (up and
;		down, respectively) to the nearest bin.
;	/EXTEND
;		Switch.  If set, the upper and lower boundaries are extended (up and
;		down, respectively) by half a bin.
;
;		NOTE:  If BINSIZE is not set, ROUND and EXTEND are ignored.
;
;	/TOP_ADJUST
;		Switch.  If set, adjusts for the possibility of the uppermost element
;		of ARR being counted in a separate channel.
;	/NORMALIZE
;		Switch.  If set, the output is normalized to a total sum of 1.
;	OMIN
;		Optional output.  See below.
;	OMAX
;		Optional output.  See below.
;	VALUES
;		Optional output.  See below.
;	REVERSE_INDICES
;		Optional output, see below.
; OUTPUTS:
;		Returns a histogram of the original array, with either binsize provided
;		by BIN or number of channels provided by N_CHANNELS.
; OPTIONAL OUTPUT PARAMETERS:
;	OMIN
;		Name of a variable to receive the value of MIN used internally.  Same
;		as in HISTOGRAM.
;	OMAX
;		Name of a variable to receive the value of MAX used internally.  Same
;		as in HISTOGRAM.
;	VALUES
;		Returns a vector of the nominal values associated with the bins
;		(LEFT, CENTER or RIGHT, according to the keywords).
;	REVERSE_INDICES
;		Same meaning as in the original HISTOGRAM routine.  See there.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		ARR must be numeric and BIN must be a positive scalar.  No other
;		restrictions.
; PROCEDURE:
;		Straightforward.  Calls the IDL function HISTOGRAM.  Also calls ARREQ,
;		CAST, DEFAULT, FPU_FIX, ISNUM and ONE_OF from MIDL.
; MODIFICATION HISTORY:
;		Created 15-MAY-1996 by Mati Meron.
;		Modified 25-JUN-2000 by Mati Meron.  Internal changes only.
;		Modified 1-AUG-2001 by Mati Meron.  Checked compatibility with Windows
;		and added keywords MASK and ROUND.
;		Modified 5-JAN-2002 by Mati Meron.  Added keyword EXTEND and improved
;		internal consistency.
;-

	on_error, 1
	if not Isnum(arr,type=typ) then message, 'Not a numeric array!'
	if Isnum(msk) then begin
		sar = size(reform(arr))
		sms = size(reform(msk))
		if Arreq(sar[0:sar[0]],sms[0:sms[0]]) then warr=arr[where(msk ne 0)] $
		else message, 'Mask size mismatch!'
	endif else warr = arr
	wtyp = typ > 4
	warr = Cast(warr,wtyp)
	omin = min(warr, max = omax)
	if n_elements(min) ne 0 then omin = Cast(min,wtyp)
	if n_elements(max) ne 0 then omax = Cast(max,wtyp)
	if omax lt omin then message, 'MAX must be >= MIN'

	bex = Isnum(bin)
	if bex then begin
		if bin le 0 then message, 'BIN must be positive!'
		if keyword_set(rnd) then begin
			omin = Cast(bin*floor(omin/bin),wtyp)
			omax = Cast(bin*ceil(omax/bin),wtyp)
		endif
		if keyword_set(ext) then begin
			omin = omin - 0.5*bin
			omax = omax + 0.5*bin
		endif
	endif

	span = omax - omin
	nch = Default(nch,1l,/dtype) > 1
	sh = 0.5*abs(One_of(lef,cen,rig))

	if span gt 0 and (bex or nch gt 1) then begin
		if bex then wbin = Cast(bin,wtyp,wtyp) $
		else wbin = span*(1+Toler(span))/nch
		harr = (warr - omin)/wbin
		hmax = span/wbin
		res = histogram(harr, min = 0, max = hmax, reverse_indices = rev)
		nre = n_elements(res)
		if keyword_set(top) and nre gt 1 then begin
			dum = where(harr eq ceil(hmax), ndum)
			if ndum gt 0 then begin
				res[nre-2] = res[nre-2] + ndum
				res(nre-1) = res(nre-1) - ndum
			endif
			if res[nre-1] eq 0 then begin
				nre = nre - 1
				res = res[0:nre-1]
			endif
		endif
		val = omin + wbin*(findgen(nre) + sh)
	endif else begin
		dum = where(warr ge omin and warr le omax,ndum)
		res = [ndum]
		val = [(1-sh)*omin + sh*omax]
	endelse
	if keyword_set(norm) then res = res/(wbin*total(res))

	return, FPU_fix(res)
end