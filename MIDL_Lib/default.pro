Function Default, x, y, strict = strit, dtype = deft, low = lot, high = hit

;+
; NAME:
;		DEFAULT
; VERSION:
;		4.0
; PURPOSE:
;		Provides an automatic default value for nondefined parameters.
; CATEGORY:
;		Programming.
; CALLING SEQUENCE:
;		Result = DEFAULT( X, Y [, keywords])
; INPUTS:
;	X, Y
;		Arbitrary, at least one needs to be defined.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/STRICT
;		Switch.  If set, X is considered defined only if it is of the same type
;		as Y.
;	/DTYPE
;		Switch.  If set, the result will be typecast into the type of Y.
;		Explicit settings for LOW and/or HIGH (see below) override DTYPE.
;	LOW
;		Numeric value representing a valid numeric type. If given, the result
;		is of type >= LOW.
;	HIGH
;		Numeric value representing a valid numeric type. If given, the result
;		is of type <= HIGH.
; OUTPUTS:
;		X if it is defined, otherwise Y.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		All type casting is bypassed if the result is not of numeric type.
; PROCEDURE:
;		Uses the functions CAST, ISNUM and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Modified 15-NOV-1993 by Mati Meron.  The keyword TYPE has been replaced
;		by STRICT.  Added keywords DTYPE, LOW and HIGH.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	xtyp = Type(x)
	ytyp = Type(y)

	if not (xtyp eq 0 or keyword_set(strit)) then atyp = xtyp else $
	if ytyp ne 0 then atyp = ytyp else message,'Insufficient data!'

	if xtyp eq atyp then res = x else res = y

	if keyword_set(deft) then begin
		if n_elements(lot) eq 0 then lot = ytyp
		if n_elements(hit) eq 0 then hit = ytyp
	end

	if Isnum(res) then return, Cast(res,lot,hit) else return, res
end
