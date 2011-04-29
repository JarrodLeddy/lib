Function Deglitch, arr, thresh, down = down, up = up, count = cnt

;+
; NAME:
;		DEGLITCH
; VERSION:
;		4.0
; PURPOSE:
;		Replaces exceptional array elements by the average of their neighbors.
; CATEGORY:
;		Array Function.
; CALLING SEQUENCE:
;		Result = DEGLITCH( ARR, THRESH [, keywords])
; INPUTS:
;	ARR
;		Array, numeric, otherwise arbitrary.
;	THRESH
;		Threshold value for element replacement.  Must be > 1.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/DOWN
;		Switch.  If set the correction is downward, i.e. elements which are too
;		big (in absolute value) are replaced.  This is the default.
;	/UP
;		Switch.  If set the correction is upward, i.e. elements which are too
;		small (in absolute value) are replaced.
;	COUNT
;		Optional output, see below.
; OUTPUTS:
;		Returns the corrected array, i.e. an array of the same format as ARR,
;		in which all the exceptional element have been replaced by the average
;		of their neighbors.
; OPTIONAL OUTPUT PARAMETERS:
;	COUNT
;		The name of the variable to receive the number of exceptional elements.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Compares the absolute values of the original array and the one obtained
;		by neighborhood averaging.  Locates exceptions and replaces them by
;		neighborhood average.  Uses FPU_FIX, NEIGHBORS and ONE_OF from MIDL.
; MODIFICATION HISTORY:
;		Created 30-MARCH-1994 by Mati Meron.
;		Modified 10-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	if thresh le 1 then message, 'Threshold must be > 1!'
	dir = One_of(down,up) > 0
	cnt = 0l
	res = arr
	siz = size(arr)
	ndmx = 7
	ndm = siz(0)
	if ndm gt 0 then begin
		if ndm lt ndmx then asiz = [ndmx,replicate(1,ndmx-ndm),siz[1:*]]
		tarr = make_array(size = asiz)
		abar = tarr + abs(arr)
		a = lonarr(ndmx)
		for i = ndmx - ndm, ndmx - 1 do begin
			a[i] = 1
			b = - a
			tarr = tarr + $
			shift(abar,a[0],a[1],a[2],a[3],a[4],a[5],a[6]) + $
			shift(abar,b[0],b[1],b[2],b[3],b[4],b[5],b[6])
			a[i] = 0
		endfor
		abar = reform(abar,asiz[ndmx-ndm+1:ndmx])
		tarr = reform(tarr,asiz[ndmx-ndm+1:ndmx])/(2.^ndm)
		if dir then fset = where(tarr gt thresh*abar,cnt) $
		else fset =  where(abar gt thresh*tarr,cnt)
		for i = 0, cnt - 1 do res(fset[i]) = $
		total(res(Neighbors(fset[i],siz,count=con)))/con
    endif

	return, FPU_fix(res)
end
