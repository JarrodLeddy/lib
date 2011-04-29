Function Join_xy, x, y, z, third_column = thc

;+
; NAME:
;		JOIN_XY
; VERSION:
;		4.3
; PURPOSE:
;		Converting X and Y (optionally Z) arrays into a single data package.
; CATEGORY:
;		Utility
; CALLING SEQUENCE:
;		Result = JOIN_XY( X [, Y [, Z] [/THIRD])
; INPUTS:
;	X
;		Numeric, scalar or vector
; OPTIONAL INPUT PARAMETERS:
;	Y
;		Numeric, if provided must be same length as X.
;	Z
;		Numeric, if provided must be same length as X.
; KEYWORD PARAMETERS:
;	/THIRD_COLUMN
;		Switch.  If set, output has three columns, regardless of whether Z is
;		defined.
; OUTPUTS:
;		Returns a [2,*] or [3,*] array, according to the following rules:
;
;		Only X given	:	Values of X assigned to second column.  First column
;							filled with 0, 1, ...  If /THIRD is set, third
;							column filled with zeroes.
;		X and Y given	:	Values of X assigned to first column, Y to second.
;							If /THIRD is set, third column filled with zeroes.
;		X, Y and Z given:	Values of X assigned to first column, Y to second
;							and Z to third.

; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		All the inputs which are provided must have same number of elements.
; PROCEDURE:
;		Straightforward.  Calls CALCTYPE and HOW_MANY from MIDL.
; MODIFICATION HISTORY:
;		Created 10-SEP-2003 by Mati Meron as the inverse of SPLIT_XY.
;-

	on_error, 1

	np = How_many(fir=x,sec=y,thi=z)
	if np gt 0 then begin
		typ = Calctype(x,y,z,def=4)
		len = n_elements(x)
		fdim = 2 > np + keyword_set(thc) < 3
		res = make_array(fdim,len,type=typ)
		case np of
			1	:	begin
						res[0,*] = findgen(len)
						res[1,*] = x
					end
			2	:	begin
						if n_elements(y) eq len then begin
							res[0,*] = x
							res[1,*] = y
						endif else message, 'Data length discrepancies!'
					end
			3	:	begin
						if n_elements(y) eq len and n_elements(z) eq len $
						then begin
							res[0,*] = x
							res[1,*] = y
							res[2,*] = z
						endif else message, 'Data length discrepancies!'
					end
			else:	message, 'Too many inputs!'
		endcase
	endif else message, 'Missing input!'

	return, reform(res,fdim,len)
end