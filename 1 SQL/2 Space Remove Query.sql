SELECT * FROM EMPLOYEE_DETAIL where
--rownum=1 and
--and  (SAAS_USER_NAME) =  (:saasuserlogin)
--and  (replace(FULL_NAME, ' ', '')) =  (:saasuserlogin);
--and  (REGEXP_REPLACE(FULL_NAME, '[^0-9A-Za-z]', '')) =  (REGEXP_REPLACE(:saasuserlogin, '[^0-9A-Za-z]', ''))
(
 (REGEXP_REPLACE(FULL_NAME, '[^0-9A-Za-z]', '')) =  (REGEXP_REPLACE(:saasuserlogin, '[^0-9A-Za-z]', ''))
OR
 (REGEXP_REPLACE(PERSON_NUMBER, '[^0-9A-Za-z]', '')) =  (REGEXP_REPLACE(:saasuserlogin, '[^0-9A-Za-z]', ''))
OR
 (REGEXP_REPLACE(DISPLAY_NAME, '[^0-9A-Za-z]', '')) =  (REGEXP_REPLACE(:saasuserlogin, '[^0-9A-Za-z]', ''))
OR
 (REGEXP_REPLACE(SAAS_USER_NAME, '[^0-9A-Za-z]', '')) =  (REGEXP_REPLACE(:saasuserlogin, '[^0-9A-Za-z]', ''))
OR
 lower((REGEXP_REPLACE(EMAIL_ADDRESS, '[^0-9A-Za-z]', ''))) =   lower((REGEXP_REPLACE(:saasuserlogin, '[^0-9A-Za-z]', '')))
)
--(
--(FULL_NAME) =  (:saasuserlogin)
--OR
--(PERSON_NUMBER) =  (:saasuserlogin)
--OR
--(DISPLAY_NAME) =  (:saasuserlogin)
--OR
-- (EMAIL_ADDRESS) =  (:saasuserlogin)
--)
