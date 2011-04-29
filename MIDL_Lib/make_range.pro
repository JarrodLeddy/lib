Function Make_range, ran, default = def, nozero = noz, neran = ner

;+
; NAME:
;		MAKE_RANGE
; VERSION:
;		4.2
; PURPOSE:
;		Generates a range for operations on 1D arrays.
; CATEGORY:
;		Programming utility.
; CALLING SEQUENCE:
;		Result = MAKE_RANGE( RAN [, DEFAULT = DEF])
; INPUTS:
;	RAN
;		Numeric scalar or vector, must be of one of the integer types.  May not
;		be given, but only if DEFAULT (see below) is provided.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	DEFAULT
;		A default value(s) to be used if RAN is not provided.
;	/NOZERO
;		Switch.  If set, a single element vector is treated as scalar, i.e. no
;		"zero extension" (see case 2 below).
;	NERAN
;		Optional output, see below.
; OUTPUTS:
;		Depending on the input.  The possibilities are:
;
;		1)	RAN is a scalar.  In this case the output is simply RAN.
;		2)	RAN is a 1-element vector.  In this case the output is
;			LINDGEN(RAN + 1) i.e. the vector [0, 1,... ,RAN].  However, if
;			/NOZERO is set, 1-element vector is treated as scalar (see (1)).
;		3)	RAN is a 2-element vector.  In this case the output is the vector
;			[min(RAN), min(RAN) + 1, ... , max(RAN)].
;		4)	RAN is a multielement vector.  In this case the output is RAN,
;			sorted into order and with repeated elements (if any) removed.
;
;		In all cases the output is converted to type LONG.
; OPTIONAL OUTPUT PARAMETERS:
;	NERAN
;		Returns the number of elements of the result (i.e. N_ELEMENTS(result)).
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		RAN must be of one of the integer types.
; PROCEDURE:
;		Straightforward.  Calls DEFAULT, ISNUM and SORPURGE from MIDL.
; MODIFICATION HISTORY:
;		Created 10-FEB-2002 by Mati Meron.
;		Modified 10-JUL-2002 by Mati Meron.  Added keyword NERAN.
;		Modified 30-OCT-2002 by Mati Meron.  Added keyword NOZERO.
;-

	on_error, 1

	ner = 0l
	if Isnum(def,/int) then wran = Default(ran,def) $
	else if Isnum(ran,/int) then wran = ran
	if Isnum(wran,/int) then begin
		case (size(wran))[0] of
			0	:	res = wran
			1	:	begin
						if n_elements(wran) eq 1 and not keyword_set(noz) $
						then res = [0,wran] else res = wran
						if n_elements(res) eq 2 then begin
							min = min(res,max=max)
							res = min + lindgen(max-min+1)
						endif
						res = res(Sorpurge(res))
					end
			else:   message, 'Input must be scalar or vector!'
		endcase
	endif else message, 'Input must be of one of the integer types!'
	ner = n_elements(res)

	return, long(res)
end