Function Quad_eval, r, c, b, a

;+
; NAME:
;		QUAD_EVAL
; VERSION:
;		4.3
; PURPOSE:
;		Evaluates a general multidimensional quadratic function.
; CATEGORY:
;		Mathematical, general.
; CALLING SEQUENCE:
;		Result = QUAD_EVAL ( R, C [, B [, A]])
; INPUTS:
;	R
;		A vector or an array of vectors.  An [M,N] matrix is taken as an array
;	of N vectors of length M.  Both M and N can be 1.
;	C
;		A square matrix.  Its dimension must agree with the vector length
;	specified by R.  A scalar is taken as an [1,1] matrix.
; OPTIONAL INPUT PARAMETERS:
;	B
;		A vector of length M (same as the dimension of C).
;	A
;		Scalar
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns the value of the quadratic expression
;
;			A + B /dot R + transpose(R)*C*R
;
;		If the R input is an array of vectors (see above) the result is a
;		vector of length N, with one entry for each vector in R.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		A must be a scalar and the appropriate dimensions of B, C and R must
;		agree as described above.
; PROCEDURE:
;		Straightforward.  Calls ARREQ, CALCTYPE, DEFAULT and DIAGOVEC from MIDL
; MODIFICATION HISTORY:
;		Created 25-JAN-2003 by Mati Meron.
;-

	on_error, 1
	if n_params() lt 2 then message, 'Missing inputs!'

	typ = Calctype(0.,r,c)
	sic = size(c)
	if sic[0] eq 0 then begin
		wc = reform([c],1,1)
		sic = size(wc)
	endif else wc = c

	if sic[0] eq 2 then begin
		n = sic[1]
		if sic[2] ne n then message, 'C must be a square matrix!'
		wc = 0.5*(wc + transpose(wc))
		wb = [Default(b,make_array(n,typ=typ),low=typ)]
		if not Arreq((size(wb))[0:1],[1,n]) then $
		message, 'B and C dimensions not compatible!'
		wa = Default(a,0,low=typ)
		if n_elements(wa) ne 1 then message, 'A must be scalar!'
		wr = [r]
		sir = size(wr)
		if sir[0] gt 2 then message, 'R must be a 1 or 2D array!'
		if sir[1] ne n then message, 'R and C dimensions not compatible!'
		wrt = transpose(wr)
		res = wa + wrt#wb + 0.5*Diagovec(wrt#wc#wr)
	endif else message, 'C can only be a scalar or a 2D square matrix'

	return, res
end