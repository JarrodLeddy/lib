;+
; NAME
;   GET_SQL_CATCH
; AUTHOR:
;	Sergey Koposov, Max Planck Institute of Astronomy/Institute of
;	Astronomy Cambridge
;   Email: math@sai.msu.ru
;   UPDATED VERSIONs can be found on my WEB PAGE:
;       http://lnfm1.sai.msu.ru/~math/
;
; PURPOSE:
; This is just a small library function used for catching and printing of the
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

function get_sql_catch
	ojbs = OBJ_NEW('IDLJavaObject$IDLJAVABRIDGESESSION')  
	ojex = ojbs -> GetException()  
	str = 'Exception thrown: '+ ojex -> ToString()  
	obj_destroy, ojex
	obj_destroy, ojbs
	return, str	
end
		
