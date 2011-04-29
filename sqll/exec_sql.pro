;+
; NAME
;   EXEC_SQL
; AUTHOR:
;	Sergey Koposov, Max Planck Institute of Astronomy/Institute of
;	Astronomy Cambridge
;   Email: math@sai.msu.ru WEB: http://lnfm1.sai.msu.ru/~math
;   UPDATED VERSIONs can be found that WEB PAGE:
;       http://code.google.com/p/idl-sql/
;  Copyright (C) 2005-2009 Sergey Koposov
;
; PURPOSE:
;    Execute the SQL queries from IDL 
;
; CALLING SEQUENCE:
; EXEC_SQL, sql_query, [ USER= , PASS=, URL=, PROTOCOL=, HOST= , 
;                        PORT=, DB= ] )
;
; DESCRIPTION:
; EXEC_SQL uses the JDBC to connect to the database, execute the query
; without returning any results.
;
; INPUTS:
;     SQL_QUERY - The SQL query which you want to execut
; OPTIONAL INPUT KEYWORDS:
;     USER
;     PASS 
;     URL
;     PROTOCOL 
;     HOST 
;     PORT 
;     DB
;     DRIVER
; 				see the description of get_sql.pro for details about these
;				keywords

pro exec_sql, query, DB=db, HOST=host, PORT=port, USER=user, PASS=pass,$
							URL=url, PROTOCOL=protocol
	on_error,2
	get_sql_setup, user, pass, driver, url, protocol, host, port, db
	if n_elements(query) ne 1 then message, 'The query should be a scalar string'
	obj = OBJ_NEW('IDLJavaObject$idl_sql','idl_sql')

	CATCH, error_status  
	IF (error_status NE 0) THEN BEGIN
		catch, /cancel
		obj_destroy, obj 
		message, get_sql_catch()
	ENDIF  

	obj->exec_sql,query,url,user,pass,driver
	obj_destroy, obj
end
 

