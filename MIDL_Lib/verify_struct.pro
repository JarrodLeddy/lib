Function Verify_struct, struct, name

;+
; NAME:
;		VERIFY_STRUCT
; VERSION:
;		4.3
; PURPOSE:
;		Verifying that a provided input is a structure, of the appropriate type.
; CATEGORY:
;		Programing Utility.
; CALLING SEQUENCE:
;		Result = VERIFY_STRUCT( STRUCT, NAME)
; INPUTS:
;	STRUCT
;		Arbitrary.
;	NAME
;		Character constant or variable, mandatory.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		If STRUCT is a structure, of the type corresponding to NAME,
;		VERIFY_STRUCT returns 1b, else it returns 0b.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward, using TAG_NAMES.  Calls STREQ and TYPE from MIDL.
; MODIFICATION HISTORY:
;		Created 25-JUL-2001 by Mati Meron.
;		Modified 10-JUL-2003 by Mati Meron.  Internal simplification.
;-

	on_error, 1

	if Type(name) ne 7 then message, 'A string value for NAME is needed!'
	if Type(struct) eq 8 then res = Streq(tag_names(struct,/str),name) $
	else res = 0b

	return, res
end
