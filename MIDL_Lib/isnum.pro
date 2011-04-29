Function Isnum, x,  type = typ, strict = stri, $
	unsigned = unsg, integer = intg, double = doub, complex = comp

;+
; NAME:
;		ISNUM
; VERSION:
;		4.0
; PURPOSE:
;		Checks whether the input is a number.
; CATEGORY:
;		Programming.
; CALLING SEQUENCE:
;		Result = ISNUM(X)
; INPUTS:
;	X
;		Arbitrary, doesn't even have to exist.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	TYPE
;		Optional output.  See below.
;	/STRICT
;		Switch.  If set, unsigned integers are *NOT* considered numbers.
;	/UNSIGNED
;		Switch.  If set the result is 1 only if X is of any unsigned integer
;		type.
;	/INTEGER
;		Switch.  If set the result is 1 only if X is of any integer type,
;		whether signed or unsigned.
;	/DOUBLE
;		Switch.  If set the result is 1 only if X is DOUBLE or DCOMPLEX.
;	/COMPLEX
;		Switch.  If set the result is 1 only if X is COMPLEX or DCOMPLEX.
; OUTPUTS:
;		Returns 1 if X is number (optionally, satisfying the constraints set
;		by the keywords), 0 otherwise.  Output type is byte.
; OPTIONAL OUTPUT PARAMETERS:
;	TYPE
;		The name of the variable to receive the numeric code of the type of X.
;		Included for convenience to save an additional call to TYPE.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Using TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUN-1995 by Mati Meron.
;		Modified 5-MAY-1996 by Mati Meron.  Added keywords DOUBLE, COMPLEX and
;		TYPE.
;		Modified 25-DEC-2000 by Mati Meron.  Added keyword INTEGER.
;		Modified 30-JAN-2001 by Mati Meron.  Added recognition of new numeric
;		types and the keywords UNSIGNED and STRICT.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1

	anumtyps = [1l,2,3,4,5,6,9,12,13,14,15]
	snumtyps = [1l,2,3,4,5,6,9,14]
	unsgtyps = [12l,13,15]
	intgtyps = [1l,2,3,12,13,14,15]
	doubtyps = [5l,9]
	comptyps = [6l,9]

	typ = Type(x)
	if keyword_set(stri) then res = (where(snumtyps eq typ))[0] ge 0 $
	else res = (where(anumtyps eq typ))[0] ge 0

	if keyword_set(unsg) then res = res and (where(unsgtyps eq typ))[0] ge 0
	if keyword_set(intg) then res = res and (where(intgtyps eq typ))[0] ge 0
	if keyword_set(doub) then res = res and (where(doubtyps eq typ))[0] ge 0
	if keyword_set(comp) then res = res and (where(comptyps eq typ))[0] ge 0

	return, res
end
