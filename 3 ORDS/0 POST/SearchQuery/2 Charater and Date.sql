select * from XXZLR_FILE_DETAILS_TBL 
where 
upper(ATTRIBUTE1)=upper(:ptransactionType)
and 
(
(UPPER (ZIP_FILE_NAME) LIKE '%' || UPPER (:pZipFileName) || '%' OR :pZipFileName IS NULL) OR 
UPPER(:pZipFileName)= UPPER('Search') OR UPPER(:pZipFileName)= UPPER('undefined') 
and  
(
LOAD_DATE_TIME BETWEEN  
                        DECODE(:pFromDate,     'undefined'	, LOAD_DATE_TIME,
                                                'Search'	, LOAD_DATE_TIME,
                                                NULL, 		to_date('1951-01-01', 'yyyy-mm-dd'),
                                                            to_date(:pFromDate, 'yyyy-mm-dd')) 
        AND
        DECODE(:pToDate,   'undefined'	, LOAD_DATE_TIME,
                                                 'Search'	, LOAD_DATE_TIME,
                                                  NULL, 		to_date('1951-01-01', 'yyyy-mm-dd'),
                                                                to_date(:pToDate, 'yyyy-mm-dd') ) 
) 


)

