Function Centft, r, f, delta_r = dlr, inverse = inv, symm = sym, asymm = asym, $
	nozero = noz, integral = int, positive_r = psr, join_xy = jxy, $
	full_f = wf, coord = rok

;+
; NAME:
;		CENTFT
; VERSION:
;		4.2
; PURPOSE:
;		Interface to FFT, specialized for symmetric inputs and representation.
; CATEGORY:
;		Mathematical, general
; CALLING SEQUENCE:
;		Result = CENTFT( R [, F] [, keywords])
; INPUTS:
;	R
;		Numeric, Either a vector (scalar is considered to be a vector of
;		length 1) or an [2,*] array.
; OPTIONAL INPUT PARAMETERS:
;	F
;		Numeric, acceptable only when X is a vector, in which case Y has to be
;		a vector of same length.  This is the function to be Fourier transformed
;
;		Note:	When only one input is provided, it is processed by SPLIT_XY,
;				(see there for details.  with both R and F generated internally.
; KEYWORD PARAMETERS:
;	DELTA_R
;		Scalar numeric parameter, provides the spacing of the R values when an
;		R vector is not given.  If R is given, DELTA_R is ignored.
;	/INVERSE
;		Switch,  Same meaning as in FFT, signifies that an inverse transform
;		is to be taken.
;	/SYMM
;		Switch.  If set, the F values provided are taken as the values of the
;		function for positive values of R, and F is extended symmetrically to
;		negative values of R.
;	/ASYMM
;		Switch.  Same as /SYMM only signifies antisymmetric extension.
;
;		Note:  When neither /SYMM nor /ASYMM are set, the function F is used as
;				is, with no extensions.
;	/NOZERO
;		Switch.  Used only when data extension (whether symmetric or asymmetric)
;		is called for.  Signifies that the first value of F given corresponds to
;		the minimal non-zero R.  By default it is assumed that the first value
;		corresponds to R = 0.  Thus, normally, the values of R are assumed to be
;		[... -2DR, -DR, 0, DR, ...], but when /NOZERO is set the values are
;		assumed to be [... -3/2*DR, -1/2*DR, 1/2*DR, 3/2*DR, ...]
;	/INTEGRAL
;		Switch.  If set, the Fourier transform is normalized according to the
;		Fourier integral convention.  This means multiplying by DR for direct
;		transform and by DK/(2*PI) for inverse one.  The standard normalization
;		is multiplying by 1/N (where N is number of points) for direct and by
;		1 for inverse.
;	/POSITIVE_R
;		Switch.  If set, the output (and the COORD output) are trimmed to the
;		range of positive coordinates only.
;	/JOIN_XY
;		Switch.  If set, the resulting K values and transform values are joined
;		in a single [2,*] array, which can be read using SPLIT_XY.
;	FULL_F
;		Optional output, see below.
;	COORD
;		Optional output, see below.
; OUTPUTS:
;		Returns the Fourier transform of F, arranged so that the values
;		corresponding to zero frequency are in the middle, instead of at
;		the ends
;		as LONG.
; OPTIONAL OUTPUT PARAMETERS:
;	FULL_F
;		Returns the full (extended) vector F used in the calculation.
;	COORD
;		Returns the K coordinates (i.e. the frequencies) corresponding to the
;		transformed values.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		When an antisymmetric extension is asked for, either F[0] must be 0
;		or the /NOZERO keyword must be set.
; PROCEDURE:
;		Straightforward.  Extends F as required and applies FFT in combination
;		with apropriate shifts and phase shifts, to get the required
;		representation.
;		CENTFT calls CAST, DEFAULT, ISNUM, ONE_OF and SPLIT_XY from MIDL.
; MODIFICATION HISTORY:
;		Created 25-DEC-2002 by Mati Meron.
;-

	on_error, 1
	phn = dcomplex(0,!dpi)

	dbtyp = Isnum(f,/doub)
	n = Split_xy(r,f,x=tr,y=tf,inpx=inx)
	if inx then dr = Cast(max(tr,min=minr) - minr, 4)/(n-1) $
	else dr = Default(dlr,1.,low=4)
	symtyp = One_of(sym,asym)
	nozfl = keyword_set(noz)
	if keyword_set(inv) then idir = 1 else idir = -1

	case symtyp of
		-1	:	wf = tf
		0	:	wf = [reverse(tf[1-nozfl:*]),tf]
		1	:	if (nozfl or tf[0] eq 0) then wf= [-reverse(tf[1-nozfl:*]),tf] $
				else message, "Can't antisymmetrize, bad [0] component!"
	endcase

	nf = n_elements(wf)
	nh = nf/2
	if not nf mod 2 then begin
		phn = phn/nf
		v = replicate(1d,nf)
		v[nh:*] = -1
		v = v*exp(idir*phn*lindgen(nf))
		res = shift(v*fft(v*shift(wf,-nh),idir),nh)*exp(idir*phn/2)
	endif else res = shift(fft(shift(wf,-nh),idir),nh)

	if keyword_set(int) then begin
		if keyword_set(inv) then imult = dr/(2*!dpi) else imult = nf*dr
		res = imult*res
	endif

	q = lindgen(nf)
	rok = Cast((q - (nf - 1)/2d)*2*!dpi/(nf*dr),4,4+dbtyp)
	res = Cast(res,6,6+3*dbtyp,/fix)

	if keyword_set(psr) then begin
		rok = rok[nh:*]
		res = res[nh:*]
	endif

	if keyword_set(jxy) then res = transpose([[rok],[res]])

	return, Cast(res,6,6+3*dbtyp,/fix)
end