Function Solve_linsys, arr, rhs, threshold = thresh, status = stat, row = row,$
	svd = svdfl, umat = u, vmat = v, dvec = wvec

;+
; NAME:
;		SOLVE_LINSYS
; VERSION:
;		4.0
; PURPOSE:
;		Solves the system of linear equations ARR*X = RHS
; CATEGORY:
;		Mathematical Function /matrix manipulation.
; CALLING SEQUENCE:
;		Result = SOLVE_LINSYS( ARR, RHS [, keywords])
; INPUTS:
;	ARR
;		Matrix, numeric.  Must be square, unless the keyword SVD is set.
;	RHS
;		Vector representing the right hand side of the equation.  Length should
;		be compatible to the dimensions of the matrix.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	THRESHOLD
;		Sets the threshold that's used to determine whether the matrix is
;		regular.  Default value is 1e-20.  See OPTIONAL OUTPUT PARAMETERS for
;		details.
;	STATUS
;		Optional output, see below.
;	/ROW
;		Switch.  If set, ARR is taken in a row major format.  Default is
;		column major (IDL standard).
;	/SVD
;		Switch.  Specifies solution using the Singular Value Decomposition
;		method.  Default is LU decomposition.
;	UMAT
;		Optional SVD output.  See below.
;	VMAT
;		Optional SVD output.  See below.
;	DVEC
;		Optional SVD output.  See below.
; OUTPUTS:
;		Returns the solution of the linear system in a vector form, type
;		floating or higher.
; OPTIONAL OUTPUT PARAMETERS:
;	STATUS
;		The name of the variable to receive the status flag for the operation.
;		Possible values are 0 for a singular ARR, 1 for regular.  ARR is
;		considered singular if the ratio of the smallest and largest diagonal
;		element in the LU decomposition (or the diagonal part of the SVD
;		decomposition) of ARR is less then THRESHOLD.
;	UMAT
;		SVD only.  The name of the variable to receive the U matrix from the
;		SVD decomposition.  See SVD routine for more detail.
;	VMAT
;		SVD only.  The name of the variable to receive the V matrix from the
;		SVD decomposition.  See SVD routine for more detail.
;	DVEC
;		Named variable.  Result depends on calculation mode, namely:
;			LU	:	vector of the diagonal elements of the LU decomposition.
;			SVD	:	vector of the diagonal elements of W (see the SVD routine).
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Normally uses LU decomposition and backsubstitution, followed by LU
;		correction.  These operations are perfomed by the system routines
;		LUDC, LUSOL and LUMPROVE, based on routines from the book NUMERICAL
;		RECIPES IN C.  If the keyword SVD is set, the solution is obtained
;		using Singular Value Decomposition, and back-substitution performed by
;		the system routines SVDC and SVSOL (same source).  Also uses the
;		functions CAST, DEFAULT, DIAGOVEC, FPU_FIX, ISNUM and TOLER from MIDL.
; MODIFICATION HISTORY:
;		Created 15-DEC-1991 by Mati Meron.
;		Modified 25-MAY-1993 by Mati Meron.  SVD option added.
;		Modified 30-JUN-1995 by Mati Meron.  Changed from the SVD and SVBKSB
;		routines to the new SVDC and SVSOL.  The change is transparent to the
;		user other than the fact that that it allows for a DOUBLE type SVD
;		solution.
;		Modified 25-MAR-1997 by Mati Meron.  Changed from LUDCMP, LUBKSB and
;		MPROVE to the newer LUDC, LUSOL and LUMPROVE.  Same as with the
;		previous change, it is transparent for the user other than the fact
;		that it allows for a DOUBLE type solution.
;		Also added the keyword ROW which allows for treating the input matrix
;		in standard algebraic fashion, instead of the transposed IDL fashion.
;		Modified 10-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	siz = size(arr)
	if siz(0) ne 2 then message, 'Not a matrix!' else $
	if n_elements(rhs) ne siz(1) then message, 'Incompatible sizes!'
	dob = Isnum(arr,/double) or Isnum(rhs,/double)
	thresh = Default(thresh,Toler(double=dob))
	col = keyword_set(row) eq 0

	if keyword_set(svdfl) then begin
		if siz[1] lt siz[2] then begin
			tarr = [arr,fltarr(siz[2] - siz[1], siz[2])]
			trhs = [rhs,fltarr(siz[2] - siz[1])]
		endif else begin
			tarr = arr
			trhs = rhs
		endelse
		svdc, tarr, w, u, v, double = dob, column = col
		u = FPU_fix(u)
		v = FPU_fix(v)
		w = FPU_fix(w)
		wvec = w
		abw = abs(wvec)
		smalw = where(abw lt thresh*max(abw), scon)
		if scon gt 0 then w[smalw] = 0
		res = svsol(u,w,v,trhs, double = dob, column = col)
	endif else begin
		if siz[1] ne siz[2] then message, 'Not a square matrix!'
		if siz[1] eq 1 then tarr = reform(arr,1,1) else tarr = arr
		trhs = Cast(rhs,4)
		ludc, tarr, ivec, double = dob, column = col
		tarr = FPU_fix(tarr)
		if siz[1] eq 1 then tarr = reform(tarr,1,1)
		wvec = Diagovec(tarr)
		abw = abs(wvec)
		smalw = where(abw lt thresh*max(abw), scon)
		res = lusol(tarr,ivec,trhs, double = dob, column = col)
		res = lumprove(arr,tarr,ivec,trhs,res, double = dob, column = col)
	endelse
	stat = (scon eq 0)

	return, FPU_fix(res)
end
