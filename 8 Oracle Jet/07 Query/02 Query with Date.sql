select * from XXEPG_INT_PROCESS_REQUESTS
WHERE 
(

(UPPER (INTERFACE_NAME) LIKE '%' || UPPER (:p_INTERFACE_NAME) || '%' OR :p_INTERFACE_NAME IS NULL) OR 
UPPER(:p_INTERFACE_NAME)= UPPER('Search') OR UPPER(:p_INTERFACE_NAME)= UPPER('undefined') 
and  
(UPPER (INTERFACE_PARAMETERS) LIKE '%'|| UPPER (:p_INTERFACE_PARAMETERS) || '%' OR :p_INTERFACE_PARAMETERS IS NULL) OR 
UPPER(:p_INTERFACE_PARAMETERS)= UPPER('Search') OR UPPER(:p_INTERFACE_PARAMETERS)= UPPER('undefined') 
and
(UPPER (CREATED_BY) LIKE '%'|| UPPER (:p_CREATED_BY) || '%' OR :p_CREATED_BY IS NULL) OR 
UPPER(:p_CREATED_BY)= UPPER('Search') OR UPPER(:p_CREATED_BY)= UPPER('undefined') 
and
(
INTERFACE_RUN_DATE BETWEEN  
DECODE(:p_fromDate,     'undefined'	, INTERFACE_RUN_DATE,
						'Search'	, INTERFACE_RUN_DATE,
                        NULL, 		to_date('1951-01-01', 'yyyy-mm-dd'),
									to_date(:p_fromDate, 'yyyy-mm-dd')) 
AND
					
DECODE(:p_toDate,   'undefined'	, INTERFACE_RUN_DATE,
					'Search'	, INTERFACE_RUN_DATE,
                    NULL, 		to_date('1951-01-01', 'yyyy-mm-dd'),
                    to_date(:p_toDate, 'yyyy-mm-dd') ) 
) 
)
ORDER BY interface_run_id DESC
