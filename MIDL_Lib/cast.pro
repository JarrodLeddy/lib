Function Cast, x, lo, hi, strict = str, round = rnd, fix = fix
;+
; NAME:
;		CAST
; VERSION:
;		4.0
; PURPOSE:
;		Generalized type casting.  Converts variables whose type code is out
;		of the range [LO,HI] into this range.
; CATEGORY:
;		Programming (type conversion).
; CALLING SEQUENCE:
;		Result = CAST( X, [LO [,HI]])
; INPUTS:
;	X
;		Numerical, arbitrary (see /STRICT for possible limitations).
;	LO
;		Number representing a type code, range (1:15).  If out of this range,
;		an error results.  If not given, it is set to 1.
; OPTIONAL INPUT PARAMETERS:
;	HI
;		Type code, same as LO.  Default value is 9 (note that, though higher
;		number codes exist, 9 corresponds to the "numerically highest" type).
;		If HI is provided and corresponds to a "numerically lower" type than
;		LO, it is set to LO.
; KEYWORD PARAMETERS:
;	/STRICT
;		Switch.  If set, unsigned values are not accepted as numbers.
;	/ROUND
;		Switch.  If set AND the casting is to any integer type, rounding is
;		performed prior to type casting.
;	/FIX
;		Switch.  If set, the output is filtered through FPU_FIX, eliminating
;		floating underflow errors.
; OUTPUTS:
;		If the type of X is < LO, CAST returns X converted to type LO.
;		If the type of X is > HI, CAST returns X converted to type HI.
;		Otherwise CAST returns X.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		And attempt to call CAST with non-numerical input or with type codes
;		not corresponding to known numerical codes, will yield an error.
; PROCEDURE:
;		Identifies the type of X, and if out of the range given by [LO,HI]
;		calls the proper conversion routine using the system routine
;		CALL_FUNCTION.  The "range" follows the numerical order of types, i.e.
;
;				1, 2, 3, 14, 4, (5-6), 9
;
;		Unsigned types (Uint, Ulong, Ulong64) are either ignored (if /STRICT
;		is set) or converted to the signed types of same length.
;
;		CAST uses CALCTYPE, FPU_FIX and ISNUM from MIDL.
; MODIFICATION HISTORY:
;		Created 25-DEC-1991 by Mati Meron.
;		Modified 15-JUN-1995 by Mati Meron to accept the new DOUBLECOMPLEX type.
;		Modified 25-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Modified 25-DEC-2000 by Mati Meron.  Added keyword ROUND.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;		Totally rewritten by Mati Meron, on 15-FEB-2001, to accomodate all new
;		numeric types.  Added keyword STRICT.  Eliminated type conversion for
;		CHARACTER type as it serves no useful purpose.
;-

	on_error, 1
	ran = [1l,9]
	intgtyps = [1l,2,3,12,13,14,15]
	conv = ['nada', 'byte', 'fix', 'long', 'float', 'double', 'complex', $
		'', '', 'dcomplex','','','uint','ulong','long64','ulong64']

	inum = Isnum(x, type = ityp, strict = str)
	if inum then begin
		if n_elements(lo) eq 0 then ilo = ran[0] $
		else ilo = Calctype(lo,ran[0],/types,/max,strict=str,/quiet)
		if n_elements(hi) eq 0 then ihi = ran[1] $
		else ihi = Calctype(hi,ran[1],/types,/min,strict=str,/quiet)
	endif else message, 'Non numeric input!'

	if ilo*ihi ne 0 then begin
		if ihi eq Calctype(ilo,ihi,/types,/min,/exact) then ihi = ilo
		if keyword_set(rnd) and (where(intgtyps eq ihi))[0] ge 0 and $
		(where(intgtyps eq ityp))[0] lt 0 then res = round(x) else res = x
		if ilo ne ihi then begin
			if Calctype(ilo,ityp,/types,/max,strict=str,/exact) ne ityp $
			then res = call_function(conv[ilo],res) else $
			if Calctype(ihi,ityp,/types,/min,strict=str,/exact) ne ityp $
			then res = call_function(conv[ihi],res)
		endif else if ityp ne ilo then res = call_function(conv[ilo],res)
	endif else message, 'unacceptable HI/LO codes'

	if keyword_set(fix) then return, FPU_fix(res) else return, res
end
