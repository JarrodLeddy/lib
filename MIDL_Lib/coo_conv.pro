Function Coo_conv, r, axis = ax, from = sor, to = des

;+
; NAME:
;		COO_CONV
; VERSION:
;		4.0
; PURPOSE:
;		Transforms values between the coordinate systems supported by IDL.
;		Allowed coord systems are DATA, DEVICE (only for X, Y axes) and NORMAL.
;		Functionally similar to the IDL function CONVERT_COORD, COO_CONV is
;		maintained for historical reasons.
; CATEGORY:
;		Plotting /General Graphics.
; CALLING SEQUENCE:
;		Result = COO_CONV( R, AXIS = AX [, keywords])
; INPUTS:
;	R
;		numeric, otherwise arbitrary, assumed to be a coordinate(s) in the
;		direction specified by AXIS.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	AXIS
;		Sets the transformation axis.  Accepts either a numeric value, one of
;		(0, 1, 2) or a character value (only first character matters), one of
;		('X', 'Y', 'Z').  Mandatory.
;	FROM
;		Character value (only first 3 characters matter), specifies input
;		coord. system.  One of ('DATA','DEVICE','NORMAL').  Defaults to 'DATA'.
;	TO
;		Same as FROM.  Specifies output coord. system.
; OUTPUTS:
;		'' (0 length string) in case of failure (bad keyword value), otherwise
;		returns the transformed value as floating (or double if the input is
;		of type double).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses calls to CAST, DEFAULT, FPU_FIX, ISNUM, STREQ, STRMATCH_MM and
;		TYPE from MIDL.  Converts coordinates using values provided by relevant
;		system variables.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Modified 10-SEP-1998 by Mati Meron.  Underflow filtering added.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	axes = ['X', 'Y', 'Z']
	if Isnum(ax) then nax = fix(ax) else $
	if Type(ax) eq 7 then nax = StrMatch_mm(ax,axes,1) $
	else message, 'Bad input!'
	if nax eq -1 or nax gt 2 then begin
	message, 'No such axis!', /continue
	return, ''
	endif else res = Cast(r,4,5)

	posib = ['DATA', 'DEVICE', 'NORMAL']
	sor = Default(sor,'DATA')
	des = Default(des,'DATA')
	if StrMatch_mm(sor,posib,3) eq -1 or StrMatch_mm(des,posib,3) eq -1 then $
	begin
		message, 'Unknown coordinate system!', /continue
		return, ''
	endif
	if nax eq 2 and (sor eq 'DEVICE' or des eq 'DEVICE') then begin
		message, 'DEVICE coordinates for Z axis do not exist!', /continue
		return, ''
	endif
	if Streq(sor,des) then return, res

	q = [[!x.s],[!y.s],[!z.s]]
	v = [!d.x_vsize,!d.y_vsize,1]
	t = [!x.type,!y.type,0]

	if Streq(sor,'DATA') then cvec = q[*,nax] $
	else if Streq(des,'DATA') then cvec = [-q[0,nax],1.]/q[1,nax] $
	else cvec = [0.,1.]

	if Streq(des,'DEVICE') then cvec = cvec*v[nax] $
	else if Streq(sor,'DEVICE') then cvec[1] = cvec[1]/v[nax]

	if Streq(sor,'DATA') and t[nax] then res = alog10(res)
	res = cvec[1]*res
	if cvec[0] ne 0 then res = cvec[0] + res
	if Streq(des,'DATA') and t[nax] then res = 10^(res)

	return, FPU_fix(res)
end
