SELECT * FROM XX_REQUEST_DTL_V rd
where 
    rd.request_id=DECODE(:prequest_id, 0, rd.request_id, null, rd.request_id, :prequest_id)
    and  rd.PERSON_ID=DECODE(:pperson_id, 0, rd.PERSON_ID, null, rd.PERSON_ID, :pperson_id)
and (    

    (
        (UPPER (rd.request_type) LIKE '%' || UPPER (:lrequest_type) || '%' OR :lrequest_type IS NULL) OR 
        UPPER(:lrequest_type)= UPPER('Search') OR UPPER(:lrequest_type)= UPPER('undefined') 
    )
    and 
    (
        REQUEST_DATE  BETWEEN 
        --to_date('2022-02-08', 'YYYY-mm-dd') and  to_date('2022-02-08', 'YYYY-mm-dd')
        DECODE(:lrequest_from_date,  'undefined'	 , REQUEST_DATE,
                                'Search'	 , REQUEST_DATE,
                                 NULL, 		  to_date('1951-01-01', 'YYYY-mm-dd'),
                                              to_date(:lrequest_from_date, 'YYYY-mm-dd')) 
        AND
        DECODE(:lrequest_to_date,  'undefined'	 , REQUEST_DATE,
                                'Search'	 , REQUEST_DATE,
                                 NULL        ,to_date('4712-01-01', 'YYYY-mm-dd'),
                                              to_date(:lrequest_to_date, 'YYYY-mm-dd')) 
    )
)    
    --and req.PERSON_ID=1247
