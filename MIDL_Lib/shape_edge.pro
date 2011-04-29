Function Shape_edge, shape, edge, segment = seg, close = clo, exists = exs

;+
; NAME:
;		SHAPE_EDGE
; VERSION:
;		3.3
; PURPOSE:
;		Modifies a SHAPE (see SHAPE_VER for a definition) by cutting it along
;		a straight edge.
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		Result = SHAPE_EDGE( SHAPE, EDGE [, keywords])
; INPUTS:
;	SHAPE
;		Two dimensional shape i.e. a [2,*] numeric array.
;	EDGE
;		An (2,2) numeric array representing a straight line in the
;		[[point],[direction]] format, i.e. EDGE[*,0] is a point on the line,
;		EDGE[*,1] is a vector in the direction of the line.  This format can be
;		changed using the SEGMENT keyword (see below).
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/SEGMENT
;		Switch.  If set, the line provided by EDGE is assumed to be in a
;		[[point1],[point2]] format, i.e. EDGE[*,0] and EDGE[*,1] are two
;		different points on the line.
;	/CLOSE
;		Switch.  If set, forces closure of the output shape.  If the input
;		shape happens to be closed, the output one is being closed
;		automatically unless CLOSE is explicitly set to zero.
;	EXISTS
;		Optional output, see below.
; OUTPUTS:
;		Returns a new shape, made of the points of the original shape which
;		were not cut off by the edge, plus the points introduced by the edge
;		line cutting through line segments of the original shape.
;		Important:  The edge line is DIRECTED.  Its direction is the direction
;		of the direction vector.  The points to the left of the line (relative
;		to the line direction) are maintained, those to the right are cut off.
;		This is consistent with viewing the edge line as part of a mathematical
;		contour (in a mathematically positive direction) and keeping the points
;		inside the contour.
;		If there are no points left in the result shape, a single point (i.e.
;		2D vector) with X and Y coordinates equal to the square root of the
;		maximal floating value (machine dependent) is returned.
; OPTIONAL OUTPUT PARAMETERS:
;	EXISTS
;		The name of a variable to receive calculation status result.  Returns
;		1b if the result shape is non-empty, 0b otherwise.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses LINCROSS from MIDL to find crossing points of the EDGE line and
;		the shape and adjusts the shape appropriately.  Also calls ARREQ,
;		DEFAULT, FPU_FIX, SHAPE_CLOSE, SHAPE_VER, VINP and VNORM from MIDL.
; MODIFICATION HISTORY:
;		Created 10-NOV-1997 by Mati Meron.
;		Modified 20-JUL-1999 by Mati Meron.  Added keywords SEGMENT and EXISTS.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	sinf = machar()
	res = sqrt(reform(replicate(sinf.xmax,2),2,1))
	exs = 0b

	wedge = edge
	if keyword_set(seg) then wedge[*,1] = wedge[*,1] - wedge[*,0]
	ep = wedge[*,0]
	ed = wedge[*,1]
	if Vnorm(ed) eq 0 then begin
		message, 'Line direction not defined!', /continue
		return, 0
	endif
	en = [-ed[1],ed[0]]

	ndim = Shape_ver(shape,len = np)
	if ndim ne 2 then begin
		if ndim eq 3 then message, 'Only 2-D shapes accepted!', /continue $
		else message, 'Improper or missing shape!', /continue
		return, 0
	endif

	pos = reform(en#shape - Vinp(en,ep)) ge 0
	a = where(pos gt [0,pos], nsec)
	if nsec gt 0 then begin
		b = where(pos gt [pos[1:*],0])
		for i = 0l, nsec - 1 do begin
			if a[i] ne 0 then begin
				id = Lincross(wedge,shape[*,a[i]-1:a[i]],lin = 1,cross = cro)
				if id and not Arreq([cro],shape[*,a[i]]) then res=[[res],[cro]]
			endif
			res = [[res],[shape[*,a[i]:b[i]]]]
			if b[i] ne np - 1 then begin
				id = Lincross(wedge,shape[*,b[i]:b[i]+1],lin = 1,cross = cro)
				if id and not Arreq([cro],shape[*,b[i]]) then res=[[res],[cro]]
			endif
		endfor
		res = res(*,1:*)
		if (size(res))(0) eq 1 then res = [[res],[res]]
		if (Arreq(shape[*,0],shape[*,np-1]) and Default(clo,1) ne 0) $
		or keyword_set(clo) then res = Shape_close(res)
		exs = 1b
	endif

	return, FPU_fix(res)
end
