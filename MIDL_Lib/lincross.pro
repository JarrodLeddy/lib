Function Lincross, fir, sec, lines = lin, cross = crp

;+
; NAME:
;		LINCROSS
; VERSION:
;		4.0
; PURPOSE:
;		Finds the crossing point of two line segments or lines, in 2D.
; CATEGORY:
;		Geometry.
; CALLING SEQUENCE:
;		Result = LINCROSS( FIR, SEC [,LINES = LIN] [,CROSS = CRP])
; INPUTS:
;	FIR
;		First line/line_segment provided as a (2,2) array.  Two possible forms:
;			1)	Segment:  Endpoints given by 2D vectors FIR(*,0) and FIR(*,1).
;			2)  Line: Point on the line given by FIR(*,0), line direction by
;				FIR(*,1).
;		Whether FIR is interpreted as a line or a segment depends on the
;		value provided to LINES.  Default interpretation is segment.
;	SEC
;		Same as FIR, for the second line/line _segment.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	LINES
;		Numeric code specifying whether FIR and SEC should be considered lines
;		or segments.  Possible values are
;
;		LINES			FIR			SEC
;
;		0 or
;		undefined		segment		segment
;		1				line		segment
;		2				segment		line
;		3				line		line
;	CROSS
;		Optional output, see below.
; OUTPUTS:
;		Returns 1b if a crossing exists, 0b otherwise.  For lines a crossing
;		always exists, unless they happen to be parallel.
; OPTIONAL OUTPUT PARAMETERS:
;	CROSS
;		The name of a variable to receive the coordinates of the crossing point
;		as a 2D vector (X_cross,Y_cross).  If no crossing exists, both values
;		are set to the square root of the maximal floating value (machine
;		dependent).
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calls DEFAULT, FPU_FIX and SOLVE_LINSYS from MIDL.
; MODIFICATION HISTORY:
;		Created 10-NOV-1997 by Mati Meron.
;		Modified 15-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	sinf = machar()
	crp = sqrt(replicate(sinf.xmax, 2))
	lin =  0b > Default(lin,0b,/dtype) < 3b
	lfl = [lin mod 2b, lin/2b]

	if lfl[0] then begin
		ap = fir[*,0]
		ad = fir[*,1]
	endif else begin
		ap = 0.5*(fir[*,1] + fir[*,0])
		ad = fir[*,1] - fir[*,0]
	endelse

	if lfl[1] then begin
		bp = sec[*,0]
		bd = sec[*,1]
	endif else begin
		bp = 0.5*(sec[*,1] + sec[*,0])
		bd = sec[*,1] - sec[*,0]
	endelse

	if (ad[0]*bd[1] - ad[1]*bd[0]) ne 0 then begin
		ctem = Solve_linsys([[ad],[-bd]], bp - ap, stat = isok)
		isok = min(isok and (lfl or abs(ctem) le 0.5))
		if isok then crp = FPU_fix(0.5*([[ad],[bd]]#ctem + ap + bp))
	endif else isok = 0b

	return, isok
end
