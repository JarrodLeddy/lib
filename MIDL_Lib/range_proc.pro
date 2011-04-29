Function Range_proc, inr, sort = sor, unique = uni

;+
; NAME:
;		RANGE_PROC
; VERSION:
;		4.3
; PURPOSE:
;		Index range generation.
; CATEGORY:
;		Utility
; CALLING SEQUENCE:
;		Result = RANGE_PROC( INR [, keywords])
; INPUTS:
;	INR
;		Character or numeric (of an integer type), scalar or array.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/SORT
;		Switch.  If set, the output is sorted in ascending order.
;	/UNIQUE
;		Switch.  If set, multiple instances of same index are eliminated,
;		leaving only a single one.
;
;		Note:  SORT and UNIQUE are independent.
; OUTPUTS:
;		Returns an array of indices, using the following rules:
;
;		1)	Numeric input (of any of the integer types):  The output is same as
;			input (but of type no lower than LONG).
;		2)	Character scalar representing a number, such as '7'.  The output is
;			the input, converted into a number.
;		3)	Character scalar of the form '3 - 8' or '12: 7'.  In this case the
;			output is an array extending from the lower to the higher number
;			(like [3,4,5,6,7,8] for the first case).  Note that even if the
;			numbers are reversed, like in the second case, the output is still
;			in ascending order ([7,8,9,10,11,12] for the second case).
;		4)	Character scalar containing multiple instances of (2) and/or (3)
;			separated with comas, such as '4: 8,2,6-1,12'.  In this case each
;			coma-bracketed piece is processed according to rules (2-3) above
;			and the results are joined together in the order in which they
;			appear in the input.  No overall ordering occurs (unless /SORT is
;			set).  Thus, the input above will yield as output the array:
;			[4,5,6,7,8,2,1,2,3,4,5,6,12].
;		5)	Character array, with each term being of the form (4).  In this
;			case each term is processed according to (4) and the results are
;			joined together in order.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Calls CAST, ISNUM, MAKE_RANGE, SORPURGE, STRPARSE_MM
;		and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 30-MAR-2003 by Mati Meron.
;-

	on_error, 1

	typ = Type(inr)
	if typ eq 7 then begin
		str = strcompress(strjoin(inr,',',/single),/remove)
		n = Strparse_mm(str,',',lis)
		res = 0l
		for i = 0l, n do begin
			pn = Strparse_mm(lis[i],'-:',plis)
			plis = long(plis)
			case pn of
				0	:	res = [res,plis]
				1	:	res = [res,Make_range(plis)]
				else:	message, 'Bad input!'
			endcase
		endfor
		res = res[1:*]
	endif else begin
		if Isnum(inr,/int) then res = Cast([inr],3) else message, 'Bad input!'
	endelse

	if keyword_set(sor) then res = res[sort(res)]
	if keyword_set(uni) then begin
		s = Sorpurge(res)
		res = res[s[sort(s)]]
	endif

	return, res
end