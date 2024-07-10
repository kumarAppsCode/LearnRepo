SELECT Distinct * FROM FS_EMPLOYEE_DETAIL_V
WHERE 
( (UPPER (PERSON_NUMBER) LIKE '%'|| UPPER (:searchValue) || '%' OR :searchValue IS NULL) OR UPPER(:searchValue)= UPPER('Search') OR UPPER(: searchValue)= UPPER('undefined') 
OR 
(UPPER (FULL_NAME) LIKE '%'|| UPPER (:searchValue) || '%' OR :searchValue IS NULL) OR UPPER(:searchValue)= UPPER('Search')OR UPPER(:searchValue)= UPPER('undefined')
OR 
(UPPER (FIRST_NAME) LIKE '%'|| UPPER (:searchValue) || '%' OR :searchValue IS NULL) OR UPPER(:searchValue)= UPPER('Search') OR UPPER(:searchValue)= UPPER('undefined') 
OR 
(UPPER (EMAIL_ADDRESS) LIKE '%'|| UPPER (:searchValue) || '%' OR :searchValue IS NULL) OR UPPER(:searchValue)= UPPER('Search') OR UPPER(:searchValue)= UPPER('undefined'))
