Pro Arro, from = tail, to = head, size = siz, tail = ta, twosided = twos, $
	device = dev, normal = nor, _extra = _e

;+
; NAME:
;		ARRO.
; VERSION:
;		4.0
; PURPOSE:
;		Draws an arrow in the current plot area, from the FROM to the TO
;		location.  DATA coordinates are used, unless one of the keywords
;		/DEVICE or /NORMAL is set.
; CATEGORY:
;		General Graphics.
; CALLING SEQUENCE:
;		ARRO, FROM = tail, TO = head [, keywords]
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	FROM
;		Two dimensional vector, start location, mandatory.
;	TO
;		Two dimensional vector, end location, mandatory.
;	SIZE
;		Scalar, specifies size of head [and tail], default is 1.
;	/TAIL
;		Switch.  Puts a tail on the arrow.
;	/TWOSIDED
;		Switch.  Draws a twosided arrow (heads on both ends).
;	/DEVICE
;		Standard IDL plotting interpretation.
;	/NORMAL
;		Ditto.
;	_EXTRA
;		A formal keyword used to pass all plotting keywords.  Not to be used
;		directly.
; OUTPUTS:
;		None.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		The keywords passed through _EXTRA are transferred to the PLOTS
;		routine.  No keyword verification is performed by ARRO.
; PROCEDURE:
;		Uses DEFAULT, ONE_OF, SHAPE_COCON, SHAPE_TRANS and WHERINSTRUCT
;		from MIDL.  All the coordinates are converted to DEVICE coordinates for
;		shape generation and plotting purposes.
; MODIFICATION HISTORY:
;		Created 15-JUL-1991 by Mati Meron.
;		Modified 15-DEC-1991 by Mati Meron.  Added keywords COLOR and TWOSIDED.
;		Modified 15-DEC-1993 by Mati Meron.  Now ARROW takes advantage of the
;		keyword inheritance property and accepts all IDL plotting keywords.
;		Modified 5-OCT-1994 by Mati Meron.  Name changed to ARRO to avoid
;		conflicts with library routines.
;		Modified 15-JUN-1995 by Mati Meron.  Utilizes WHERINSTRUCT for improved
;		keyword inheritance.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;-

	on_error, 1
	siz = Default(siz,1)
	posib = ['DATA', 'DEVICE', 'NORMAL']
	sor = posib(1 + One_of(dev,nor))

	tem = Shape_cocon([[tail],[head]], from = sor, to = 'DEVICE')
	ang = atan(tem[1,1] - tem[1,0], tem[0,1] - tem[0,0])

	arrhead = siz*Shape_trans(transpose([[0,-2,-2,0],[0,1,-1,0]]),ang)
	usersym, arrhead, /fill
	plots, tem, /device, _extra = _e
	plots, tem[*,1], psym = 8, /device, _extra = _e
	if keyword_set(twos) then begin
		arrhead = Shape_trans(arrhead,180,/degrees)
		usersym, arrhead, /fill
		plots, tem[*,0], psym = 8, /device, _extra = _e
	endif else begin
		if keyword_set(ta) then begin
			x = [1,-1,1,-1,1]
			y = [0,1,0,-1,0]
			arrtail = siz*Shape_trans(transpose([[x-1,x,x+1],[y,y,y]]),ang)
			nth = Wherinstruct('thi',_e,thcon)
			if thcon eq 1 then thi = _e.(nth(0)) else thi = !p.thick
			usersym, arrtail, thick = thi
			plots, tem[*,0], psym = 8, /device, _extra = _e
		endif
	endelse

    return
end
