Function Split_xy, x, y, z, x_ret = xrt, y_ret = yrt, z_ret = zrt, $
	inpx = inx, inpz = inz, mintyp = mtp, keep_trail = ket, warning = warn

;+
; NAME:
;		SPLIT_XY
; VERSION:
;		4.1
; PURPOSE:
;		Converting data into X and Y arrays, for processing purposes.
; CATEGORY:
;		Utility
; CALLING SEQUENCE:
;		Result = SPLIT_XY( X [, Y] [, keywords])
; INPUTS:
;	X
;		Numeric, Either a vector (scalar is considered to be a vector of
;		length 1) or an [2,*] array (currently also [3,*] array).
; OPTIONAL INPUT PARAMETERS:
;	Y
;		Numeric, acceptable only when X is a vector, in which case Y has to be
;		a vector of same length.
;	Z
;		Numeric, acceptable only when X and Y are vectors, in which case Z has
;		to be a vector of same length.
; KEYWORD PARAMETERS:
;	X_RET
;		Optional output, see below.
;	Y_RET
;		Optional output, see below.
;	Z_RET
;		Optional output, see below.
;	INPX
;		Optional output, see below.
;	INPZ
;		Optional output, see below.
;	MINTYP
;		Sets minimal data type for the optional outputs X_RET and Y_RET.
;		Default value is 4, i.e. type FLOAT.
;	/KEEP_TRAIL
;		Switch.  If set and X is of dimension [2,1] or [3,1], the trailing
;		dimension of 1 is kept, else it is eliminated.
;	/WARN
;		Switch.  If set, the function issues a warning message in case of bad or
;		missing input, else it returns zero without warnings.
; OUTPUTS:
;		Returns the length of the resulting X and Y (and Z if needed) vectors,
;		as LONG.
; OPTIONAL OUTPUT PARAMETERS:
;	X_RET
;		The name of the variable to receive the resulting X vector.
;	Y_RET
;		The name of the variable to receive the resulting Y vector.
;	Z_RET
;		The name of the variable to receive the resulting Z vector, only if
;		required.
;	INPX
;		Returns 1 if X-values were present in the input, O otherwise (i.e. when
;		the X-values were generated internally).
;	INPZ
;		Returns 1 if Z-values were present in the input, (i.e. if either 3
;		input vectors or a single input [3,*] array is provided, O otherwise.
;		Note that, unlike in the X-values case, if no Z-values are present no
;		Z-return is generated.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None other than those specified in types and sizes of variables.
; PROCEDURE:
;		The following cases are possible:
;			1)  X is a [2,N] array, with Y undefined.  In this case the
;				function returns N and the X_RET and Y_RET return variables are
;				set to X[0,*] and X[1,*], respectively.
;			2)  X is a [3,N] array, with Y and Z undefined.  In this case the
;				function returns N and the X_RET and Y_RET and Z_RET return
;				variables are set to X[0,*], X[1,*] and X[2,*], respectively.
;			3)  X is a 1D vector (scalar also qualifies, as vector of length 1)
;				with Y undefined.  In this case the function returns N, X_RET
;				is set to a vector of length N, same type as X and values
;				of 0,...N-1, while Y_RET is set to X.
;			4)	X and Y are both defined and are vectors of *same* length N.
;				In this case, the function returns N, X_RET is set to X and
;				Y_RET is set to Y.
;			5)	X, Y and Z are all defined and are vectors of *same* length N.
;				In this case, the function returns N, X_RET is set to X, Y_RET,
;				is set to Y and Z_RET is set to Z.
;			6)	In all other cases, the function returns 0 and X_RET, Y_RET
;				and Z_RET are not defined.
;
;		SPLIT_XY calls ARREQ, CAST, DEFAULT and ISNUM from MIDL.
; MODIFICATION HISTORY:
;		Created 10-MAY-2001 by Mati Meron.
;		Modified 1-SEP-2002 by Mati Meron.  Added third vector (Z) option.
;		Modified 10-SEP-2002 by Mati Meron.  Added keyword KEEP_TRAIL.
;		Modified 5-SEP-2003 by Mati Meron.  Added keyword INPZ.
;-

	on_error, 1

	inx = (inz = 0b)
	if Isnum(x) gt 0 then begin
		stem = size(x)
		if keyword_set(ket) and Arreq(stem([0,2]),[2,1]) $
		then wx = reform(x,stem([1,2])) else wx = reform([x])
		sizx = size(wx)
		n = sizx[1]
		res = sizx[sizx[0]]
		case Isnum(x) + Isnum(y) + Isnum(z) of
			1	:	begin
						case sizx[0] of
							1	:	begin
										xrt = make_array(res,type=sizx[2],/ind)
										yrt = [wx]
									end
							2	:	begin
										if n le 3 then begin
											inx = 1b
											inz = (n eq 3)
											xrt = wx[0,*]
											yrt = wx[1,*]
											if inz then zrt = wx[2,*]
										endif else res = 0l
									end
							else:	res = 0l
						endcase
					end
			2	:	begin
						wy = reform([y])
						sizes = [sizx[0:1],(size(wy))[0:1]]
						if Arreq(sizes,[1,n,1,n]) then begin
							inx = 1b
							xrt = wx
							yrt = wy
						endif else res = 0l
					end
			3	:	begin
						wy = reform([y])
						wz = reform([z])
						sizes = [sizx[0:1],(size(wy))[0:1],(size(wz))[0:1]]
						if Arreq(sizes,[1,n,1,n,1,n]) then begin
							inx = (inz = 1b)
							xrt = wx
							yrt = wy
							zrt = wz
						endif else res = 0l
					end
		endcase
	endif else res = 0l

	if res gt 0 then begin
		mtyp = Default(mtp,4,/dtyp) > 1
		xrt = Cast(reform(xrt),mtyp)
		yrt = Cast(reform(yrt),mtyp)
		if inz then zrt = Cast(reform(zrt),mtyp)
	endif else if keyword_set(warn) then message, 'Bad or missing input!', /con

	return, res
end