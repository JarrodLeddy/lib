Function Base_gen, x, dimension = dim, scale_back = scb

;+
; NAME:
;		BASE_GEN
; VERSION:
;		4.5
; PURPOSE:
;		Generates an orthogonal array-vector set.
; CATEGORY:
;		Mathematical, vector-array operations.
; CALLING SEQUENCE:
;		Result = BASE_GEN( [x] [, keywords])
; INPUTS:
;	X
;		Vector, numeric.  Ignored if DIM (see below) is provided, mandatory
;		otherwise.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	DIM
;		Numeric scalar, serves as an alternative to X.  See details in
;		procedure.
;	/SCALE_BACK
;		Switch.  If set, the rows remain unnormalized (actually, are normalized
;		to N.  The default is normalized to 1.
; OUTPUTS:
;		Returns a square array, orthogonal, of size [N,N} where N equals either
;		the length of X (if provided) or DIM.  The array is related to a
;		Fourier Transform and can be used to effect such.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Generates an array through a process related to Fourier transformation.
;		The rows of the array are given by cosines and sines of multiples of
;
;				2*pi*(N-1)*Y/N
;		where
;				N = (X - X[0])/(X[N-1] - X[0])
;
;		If X is not provided (i.e. DIM is used), FINDGEN(DIM) is used for X.
;
;		BASE_GEN calls CAST, DIAGOARR, IMAGINARY_MM, ISNUM, REAL_MM, TYPE and
;		VNORM, FROM MIDL.
; MODIFICATION HISTORY:
;		Created 15-DEC-2003 by Mati Meron.
;-

	on_error, 1

	if Isnum(dim) then wx = make_array(dim,/ind,typ = 4 + Isnum(dim,/doub)) $
	else wx = [x]
	siz = size(wx)
	if siz[0] eq 1 then begin
		n = siz[1]
		typ = Type(wx) > 4
		res = make_array(n, n, typ=5, val=1)
		nh = n/2
		if n gt 1 then begin
			wx = wx[sort(wx)]
			wx = (wx - wx[0])/(wx[n-1] - wx[0])
			mvec = exp(2*!dpi*dcomplex(0,1)*(n-1)/n*wx)
			vec = replicate(1d,n)
			idn = Diagoarr(vec)
			for k = 1l, nh do begin
				vec = vec*mvec
				res[*,2*k-1] = Imaginary_mm(vec)
				res[*,2*k < (n-1)] = Real_mm(vec)
			endfor
			for l = 0l, n - 1 do begin
				if l gt 0 then begin
					tem = res[*,0:l-1]
					res[*,l:n-1] = (idn -  tem#transpose(tem))#res[*,l:n-1]
				endif
				res[*,l] = res[*,l]/Vnorm(res[*,l])
			endfor
			if keyword_set(scb) then res = sqrt(double(n))*res
		endif
	endif else message, 'Input must be scalar or vector!'

	return, Cast(res,typ,typ,/fix)
end