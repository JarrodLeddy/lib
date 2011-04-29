Function extend_array, arr, off, newsize = nsiz, value = val, edge_extend = ext

;+
; NAME:
;		EXTEND_ARRAY
; VERSION:
;		4.0
; PURPOSE:
;		Extends an array to a larger size, filling the blanks according to
;		keyword specifications.
; CATEGORY:
;		Array function.
; CALLING SEQUENCE:
;		Result = EXTEND_ARRAY( ARR, [, OFF] [,keywords]])
; INPUTS:
;	ARR
;		Array, arbitrary.
;	OFF
;		Vector containing the offset of ARR into the result array.  Defaults
;		to zero(s).  If the number of entries is smaller then the dimension
;		(either of ARR or of the result) missing entries are replaced with 0,
;		from left.  Thus if the result has dimensions of (4,5,6) but offset
;		is given as [2,2], an offset of [0,2,2] is used.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	NEWSIZE
;		A vector, containing the parameters of the result array, in the format
;		of the output of the IDL SIZE function.  If not given, the size used is
;		the minimal size capable of containing the original array with the
;		specified offset.
;	VALUE
;		A scalar value used to fill the blanks in the result array.  Defaults
;		to 0.  Warning:  VALUE and EDGE_EXTEND cannot be specified at the same
;		time
;	/EDGE_EXTEND
;		Switch.  If set, the blanks in the result array are filled with the
;		adjoining edge values of ARR.  Warning:  EDGE_EXTEND and VALUE cannot
;		be specified at the same time
; OUTPUTS:
;		Returns an array of size specified either by NEWSIZE or combination of
;		the original size and offset.  The original arry is imbedded in the
;		result, and the blanks are filled according to the keywords VALUE or
;		EDGE_EXTEND.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The new size, as provided by NEWSIZE, must be large enough to contain
;		the original array with the offset.
; PROCEDURE:
;		Straightforward.  Calls DEFAULT and ONE_OF from MIDL.
; MODIFICATION HISTORY:
;		Created 20-JAN-1997 by Mati Meron.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	ndm = 7

	siz = size([arr])
	nda = siz[0]
	if nda lt ndm then sir = [ndm,replicate(1l,ndm-nda),siz[1:*]] else sir = siz

	nof = n_elements(off)
	if nof eq 0 then l = replicate(0l,ndm) else $
	if nof lt ndm then l = [replicate(0l,ndm-nof),off] else $
	if nof eq ndm then l = off else message, 'Offset dimension error!'
	h = l + sir[1:ndm] - 1
	nds = nda > nof

	if n_elements(nsiz) gt 0 then begin
		nds = nsiz[0]
		if nds ge nda then begin
			sir[ndm-nds+1:ndm] = nsiz[1:nds]
			sir[ndm + 1] = sir[ndm+1] > nsiz(nds+1)
		endif else message, 'Insufficient number of result dimensions!'
		dum = where((sir[1:ndm] - h) lt 1, ndum)
		if ndum gt 0 then message, 'Insufficient new size!'
	endif else sir[1:ndm] = h + 1
	s = sir[1:ndm] - h - 1

	prod = 1l
	for i = 1, ndm do prod = prod*sir[i]
	sir[ndm + 2] = prod

	exfl = One_of(val,ext) > 0
	val = Default(val,0)

	res = make_array(size = sir, value = val)
	res[l[0]:h[0],l[1]:h[1],l[2]:h[2],l[3]:h[3],$
		l[4]:h[4],l[5]:h[5],l[6]:h[6]] = arr

	if exfl then begin

		if l[0] gt 0 then $
		res[0:l[0]-1,*,*,*,*,*,*] = res[replicate(l[0],l[0]),*,*,*,*,*,*]
		if s[0] gt 0 then $
		res[h[0]+1:*,*,*,*,*,*,*] = res[replicate(h[0],s[0]),*,*,*,*,*,*]

		if l[1] gt 0 then $
		res[*,0:l[1]-1,*,*,*,*,*] = res[*,replicate(l[1],l[1]),*,*,*,*,*]
		if s[1] gt 0 then $
		res[*,h[1]+1:*,*,*,*,*,*] = res[*,replicate(h[1],s[1]),*,*,*,*,*]

		if l[2] gt 0 then $
		res[*,*,0:l[2]-1,*,*,*,*] = res[*,*,replicate(l[2],l[2]),*,*,*,*]
		if s[2] gt 0 then $
		res[*,*,h[2]+1:*,*,*,*,*] = res[*,*,replicate(h[2],s[2]),*,*,*,*]

		if l[3] gt 0 then $
		res[*,*,*,0:l[3]-1,*,*,*] = res[*,*,*,replicate(l[3],l[3]),*,*,*]
		if s[3] gt 0 then $
		res[*,*,*,h[3]+1:*,*,*,*] = res[*,*,*,replicate(h[3],s[3]),*,*,*]

		if l[4] gt 0 then $
		res[*,*,*,*,0:l[4]-1,*,*] = res[*,*,*,*,replicate(l[4],l[4]),*,*]
		if s[4] gt 0 then $
		res[*,*,*,*,h[4]+1:*,*,*] = res[*,*,*,*,replicate(h[4],s[4]),*,*]

		if l[5] gt 0 then $
		res[*,*,*,*,*,0:l[5]-1,*] = res[*,*,*,*,*,replicate(l[5],l[5]),*]
		if s[5] gt 0 then $
		res[*,*,*,*,*,h[5]+1:*,*] = res[*,*,*,*,*,replicate(h[5],s[5]),*]

		if l[6] gt 0 then $
		res[*,*,*,*,*,*,0:l[6]-1] = res[*,*,*,*,*,*,replicate(l[6],l[6])]
		if s[6] gt 0 then $
		res[*,*,*,*,*,*,h[6]+1:*] = res[*,*,*,*,*,*,replicate(h[6],s[6])]

	endif

	return, reform(res,sir[ndm-nds+1:ndm])
end
