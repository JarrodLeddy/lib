;+
; NAME
;   GET_SQL_SETUP
; AUTHOR:
;	Sergey Koposov, Max Planck Institute of Astronomy/Institute of
;	Astronomy Cambridge
;   Email: math@sai.msu.ru
;   UPDATED VERSIONs can be found on my WEB PAGE:
;       http://lnfm1.sai.msu.ru/~math/
;
; PURPOSE:
; This is just a small library function used for setting up of the
; connection parameters. 
; Java Exceptions
;
; LICENSE:
;    This file is part of IDL_SQL
;
;    IDL_SQL is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    IDL_SQL is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with IDL_SQL; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;-

pro get_sql_setup, user, pass, driver, url, protocol, host, port, db
	if not keyword_set(driver) then $
	begin
		defsysv, '!_IDL_SQL_DRIVER', EXISTS=ex
		if (ex eq 0) then $
			message, 'The driver class must be known (via system variable !_IDL_SQL_DRIVER or DRIVER option of this routine)'
		driver=!_IDL_SQL_DRIVER
	end

	if not keyword_set(user) then $
	begin
		defsysv, '!_IDL_SQL_USER', EXISTS=ex
		if (ex eq 0) then $
			message, 'The user name must be known (via system variable !_IDL_SQL_USER or USER option of this routine)'
		user=!_IDL_SQL_USER
	end
	if not keyword_set(pass) then $
	begin
		defsysv, '!_IDL_SQL_PASS', EXISTS=ex
		if (ex eq 0) then $
			pass='' $
		else $
			pass=!_IDL_SQL_PASS
	end

	if not keyword_set(url) then $
	begin

		defsysv, '!_IDL_SQL_URL', EXISTS=ex
		if ex eq 1 then url = !_IDL_SQL_URL else $
		begin
			if not keyword_set(port) then $
			begin
				defsysv, '!_IDL_SQL_PORT', EXISTS=ex
				if (ex eq 0) then $
					message, 'The port number must be known (via system variable !_IDL_SQL_PORT or PORT option of this routine)'
				port=!_IDL_SQL_PORT
			end
			
			if not keyword_set(host) then $
			begin
				defsysv, '!_IDL_SQL_HOST', EXISTS=ex
				if (ex eq 0) then $
					host='localhost' $
				else $
					host=!_IDL_SQL_HOST
			end

			if not keyword_set(db) then $
			begin
				defsysv, '!_IDL_SQL_DB', EXISTS=ex
				if (ex eq 0) then $
					message, 'The database name must be known (via system variable !_IDL_SQL_DB or DB option of this routine)'
				db=!_IDL_SQL_DB
			end
			if not keyword_set(protocol) then $
			begin
				defsysv, '!_IDL_SQL_PROTOCOL', EXISTS=ex
				if (ex eq 0) then $
					message, 'The protocol must be known (via system variable !_IDL_SQL_PROTOCOL or PROTOCOL option of this routine)'
				protocol=!_IDL_SQL_PROTOCOL
			end
			
			url = protocol + host + ':' + port +'/'+ db 
		end
	end
end
