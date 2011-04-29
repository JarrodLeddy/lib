Function Toler, x, type = typ, double = dob

;+
; NAME:
;		TOLER
; VERSION:
;		4.0
; PURPOSE:
;		Establishes numerical tolerance value for numerical procedures.
; CATEGORY:
;		Programming.
; CALLING SEQUENCE:
;		Result = TOLER(X [, keywords])
; INPUTS:
;	X
;		Numeric, otherwise arbitrary.  Ignored if one of the keywords TYPE or
;		DOUBLE (see below) is used.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	TYPE
;		Numeric type code.  If given overrides the type provided by X.
;	/DOUBLE
;		Switch.  Specifies double precision.  If given, overrides both TYPE and
;		the type provided by X.
; OUTPUTS:
;		Returns a value equal to the .EPS field of the structure created
;		by the IDL function MACHAR.  If the type code, as set by the type of X,
;		or directly by one of the keywords TYPE or DOUBLE is 5 (DOUBLE) or 9
;		(DOUBLECOMPLEX), MACHAR is called with the keyword /DOUBLE.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		X (when provided) must be numeric else an error occurs.  Similarly,
;		calling TOLER with TYPE = 8 or 9 will cause an error.
; PROCEDURE:
;		Straightforward.  Uses MACHAR.  Calls DEFAULT and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUN-1995 by Mati Meron.
;		Modified 10-SEP-1998 by Mati Meron.  Added keyword /DOUBLE.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	nonum = [7,8,10,11]
	if keyword_set(dob) then typ = 5 else typ = Default(typ,Type(x))
	if (where(nonum eq typ))[0] ge 0 then message, 'input must be numeric!'
	eps = Machar(double = typ eq 5 or typ eq 9)
	return, eps.eps
end
