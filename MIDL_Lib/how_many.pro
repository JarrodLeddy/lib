Function How_many, first = v_0, second = v_1, third = v_2, fourth = v_3, $
	fifth = v_4, sixth = v_5, seventh = v_6, eighth = v_7, $
	mask = msk, nozero = noz, low = lo, high = hi, which_ones = bcod

;+
; NAME:
;		HOW_MANY
; VERSION:
;		4.0
; PURPOSE:
;		Called with up to 8 keyword parameters, HOW_MANY checks how many and
;		which of the corresponding variables are defined and (optionally)
;		within given type limits.
; CATEGORY:
;		Programming.
; CALLING SEQUENCE:
;		Result = HOW_MANY ([FIRST ... ] [LOW =LO] [HIGH = HI] [/NOZERO] $
;			[WHICH_ONES = BCOD])
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	FIRST	|
;	SECOND	|
;	THIRD	|
;	FOURTH	|	Each of these keywords accept an arbitrary input,
;	FIFTH	|	including no input or undefined input.
;	SIXTH	|
;	SEVENTH	|
;	EIGHTH	|
;
;	MASK
;		An optional masks which can be used to force HOW_MANY to ignore some
;		of the inputs.  Provided as numerical array, any 0 value translates to
;		"ignore" (and any nonzero value to "accept").  Thus,
;		MASK = [3,5,0,1,1,-3,0,2] signals "ignore THIRD and SEVENTH".  Note
;		that if the length of the input to MASK is shorter than 8 (the allowed
;		number of tested inputs, the reminder is assumed to be filled with 0s.
;	/NOZERO
;		Switch.  If set, specifies that only non zero (or non null string)
;		values are to be recognized as existing.
;	LOW
;		Optional numeric input, specifying the lowest limit of type code that
;		is recognized.  For example, if LOW is set to 3, variables of type BYTE
;		and INTEGER will not be recognized as defined.  Default value is 1,
;		i.e. everything is recognized.
;	HIGH
;		Same as LOW for the upper limit.  Default value is 12, i.e. everything
;		is recognized.
;	WHICH_ONES
;		Optional output, see below.
; OUTPUTS:
;		Returns the number of defined keyword variables, regardless of their
;		types and values.
; OPTIONAL OUTPUT PARAMETERS:
;	WHICH_ONES
;		The name of a variable to receive a a binary representation of the
;		defined variables, as a long integer.  For example, if the variables
;		corresponding to FIRST, FIFTH and SIXTH are defined, the result is
;			2^0 + 2^4 + 2^5 = 49.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		Currently HOW_MANY is restricted to a maximum of 8 variables.  If
;		needed, the number can be increased.
; PROCEDURE:
;		Straightforward.  Calls DEFAULT, ISNUM and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 15-AUG-1994 by Mati Meron, as a more general version of ONE_OF.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;		Modified 10-DEC-2002, added keyword MASK.
;-

	on_error, 1
	nmax = 8
	vnams = ['v_0','v_1','v_2','v_3','v_4','v_5','v_6','v_7']
	nozf = keyword_set(noz)
	lo = Default(lo,1,/dtype) > 1
	hi = Default(hi,15,/dtype) < 15

	exlist = lonarr(nmax)
	for i = 0, nmax - 1 do begin
		idum = execute('typ = Type(' + vnams[i] + ')')
		ityp = typ ge lo and typ le hi
		if ityp and nozf then idum = execute('ityp=keyword_set('+vnams[i]+')')
		exlist[i] = ityp
	endfor
	if Isnum(msk) then exlist = exlist*(msk ne 0)
	bcod = long(total(exlist*2l^lindgen(nmax)))

	return, long(total(exlist))
end
