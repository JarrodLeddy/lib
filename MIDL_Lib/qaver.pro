Function Qaver, arr, naver, inverse = inv

;+
; NAME:
;		QAVER
; VERSION:
;		4.0
; PURPOSE:
;		Performs Q averaging which is the discrete equivalent of exponential
;		averaging
; CATEGORY:
;		Mathematical, array.
; CALLING SEQUENCE:
;		Result = QAVER(ARR [,NAVER [,/INVERSE]])
; INPUTS:
;	ARR
;		Numerical vector.
; OPTIONAL INPUT PARAMETERS:
;	NAVER
;		Equivalent averaging length.  Default velue is one (in which case the
;		output simply equals the input).
; KEYWORD PARAMETERS:
;	/INVERSE
;		Switch.  If set, the original vector is restored from the average.
; OUTPUTS:
;		Returns a vector of the same length and type as ARR, such that
;		RES[i] = (1 - Q)*Sum(ARR(i-j)*Q^j), where Q = 1 - 1/NAVER.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calls DEFAULT from MIDL.
; MODIFICATION HISTORY:
;		Created 25-JUN-2000 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	nar = n_elements(arr)
	nav = Default(naver,1.,lo=4) > 1.
	invfl = keyword_set(inv)

	res = arr
	if invfl then for i= 1l ,nar-1 do res[i]= (1-nav)*arr[i-1]+ nav*arr[i] $
	else for i = 1l, nar-1 do res[i]= res[i-1]+ (res[i]-res[i-1])/nav

	return, res
end
