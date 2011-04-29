Function Sinctran, x, y, norm = nrm

;+
; NAME:
;		SINCTRAN
; VERSION:
;		4.3
; PURPOSE:
;		Generates a Sinc array for sinc interpolation purposes.
; CATEGORY:
;		Mathematical
; CALLING SEQUENCE:
;		Result = SINCTRAN( X, Y [, /NORM])
; INPUTS:
;	X
;		Vector, numeric.  Must be equispaced.
;	Y
;		Numeric vector or scalar
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/NORM
;		Switch.  If set, the resulting array is normalized by rows
; OUTPUTS:
;		Returns an array of dimensions (N_ELEMENTS(X),N_ELEMENTS(Y)),
;		containing the values of Sinc((X[i]-Y[j])/delta_X), where
;		Sinc(z) = sin(pi*z)/(pi*z) and delta_X is the spacing between
;		consecutive values of X.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None other than the restrictions mentioned for X
; PROCEDURE:
;		Straightforward.  Calls CALCTYPE, CAST, DIF, ISNUM, SP_BESELJ and TOLER
;		From MIDL.
; MODIFICATION HISTORY:
;		Created 15-SEP-2002 by Mati Meron.
;-

	on_error, 1

	if Isnum(x) and Isnum(y) then begin
		nx = n_elements(x)
		if nx gt 1 then begin
			chk = Dif(x,2,/clip)
			if max(abs(chk)) le 4*Toler(x)*max(abs(x)) then begin
				ny = n_elements(y)
				dx = (max(x,min=min) - min)/(nx-1.)
				typ = Calctype(x,y,def=4) > 4
				eps = Toler(typ=typ)
				res = make_array(nx,ny,typ=typ)
				for i = 0, nx - 1 do res[i,*] = y
				for j = 0, ny - 1 do res[*,j] = res[*,j] - x
				res = Sp_beselj(!dpi/dx*res,0)
				if keyword_set(nrm) then begin
					nfac = total(res,1)
					for j = 0, ny - 1 do res[*,j] = res[*,j]/nfac[j]
				endif
			endif else message, 'X has to be equispaced!'
		endif else message, 'X needs at least two elements!'
	endif else message, 'Missing or bad input!'

	return, reform(Cast(res,typ,typ,/fix) + eps - eps,nx,ny)
end