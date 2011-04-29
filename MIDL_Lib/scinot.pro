Function Scinot, axis, index, value, level, digits = dig

;+
; NAME:
;		SCINOT
; VERSION:
;		5.2
; PURPOSE:
;		Formating function for plot labels.
; CATEGORY:
;		Utility.
; CALLING SEQUENCE:
;		Result = SCINOT( AXIS, INDEX, VALUE, LEVEL [DIGITS = DIG])
; INPUTS:
;	AXIS, INDEX, VALUE, LEVEL
;		See IDL keywords [XYZ]TICKFORMAT for description.  Only VALUE is
;		actually used by SCINOT.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	DIGITS
;		Specifies the number of significant digits in the produced labels.
;		Default value is 2.
; OUTPUTS:
;		Returns a string representing VALUE in scientific notation, in the
;		format (default) of d.dx10^d[d].
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calls DEFAULT from MIDL
; MODIFICATION HISTORY:
;		Created 15-FEB-2006 by Mati Meron.
;-

	on_error, 1
	if value ne 0 then begin
		wdig = Default(dig,2,/dtyp) > 2
		form = strcompress('(f' + string(wdig+2) +'.'+ string(wdig-1) +')',/rem)
		ilog = floor(alog10(abs(value)))
		sval = 0.1^ilog*value
		res = string(sval, form= form) + 'x10!e' + string(ilog) + '!n'
	endif else res = '0'

	return, strcompress(res,/rem)
end
