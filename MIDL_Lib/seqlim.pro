Function Seqlim, svl, rvl, zero_pad = zpd, error = erv, status = stat

;+
; NAME:
;		SEQLIM
; VERSION:
;		4.0
; PURPOSE:
;		Estimates limits of infinite sequences.
; CATEGORY:
;		Mathematical Function (General).
; CALLING SEQUENCE:
;		Result = SEQLIM( SVL [, RVL ] [, keywords])
; INPUTS:
;	SVL
;		Numeric vector containing consecutive terms of the sequence.  At least
;		two terms are needed.
; OPTIONAL INPUT PARAMETERS:
;	RVL
;		Numeric vector, same length as SVL.  Contains estimates of the
;		deviations of the terms of SVL from the limit.  Usually RVL is
;		generated internally, since if good estimates of the deviations from
;		the limit do exist, SEQLIM is not needed.
; KEYWORD PARAMETERS:
;	/ZERO_PAD
;		Switch.  Used only when RVL is not provided, specifies how a difference
;		series is generated from the terms of SVL.  When ZERO_PAD is set, it
;		implies a zero term preceding the first term of SVL, i.e. SVL has the
;		form of [0, SVL(0), SVL(1),...], giving rise to a difference series of
;		the form [SVL(0), SVL(1) - SVL(0), ...].  If ZERO_PAD is not set, the
;		difference series is [SVL(1) - SVL(0), ...].  Therefore, at least four
;		sequence values are needed in the absence of ZERO_PAD but only 3 when
;		ZERO_PAD is set.
;	ERROR
;		Optional output, see below.
;	STATUS
;		Ditto.
; OUTPUTS:
;		Returns the limit estimate if one is found, otherwise returns machine
;		maximum.
; OPTIONAL OUTPUT PARAMETERS:
;	ERROR
;		The name of the variable to receive the estimated error of the returned
;		limit value.  If the sequence doesn't seem to converge, returns machine
;		maximum.
;	STATUS
;		The name of the variable to receive convergence status information.
;		Returns 1 if the sequence converges, 0 otherwise.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses Neville's interpolation algorithm.  Calls CAST, ISNUM and
;		SERIES_SUM from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JUN-1992 by Mati Meron.
;		Completely rewritten 30-SEP-1998 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	sinf = machar(double=Isnum(svl,/double,typ=styp))
	if styp eq 6 then wtyp = 9 else wtyp = 5
	erv = sinf.xmax
	lim = erv
	stat = 0

	kl = n_elements(svl) - 1
	rl = n_elements(rvl) - 1

	if rl ge 0 then begin
		if rl eq kl then begin
			ws = Cast(svl,wtyp)
			wr = Cast(rvl,wtyp)
			if kl ge 1 then begin
				kf = (where([1,abs(wr[1:rl])- abs(wr[0:rl-1])] ge 0,nd))[nd-1]
				if kf lt kl then begin
					q = ws
					lim = q[kl]
					l = kl
					while l gt kf do begin
						l = l - 1
						for k = l+1, kl do q[k] = $
							(wr[l]*q[k] - wr[k]*q[k-1])/(wr[l] - wr[k])
						nerv = abs(q[kl] - lim)
						if nerv le erv then begin
							lim = q[kl]
							erv = nerv
						endif else kf = kl
					endwhile
					stat = 1
				endif
			endif else begin
				lim = ws[0]
				stat = 3
			endelse
		endif else message, 'incompatible data lengths'
	endif else begin
		zpfl = keyword_set(zpd)
		if kl ge (3 - zpfl) then begin
			if zpfl then lim = Series_sum(svl-[0,svl], err= terv, stat= stat) $
			else lim = svl[0] + Series_sum(svl[1:*]-svl, err= terv, stat= stat)
			erv = erv < terv
		endif else begin
			if kl ge 1 and max(svl, min = mis) eq mis then begin
				lim = svl[0]
				stat = 3
			endif else message, 'insufficient data!', /continue
		endelse
	endelse

	erv = Cast(erv,4,styp,/fix)
	return, Cast(lim,4,styp,/fix)
end
