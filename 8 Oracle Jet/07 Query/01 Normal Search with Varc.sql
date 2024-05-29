SELECT * FROM XXEPG_INTERFACE_MASTER_V
WHERE 
(

(UPPER (INTERFACE_DISPLAY) LIKE '%' || UPPER (:searchVal) || '%' OR :searchVal IS NULL) OR 
UPPER(:searchVal)= UPPER('Search') OR UPPER(:searchVal)= UPPER('undefined') 

OR 
(UPPER (SOURCE_APPLICATION) LIKE '%'|| UPPER (:searchVal) || '%' OR :searchVal IS NULL) OR 
UPPER(:searchVal)= UPPER('Search') OR UPPER(:searchVal)= UPPER('undefined') 

OR 
(UPPER (INTEGRATION_CODE) LIKE '%'|| UPPER (:searchVal) || '%' OR :searchVal IS NULL) OR 
UPPER(:searchVal)= UPPER('Search') OR UPPER(:searchVal)= UPPER('undefined') 

OR 
(UPPER (module) LIKE '%'|| UPPER (:searchVal) || '%' OR :searchVal IS NULL) OR 
UPPER(:searchVal)= UPPER('Search') OR UPPER(:searchVal)= UPPER('undefined') 

OR 
(UPPER (SOURCE_APPLICATION) LIKE '%'|| UPPER (:searchVal) || '%' OR :searchVal IS NULL) OR 
UPPER(:searchVal)= UPPER('Search') OR UPPER(:searchVal)= UPPER('undefined') 

)

