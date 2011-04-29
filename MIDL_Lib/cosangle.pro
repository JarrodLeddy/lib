Function Cosangle, u, v

;+
; NAME:
;		COSANGLE
; VERSION:
;		4.0
; PURPOSE:
;		Finds the Cosine of the angle between two vectors.
; CATEGORY:
;		Geometry, General.
; CALLING SEQUENCE:
;		Result = COSANGLE ( U, V)
; INPUTS:
;	U, V
;		Vectors, numeric, same length, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the Cosine of the angle between the two vectors.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		Vectors must be non-zero.
; PROCEDURE:
;		Uses the functions FPU_FIX, VINP and VNORM from MIDL.
; MODIFICATION HISTORY:
;		Created 30-JUNE-1992 by Mati Meron.
;		Added to MIDL 10-NOV-1997 by Mati Meron.
;		Modified 10-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1

	return, FPU_fix(Vinp(u,v)/(Vnorm(u)*Vnorm(v)))
end
