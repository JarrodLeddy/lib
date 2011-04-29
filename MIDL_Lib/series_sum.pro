Function Series_sum, ser, error = erv, status = stat

;+
; NAME:
;		SERIES_SUM
; VERSION:
;		4.0
; PURPOSE:
;		Estimates sums of infinite series.
; CATEGORY:
;		Mathematical Function (General).
; CALLING SEQUENCE:
;		Result = SERIES_SUM( SVL [, keywords])
; INPUTS:
;	SER
;		Numeric vector containing consecutive terms of the series.  At least
;		three terms are needed to get a result, 4 or more terms to get both
;		result and error estimate.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	ERROR
;		Optional output, see below.
;	STATUS
;		Ditto.
; OUTPUTS:
;		Returns the sum estimate if one is found, otherwise returns machine
;		maximum.
; OPTIONAL OUTPUT PARAMETERS:
;	ERROR
;		The name of the variable to receive the estimated error of the returned
;		sum value.  If the series doesn't seem to converge, returns machine
;		maximum.
;	STATUS
;		The name of the variable to receive convergence status information.
;		Returns 1 if the series converges, 0 otherwise.  If the data is
;		insufficient for error estimate, returns 3.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses the routine SEQLIM from MIDL.  Also uses CAST, ISNUM and TOLER.
; MODIFICATION HISTORY:
;		Created 15-JUN-1992 by Mati Meron.
;		Completely rewritten 30-SEP-1998 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	sinf = machar(double=Isnum(ser,/double,typ=styp))
	erv = sinf.xmax
	lim = erv
	stat = 0

	if styp eq 6 then atyp = 9 else atyp = 5
	a = Cast(ser,atyp)

	if n_elements(a) ge 3 then begin
		dum = where(a ne 0, na)
		if na ge 3 then begin
			a = a[dum]
			s = a
			for i = 1l, na - 1 do s[i] = s[i-1] + s[i]
			nt = (where(abs(a) ge [0,abs(a)], ndum))[ndum-1]
			s = s[nt:*]
			a = a[nt:*]
			na = na - nt
			if na ge 3 then begin
				b = a - [0,a]
				c = b - [0,b]
				q = [0,0,(b^2-a*c)[2:*]/(b-c)[2:*]]
				zlev = abs(2*[0,0,a[2:*]]*Toler(ser)*(1-a/b))
				bq = [0,0,b[2:*]] + q
				nz = (where(abs([0,0,b[2:*]] + q) le zlev, ndum))[ndum-1] + 1
				if nz lt na then begin
					a = a[nz:*]
					b = b[nz:*]
					q = q[nz:*]
					svl = s[nz:*] - a*(a + q)/(b +q)
					na = na - nz
					if max(abs(q)) le Toler(ser) then begin
						lim = svl[na-1]
						erv = 0
						stat = 1
					endif else begin
						lim = Seqlim(svl,q,error=terv,status=stat)
						erv = erv < terv
					endelse
				endif else message, 'Series not converging!', /continue
			endif else message, 'Not enough decreasing terms', /continue
		endif else begin
			if na eq 0 then begin
				lim = 0
				erv = 0
				stat = 1
			endif else message, 'At least 3 non zero terms required!, /continue
		endelse
	endif else message, 'At least 3 terms required!', /continue

	erv = Cast(erv,styp,styp,/fix)
	return, Cast(lim,styp,styp,/fix)
end
