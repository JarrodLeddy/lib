Function Prep_FT, num, time = rtim

;+
; NAME:
;		PREP_FT
; VERSION:
;		4.3
; PURPOSE:
;		Finds an "element number" minimizing calculation time of an FFT.
; CATEGORY:
;		Mathematical utility.
; CALLING SEQUENCE:
;		Result = PREP_FT (NUM)
; INPUTS:
;	NUM
;		Positive scalar of any of the integer types.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	TIME
;		Optional output, see below.
; OUTPUTS:
;		Returns a long integer >= NUM such that using it instead of NUM as the
;		number of elements of the array which is to be Fourier transformed will
;		minimize calculation time.
; OPTIONAL OUTPUT PARAMETERS:
;	TIME
;		Returns the approximate running time, in units of 2*T_2 (see the IDL
;		FFT routine for details).
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None other than the restrictions on NUM mentioned above.
; PROCEDURE:
;		Finds a product of powers of 2 and 3 (for even input) or 3 and 5 (for
;		odd input such that:
;			1)	The product is larger than or equal to NUM.
;			2)  The FFT calculation time for the product is smaller than for
;				any other product with property 1.
;		Calls ISNUM from MIDL.
; MODIFICATION HISTORY:
;		Created 5-JAN-2003 by Mati Meron.
;		Modified 20-SEP-2003 by Mati Meron.  Added keyword TIME.
;-

	on_error, 1

	if not Isnum(num,/integ) then message, 'Input must be an integer!'
	if num le 0 then message, 'Input must be positive!'

	lnum = alog(num)
	if num mod 2 then begin
		fac = [3l,5l]
		wei = [6.,10.]
	endif else begin
		fac = [2l,3l]
		wei = [1.,6.]
	endelse
	lfac = alog(fac)

	rat = ceil(lnum/lfac[1])
	sec = lindgen(rat+1)
	fir = ceil((lnum - lfac[1]*sec)/lfac[0])
	if fir[rat] lt 0 then begin
		fir = fir[0:rat-1]
		sec = sec[0:rat-1]
	endif

	pnum = fac[0]^fir*fac[1]^sec
	mer = pnum*[wei[0]*fir + wei[1]*sec]
	rtim = min(mer,imin)

	return, pnum[imin]
end