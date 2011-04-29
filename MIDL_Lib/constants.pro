Pro Constants, mks = mks, cgs = cgs

;+
; NAME:
;		CONSTANTS
; VERSION:
;		4.8
; PURPOSE:
;		Creates or updates a system variable named !PCON.  !PCON is a structure
;		the fields of which contain values of physical constants as follows:
;		!PCON
;			USYS  - Unit System.  Either 'MKS' or CGS'.
;			C     -	Speed of light.
;			E     -	Electron charge.
;			H     -	Planck constant.
;			ME    -	Electron mass.
;			K     -	Boltzman constant.
;			NA    -	Avogadro constant.
;
;			ECONV -	Used internally for unit conversion.
;
;			HBAR  -	Planck constant divided by 2*pi.
;			ALPHA -	Fine structure constant.
;			AMU   -	Atomic mass unit.
;			SIGMA -	Stefan-Boltzman radiation constant.
;
;		All the values are given in a double precision format.  Of course, the
;		actual accuracy depends on how precisely they can be measured.
; CATEGORY:
;		Utility.
; CALLING SEQUENCE:
;		CONSTANTS [,/MKS or /CGS]
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/MKS
;		Switch.  Sets the units system to MKS.  This is also the default.
;	/CGS
;		Switch.  Sets the units system to CGS.  Default is MKS.
; OUTPUTS:
;		None.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		Can't use both MKS and CGS at the same time.
; PROCEDURE:
;		Either creates or, if already exists, updates the system variable
;		!PCONS.  Uses ONE_OF from MIDL.
; MODIFICATION HISTORY:
;		Created 30-MAR-1994 by Mati Meron.
;		Checked for operation under Windows, 25-JAN-2001, by Mati Meron.
;		Modified 10-APR-2004 by Mati Meron.  Internal changes only.
;-

	tem = {pcv,usys:'CGS', $
		c:	2.99792458d10, $
		e:	4.8032068d-10, $
		h:	6.6260755d-27, $
		me:	9.1093897d-28, $
		k:	1.380658d-16, $
		na:	6.0221367d23, $
		econv: 1d, hbar: 1d, alpha: 1d,	amu: 1d, sigma: 1d}

	if One_of(mks,cgs) le 0 then begin
		tem.usys = 'MKS'
		tem.c  = 1d-2*tem.c
		tem.e  = tem.e/(10d*tem.c)
		tem.h  = 1d-7*tem.h
		tem.me = 1d-3*tem.me
		tem.k  = 1d-7*tem.k

		tem.econv = 1d-7*tem.c^2
		tem.amu = 1d-3
	endif

	tem.hbar = tem.h/(2d*!dpi)
	tem.alpha = tem.econv*tem.e^2/(tem.c*tem.hbar)
	tem.amu = tem.amu/tem.na
	tem.sigma = tem.hbar/60d*(!dpi/tem.c*(tem.k/tem.hbar)^2)^2

	defsysv, '!pcon', exists = exs
	if exs then dum = execute('!pcon = tem') else defsysv, '!pcon', tem

	return
end
