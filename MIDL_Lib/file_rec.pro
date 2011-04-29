Pro File_rec

;+
; NAME:
;		FILE_REC
; VERSION:
;		5.2
; PURPOSE:
;		Access to the file record established by FILE_GET..
; CATEGORY:
;		Utility
; CALLING SEQUENCE:
;		FILE_REC
; INPUTS:
;		None.
; OPTIONAL INPUT PARAMETERS:
;		None.
; KEYWORD PARAMETERS:
;		None.
; OUTPUTS:
;		None other than screen output.
; OPTIONAL OUTPUT PARAMETERS:
;		None.
; COMMON BLOCKS:
;		Block FILEINF0.  Includes the a structure containing a list of calling
;		routines and the file path and filter used in the previous call for each
;		of these routines.  These will be reused unless a full file name is
;		provided or unless overridden by explicit values provided through PATH
;		and FILTER.
; SIDE EFFECTS:
;		None.
; RESTRICTIONS:
;		None.
; PROCEDURE:
;		If the common block FILEINFO have been established, returns the contents
;		of the structure CPFDAT (calling routines, file paths and extensions) in
;		tabular form.  Also returns current default path.
; MODIFICATION HISTORY:
;		Modified 30-NOV-2005 by Mati Meron.
;-

	common fileinfo, cpfdat

	on_error, 1

	print
	if Type(cpfdat) eq 8 then begin
		tabulate, cpfdat.call[0:cpfdat.nent-1],cpfdat.path[0:cpfdat.nent-1],$
		cpfdat.ext[0:cpfdat.nent-1],form=['a16','a48','a8'], /ind, $
		head = ['Caller', 'read/write Path', 'Ext.']

		print
		print, 'Current Default Path:	', cpfdat.dpath
	endif else print, '		No record established yet.'
	print

	return
end