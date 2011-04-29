Function Rascii, filnam, buffer = buf, double = doub, $
	quiet = qui, show = sho, skip = skip, file_name = wfilnam, $
    npoints = ncr, header = head, error_status = err, _extra = _e

;+
; NAME:
;		RASCII
; VERSION:
;		4.1
; PURPOSE:
;		Reads data from an ASCII file into an array.  It is assumed that the
;		file contains columns of numbers, with the same number of entries in
;		each row.  The numbers may be separated by commas, spaces and/or tabs.
;		The file may contain a header.  The first line in which the first
;		non-blank character is one of ".+-0123456789" will be considered the
;		beginning of the data.  Text lines imbedded in the data are skipped.
; CATEGORY:
;		Input/Output.
; CALLING SEQUENCE:
;		Result = RASCII( FILNAM [, optional keywords])
; INPUTS:
;	FILNAM
;		Char. value, the name of the data file.  Default extension on VMS
;		is '.DAT'.  Elsewhere there is no default extension.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;	BUFFER
;		Initial number of data rows.  Default is 256.  In any case the result
;		Is trimmed to the actual number.
;	/DOUBLE
;		Switch.  If set, the data is input as DOUBLE.  Default is FLOAT.
;	/QUIET
;		Switch.  If set, error messages are suppressed.
;	/SHOW
;		Switch.  If set, the header (if one exists) is printed to the screen.
;	SKIP
;		Number of lines to skip at the beginning of the file.  This keyword can
;		be used if the header of the file contains lines beginning with
;		".+-0123456789" which would otherwise be read as data.  Default is 0.
;	FILE_NAME
;		Optional output, see below.
;	NPOINTS
;		Optional output, see below.
;	HEADER
;		Optional output, see below.
;	ERROR_STATUS
;		Optional output, see below.
;	_EXTRA
;		A formal keyword used to pass keywords to imbedded routines.  Not to
;		be used directly.
; OUTPUTS:
;		Returns the data in a (NC,NR) floating (or double precision if DOUBLE
;		is set) array, where NC, NR, are the numbers of columns and rows,
;		respectively.  In case of error returns 0.
; OPTIONAL OUTPUT PARAMETERS:
;	FILE_NAME
;		The name of a variable to receive the full name (including path) of
;		the file used.  Doesn't need to be defined prior to the call.  In case
;		of error returns null string.
;	NPOINTS
;		The name of a 2-dim vector to receive the values of NC, NR (see above).
;		Doesn't need to be defined prior to the call.  In case of an error
;		returns [0,0].
;	HEADER
;		The name of a character array to receive the header lines.  Doesn't
;		need to be defined prior to the call.  In case of an error, or if no
;		header exists, returns a zero length string.
;	ERROR_STATUS
;		The name of a variable to receive the I/O error code if one occurs.
; COMMON BLOCKS:
;		None.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		Straightforward.  Uses DEFAULT, FILE_GET, STREQ and STRPARSE_MM from
;		MIDL.
; MODIFICATION HISTORY:
;		Created 25-JAN-1992 by Mati Meron.
;		Modified 25-MAY-1994 by Mati Meron.  Added buffering and DOUBLE option.
;		Modified 14-FEB-1995 by Mark Rivers.  Added keyword SKIP.
;		Modified 24-JUL-1995 by Mati Meron.  Removed a UNIX/VMS conflict in the
;		file OPENR statement.
;		Modified 10-JUL-1997 by Mati Meron.  Name changed from READ_ASCII to
;		RASCII to avoid conflict with the READ_ASCII routine in IDL ver. 5.
;		Modified 12-SEP-1997 by Mati Meron.  Added keyword ERROR_STATUS,
;		following a modification by Roger Dejus, XFD/APS.
;		Checked for operation under Windows, 30-JAN-2001, by Mati Meron.
;		Modified 10-MAY-2001 by Mati Meron.  Added interactive file pick.
;		Modified 1-APR-2002 by Mati Meron.  Added keywords QUIET and FILE_NAME.
;-

	on_error, 1

	err = 0l
	ncr = [0l,0l]
	bufsiz = (round(Default(buf,256)/256.) > 1l)*256l
	nrtem = bufsiz
	dtyp = 4 + keyword_set(doub)
	on_ioerror, file_no_good
	if Streq(!version.os,'vms',3) then begin
		openr, datun, filnam, default = '.dat', /get_lun
	endif else begin
		wfilnam = File_get(filnam,/read,stat=stat,_extra=_e)
		if stat then openr, datun, wfilnam, /get_lun $
		else message, 'No file!'
	endelse

	line = ''
	head = ''
	nc = 0l
	if keyword_set(sho) then print
	on_ioerror, data_no_good
	if n_elements(skip) ne 0 then for i = 0l, skip-1 do $
		readf, datun, line, prompt = ''
	while nc eq 0 and not eof(datun) do begin
		finf = fstat(datun)
		readf, datun, line, prompt = ''
		if line ne '' then begin
			bline = byte(strtrim(line,1))
			if Strparse_mm(' .+-0123456789 ',string(bline[0])) eq 0 then begin
				head = [temporary(head),line]
				if keyword_set(sho) then print, line
			endif else nc = 1l + Strparse_mm(line, '	, ')
		endif
	endwhile
	head = transpose(head(n_elements(head) gt 1:*))

	if nc gt 0 then begin
		point_lun, datun, finf.cur_ptr
		datline = make_array(nc, type = dtyp)
		data = make_array(nc,bufsiz, type = dtyp)
		on_ioerror, next
		nr = 0l
		next:
		while not eof(datun) do begin
			readf, datun, datline, prompt = ''
			data[*,nr] = datline
			nr = nr + 1l
			if nr eq nrtem then begin
				data = [[data],[make_array(nc,bufsiz, type = dtyp)]]
				nrtem = nrtem + bufsiz
			endif
		endwhile
		data = data[*,0:nr-1]
		ncr = [nc,nr]
	endif else data = 0

	free_lun, datun
	return, data

	data_no_good:
	free_lun, datun
	file_no_good:
	if not keyword_set(qui) then print, !err_string
	err = !error
	return, 0

end