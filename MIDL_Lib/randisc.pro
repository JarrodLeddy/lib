Function Randisc, seed, d_0, d_1, d_2, d_3, d_4, d_5, d_6, d_7, $
	amplitude = amp, uniform = uni, binomial = bin, normalize = nor

;+
; NAME:
;		RANDISC
; VERSION:
;		4.0
; PURPOSE:
;		Generates a set of discretely distributed random numbers.
; CATEGORY:
;		Mathematical function.
; CALLING SEQUENCE:
;		Result = RANDISC (SEED,  [,parameters] [,keywords])
; INPUTS:
;	SEED
;		A named variable containing the seed value for random number generation.
;		Does not need to be defined prior to call.  For details see IDL
;		routines RANDOMN and RANDOMU.
; OPTIONAL INPUT PARAMETERS:
;	D_0 through D_7
;		Dimensions of the result.  All default to 1.  Trailing dimensions of 1
;		are removed.
; KEYWORD PARAMETERS:
;	AMPLITUDE
;		Numerical value, rounded to long integer on input.  Specifies the
;		output range.  Output values are randomly spread among AMP + 1 possible
;		values ranging from -AMP to AMP (unless the keyword NORMALIZE is used),
;		with a spacing of 2.  Default value of AMP is 1.
;	/UNIFORM
;		Switch.  Specifies uniform distribution.  This is the default.
;	/BINOMIAL
;		Switch.  Specifies binomial distribution.  For large values of AMP the
;		result approaches a Gaussian with sigma = sqrt(AMP)
;	/NORMALIZE
;		Switch.  If set, the result is normalized to lie in the [-1,1] range,
;		with a spacing of -2/AMP
; OUTPUTS:
;		Returns number randomly distributed among the values
;		-AMP, -AMP + 2 ... AMP or, if the keyword NORMALIZE is set, among
;		-1, -1 + 2/AMP ... 1.  The distribution may be uniform (the default) or
;		binomial (quasi gaussian).  The result can have any number (up to 8) of
;		dimensions which are specified by the optional variables D_0, ... D_7.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		On return, SEED is replaced with the new value of the randomizer seed.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Uses the system routine RANDOMU.  Also uses DEFAULT and ONE_OF from
;		MIDL.
; MODIFICATION HISTORY:
;		Created 20-APR-1995 by Mati Meron.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;-

	on_error, 1
	dnums = ['d_0', 'd_1', 'd_2', 'd_3', 'd_4', 'd_5', 'd_6', 'd_7']
	d = replicate(1l,8)
	for i = 0, n_params() - 2 do idum = execute('d[i] = ' + dnums[i])
	amp = Default(amp,1,/dtype) > 1
	wamp = 1 + amp + (1 - amp)*(One_of(uni,bin) > 0)

	dist = floor(wamp*randomu(seed,d[0],d[1],d[2],d[3],d[4],d[5],d[6],d[7]))
	for i = 0l, amp - wamp do dist = $
		dist + floor(wamp*randomu(seed,d[0],d[1],d[2],d[3],d[4],d[5],d[6],d[7]))

	if keyword_set(nor) then return, 2.*dist/amp - 1 else return, 2.*dist - amp
end
