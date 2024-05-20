set SERVEROUTPUT ON;
DECLARE
CURSOR getdata IS
SELECT 
EMPLOYEE_NUMBER,
DATE_FROM,
DATE_TO,
FEEDING_TIME,
LAST_MATERNITY,
DM_FLAG,
PERSON_ID,
    json_object(
    'fh_end_date' value to_char(DATE_FROM, 'RRRR-MM-DD'),
    'fh_start_date' value to_char(DATE_TO, 'RRRR-MM-DD'),
    'fh_time'  value FEEDING_TIME               
    ) as ldata
FROM ****
where 
1=1
and DM_FLAG is null;

lcount number:=0;
lseq number:=null;

BEGIN 
FOR c0 IN getdata 
LOOP 
lseq:=FS_TRANSACTION_ID.nextval;
INSERT INTO fs_****details (
    request_id,
    object_version_num,
    request_number,
    request_type_id,
    REQUEST_TYPE,
    REQUESTER_ID,
    PERSON_ID,
	REQUEST_DATE,
    REQUEST_DATA,
    description,
    request_status,
    integration_status,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
    )VALUES (
    lseq,
    0,
    'FH00'||lseq,
    100518,
    'FEEDING_HOURS',
    c0.PERSON_ID,
    c0.PERSON_ID,
    c0.DATE_FROM,
	to_clob(c0.ldata),
    'Data Migration',
    'Approved', --Approved--Draft
    'Y',
    c0.EMPLOYEE_NUMBER,
    c0.DATE_FROM,
    c0.EMPLOYEE_NUMBER,
    c0.DATE_FROM,
    c0.EMPLOYEE_NUMBER
    );
commit;

update ****
set DM_FLAG='Y'
where 
trim(EMPLOYEE_NUMBER)=trim(c0.EMPLOYEE_NUMBER);
commit;
lcount:=lcount+1;
--dbms_output.put_line('lseq:=>'||lseq);
lseq:=null;
end loop;
dbms_output.put_line('Total No of Record:=>'||lcount);
END;
