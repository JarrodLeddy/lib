Function Prinums, nlo, nhi, bypass = byp

;+
; NAME:
;		PRINUMS
; VERSION:
;		4.0
; PURPOSE:
;		Calculates a table of prime numbers in the range NLO - NHI.
; CATEGORY:
;		Mathematical function (general).
; CALLING SEQUENCE:
;		List = PRINUMS( [NLO,] NHI)
; INPUTS:
;	NHI
;		Upper limit of the range of the primes table.  Converted to long
;		integer on input.
; OPTIONAL INPUT PARAMETERS:
;	NLO
;		Lower limit of the prime table range.  Converted to long integer on
;		input.If not provided, i.e. if only one input parameter is provided,
;		NLO defaults to 1.
; KEYWORD PARAMETERS:
;	/BYPASS
;		Switch.  Used only on internal calls.
; OUTPUTS:
;		Returns the list of primes between NLO and NHI (inclusive), as long
;		integer.  If no primes are found, returns 0.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		Inputs must be positive.  If both NLO and NHI are given, NHI >= NLO.
; PROCEDURE:
;		Uses the Sieve of Erasthotenes algorithm.  Generates the primes table
;		calling itself recursively.
; MODIFICATION HISTORY:
;		Created 15-NOV-1991 by Mati Meron.
;		Modified 15-DEC-1993 by Mati Meron.  Combined previous PRIMES and
;		PR_SIEVE in a single routine.
;		Modified 20-JUN-1995 by Mati Meron.  Renamed PRINUMS to avoid conflict
;		with an IDL routine bearing the same name.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1

	khi = long(nlo)
	if not keyword_set(byp) then begin
		if n_params() eq 2 then begin
			khi = long(nhi)
			klo = ceil(nlo)
		endif else klo = 1l
		if klo lt 1 then message, 'Lower limit must be positive'
		if khi lt klo then message, 'Upper limit must be >= than lower limit!'
		pmax = 2 > long(sqrt(khi))
		if pmax ge klo then pmax = khi
	endif else pmax = khi

	case pmax of
		1	:	ptab = [0l]
		2	:	ptab = [2l]
		3	:	ptab = [2l,3l]
		else:	begin
					ptab = Prinums(sqrt(pmax), /bypass)
					tem = lindgen(pmax + 1)
					for i = 0l, n_elements(ptab) - 1 do $
						tem(ptab[i]*(1l + lindgen(pmax/ptab[i]))) = 0
					dum = where(tem gt 1, pcount)
				if pcount gt 0 then ptab = [ptab, tem[dum]]
				end
	endcase

	if pmax lt khi then begin
		tem = klo + lindgen(khi - klo + 1)
		for i = 0l, n_elements(ptab) - 1 do begin
			p = ptab[i]
			pnum = khi/p - (klo - 1)/p
			poff = (klo + p - 1)/p*p - klo
			if pnum gt 0 then tem(p*lindgen(pnum) + poff) = 0
		endfor
		ptab = ([0l,tem])(where(tem ge klo > 2, pcount) + 1)
	endif

	return, ptab
end
