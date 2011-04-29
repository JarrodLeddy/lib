Function Npardef, p_0, p_1,  p_2,  p_3,  p_4,  p_5,  p_6,  p_7, $
			p_8, p_9, p_10, p_11, p_12, p_13, p_14, p_15, $
			p_16, p_17, p_18, p_19, p_20, p_21, p_22, p_23, $
			p_24, p_25, p_26, p_27, p_28, p_29, p_30, p_31, which = whi

;+
; NAME:
;		NPARDEF
; VERSION:
;		5.3
; PURPOSE:
;		Identifying defined parameters.
; CATEGORY:
;		Programing utility.
; CALLING SEQUENCE:
;		Result = NPARDEF( P_0, .... [, WHICH = WHI])
; INPUTS:
;	P_0, P_1, ...
;		Parameter names or values, arbitrary, don't even need to be defined.
;		Maximal number accepted is currently 32 but can be extended.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	WHICH
;		Optional output, see below.
; OUTPUTS:
;		Returns the number of defined inputs.
; OPTIONAL OUTPUT PARAMETERS:
;	WHICH
;		Returns a vector with the indices of the defined inputs, or -1 if none
;		is defined.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Serves as replacement for RSI's NPARAMS which doesn't
;		distinguish between defined and undefined parameters.
; MODIFICATION HISTORY:
;		Created 20-FEB-2006 by Mati Meron.
;-

	on_error, 1

	nmx = 32
	pnam =  strcompress('p_' + sindgen(nmx),/remove)
	si = sindgen(nmx)
	ptyp = lonarr(nmx)
	n = n_params()
	if n le nmx then begin
		for i = 0l, n-1 do dum = execute('ptyp['+si[i]+']=Type('+pnam[i]+')')
		whi = where(ptyp gt 0, res)
	endif else message, 'Too many inputs!'

	return, res
end