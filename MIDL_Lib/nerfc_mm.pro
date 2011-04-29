Function Nerfc_mm, x

;+
; NAME:
;		NERFC_MM
; VERSION:
;		4.0
; PURPOSE:
;		Calculates A renormalized complementary error function.
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = NERFC_MM( X )
; INPUTS:
;	X
;		Numeric, otherwise arbitrary.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None
; OUTPUTS:
;		Returns the values of exp(x^2)*(1 - errorf(x)).  For larger values of
;		X, above ~4, this values cannot be calculated directly from the error
;		function due to cancellation errors.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		For large and negative values of Real(x) an overflow may result.  A
;		warning is issued in such case.
; PROCEDURE:
;		Using direct calculation for small values of abs(x) and continued
;		fraction expansion for larger values.  Call ABS_MM, CAST, CONFRAC,
;		ERRORF_MM, ISNUM and REAL_MM, from MIDL.
; MODIFICATION HISTORY:
;		Created 20-DEC-1994 by Mati Meron, under the name RENERF_FUN.
;		Renamed M_NERFC and completely rewritten 15-JAN-1996, by Mati Meron,
;		in order to enhance range and accuracy.
;		Modified 25-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Renamed 25-SEP-1999 by Mati Meron, to NERFC_MM.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	len = 32

	sinf = machar(double = Isnum(x,/double))
	cbound = alog(2d)*(sinf.maxexp - 4)
	hbound = alog(2d)*(sinf.maxexp - 1)
	isc = Isnum(x,/complex,type=typ)
	if isc then z = Cast(x,9) else z = Cast(x,5)
	res = 0*z

	tm = where(Abs_mm(z) lt sqrt(cbound), ntm)
	if ntm ne 0 then res(tm) = exp((z(tm))^2)*Errorf_mm(z(tm),/comp)

	tm = where(Abs_mm(z) ge sqrt(cbound), ntm)
	if ntm ne 0 then begin
		a = 0.5d*dindgen(len)
		a[0] = 1d/sqrt(!dpi)
		b = dblarr(len,2)
		b[*,1] = 1d
		tz = z[tm]
		tr = res[tm]
		comp = Real_mm(tz^2)

		sm = where(Real_mm(tz) ge 0, nsm)
		if nsm ne 0 then tr[sm] = Confrac(a,b,tz[sm],/rel)
		sm = where(Real_mm(tz) lt 0 and comp lt hbound, nsm)
		if nsm ne 0 then tr[sm] = 2*exp((tz[sm])^2) - Confrac(a,b,-tz[sm],/rel)
		sm = where(Real_mm(tz) lt 0 and comp ge hbound, nsm)
		if nsm ne 0 then begin
			message, 'Function overflows for large negative values', /continue
			message, 'Replacing with machine maximum', /continue
			tr[sm] = sinf.xmax
		endif

		res[tm] = tr
	endif

	return, Cast(res,4,typ,/fix)
end
