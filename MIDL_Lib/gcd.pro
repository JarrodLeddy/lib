Function GCD, fir, sec, nozero = noz

;+
; NAME:
;		GCD
; VERSION:
;		4.5
; PURPOSE:
;		Calculates greatest common divisors.
; CATEGORY:
;		Mathematical, general.
; CALLING SEQUENCE:
;		Result = GCD( FIR, SEC [, NOZERO])
; INPUTS:
;	FIR
;		Numeric scalar or array of any of the integer types.
;	SEC
;		Numeric scalar or array (if so, it must be3 of same length as FIR) of
;		any of the integer types.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/NOZERO
;		Switch.  If set, zero values are not allowed.
; OUTPUTS:
;		Returns the greater common divisor(s) of FIR and SEC.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None other than those on data types, as listed above.
; PROCEDURE:
;		Straightforward application of Euclid's algorithm.  Calls ISNUM and
;		CALCTYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 25-AUG-2003 by Mati Meron.
;-

	on_error, 1

	if Isnum(fir,/int) and Isnum(sec,/int) then begin
		wfir = abs(fir)
		wsec = abs(sec)
		if keyword_set(noz) then if min(wfir) eq 0 or min(wsec) eq 0 $
		then message, '/NOZERO is set, zeros not allowed!'
		nf = n_elements(fir)
		ns = n_elements(sec)
		case (nf eq ns) + 2*(nf eq 1) + 4*(ns eq 1) of
			0	:	message, 'Impossible combination!'
			1	:
			2	:	wfir = replicate(wfir,ns)
			4	:	wsec = replicate(wsec,nf)
			7	:
		endcase

		n = nf > ns
		wind = lindgen(n)
		res = make_array(n,typ=Calctype(fir,sec))
		zer = where(wsec eq 0, nzer, comp = czer, ncomp = nczer)
		if nzer gt 0 then begin
			res[zer] = wfir[zer]
			if nczer gt 0 then wind = wind[czer]
		endif
		while nczer gt 0 do begin
			tem = wfir[wind] mod wsec[wind]
			zer = where(tem eq 0, nzer, comp = czer, ncomp = nczer)
			if nzer gt 0 then res[wind[zer]] = wsec[wind[zer]]
			if nczer gt 0 then begin
				wfir[wind] = wsec[wind]
				wsec[wind] = tem
				wind = wind[czer]
			endif
		endwhile
	endif else message, 'Inputs must be of one of the integer types!'
	if (size(fir))[0] eq 0 and (size(sec))[0] eq 0 then res = res[0]

	return, res
end