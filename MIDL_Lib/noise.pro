Function Noise, dat, poisson = pois, seed = sed

;+
; NAME:
;		NOISE
; VERSION:
;		4.0
; PURPOSE:
;		Adds Gaussian or Poissonian noise to data.
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = NOISE( DAT [, keywords])
; INPUTS:
;	DAT
;		numerical, nonnegative.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/POISSON
;		Switch.  If set, Poisson noise is generated.  The default is gaussian.
;	SEED
;		Can be used to provide a randomization seed.  Optional but highly
;		recommended (with an uninitialized variable) when doing repeated calls
;		to NOISE.  See RESTRICTIONS below.
; OUTPUTS:
;		Returns the input data with noise added to it.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		NOISE relies on the IDL routines RANDOMU and RANDOMN which, in the
;		absence of externally provided seed generate one using the system
;		time.  When consecutive calls to NOISE are made on a fast machine,
;		they may occur within a single "clock tick" yielding the same random
;		series.  This is highly undesirable.  The problem can be avoided if
;		NOISE is always called with SEED = S when S is an uninitialized
;		variable.
; PROCEDURE:
;		Generates Gauss-distributed (with sigma = square_root(dat)) random
;		numbers for gaussian noise.  Uses the rejection method for Poisson
;		noise.  Calls CAST, DEFAULT and FPU_FIX from MIDL.
; MODIFICATION HISTORY:
;		Created 25-JAN-1997 by Mati Meron.
;		Modified 10-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	neld = n_elements(dat)
	if neld eq 0 then message, 'No data!'
	mult = Default(mult,1.,/dtype)
	wdat = Cast(dat,3,3) > 0

	if keyword_set(pois) then begin
		slim = long(2d^31 - 2)
		sdat = sqrt(2*wdat)
		res = -wdat
		a = where(res lt 0, ndo)

		while ndo gt 0 do begin
			kres = wdat[a] + sdat[a]*tan(!pi*(randomu(sed,ndo) - 0.5))
			kres = floor(-slim > kres < slim)
			b = where (kres ge 0, ndo)
			if ndo gt 0 then begin
				ab = a[b]
				u = wdat[ab]
				su = sdat[ab]
				v = kres[b] + 0.5
				rat = exp(v*(1 + alog(u/(v - 1./(24*v)))) - u)* $
					su/atan(su, (v - u)^2 + 2*u - 0.25)/(2*u + 1./6)
				c = where(rat ge randomu(sed,ndo), ndo)
				if ndo gt 0 then res[ab[c]] = kres[b[c]]
			endif
			a = where(res lt 0, ndo)
		endwhile
	endif else res = wdat + round(sqrt(dat)*randomn(sed,neld))

	return, FPU_fix(res)
end
