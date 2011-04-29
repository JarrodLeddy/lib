Pro Screen, background = bkg, foreground = frg, true = tin, complement = cmp, $
	undo = und, redo = red, first = fir, last = las

;+
; NAME:
;		SCREEN
; VERSION:
;		5.5
; PURPOSE:
;		Setting foreground (!p.color) and background (!p.background) plotting
;		colors.
; CATEGORY:
;		Graphics utility.
; CALLING SEQUENCE:
;		SCREEN [, keywords]
; INPUTS:
;		None
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	BACKGROUND
;		Background color index given as RGB triple.  Default is [0,0,0] (white).
;	FOREGROUND
;		Foreground color index given as RGB triple.  Default is [DTS,DTS,DTS]
;		where DTS = !d.table_size.  This evaluates to black.
;
;	Note:	In both cases, if a scalar value N is given, an [N,N,N] triple is
;			used, else if less than 3 values are present, the remainder is zero
;			padded.  All this, however, can be everrided by the keyword /TRUE.
;	/TRUE
;		Switch.  If set, BACKGROUND and FOREGROUND are taken as scalar True
;		Color values.
;	/COMPLEMENT
;		Switch.  If set and only one of FOREGROUND, BACKGROUND is given, then
;		the second one is set as its RGB complement.
;	/UNDO
;		Switch.  If set, restores the previous in list values for	|
;		background and foreground (if there are previous values)	| Only one
;	/REDO															| of these
;		Switch.  If set, changes to the next in list values for 	| four
;		background and foreground (if there are next values).		| keywords
;	/FIRST															| may be
;		Switch.  If set, changes to the first in list set of 		| used at
;		values for background and foreground.						| any given
;	/LAST															| call
;		Switch.  If set, changes to the last in list set of 		|
;		values for background and foreground.						|
; OUTPUTS:
;		None.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		Block BFGROUND.  Includes:
;			CNUM	-	The value of !d.table_size.
;			IND		-	The current index into the color lists.
;			BCOL	-	List of background colors (in True Color format)
;			FCOL	-	List of foreground colors (in True Color format)
; SIDE EFFECTS:
;		Changes the values of of !P.BACKGROUND and !P.COLOR, in the !P system
;		variable.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Reads the inputs (if any) and generates appropriate
;		entries into the background and foreground lists in the common block.
;		Moves foreward/backward within the list, if required.  Calls HOW_MANY,
;		ONE_OF and POLEVAL from MIDL.
; MODIFICATION HISTORY:
;		Created 1-JAN-1998 by Mati Meron.
;		Modified 15-JUN-2006 by Mati Meron.  Added keyword /TRUE.
;-

	common bfground, cnum, ind, bcol, fcol

	on_error, 1
	if n_elements(cnum) eq 0 then begin
		cnum = !d.table_size
		ind = 0l
		bcol = [0l]
		fcol = [cnum^3 - 1]
	endif

	inp = How_many(first = bkg,second = frg, which = winp)
	act = One_of(fir,las,und,red)

	if inp gt 0 or act lt 0 then begin
		bcol = [bcol,bcol[ind]]
		fcol = [fcol,fcol[ind]]
		ind = ind + 1
		cmfl = keyword_set(cmp)
		tifl = keyword_set(tin)
		if tifl then mnum = cnum^3 - 1 else mnum = cnum - 1
		upfl = [1,1]
		case winp of
	    	0	:	begin
						bkg = mnum
						frg = 0l
					end
			1	:	if cmfl then frg = mnum - bkg else upfl[1] = 0
			2	:	if cmfl then bkg = mnum - frg else upfl[0] = 0
			3	:
		endcase
		if upfl[0] then begin
			if not tifl then begin
				if (size(bkg))[0] eq 0 then wbkg = replicate(bkg,3) $
				else wbkg = ([bkg,0,0])[0:2]
				bcol[ind] = Poleval(cnum, 0 > wbkg < (cnum - 1))
			endif else bcol[ind] = bkg
		endif
		if upfl[1] then begin
			if not tifl then begin
				if (size(frg))[0] eq 0 then wfrg = replicate(frg,3) $
				else wfrg = ([frg,0,0])[0:2]
				fcol(ind) = Poleval(cnum, 0 > wfrg < (cnum - 1))
			endif else fcol[ind] = frg
		endif
	endif else begin
		case act of
			0	:	ind = 0l
			1	:	ind = n_elements(bcol) - 1
			2	:	ind = (ind - 1) > 0l
			3	:	ind = (ind + 1) < (n_elements(bcol) - 1)
		endcase
	endelse

	!p.background = bcol[ind]
	!p.color = fcol[ind]

	return
end
