Function Lexisort, v_0, v_1, v_2, v_3, v_4, v_5, v_6, v_7

;+
; NAME:
;		LEXISORT
; VERSION:
;		4.5
; PURPOSE:
;		"Lexicographic sort" on a set of vectors..
; CATEGORY:
;		Array Manipulation.
; CALLING SEQUENCE:
;		Result = LEXISORT (V_0 [, V_1, ...])
; INPUTS:
;	V_0 through V_7
;		Numeric vectors.  There are two possibilities:
;
;		1)	Anything between 1 to 8 inputs, all of which are vectors of the
;			same length.
;		2)	A *single* 2D array input.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None
; OUTPUTS:
;		Returns a vector of indices representing the "lexicographic order" of
;		the input.  The meaning of this is as follows:
;
;		For case 1, first V_0 is sorted.  If all the elements of V_0 are
;		different, the output is simply sort(V_0).  If some of the elements
;		are the same, they're further sorted according to the values of the
;		corresponding elements of V_1.  The process continues till the sort
;		is fully resolved or all the vectors have been used up.
;
;		For case two the process is the same, only the vectors are replaced
;		by the *rows* of the 2D array.
; OPTIONAL OUTPUT PARAMETERS:
;		None
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses consecutive SORT-reorder cycles.  Calls SORPURGE and TYPE from MIDL
; MODIFICATION HISTORY:
;		Created 20-NOV-2003 by Mati Meron.
;-

	on_error, 1
	vnams =  strcompress('v_' + sindgen(8),/remove)

	m = n_params()
	case m of
		0	:	message, 'No input!'
		1	:	begin
					dum = execute('arr = reform([' + vnams[0] + '])')
					siz = size(arr)
					if siz[0] eq 2 then begin
						m = siz[1]
						n = siz[2]
					endif else if siz[0] gt 2 then $
					message, 'More than 2 dimensions not allowed!'
				end
		else:	begin
					dum = execute('vec = reform([' + vnams[0] + '])')
					n = n_elements(vec)
					arr = make_array(m,n,typ=Type(vec))
					arr[0,*] = vec
					for i = 1, m-1 do begin
						dum = execute('vec = reform([' + vnams[i] + '])')
						if n_elements(vec) eq n then arr[i,*] = vec $
						else message, 'Length mismatch!'
					endfor
				end
	endcase

	if m gt 1 then begin
		i = 0
		res = (sor = sort(arr[0,*]))
		repeat begin
			for j = i, m-1 do arr[j,*] = arr[j,sor]
			sop = [Sorpurge(arr[i,*],/no_sort,net=nn),n]
			if nn eq n then break
			i = i + 1
			sor = lindgen(n)
			dsop = sop[1:nn] - sop[0:nn-1] - 1
			p = where(dsop gt 0,np)
			for k = 0, np-1 do begin
				lo = sop[p[k]]
				hi = lo + dsop[p[k]]
				ksor = sort(arr[i,lo:hi])
				sor[lo:hi] = (sor[lo:hi])[ksor]
			endfor
			res = res[sor]
		endrep until i eq m-1
	endif else res = sort(arr)

	return, res
end