Function Shuffle, arr, seed = sed

;+
; NAME:
;		SHUFFLE
; VERSION:
;		4.0
; PURPOSE:
;		Randomizes an array.
; CATEGORY:
;		Array function.
; CALLING SEQUENCE:
;		Result = SHUFFLE( ARR [, SEED = SEED])
; INPUTS:
;	ARR
;		Array, arbitrary type.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	SEED
;		Randomization seed, optional.
; OUTPUTS:
;		Returns an array with the same values as the original one but in random
;		order.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Uses the system routine RANDOMU.
; MODIFICATION HISTORY:
;		Created 1-MAY-1995 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	if n_elements(sed) ne 0 then wsed = sed

	return, arr(sort(randomu(wsed,n_elements(arr))))
end
