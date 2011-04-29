Function Quad_solve, r, f, aval = avl, bvec = bvc, cmat = cmt, $
	stat = stt, rstat = rst

;+
; NAME:
;		QUAD_SOLVE
; VERSION:
;		4.3
; PURPOSE:
;		Reconstructs the parameters of a general multidimensional quadratic
;		function from its values.
; CATEGORY:
;		Mathematical, general.
; CALLING SEQUENCE:
;		Result = QUAD_SOLVE ( R, F [keywords])
; INPUTS:
;	R
;		An [M,N] matrix is taken as an array of N vectors of length M.  The
;		values of M and N are not arbitrary, they must satisfy the equation
;
;			N = (M + 1)*(M + 2)/2
;	F
;		A vector of length N.
; OPTIONAL INPUT PARAMETERS:
;		None
; KEYWORD PARAMETERS:
;	AVAL
;		Optional return, see below.
;	BVEC
;		Optional return, see below.
;	CMAT
;		Optional return, see below.
;	STAT
;		Optional return, see below.
;	RSTAT
;		Optional return, see below.
; OUTPUTS:
;		Returns the "center". i.e. the zero gradient location of the quadratic
;		expression corresponding to the data.
;
;		QUAD_SOLVE assumes that the N function values in F are related to the
;		vectors in R through the quadratic relationship
;
;			F[i] = A + B /dot R[i] + transpose(R[i])*C*R[i]
;
;		and proceeds to find the corresponding A (scalar), B (vector of length
;		M) and C (square MxM symmetric matrix.  Note, this is an exact
;		calculation, not an approximation.
;
;		The center of the quadratic expression above is given by
;
;			R_cent = Inverse(C)*B
;
;		This is a vector of length M and that's what is returned by the function
; OPTIONAL OUTPUT PARAMETERS:
;	AVAL
;		Returns the scalar value A.
;	BVEC
;		Returns the vector B.
;	CMAT
;		Returns the symmetric matrix C.
;	STAT
;		Status variable, returns 1 if the data is regular, i.e. allows for the
;		calculation of A, B and C.  Else, returns 0.  If the data is not quite
;		singular but nearly so, resulting in loss of precision in inversion,
;		STAT returns 2.
;	RSTAT
;		Status variable.  Returns 1 if the C-matrix is regular, thus allowing
;		for the calculation of the center (see OUTPUTS, above).  Else, returns 0
;
;		Note:	It is possible for STAT to be 1 and for RSTAT to be 0 at the
;				same time.  The opposite, obviously, is not possible.
;		Note:	Even if RSTAT is 0, a center may still be calculated (as long
;				as STAT is 1.  The calculation is performed using SVD in this
;				case and the result, of course, is not unique.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The dimensions of R and F must be appropriate (see above).
; PROCEDURE:
;		Based on the paper "Quadratic Optimization of Multivariable Functions",
;		unpublished.
;		Straightforward.  Calls ARREQ, CALCTYPE, CAST and SOLVE_LINSYS from MIDL
; MODIFICATION HISTORY:
;		Created 25-JAN-2003 by Mati Meron.
;-

	on_error, 1

	stt = (rst = 0b)
	typ = Calctype(r,f,0.)
	sizr = size(reform(r))

	case sizr[0] of
		0	:	message, 'Scalar R input not acceptable!'
		1	:	begin
					if sizr[1] eq 3 then wr = Cast(reform(r,1,3),5) $
					else message, 'Bad R-input dimensions!'
				end
		2	:	wr = Cast(reform(r),5)
		else:	message, 'R input cannot have more than 2 dimensions!'
	endcase
	sizr = size(wr)
	m = sizr[1]
	n = sizr[2]
	if n ne (m+1)*(m+2)/2 then message, 'Bad R-input dimensions!.
	sizf = size(reform(f))
	if Arreq(sizf[0:1],[1,n]) then wf = Cast(reform(f),5) else $
	message, 'Length of F must equal second dimension of R'

	res = replicate((machar()).xmax,m)

	qop = identity(n,/double) - make_array(n,n,val=1d/n)
	rtqop = reform(qop#transpose(wr),n,m)
	rtqr_inv = invert(wr#rtqop,qstat,/double)
	if not qstat then begin
		qtem = rtqop#rtqr_inv
		lop = qtem#transpose(rtqop)
		mop = qop - lop
		sop = make_array(m*(m+1)/2,n,/double)
		for i = 0l, m - 1 do begin
			for j = 0l, i do begin
				sop(i*(i+1)/2 + j,*) = wr[i,*]*wr[j,*]
			endfor
		endfor
		stmop = reform(mop#transpose(sop),n,m*(m+1)/2)
		stms_inv = invert(sop#stmop,mstat,/double)
		if not mstat then begin
			stt = 1b + (qstat eq 2 or mstat eq 2)
			cvc = wf#stmop#stms_inv
			ftem = wf - cvc#sop
			bvc =ftem#rtqop#rtqr_inv
			avl = Cast(total(ftem - bvc#wr,/double)/n,typ,typ,/fix)
			bvc = Cast(reform(bvc),typ,typ,/fix)
			cmt = make_array(m,m,/double)
			j = 0l
			for i = 0l, m - 1 do begin
				cmt[i,0:i] = cvc[j:j+i]
				j = j + i + 1
			endfor
			cmt = reform(Cast(cmt + transpose(cmt),typ,typ,/fix),m,m)
			res = Solve_linsys(cmt,-bvc,stat=rst)
			if not rst then res = Solve_linsys(cmt,-bvc,/svd)
		endif
	endif

	return, res
end