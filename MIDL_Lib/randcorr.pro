Function Randcorr, seed, len, clen

;+
; NAME:
;		RANDCORR
; VERSION:
;		4.0
; PURPOSE:
;		Generates a set of correlated random variables.
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = RANDCORR(SEED, LEN [, CLEN])
; INPUTS:
;	SEED
;		A named variable containing the seed value for random number generation.
;		Does not need to be initialized prior to call.  For details see IDL
;		routine RANDOMN.
;	LEN
;		Length of the random vector to be produced.
; OPTIONAL INPUT PARAMETERS:
;	CLEN
;		Correlation length.  Defaults to 1 (i.e. no correlation).
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		Returns a vector of normally distributed random numbers with nonzero
;		correlation (for CLEN > 1).
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Performs Q_averaging of a standard normal sequence, using the routine
;		QAVER from MIDL.  Also calls DEFAULT from MIDL.
; MODIFICATION HISTORY:
;		Created 25-JUN-2000 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	wclen = Default(clen,1.,lo=4) > 1.
	plen = ceil(wclen*alog(1/Toler()))

	res = randomn(seed,plen+len)

	return, sqrt(2*wclen - 1)*(Qaver(res,wclen))[plen:*]
end
