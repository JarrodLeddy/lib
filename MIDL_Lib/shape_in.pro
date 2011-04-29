Function Shape_in, shape, loc, closed = cls

;+
; NAME:
;		SHAPE_IN
; VERSION:
;		4.3
; PURPOSE:
;		Provided with a 2D shape and a point, checks whether the point is
;		within the shape
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		Result = SHAPE_IN( SHAPE, LOC [, /CLOSED])
; INPUTS:
;	SHAPE
;		An [2,*] array representing a polygon.
;	LOC
;		A vector of length 2, representing a point.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/CLOSED
;		Switch.  Determines how points on the boundary of the shape are treated.
;		See below in OUTPUTS.
; OUTPUTS:
;		Returns 1l if LOC is within SHAPE, 0l otherwise.  Points on the boundary
;		are considered external unless the switch /CLOSED is set.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		Both the shape and the point need to be 2-dimensional.
; PROCEDURE:
;		Sums up the angles traversed by the vector joining LOC to consecutive
;		verices of SHAPE.  The sum is 0 for external points, 2PI for internal
;		and PI for points on the boundary.
; MODIFICATION HISTORY:
;		Created 15-JAN-2003 by Mati Meron.
;-

	on_error, 1

	if not (Isnum(loc) and n_elements(loc) eq 2) then message, $
	'A 2D location must be provided!'
	wsh = Cast(Shape_close(shape),5)
	if Shape_ver(wsh,len=len) eq 3 then message, 'Only 2D shapes accepted!'
	wsh[0,*] = wsh[0,*] - loc[0]
	wsh[1,*] = wsh[1,*] - loc[1]
	norm = sqrt(total(wsh^2,1))

	dum = where(norm eq 0, ndum)
	if ndum eq 0 then begin
		x = reform(wsh[0,*])/norm
		y = reform(wsh[1,*])/norm
		cost = -1 > (x*shift(x,-1) + y*shift(y,-1))[0:len-2] < 1
		sint = -1 > (x*shift(y,-1) - y*shift(x,-1))[0:len-2] < 1
		tet = asin(sint)
		dum = where(cost lt 0,ndum)
		if ndum gt 0 then tet[dum] = !dpi*Sign(tet[dum]) - tet[dum]
		totet = total(tet)
	endif else totet = !dpi

	res = 1 - round(cos(totet/2))
	res = (res + keyword_set(cls))/2

	return, res
end