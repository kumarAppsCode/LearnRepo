create or replace PROCEDURE FS_SEARCH_TRAVEL_HEADER_PR 
(
  PDATE_FROM IN VARCHAR2 
, PDATE_TO IN VARCHAR2 
, PEMPLOYEE_NUMBER IN VARCHAR2 
, PTRAVEL_NUMBER IN VARCHAR2 
, PTYPE IN VARCHAR2 
, p_output  OUT SYS_REFCURSOR
) AS 

l_sql     VARCHAR2(4000);
where_class varchar2(4000);
BEGIN

where_class:='1=1';

if( PDATE_FROM is not null and PDATE_FROM !='undefined') then 
where_class:=where_class|| ' AND trunc(travel_request_date)>= to_date('''||PDATE_FROM||''', ''YYYY-mm-dd'')';
end if;

if(PDATE_TO is not null and PDATE_TO !='undefined' ) then 
where_class:=where_class|| ' AND trunc(travel_request_date)<= to_date('''||PDATE_TO||''', ''YYYY-mm-dd'')';
end if;


if(PTYPE='EMP') then 

IF(PEMPLOYEE_NUMBER IS NOT NULL AND PEMPLOYEE_NUMBER !='undefined')THEN 
where_class:=where_class|| ' AND UPPER(TRIM(EMPLOYEE_NUMBER))=UPPER(TRIM('||PEMPLOYEE_NUMBER||'))';
END IF;

IF(PTRAVEL_NUMBER IS NOT NULL AND PTRAVEL_NUMBER !='undefined')THEN 
where_class:=where_class|| ' AND UPPER(PTRAVEL_NUMBER)=UPPER('||PTRAVEL_NUMBER||'))';
END IF;

--EMPL SELECT 

DBMS_OUTPUT.PUT_LINE('emp where_class==>'||where_class);



NULL;
elsif(PTYPE='IT')then

IF(PTRAVEL_NUMBER IS NOT NULL AND PTRAVEL_NUMBER !='undefined')THEN 
where_class:=where_class|| ' AND UPPER(PTRAVEL_NUMBER)=UPPER('||PTRAVEL_NUMBER||'))';
ELSE
IF(PEMPLOYEE_NUMBER IS NOT NULL AND PEMPLOYEE_NUMBER !='undefined')THEN 
where_class:=where_class|| ' AND UPPER(TRIM(EMPLOYEE_NUMBER))=UPPER(TRIM('||PEMPLOYEE_NUMBER||'))';
END IF;
END IF;


--IT SELECT 
DBMS_OUTPUT.PUT_LINE('it where_class==>'||where_class);
NULL;
elsif(PTYPE='MAN') then
--MAN SELECT 
IF(PEMPLOYEE_NUMBER IS NOT NULL AND PEMPLOYEE_NUMBER !='undefined')THEN 
where_class:=where_class|| ' AND UPPER(TRIM(EMPLOYEE_NUMBER))=UPPER(TRIM('||PEMPLOYEE_NUMBER||'))';
END IF;

IF(PTRAVEL_NUMBER IS NOT NULL AND PTRAVEL_NUMBER !='undefined')THEN 
where_class:=where_class|| ' AND UPPER(PTRAVEL_NUMBER)=UPPER('||PTRAVEL_NUMBER||'))';
END IF;


DBMS_OUTPUT.PUT_LINE('man where_class==>'||where_class);
null;
ELSE
--EMPL SELECT 
NULL;
end if;


--l_sql := 'SELECT * FROM fs_search_travel_header_v ';
l_sql := 'SELECT * FROM fs_search_travel_header_v where ' || where_class;
OPEN p_output FOR l_sql;


END FS_SEARCH_TRAVEL_HEADER_PR;




BEGIN
  FS_SEARCH_TRAVEL_HEADER_PR(:PDATE_FROM,:PDATE_TO,:PEMPLOYEE_NUMBER,:PTRAVEL_NUMBER,:PTYPE,:P_OUTPUT);
END;
