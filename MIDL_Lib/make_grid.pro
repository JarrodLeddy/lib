Function Make_grid, span, npoints, stepsize = stes, atmost = atm, $
	dimvec = wpoin, funarr = fnarr

;+
; NAME:
;		MAKE_GRID
; VERSION:
;		4.0
; PURPOSE:
;		Generates a 1-6 dimensional grid of points within a specified range.
; CATEGORY:
;		Array manipulation.
; CALLING SEQUENCE:
;		Result = MAKE_GRID( SPAN, [ NPOINTS] [keywords])
; INPUTS:
;	SPAN
;		A (2,N) numeric array, where N <= 6 is the number of grid dimensions.
;		The pair of entries in SPAN(*,i) represents the coordinate minimum and
;		maximum in the i-th dimension of the grid.
; OPTIONAL INPUT PARAMETERS:
;	NPOINTS
;		A numeric vector containing the number of points along each dimension.
;		If not provided, the same number of points will be assigned to each
;		dimension.  This default number depends on the number of dimensions, as
;		follows:
;			dimensions	|	points per dimension
;				1 				2^20
;				2				2^10
;				3				2^6
;				4				2^4
;				5				2^3
;				6				2^3
;		If NPOINTS has less entries then the number of dimensions, the missing
;		entries will be assigned the value of the last existing one.  If some
;		of the entries (but not the first) are 0 or 1, they'll be replaced by
;		the value of the preceding non-zero entry.
;
;		The meaning of NPOINTS changes if the optional keyword STEPSIZE is set.
;		In this case the entries in NPOINTS represent the step sizes along each
;		dimension (if not provided, stepsizes are set so as to yield the
;		default number of points per dimension as mentioned above).  If some of
;		the step sizes are bigger then the corresponding spans, they will be
;		adjusted to the span size.  Again, If some of the entries (but not the
;		first) are 0 or missing, they'll be replaced by the value of the
;		preceding non-zero entry.
;
;		Comment:  A NPOINTS entry of 1 is allowed if /STEPSIZE isn't set and
;		the corresponding minimum and maximum in SPAN are the same.
; KEYWORD PARAMETERS:
;	/STEPSIZE
;		Switch.  Specifies that the entries in NPOINTS are to be treated as
;		step sizes.  Note that the provides step sizes may be rounded up or
;		down, as needed, to fit within the provided interval.
;	/ATMOST
;		Switch.  Specifies that step sides can only be rounded down.
;	DIMVEC
;		Optional output, see below.
;	FUNARR
;		Optional output, see below.
; OUTPUTS:
;		Returns an array with the dimensions (NDIM,NPOINTS(0),...) where NDIM
;		is the number of dimensions of the grid, such that Result(*,i0,i1,...)
;		is a vector containing the cartesian coordinates of the point at
;		location (i0,i1,...) within the grid.  The output type is FLOAT (or
;		DOUBLE if SPAN is of type DOUBLE).
; OPTIONAL OUTPUT PARAMETERS:
;	DIMVEC
;		The name of the variable to receive the vector (NPOINTS(0),
;		NPOINTS(1),...), containing the number of points along each dimension
;		in the result.
;	FUNARR
;		The name of the variable to receive a blank array of dimensions
;		(NPOINTS(0),NPOINTS(1),...).  This array can be used to receive the
;		values of a function evaluated over the grid.  The output type is FLOAT
;		(or DOUBLE if SPAN is of type DOUBLE).
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The number of dimensions must not exceed 6.
; PROCEDURE:
;		Straightforward.  Uses CAST, DEFAULT, FPU_FIX and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 15-JAN-1992 by Mati Meron.
;		Modified 15-AUG-1994 by Mati Meron.  Added the STEPSIZE option.  Also,
;		from now on, if SPAN is of type DOUBLE, the outputs are of type DOUBLE.
;		Modified 20-JAN-1997 by Mati Meron to allow for a single point along
;		dimension with a zero span.
;		Modified 15-SEP-1998 by Mati Meron.  Added keyword DIMVEC to return the
;		number of points used along each dimension (especially useful with the
;		/STEP option.  Also added underflow filtering.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;		Modified 25-APR-2006 by Mati Meron.  Added keyword /ATMOST.
;-

	on_error, 1
	ndmax = 6
	siz = size(span)
	if siz[1] ne 2 then message, 'Wrong span dimensions!'
	if siz[0] eq 1 then ndim = 1 else $
	if siz[0] eq 2 then ndim = siz(2) $
	else message, 'Wrong span dimensions!'
	if ndim gt ndmax then message, 'Too many dimensions!'

	wspan = Cast([span[0,*],span[1,*] - span[0,*]],4,5)
	dipt = 2l^fix((21 - alog(ndim + 1)/alog(2))/ndim)

	if keyword_set(stes) then begin
		if wspan[1,0] eq 0 then message, 'Illegal span input!'
		for i = 1, ndim - 1 do if wspan[1,i] eq 0 then wspan[1,i] = wspan[1,i-1]
		wpoin = Default(npoints,FPU_fix(wspan[1,*]/(dipt-1)),low=4)
		if wpoin[0] eq 0 then message, 'illegal stepsize input!'
		npo = n_elements(wpoin)
		if npo lt ndim then wpoin = [wpoin,replicate(0.,ndim-npo)]
		for i = 1, ndim - 1 do if wpoin[i] eq 0 then wpoin[i] = wpoin[i-1]
		if keyword_set(atm) $
		then wpoin = (reform(ceil(abs(wspan[1,*]/wpoin))) > 1) + 1 $
		else wpoin = (reform(round(abs(wspan[1,*]/wpoin))) > 1) + 1
	endif else begin
		wpoin = abs(Default(npoints,replicate(dipt,ndim),/dtype))
		if wpoin[0] lt 1 then message, 'Illegal npoints input!'
		npo = n_elements(wpoin)
		if npo lt ndim then wpoin = [wpoin,replicate(0l,ndim-npo)]
		for i = 1, ndim - 1 do if wpoin[i] eq 0 then wpoin[i] = wpoin[i-1]
		dum = where(wpoin eq 1 and wspan[1,*] ne 0, ndum)
		if ndum gt 0 then message, 'Cannot have nonzero span with one point!'
	endelse

	grarr = make_array(size = [ndim + 1,ndim,wpoin,Type(wspan),0])
	fnarr = reform(make_array(size = [ndim,wpoin,Type(wspan),0]),[wpoin])

	for i = 0, ndim - 1 do begin
		if wpoin[i] eq 1 then tem = wspan[0,i] else $
		tem = wspan[0,i] + wspan[1,i]/(wpoin[i] - 1)*findgen(wpoin[i])
		case i of
			0	:	for j = 0l, wpoin[i] - 1 do grarr[i,j,*,*,*,*,*] = tem[j]
			1	:	for j = 0l, wpoin[i] - 1 do grarr[i,*,j,*,*,*,*] = tem[j]
			2	:	for j = 0l, wpoin[i] - 1 do grarr[i,*,*,j,*,*,*] = tem[j]
			3	:	for j = 0l, wpoin[i] - 1 do grarr[i,*,*,*,j,*,*] = tem[j]
			4	:	for j = 0l, wpoin[i] - 1 do grarr[i,*,*,*,*,j,*] = tem[j]
			5	:	for j = 0l, wpoin[i] - 1 do grarr[i,*,*,*,*,*,j] = tem[j]
		endcase
	endfor

	grarr = FPU_fix(grarr)
	if ndim eq 1 then return, reform(grarr) else $
		return, reform(grarr,[ndim,wpoin])
end
