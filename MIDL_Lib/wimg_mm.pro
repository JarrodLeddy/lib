Pro Wimg_mm, fname, png = png, jpg = jpg, bmp = bmp, nodef = nod, verbose= vrb,$
	 _extra = _e

;+
; NAME:
;		WIMG_MM
; VERSION:
;		5.2
; PURPOSE:
;		Interface to the graphics WRITE routines.
; CATEGORY:
;		I/O
; CALLING SEQUENCE:
;		Result = WIMG_MM, [FNAME] [, keywords]
; INPUTS:
;	FNAME
;		Character variable or constant, translating to a file name.  In standard
;		operation the user will be selecting or modifying FNAME through
;		DIALOG_PICKFILE.  This can be overriden by using the keyword /AUTO
;		which is passed by _EXTRA to FILE_GET.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	/PNG
;		Switch.  Specifies PNG format.  This is also the default.
;	/JPG
;		Switch.  Specifies JPG format.
;	/BMP
;		Switch.  Specifies BMP format.
;	/NODEF
;		Switch.  If set, there is no default mode specified, thus when WIMG_MM
;		is called with no mode specification, nothing happens.
;	/VERBOSE
;		Switch.  If set, the full name of the generated file is printed to the
;		screen.
;	_EXTRA
;		A formal keyword, used to transfer additional keywords to WRITE_PNG,
;		WRITE_JPG or WRITE_BMP.  See available keywords there.  Not to be used
;		directly.
;
;		Note:	The one keyword of interest is QUALITy, for WRITE_JPG.
; OUTPUTS:
;		None, other than the file saved.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward, calls FILE_GET from MIDL.  Interactive mode, unless the
;		keyword /AUTO (see FILE_GET) is invoked.
; MODIFICATION HISTORY:
;		Created 30-NOV-2005 by Mati Meron as straightforward development from
;		the old WPNG_MM.
;-

	on_error, 1
	def = ['png','jpg','bmp']

	whi = One_of(png,jpg,bmp) > (0 - keyword_set(nod))
	if whi eq -1 then stat = 1 else $
	wname = File_get(fname,def=def[whi],/write,/over,stat=stat,_extra=_e)
	if stat then begin
		img = TVRD(true=1)
		case whi of
			-1	:	vrb = 0
			0	:	write_png, wname, img, order = !order, _extra = _e
			1	:	write_jpeg,wname, img, true = 1, order = !order, _extra = _e
			2	:	write_bmp, wname, img, /rgb, _extra = _e
		endcase
		if keyword_set(vrb) then begin
			print
			print, '	Saved ' + wname
			print
		endif
	endif else message, 'File not saved!', /cont

	return
end