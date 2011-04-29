Function Errorf_mm, x, complementary = comp

;+
; NAME:
;		ERRORF_MM
; VERSION:
;		4.0
; PURPOSE:
;		Calculates the error function.  Replacement for the IDL ERRORF function
;		which accepts only real input.
; CATEGORY:
;		Mathematical function (general).
; CALLING SEQUENCE:
;		Result = ERRORF_MM (X [, /COMPLEMENTARY)]
; INPUTS:
;	X
;		Numeric, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/COMPLEMENTARY
;		Switch.  If set, 1 - ERRORF(X) is returned.
; OUTPUTS:
;		Returns the error function of X or, if /COMPLEMENTARY is set,
;		1 - error_function.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		For very large (in absolute value) complex values of x, with
;			pi/4 < |abs(phase(x))| < 3*pi/4
;		the results may be meaningless.  A warning will be issued in this case.
; PROCEDURE:
;		Uses CAST IGAMMA_MM and IMAGINARY_MM from MIDL.
; MODIFICATION HISTORY:
;		Created 20-MAR-1996 by Mati Meron as M_ERRORF.
;		Renamed 25-SEP-1999 by Mati Meron, to ERRORF_MM.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	sn = long(0*x + 1)
	dum = where(Real_mm(x) lt 0, ndum)
	if ndum gt 0 then sn[dum] = -1l
	wx = Cast(x,4)

	return, sn*Igamma_mm(wx^2, 0.5d, comp = comp) + keyword_set(comp)*(1 - sn)
end
