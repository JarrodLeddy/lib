Function Neighbors, ind, siz, count = cnt

;+
; NAME:
;		NEIGHBORS
; VERSION:
;		4.0
; PURPOSE:
;		Finding the nearest neighbors of an array element.
; CATEGORY:
;		Array function.
; CALLING SEQUENCE:
;		Result = NEIGHBORS( IND, SIZ [, COUNT])
; INPUTS:
;	IND
;		Index of an array element.  Provided either in contracted (1-dim) or
;		expanded version.  In the second case IND has to be a vector the length
;		of which equals the number of dimension of the array (given by SIZ(0)).
;	SIZ
;		Vector in the form of the standard output of the system function SIZE.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	COUNT
;		An optional output parameter.  See below.
; OUTPUTS:
;		Returns a vector containing the indices of the nearest neighbors of the
;		element corresponding to IND.  If no neighbors exist returns -1.
; OPTIONAL OUTPUT PARAMETERS:
;	COUNT
;		The name of the variable to receive the number of neighbors.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calls ARRLOC from MIDL.
; MODIFICATION HISTORY:
;		Created 30-MARCH-1994 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	res = [-1l]
	ndim = siz[0]

	if ndim gt 0 then begin
		nel = n_elements(ind)
		if not (nel eq 1 or nel eq ndim) then message, 'Dimensional mismatch!'
		if nel eq 1 then begin
			cind =ind
			eind = Arrloc(ind,siz,/expand)
		endif else begin
			cind = Arrloc(ind,siz,/contract)
			eind = ind
		endelse
		if min([cind,eind]) ge 0 then begin
			nmult = replicate(1l,ndim)
			for i = 1, ndim - 1 do nmult[i] = nmult[i-1]*siz[i]
			for j = 0, ndim - 1 do begin
				if eind[j] gt 0 then res = [res,cind - nmult[j]]
				if eind[j] lt siz[j+1] - 1 then res = [res,cind + nmult[j]]
			endfor
			if n_elements(res) gt 1 then res = res[1:*]
		endif
	endif
	dum = where(res ge 0,cnt)

	return, res
end
