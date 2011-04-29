Function Rascline, filnam, start= stp, buffer= buf, exact= ext, status= stat, $
	lines= larr, count= wbuf, file_name= wfilnam, file_info= finf, _extra = _e

;+
; NAME:
;		RASCLINE
; VERSION:
;		4.3
; PURPOSE:
;		Reads ascii files of unknown size.
; CATEGORY:
;		I/O
; CALLING SEQUENCE:
;		Result = RASCLINE( [FILNAM] [, keywords])
; INPUTS:
;	FILNAM
;		Char. value, the name of the data file.  If not given, the routine will
;		query for it, interactively.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	START
;		Pointer to the location in the file from which to start reading.
;		Default value is 0 (i.e. beginning of file).
;	BUFFER
;		Initial size of read buffer.  Default is 2^20 lines.  If a value is
;		provided, it is rounded up to the nearest multiple of 2^10 (i.e. 1024).
;	/EXACT
;		Switch.  If set then, if a buffer value is provided, it is not rounded
;		and if it is not provided, an error results (no defaults).
;	STAT
;		Optional output, see below.
;	LINES
;		Optional output, see below.
;	COUNT
;		Optional output, see below.
;	FILE_NAME
;		Optional output, see below.
;	FILE_INFO
;		Optional output, see below.
;	_EXTRA
;		A formal keyword used to pass keywords to imbedded routines.  Not to
;		be used directly.
; OUTPUTS:
;		Returns a long integer array including the file pointers to all the
;		lines read.
; OPTIONAL OUTPUT PARAMETERS:
;	STATUS
;		Returns an operation success code, 1 if a file is found, 0 otherwise.
;	LINES
;		Returns a character array, with each entry being one line from the file.
;	COUNT
;		Returns number of lines read.
;	FILE_NAME
;		Returns the full (including path) name of the file used.
;	FILE_INFO
;		Returns relevant info (output of FSTAT) for the file.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Double pass, reads the whole file into a string array once with an
;		oversized buffer, to find the file end, then re-reads with a correctly
;		sized buffer.  Determines pointers internally from line lengths.
;		Calls DEFAULT and FILE_GET from MIDL.
; MODIFICATION HISTORY:
;		Created 1-APR-2003 by Mati Meron.
;-

	on_error, 1

	res = (wbuf = 0l)
	wfilnam = File_get(filnam,stat=stat,/read,_extra=_e)
	if stat then begin
		stp = Default(stp,0l,/dtyp)
		if keyword_set(ext) then wbuf = buf $
		else wbuf = (ceil(Default(buf,2l^20,/dtyp)/2l^10) > 1l)*2l^10
		openr, spcun, wfilnam, /get_lun
		on_ioerror, refine
		repeat begin
			point_lun, spcun, stp
			larr = strarr(wbuf)
			readf, spcun, larr
			break
			refine:
			if eof(spcun) then begin
				finf = fstat(spcun)
				wbuf = finf.transfer_count
			endif else wbuf = 4*wbuf < (2l^31-1)
		endrep until 0 or wbuf eq 0
		if wbuf gt 0 then begin
			line = ''
			point_lun, spcun, stp
			readf, spcun, line
			finf = fstat(spcun)
			add = finf.cur_ptr - stp - strlen(line)
			res = long(([0l,total(strlen(larr)+add,/cum)])[0:wbuf-1]) + stp
		endif else larr = ''
		free_lun, spcun
	endif else larr = ''

	return, res
end