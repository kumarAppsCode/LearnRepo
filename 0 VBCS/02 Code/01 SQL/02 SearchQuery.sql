SELECT * FROM fs_tablename rd
where 
1=1
AND UPPER('EMP')=NVL(:ptype ,'EMP')
and (UPPER (rd.request_type) =(UPPER (:prequest_type)))
and (TRIM(rd.PERSON_ID)=TRIM(:pperson_id))
AND (
upper (rd.REQUEST_NUMBER) like '%'|| upper (:prequest_number) || '%' or :prequest_number is null
or upper(:prequest_number) = upper('Search') or upper(:prequest_number)= upper('undefined')
)
and 
(
TO_DATE (REQUEST_DATE) BETWEEN 
DECODE(:prequest_from_date,  'undefined'   , TO_DATE (REQUEST_DATE),
                             'Search'	   , TO_DATE (REQUEST_DATE),
                             NULL, 		     to_date('1951-01-01', 'YYYY-mm-dd'),
                                             to_date(:prequest_from_date, 'YYYY-mm-dd')) 
AND
DECODE(:prequest_to_date,  'undefined'	 , TO_DATE (REQUEST_DATE),
                            'Search'	 , TO_DATE (REQUEST_DATE),
                            NULL         ,to_date('4712-01-01', 'YYYY-mm-dd'),
                                         to_date(:prequest_to_date, 'YYYY-mm-dd')) 
)
------------------------------------------------------------------------------------
UNION ALL
SELECT * FROM fs_tablename rd
where 
1=1
AND UPPER('IT')=NVL(:ptype ,'IT')
and (UPPER (rd.request_type) =(UPPER (:prequest_type)))
AND (
rd.PERSON_ID=  DECODE(:pperson_id,  'undefined' ,rd.PERSON_ID,
                                    'Search'	, rd.PERSON_ID,
                                    NULL 	    ,rd.PERSON_ID,
                                    0           ,rd.PERSON_ID,
                                                :pperson_id) 
)AND (
upper (rd.REQUEST_NUMBER) like '%'|| upper (:prequest_number) || '%' or :prequest_number is null
or upper(:prequest_number) = upper('Search') or upper(:prequest_number)= upper('undefined')
)
and 
(
TO_DATE (REQUEST_DATE) BETWEEN 
DECODE(:prequest_from_date,  'undefined'   , TO_DATE (REQUEST_DATE),
                             'Search'	   , TO_DATE (REQUEST_DATE),
                             NULL, 		     to_date('1951-01-01', 'YYYY-mm-dd'),
                                             to_date(:prequest_from_date, 'YYYY-mm-dd')) 
AND
DECODE(:prequest_to_date,  'undefined'	 , TO_DATE (REQUEST_DATE),
                            'Search'	 , TO_DATE (REQUEST_DATE),
                            NULL         ,to_date('4712-01-01', 'YYYY-mm-dd'),
                                         to_date(:prequest_to_date, 'YYYY-mm-dd')) 
)
------------------------------------------------------------------------------------
UNION ALL
SELECT * FROM fs_tablename rd
where 
1=1
AND UPPER('MAN')=NVL(:ptype ,'MAN')
and (UPPER (rd.request_type) =(UPPER (:prequest_type)))
AND (
rd.PERSON_ID=  DECODE(:pperson_id,  'undefined' ,rd.PERSON_ID,
                                    'Search'	, rd.PERSON_ID,
                                    NULL 	    ,rd.PERSON_ID,
                                    0           ,rd.PERSON_ID,
                                                :pperson_id) 
)AND (
upper (rd.REQUEST_NUMBER) like '%'|| upper (:prequest_number) || '%' or :prequest_number is null
or upper(:prequest_number) = upper('Search') or upper(:prequest_number)= upper('undefined')
)
and 
(
TO_DATE (REQUEST_DATE) BETWEEN 
DECODE(:prequest_from_date,  'undefined'   , TO_DATE (REQUEST_DATE),
                             'Search'	   , TO_DATE (REQUEST_DATE),
                             NULL, 		     to_date('1951-01-01', 'YYYY-mm-dd'),
                                             to_date(:prequest_from_date, 'YYYY-mm-dd')) 
AND
DECODE(:prequest_to_date,  'undefined'	 , TO_DATE (REQUEST_DATE),
                            'Search'	 , TO_DATE (REQUEST_DATE),
                            NULL         ,to_date('4712-01-01', 'YYYY-mm-dd'),
                                         to_date(:prequest_to_date, 'YYYY-mm-dd')) 
)
