Function Calctype, v_0, v_1, v_2, v_3, v_4, v_5, v_6, v_7, types = typ, $
	maxtyp = max, mintyp = min, default = def, exact = exa, strict = str,$
	quiet = qui

;+
; NAME:
;		CALCTYPE
; VERSION:
;		4.0
; PURPOSE:
;		Identifies maximal (and, optionally) minimal data type for calculation.
; CATEGORY:
;		Programming.
; CALLING SEQUENCE:
;		Result = CALCTYPE( V_0 [,V_1, ... V_7] [, VALUE = VAL])
; INPUTS:
;	V_0 through V_7
;		Numeric, otherwise arbitrary, at least one should be given.  If the
;		keyword /STRICT is set, unsigned integers of all lengths are not
;		considered numerical.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/TYPES
;		Switch.  If set, the V_i parameters are taken to represent data types
;		of inputs rather then the inputs themselves.
;	/MAXTYP
;		Switch.  If set, the numerically *highest* of the data types is
;		returned.  This is the default, so there is really no need to set
;		/MAXTYP, it is just provided for completeness.
;	/MINTYP
;		Switch.  If set, the numerically *lowest* of the data types is
;		returned.
;	DEFAULT
;		Accepts an integer value to be used as default type for those input
;		variables which happen to be undefined.  If not given, undefined
;		inputs result in error.
;	/EXACT
;		Switch.  Disables the resetting of lower value to 4 and higher to 9
;		when the inputs types are 5,6.  Has no impact in other cases.
;	/STRICT
;		Switch.  If set, unsigned integers are *NOT* considered numbers.
;	/QUIET
;		Switch.  Determines error handling.  See OUTPUTS below.
; OUTPUTS:
;		If the data types of all inputs (or the inputs themself, when /TYPES
;		is set) correspond to valid numeric types (excluding unsigned integers
;		if /STRICT is set), CALCTYPE returns the numerically highest (or, if
;		/MINTYP is set, numerically lowest) of the types present.  Note that
;		the numeric order of the types is (excluding unsigned types):
;
;				1, 2, 3, 14, 4, (5-6), 9
;
;		As neither of (5,6) is equivalent or higher to the other, in case the
;		inputs are of types 5 and 6, the return value is 9 (for higher) or 4
;		(for lower) unless /EXACT is set.
;
;		The types of unsigned integers (when accepted) are converted to these
;		of signed ones of same length.
;
;		The types of undefined inputs are converted to DEFAULT if given, else
;		are left at 0 (which is *not* a valid numeric type).
;
;		If some of the data types do not correspond to valid numeric types,
;		the outcome depends on the /QUIET switch.  If /QUIET is set, the
;		routine returns 0, else it stops with an error message.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		All the V_i present have to be valid numeric inputs (or numeric data
;		types) else an error results (unless /QUIET is set).
; PROCEDURE:
;		Straightforward.  Using ISNUM and ONE_OF from MIDL.
; MODIFICATION HISTORY:
;		Created 15-FEB-2001 by Mati Meron.
;-

	on_error, 1
	vnams = ['v_0','v_1','v_2','v_3','v_4','v_5','v_6','v_7']
	anumtyps = [1l,2,3,4,5,6,9,12,13,14,15]
	equityps = [1l,2,3,4,5,6,9, 2, 3,14,14]
	snumtyps = [1l,2,3,4,5,6,9,14]
	ordrtyps = [1l,2,3,14,4,5,6,9]

	n = n_params()
	if n gt 0 then tlis = lonarr(n) else message, 'Missing input!'
	if One_of(min,max) eq 0 then what = 0 else what = n-1

	if keyword_set(str) then begin
		testtyps = snumtyps
		corrtyps = snumtyps
	endif else begin
		testtyps = anumtyps
		corrtyps = equityps
	endelse

	if keyword_set(typ) then pfix = 'tlis[i]=(' else pfix ='tlis[i]=Type('
	for i = 0, n-1 do dum = execute(pfix + vnams[i] + ')')
	val = where(tlis eq 0, nval)
	if nval gt 0 and Isnum(def,/int) then tlis(val) = def
	for i = 0, n-1 do tlis[i] = (where(testtyps eq tlis[i]))[0]
	val = where(tlis ge 0, nval)

	if nval eq n then begin
		tlis = corrtyps[tlis]
		for i = 0, n-1 do tlis[i] = (where(ordrtyps eq tlis[i]))[0]
		tlis = tlis[sort(tlis)]
		tlis = ordrtyps[tlis]
		if not keyword_set(exa) then begin
			if tlis[0] eq 5 and (where(tlis eq 6))[0] ge 0 then tlis[0] = 4
			if tlis[n-1] eq 6 and (where(tlis eq 5))[0] ge 0 then tlis[n-1] = 9
		endif
	endif else $
	if keyword_set(qui) then tlis=lonarr(n) else message, 'Unacceptable input!'

	return, long(tlis[what])
end