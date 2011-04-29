Function Partot, farr, tod, low = lo, high = hi, lofringe = lf, hifringe = hf, $
	symedge = syme, symfringe = symf

;+
; NAME:
;		PARTOT
; VERSION:
;		4.0
; PURPOSE:
;		Array summation.
; CATEGORY:
;		Array Function.
; CALLING SEQUENCE:
;		Result = PARTOT( FARR [, TOD] [, keywords])
; INPUTS:
;	FARR
;		Array, numeric, otherwise arbitrary (scalars accepted too).
; OPTIONAL INPUT PARAMETERS:
;	TOD
;		Totaling dimension.  Must be integer in the range of
;		[1, number of array dimensions]
; KEYWORD PARAMETERS:
;
;		warning!!!
;		The keywords are divided into two groups
;		1) regular mode:	LOW, HIGH, LOFRINGE, HIFRINGE
;		2) symmetric mode	SYMEDGE, SYMFRINGE
;
;		Either group (1) or (2) may be used.  Mixing will cause error.
;
;	LOW
;		Numeric vector (or scalar) containing starting channels for summation
;		for each dimension.  First entry corresponds to first dimension,
;		second to second dimension etc.  If number of entries is smaller then
;		number of dimensions, the remaining ones are replaced by 0.  If it is
;		larger then number of dimensions, the excess is ignored.  If absent,
;		all the values are replaced by 0.
;		Alternatively:  If TOD is used, LOW must be scalar (or vector of length
;		1), providing the summation start for the dimension specified by TOD.
;		Again, if absent, it is replaced by 0.
;	HIGH
;		Same as LOW for ending summation channel.  Missing values are replaced
;		by maximal value.  For example, if the array has dimensions [7,8,12]
;		and HIGH is given as [6,5] then internally [6,5,11] is used (maximal
;		value is always dimension - 1).
;	LOFRINGE
;		Numeric vector (or scalar) specifying partial counting of the value
;		in the first summation channel.  Acceptable values are in the
;		[-0.5, 0.5] range.  For example if the array has dimensions [6,8,10],
;		LOW is [2,1,5] and LOFRINGE = [0.2, 0.3,-0.4] then the beginning
;		elements in the first dimension, arr(2,*,*), will be multiplied by
;		(1 + 0.2) = 1.2 while the beginning elements in the third dimension,
;		arr(*,*,5) will be multiplied by (1 - 0.4) = 0.6.  If the number of
;		entries is shorter then the number of dimensions, it'll be padded with
;		zeros.  If it is larger, the excess will be ignored.  If absent
;		alltogether, zeros will be used.
;		Alternatively:  If TOD is used, LOFRINGE must be scalar (or vector of
;		length 1), and is applied to the summation dimension specified by TOD.
;		Again, if absent, it is replaced by 0.
;	HIFRINGE
;		Same as LOFRINGE but applied to the ending channel.
;
;	SYMEDGE
;		Used in a symmetrical mode.  IN this case the start and end channels
;		for each dimension are counted symmetrically from the center.  If the
;		number of channels in a specific dimension is odd then the center is
;		the middle channel.  For example for a vector of length 9 (indices
;		0 through 8) index of 4 (fifth element) gives the center.  For a vector
;		of length 8 (indices 0 through 7) the center is at the imaginary point
;		between indices 3 and 4.
;		Example:
;		Assume and array with dimensions [8,9,10] and SYMEDGE given as [3,3]
;		Thus:
;		On first dimension summation is from index 1 to index 6 (3 on each side
;		of the center, 6 total).
;		On second dimension summation is from index 1 to index 7 (3 on each
;		side, 7 total since the center is now also included).
;		On third dimension, since no data is provided, the summation is from
;		index 0 to index 9 (i.e full)
;		Alternatively:  If TOD is used, SYMEDGE must be scalar (or vector of
;		length 1), and is applied to the summation dimension specified by TOD.
;	SYMFRINGE
;		Same as LOFRINGE and HIFRINGE in the regular case.  Applied to both
;		summation limits, symmetrically.
; OUTPUTS:
;		Scalar equal the value of the summation, unless TOD is used, in which
;		case the output is an array with one less dimension then the original
;		one.  This is identical to the behavior of the IDL function TOTAL.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		1)  The array must be numerical.
;		2)  Mixing keywords from the regular and symmetrical group is not
;	    allowed.
;		3)  The value of TOD cannot exceed the number of dimensions.
;		4)  If TOD is used, all the edges and fringes provided by the
;	    keywords must have no more then one element.
;		5)  The values given by LOW mustn't exceed these given by HIGH.
; PROCEDURE:
;		A straightforward generalization on the IDL function TOTAL, making it
;		closer to a variable limit numerical integration.  Calling DEFAULT and
;		ISNUM from MIDL.
; MODIFICATION HISTORY:
;		Created 30-OCT-1996 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	ndmx = 7

	if not Isnum(farr) then message, 'Only numerical arrays allowed'
	siz = size(farr)
	dim = siz[0]
	tod = Default(tod,0l,/dtype)
	tofl = tod gt 0

	nlo = n_elements(lo) < dim
	nhi = n_elements(hi) < dim
	nlf = n_elements(lf) < dim
	nhf = n_elements(hf) < dim
	nse = n_elements(syme) < dim
	nsf = n_elements(symf) < dim

	syfl = max([nse,nsf]) gt 0
	if syfl and max([nlo,nhi,nlf,nhf]) gt 0 then $
	message, 'Either regular or symmetric mode must be used!'

	if tofl then begin
		if tod gt dim then message, 'Invalid summation dimension!'
		if (syfl and (max([nse,nsf]) gt 1)) or $
		((not syfl) and (max([nlo,nhi,nlf,nhf]) gt 1)) then $
		message, 'Only scalar limits and fringes allowed with 1D summation!'
	endif

	if dim gt 0 then begin
		a = replicate(0l,ndmx)
		b = [siz[1:dim]-1, a[dim:*]]
		tem = b
		lfr = replicate(0.,ndmx)
		hfr = lfr

		if syfl then begin
			if nse gt 0 then begin
				if tofl then begin
					a[tod-1] = (tem[tod-1] + 1)/2 - syme
					b[tod-1] = tem[tod-1]/2 + syme
				endif else begin
					a[0:nse-1] = (tem[0:nse-1] + 1)/2 - syme
					b[0:nse-1] = tem[0:nse-1]/2 + syme
				endelse
			endif

			if nsf gt 0 then begin
				if tofl then begin
					lfr[tod-1] = symf
					hfr[tod-1] = symf
				endif else begin
					lfr[0:nsf-1] = symf
					hfr[0:nsf-1] = symf
				endelse
	    	endif

		endif else begin
			if nlo gt 0 then if tofl then a[tod-1] = lo else a[0:nlo-1] = lo
			if nhi gt 0 then if tofl then b[tod-1] = hi else b[0:nhi-1] = hi
			if nlf gt 0 then if tofl then lfr[tod-1] = lf else lfr[0:nlf-1] = lf
			if nhf gt 0 then if tofl then hfr[tod-1] = hf else hfr[0:nhf-1] = hf
		endelse

		a = a > 0 < tem
		b = b > 0 < tem
		tem = where(a gt b, ntem)
		if ntem gt 0 then message, 'lower limits cannot exceed upper limits!'
		lfr = lfr > (-0.5) < 0.5
		hfr = hfr > (-0.5) < 0.5

		res = farr $
		(a[0]:b[0],a[1]:b[1],a[2]:b[2],a[3]:b[3],a[4]:b[4],a[5]:b[5],a[6]:b[6])

		b = b - a
		a = a - a

		if (size(res))[0] lt dim then res = reform(res,(b+1)[0:dim-1])
		if tofl then s = [tod - 1] else s = dim - lindgen(dim) - 1

		for i = 0, n_elements(s) - 1 do begin
			tres = total(res,s[i]+1)
			a(s[i]) = b(s[i])
			hcor = hfr(s[i])*res(a[0]:b[0],a[1]:b[1],a[2]:b[2],a[3]:b[3],$
					a[4]:b[4],a[5]:b[5],a[6]:b[6])
			a(s[i]) = 0
			b(s[i]) = 0
			lcor = lfr(s[i])*res(a[0]:b[0],a[1]:b[1],a[2]:b[2],a[3]:b[3],$
					a[4]:b[4],a[5]:b[5],a[6]:b[6])

			res = tres + lcor + hcor
		endfor
		if not tofl or dim eq 1 then res = res[0]
	endif else res = farr

	return, res
end
