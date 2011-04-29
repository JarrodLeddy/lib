Function Nowhere, arr, wout, count

;+
; NAME:
;		NOWHERE
; VERSION:
;		4.0
; PURPOSE:
;		Complement to the IDL WHERE function
; CATEGORY:
;		Utility.
; CALLING SEQUENCE:
;		Result = NOWHERE( ARR, WOUT [, COUNT])
; INPUTS:
;	ARR
;		Array, arbitrary.
;	WOUT
;		The output of WHERE, called with ARR and some condition.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the complement set of WOUT, i.e. if
;			WOUT = WHERE(ARR, Condition)
;		then
;			NOWHERE(ARR, WOUT) = WHERE(ARR, Not Condition)
;		If the complement is an empty set then, like WHERE, NOWHERE returns -1.
; OPTIONAL OUTPUT PARAMETERS:
;	COUNT
;		Same as COUNT in WHERE, the neame of a variable to receive the count of
;		indices returned by NOWHERE.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward application of WHERE.  Calls ARREQ from MIDL.
; MODIFICATION HISTORY:
;		Created 20-FEB-2000 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1

	count = n_elements(arr)
	if count eq 0 or n_elements(wout) eq 0 then message, $
	'Both Array and WHERE output need to be provided!'
	res = lindgen(count)

	if not Arreq(wout,-1l) then begin
		res[wout] = -1l
		tem = where(res ge 0, count)
		if count eq 0 then res = tem else res = res[tem]
	endif

	return, res
end
