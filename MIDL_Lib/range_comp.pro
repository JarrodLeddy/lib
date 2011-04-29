Function Range_comp, inarr, no_sort = nos

;+
; NAME:
;		RANGE_COMP
; VERSION:
;		5.5
; PURPOSE:
;		Index range compression.
; CATEGORY:
;		Utility
; CALLING SEQUENCE:
;		Result = RANGE_COMP( INARR [,NO_SORT])
; INPUTS:
;	INARR
;		Numeric (of an integer type), scalar or array.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/NO_SORT
;		Switch.  In normal operation the input array is sorted and purged of
;		duplicate elements prior to processing.  Setting NO_SORT bypasses the
;		sorting.
; OUTPUTS:
;		Returns a character, scalar, consisting of the unique values in INARR,
;		converted into character values and separated by commas.  All instances
;		of consecutive values are replaced by "first_value - last_value".  Thus,
;		if INARR = [1,2,3,5,8,9,10,11,14,15], then the result will be
;		'1-3,5,8-11,14-15'.
;
;		Note: RANGE_COMP is effectively an inverse of the function RANGE_PROC.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calls itself recursively.  Calls DIF, ISNUM and
;		SORPURGE from MIDL.
; MODIFICATION HISTORY:
;		Created 30-JUN-2006 by Mati Meron.
;-

	on_error, 1

	if Isnum(inarr,/int) then begin
		if keyword_set(nos) then begin
			winarr= inarr
			len = n_elements(inarr)
		endif else winarr= inarr[Sorpurge(inarr,net=len)]
		dinarr = Dif(winarr,/lin)
		dum = where(dinarr ne 1, ndum)
		if ndum gt 0 then begin
			if dum[0] eq 0 then begin
				if len eq 1 then res = string(winarr[0]) else res = $
				[string(winarr[0]),Range_comp(winarr[1:*],/no_sort)]
			endif else begin
				tres = strjoin(string(winarr[[0,dum[0]-1]]),'-')
				res = [tres,Range_comp(winarr[dum[0]:*],/no_sort)]
			endelse
		endif else begin
			if len eq 1 then res = string(winarr[0]) $
			else res = strjoin(string(winarr[[0,len-1]]),'-')
		endelse
		res = strcompress(strjoin(res,','),/rem)
	endif else message, 'Input must be of one of the integer types!'

	return, res
end