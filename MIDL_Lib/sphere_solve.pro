Function Sphere_solve, r, radius = rad, status = sta

;+
; NAME:
;		SPHERE_SOLVE
; VERSION:
;		4.8
; PURPOSE:
;		Finds the parameters (center and radius) of a multidimensional sphere,
;		Given a sufficient number of points on its surface.
; CATEGORY:
;		Mathematical, general.
; CALLING SEQUENCE:
;		Result = QUAD_SOLVE ( R, [keywords])
; INPUTS:
;	R
;		An [N,N+1] matrix, taken as an array of N+1 vectors of length N.  In a
;		special case (1D) a two element vector (interpreted as two vectors of
;		length 1 is acceptable.
; OPTIONAL INPUT PARAMETERS:
;		None
; KEYWORD PARAMETERS:
;	RADIUS
;		Optional return, see below.
;	STATUS
;		Optional return, see below.
; OUTPUTS:
;		Returns the location of the sphere's "center" as an N-element vector.
; OPTIONAL OUTPUT PARAMETERS:
;	RADIUS
;		Returns the sphere's radius
;	STATUS
;		Status variable, returns 1 if the data is regular, i.e. allows for the
;		calculation of center and radius.  Else, returns 0.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The dimensions of R must be appropriate (see above).
; PROCEDURE:
;		Based on a simplified version of the procedure described in the paper
;		"Quadratic Optimization of Multivariable Functions", unpublished.
;		Calls CALCTYPE, CAST, DIAGOVEC and SVD_INVERT, from MIDL.
; MODIFICATION HISTORY:
;		Created 5-MAR-2004 by Mati Meron.
;-

	on_error, 1

	sta = 0b
	typ = Calctype(r,0.)
	sizr = size(reform(r))

	case sizr[0] of
		0	:	message, 'Scalar R input not acceptable!'
		1	:	begin
					if sizr[1] eq 2 then wr = Cast(reform(r,1,2),5) $
					else message, 'Bad R-input dimensions!'
				end
		2	:	wr = Cast(reform(r),5)
		else:	message, 'R input cannot have more than 2 dimensions!'
	endcase
	sizr = size(wr)
	m = sizr[1]
	n = sizr[2]
	if n ne (m+1) then message, 'Bad R-input dimensions!.

	qop = identity(n,/double) - make_array(n,n,val=1d/n)
	rtqop = reform(qop#transpose(wr),n,m)
	rtqr_inv = SVD_invert(wr#rtqop,stat=sta)
	if sta then begin
		rov = Diagovec(transpose(wr)#wr)/2
		res = rov#rtqop#rtqr_inv
		rad = sqrt((total(res^2) + 2./n*total(rov - res#r)) > 0)
		rad = Cast(rad,typ,typ,/fix)
	endif else begin
		res = replicate((machar()).xmax,m)
		rad = 0.
		sta = 0b
	endelse

	return, Cast(reform(res),typ,typ,/fix)
end