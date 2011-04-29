Function Gamma_mm, x

;+
; NAME:
;		GAMMA_MM
; VERSION:
;		4.0
; PURPOSE:
;		Calculates the gamma function.  Replacement for the IDL GAMMA function
;		which accepts only real input.
; CATEGORY:
;		Mathematical, general.
; CALLING SEQUENCE:
;		Result = GAMMA_MM (X)
; INPUTS:
;	X
;		Numeric, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the gamma function of X.  Output type is same as input (but no
;		lower than FLOAT), form is same as input.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The real part of X should be greater than 0.
; PROCEDURE:
;		Calls LNGAMMA_MM
; MODIFICATION HISTORY:
;		Created 30-MAR-1996 by Mati Meron as M_GAMMA.
;		Renamed 25-SEP-1999 by Mati Meron, to GAMMA_MM.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	return, exp(Lngamma_mm(x))
end
